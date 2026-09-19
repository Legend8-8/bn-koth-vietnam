/*
    File: fn_restoreTerrain.sqf
    Author: Legend
    Description: Repairs original restorable AO terrain after players leave the outgoing AO.
    Execution: Server, scheduled RESETTING path
    Parameters:
        0: Outgoing location ID <STRING>
    Returns:
        True when the snapshot was processed, otherwise false <BOOL>
    Public: No
*/

params [["_locationId", "", [""]]];
if (!isServer) exitWith {false};

private _snapshot = missionNamespace getVariable ["BN_KOTH_terrainSnapshot", createHashMap];
if !(_snapshot isEqualType createHashMap && {(count _snapshot) > 0}) exitWith {
    if (_locationId isNotEqualTo "") then {
        [format ["Terrain restore skipped for AO=%1: no snapshot", _locationId], "WARN"] call bn_koth_fnc_common_log;
    };
    false
};

private _marker = _snapshot getOrDefault ["marker", ""];
if (_locationId isEqualTo "" || {_locationId isNotEqualTo (_snapshot getOrDefault ["locationId", ""])}
    || {_locationId isNotEqualTo (missionNamespace getVariable ["BN_KOTH_activeLocationId", ""])}
    || {_marker isEqualTo ""} || {(markerShape _marker) isEqualTo ""}) exitWith {
    [format ["Terrain restore rejected: outgoing=%1 snapshot=%2 active=%3 marker=%4", _locationId, _snapshot getOrDefault ["locationId", ""], missionNamespace getVariable ["BN_KOTH_activeLocationId", ""], _marker], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _present = allPlayers select {!isNull _x && {(vehicle _x) inArea _marker}};
if ((count _present) > 0) exitWith {
    [format ["Terrain restore skipped for AO=%1: %2 player representation(s) remain in capture marker", _locationId, count _present], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _started = diag_tickTime;
private _entries = _snapshot getOrDefault ["entries", []];
private _repaired = 0;
private _invalid = 0;
private _destroyedRestored = 0;
private _ruinsHidden = 0;
private _ruinMatchUnavailable = 0;
private _ruinMatchAmbiguous = 0;
private _matchSamples = [];
private _noMatchSamples = [];
{
    _x params ["_object", "_position", "_direction", "_up"];
    if (isNull _object) then {
        _invalid = _invalid + 1;
        continue;
    };

    if (!alive _object || {(damage _object) >= 1}) then {
        private _damageBefore = damage _object;
        private _aliveBefore = alive _object;
        private _movedBefore = (getPosATL _object) distance _position > 0.05;
        private _ruinMatch = "UNAVAILABLE";
        private _effects = configFile >> "CfgVehicles" >> (typeOf _object) >> "DestructionEffects";
        private _ruinClasses = [];
        if (isClass _effects) then {
            {
                if ((toLower (getText (_x >> "simulation"))) isEqualTo "ruin") then {
                    private _ruinClass = getText (_x >> "type");
                    if (isClass (configFile >> "CfgVehicles" >> _ruinClass)) then {
                        _ruinClasses pushBackUnique (configName (configFile >> "CfgVehicles" >> _ruinClass));
                    };
                };
            } forEach (configProperties [_effects, "isClass _x", true]);
        };

        if ((count _ruinClasses) > 0) then {
            // Destroyed originals may be far underground; search at the saved position.
            private _near = nearestObjects [_position, _ruinClasses, 2.5, true];
            {_near pushBackUnique _x} forEach (nearestTerrainObjects [_position, [], 2.5, false, true]);
            private _candidates = _near select {
                !isNull _x
                && {!isObjectHidden _x}
                && {(typeOf _x) in _ruinClasses}
                && {(getPosATL _x) distance2D _position <= 2}
                && {(vectorDir _x) distance _direction <= 0.25}
            };

            if ((count _candidates) > 1) then {
                _ruinMatch = "AMBIGUOUS";
            } else {
                if ((count _candidates) isEqualTo 1) then {
                    private _ruin = _candidates select 0;
                    // A ruin close to two destroyed originals has no safe single owner.
                    private _otherOwner = _entries findIf {
                        private _other = _x select 0;
                        !(_other isEqualTo _object)
                        && {((_x select 1) distance2D (getPosATL _ruin)) <= 2}
                        && {!isNull _other}
                        && {(!alive _other) || {(damage _other) >= 1}}
                    };
                    if (_otherOwner >= 0) then {
                        _ruinMatch = "AMBIGUOUS";
                    } else {
                        _ruin hideObjectGlobal true;
                        if (isObjectHidden _ruin) then {
                            _ruinMatch = "MATCHED";
                            _ruinsHidden = _ruinsHidden + 1;
                            if ((count _matchSamples) < 5) then {
                                _matchSamples pushBack format ["matched ruin original=%1 pos=%2 ruin=%3 ref=%4", typeOf _object, _position, typeOf _ruin, _ruin];
                            };
                        };
                    };
                };
            };
        };

        if (_ruinMatch isEqualTo "AMBIGUOUS") then {
            _ruinMatchAmbiguous = _ruinMatchAmbiguous + 1;
        };
        if (_ruinMatch isEqualTo "UNAVAILABLE") then {
            _ruinMatchUnavailable = _ruinMatchUnavailable + 1;
        };
        if (_ruinMatch isNotEqualTo "MATCHED" && {(count _noMatchSamples) < 5}) then {
            _noMatchSamples pushBack format ["ruinMatch%1 original=%2 pos=%3 moved=%4 damageBefore=%5 aliveBefore=%6", _ruinMatch, typeOf _object, _position, _movedBefore, _damageBefore, _aliveBefore];
        };

        _object setDamage [0, false, objNull, objNull, true];
        _object setVectorDirAndUp [_direction, _up];
        _object setPosATL _position;
        _object hideObjectGlobal false;
        _destroyedRestored = _destroyedRestored + 1;
        continue;
    };

    private _moved = (getPosATL _object) distance _position > 0.05;
    private _rotated = (vectorDir _object) distance _direction > 0.001
        || {(vectorUp _object) distance _up > 0.001};
    if ((damage _object) > 0 || {_moved} || {_rotated} || {isObjectHidden _object}) then {
        _object setDamage [0, false];
        if (_rotated || {_moved}) then {
            _object setVectorDirAndUp [_direction, _up];
            _object setPosATL _position;
        };
        if (isObjectHidden _object) then {_object hideObjectGlobal false};
        _repaired = _repaired + 1;
    };
} forEach _entries;

missionNamespace setVariable ["BN_KOTH_terrainSnapshot", nil];
[format ["Terrain restore AO=%1 examined=%2 partialRepaired=%3 destroyedRestored=%4 ruinsHidden=%5 ruinMatchUnavailable=%6 ruinMatchAmbiguous=%7 invalid=%8 elapsedMs=%9", _locationId, count _entries, _repaired, _destroyedRestored, _ruinsHidden, _ruinMatchUnavailable, _ruinMatchAmbiguous, _invalid, round ((diag_tickTime - _started) * 1000)], "INFO"] call bn_koth_fnc_common_log;
{[format ["Terrain restore AO=%1 %2", _locationId, _x], "INFO"] call bn_koth_fnc_common_log} forEach _matchSamples;
{[format ["Terrain restore AO=%1 %2", _locationId, _x], "WARN"] call bn_koth_fnc_common_log} forEach _noMatchSamples;
true

/*
    File: fn_updatePlayerProtection.sqf
    Author: Mongo
    Description: Computes and publishes one player's authoritative safe-zone state.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Player record <HASHMAP>
        2: Safe-zone system active <BOOL>
        3: WEST safe-zone marker <STRING>
        4: EAST safe-zone marker <STRING>
    Returns:
        Updated player record <HASHMAP>
    Public: Yes
*/

params [
    ["_uid", "", [""]],
    ["_record", createHashMap, [createHashMap]],
    ["_systemActive", false, [false]],
    ["_westMarker", "", [""]],
    ["_eastMarker", "", [""]]
];

if (!isServer) exitWith {_record};
if !(_record isEqualType createHashMap) exitWith {_record};

private _unit = _record getOrDefault ["currentUnit", objNull];
private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
private _recordState = _record getOrDefault ["state", "LOBBY"];
private _deployed = _record getOrDefault ["deployed", false];
private _eligible = _systemActive
    && {!isNull _unit}
    && {alive _unit}
    && {_deployed}
    && {_recordState in ["DEPLOYING", "ACTIVE", "RESPAWNING"]}
    && {[_assignedSide] call bn_koth_fnc_teams_validateSide};

private _protected = false;
private _intruder = false;

if (_eligible) then {
    private _areaObject = vehicle _unit;
    private _membership = [_areaObject, _systemActive, _westMarker, _eastMarker] call bn_koth_fnc_respawn_getSafeZoneMembership;
    private _insideWest = _membership select 0;
    private _insideEast = _membership select 1;
    private _insideOwn = if (_assignedSide isEqualTo west) then {_insideWest} else {_insideEast};
    private _insideOpposing = if (_assignedSide isEqualTo west) then {_insideEast} else {_insideWest};

    // Own-zone protection takes precedence if malformed map geometry overlaps both zones.
    _protected = _insideOwn;
    _intruder = !_insideOwn && {_insideOpposing};
};

private _wasProtected = _record getOrDefault ["safeZoneProtected", false];
private _wasIntruder = _record getOrDefault ["enemySafeZoneIntruder", false];

if (!isNull _unit) then {
    if ((_unit getVariable ["BN_KOTH_safeZoneProtected", false]) != _protected) then {
        _unit setVariable ["BN_KOTH_safeZoneProtected", _protected, true];
    };

    if ((_unit getVariable ["BN_KOTH_enemySafeZoneIntruder", false]) != _intruder) then {
        _unit setVariable ["BN_KOTH_enemySafeZoneIntruder", _intruder, true];
    };

    if (_intruder && {(vehicle _unit) != _unit}) then {
        if (local _unit) then {
            [_unit] call bn_koth_fnc_respawn_forceExitVehicle;
        } else {
            [_unit] remoteExecCall ["bn_koth_fnc_respawn_forceExitVehicle", owner _unit];
        };
    };

    if (_intruder && {!_wasIntruder}) then {
        private _message = "Enemy safe zone: weapons and vehicles are disabled. You remain vulnerable.";
        if (local _unit && {hasInterface}) then {
            [_message] call bn_koth_fnc_ui_notify;
        } else {
            [_message] remoteExecCall ["bn_koth_fnc_ui_notify", owner _unit];
        };
    };
};

_record set ["safeZoneProtected", _protected];
_record set ["enemySafeZoneIntruder", _intruder];

if (_protected != _wasProtected || {_intruder != _wasIntruder}) then {
    [format [
        "Safe-zone state UID=%1 side=%2 protected=%3 intruder=%4",
        _uid,
        _assignedSide,
        _protected,
        _intruder
    ], "INFO"] call bn_koth_fnc_common_log;
};

_record

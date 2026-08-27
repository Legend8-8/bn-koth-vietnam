/*
    File: fn_handleKill.sqf
    Author: SpadeMe
    Description: Server-authoritative interpretation of a kill. This is the
        ONE place that decides the authoritative victim/killer identity,
        sides, suicide/teamkill/valid-PvP, and round state. Method and weapon
        fields are currently display-grade kill-feed attribution only and
        must not be used for weapon progression or other authoritative
        progression decisions. The separate weaponAttribution field contains
        the fail-closed server evidence used by weapon mastery.
    Execution: Server
    Parameters:
        0: Dead unit <OBJECT>
        1: Engine-reported killer <OBJECT>
        2: Engine-reported instigator <OBJECT> (optional, e.g. a vehicle's gunner)
        3: Fail-closed weapon attribution result <HASHMAP>
    Returns:
        Canonical kill record, or an empty HashMap if the kill was ignored <HASHMAP>
    Public: Yes
*/

params ["_killed", "_killer", ["_instigator", objNull], ["_weaponAttribution", createHashMap, [createHashMap]]];

if (!isServer) exitWith {createHashMap};
if (isNull _killed) exitWith {createHashMap};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["combat_handleKill rejected: BN_KOTH_playerRecords missing/invalid", "WARN"] call bn_koth_fnc_common_log;
    createHashMap
};

private _victimUid = [_killed, _records] call bn_koth_fnc_common_resolvePlayerUid;
if (_victimUid isEqualTo "") exitWith {
    [format ["combat_handleKill ignored: victim UID unresolved type=%1", typeOf _killed], "INFO"] call bn_koth_fnc_common_log;
    createHashMap
};

private _victimRecord = _records getOrDefault [_victimUid, createHashMap];
private _victimSide = _victimRecord getOrDefault ["assignedSide", side _killed];
private _victimName = _victimRecord getOrDefault ["name", name _killed];

// Prefer the instigator (e.g. the gunner of a vehicle) over a non-person killer
private _effKiller = if (!isNull _instigator) then { _instigator } else { _killer };
private _killerIsPerson = !isNull _effKiller && { _effKiller isKindOf "Man" };
private _killerUid = if (_killerIsPerson) then { [_effKiller, _records] call bn_koth_fnc_common_resolvePlayerUid } else { "" };
private _hasIdentifiedKiller = _killerIsPerson && !(_killerUid isEqualTo "");

private _suicide = _hasIdentifiedKiller && { _effKiller isEqualTo _killed };

private _killerRecord = if (_hasIdentifiedKiller) then { _records getOrDefault [_killerUid, createHashMap] } else { createHashMap };
private _killerSide = if (_hasIdentifiedKiller) then { _killerRecord getOrDefault ["assignedSide", side _effKiller] } else { sideUnknown };
private _killerName = if (_hasIdentifiedKiller) then { _killerRecord getOrDefault ["name", name _effKiller] } else { "" };

private _teamkill = _hasIdentifiedKiller && {!_suicide} && {_killerSide isEqualTo _victimSide};
private _validPvp = _hasIdentifiedKiller && {!_suicide} && {!_teamkill};

// Kill method and weapon are currently DISPLAY-GRADE attribution for the
// kill feed only. They are heuristic and are not authoritative enough for
// weapon progression, unlocks, rewards, or persisted statistics.
private _method = "other";
private _weaponDisplay = "";
private _killerInVehicle = false;
if (_hasIdentifiedKiller) then {
    private _killerVeh = vehicle _effKiller;
    _killerInVehicle = !(_killerVeh isEqualTo _effKiller);

    _method = if (!_killerInVehicle) then {
        "direct"
    } else {
        if (_killerVeh isKindOf "Air") then {
            "cas"
        } else {
            private _isArtillery = (_killerVeh isKindOf "StaticMortar")
                || {getNumber (configFile >> "CfgVehicles" >> typeOf _killerVeh >> "artilleryScanner") == 1};
            if (_isArtillery) then {"artillery"} else {"vehicle"};
        };
    };

    if (_killerInVehicle) then {
        // Kill feed shows the mount, not the specific weapon/turret fired -
        // register the vehicle itself as the credited weapon.
        _weaponDisplay = getText (configFile >> "CfgVehicles" >> typeOf _killerVeh >> "displayName");
        if (_weaponDisplay isEqualTo "") then { _weaponDisplay = typeOf _killerVeh };
    } else {
        private _weaponClass = currentWeapon _effKiller;
        if !(_weaponClass isEqualTo "") then {
            _weaponDisplay = getText (configFile >> "CfgWeapons" >> _weaponClass >> "displayName");
            if (_weaponDisplay isEqualTo "") then { _weaponDisplay = _weaponClass };
        };
    };
};

// Approximate range only - never exact precision
private _distText = "";
if (_hasIdentifiedKiller && {!_suicide}) then {
    private _dist = _killed distance _effKiller;
    private _rounded = (round (_dist / 20)) * 20;
    _distText = format ["~%1m", (_rounded max 20)];
};

private _roundState = [] call bn_koth_fnc_round_getState;

private _kill = createHashMap;
_kill set ["victimUid", _victimUid];
_kill set ["victimName", _victimName];
_kill set ["victimSide", _victimSide];
_kill set ["killerUid", _killerUid];
_kill set ["killerName", _killerName];
_kill set ["killerSide", _killerSide];
_kill set ["suicide", _suicide];
_kill set ["teamkill", _teamkill];
_kill set ["validPvp", _validPvp];
_kill set ["method", _method];
_kill set ["weapon", _weaponDisplay];
_kill set ["killerInVehicle", _killerInVehicle];
_kill set ["distanceText", _distText];
_kill set ["roundActive", _roundState isEqualTo "ACTIVE"];
_kill set ["weaponAttribution", _weaponAttribution];

[format [
    "combat_handleKill: victim=%1(%2) killer=%3(%4) suicide=%5 teamkill=%6 validPvp=%7 method=%8 weapon=%9 killerInVehicle=%10 dist=%11 round=%12",
    _victimUid, _victimSide, _killerUid, _killerSide, _suicide, _teamkill, _validPvp, _method, _weaponDisplay, _killerInVehicle, _distText, _roundState
], "INFO"] call bn_koth_fnc_common_log;

// Progression/reward/stat consumers may use the authoritative identity fields.
// Weapon mastery must use weaponAttribution only, never the display-grade
// method/weapon fields above.

[_kill] call bn_koth_fnc_combat_publishKillFeed;

_kill

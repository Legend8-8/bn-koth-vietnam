/*
    File: fn_acquireWeapon.sqf
    Author: Legend
    Description: Validates and atomically commits one server-authoritative
        permanent weapon purchase or server-session rental.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Requested weapon classname <STRING>
        2: Operation token (PURCHASE or RENT) <STRING>
    Returns:
        Structured acquisition result <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_weaponClass", "", [""]],
    ["_operation", "", [""]]
];

private _reject = {
    params ["_code", "_message"];
    createHashMapFromArray [
        ["success", false], ["code", _code], ["message", _message],
        ["uid", _uid], ["operation", toUpper _operation],
        ["requestedClass", toLower _weaponClass], ["committed", false], ["charged", 0]
    ]
};

if (!isServer) exitWith {["NOT_SERVER", "Weapon acquisition is server-authoritative."] call _reject};
if (_uid isEqualTo "") exitWith {["INVALID_UID", "Weapon acquisition requires a player UID."] call _reject};
if (_weaponClass isEqualTo "") exitWith {["INVALID_WEAPON", "Weapon acquisition requires a classname."] call _reject};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {["PLAYER_RECORDS_UNAVAILABLE", "Player registry is unavailable."] call _reject};
if (isNil {_records get _uid}) exitWith {["PLAYER_NOT_REGISTERED", "Player is not registered."] call _reject};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {["PLAYER_NOT_REGISTERED", "Player is not registered."] call _reject};

private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {
    [_metadata getOrDefault ["code", "INVALID_METADATA"], "Weapon metadata lookup failed."] call _reject
};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE", "Progression state is unavailable."] call _reject};
private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE", "Player progression is unavailable."] call _reject};

private _entitlement = [_uid, _weaponClass] call bn_koth_fnc_progression_evaluateWeaponEntitlement;
private _result = [
    _operation, _uid, _weaponClass, _progression, _metadata, _entitlement
] call bn_koth_fnc_progression_acquisition_evaluateRules;

if !(_result getOrDefault ["success", false]) exitWith {
    [format ["Weapon acquisition rejected UID=%1 operation=%2 requested=%3 canonical=%4 code=%5", _uid, toUpper _operation, toLower _weaponClass, _result getOrDefault ["canonicalClass", ""], _result getOrDefault ["code", "UNKNOWN"]], "WARN"] call bn_koth_fnc_common_log;
    _result
};
if !(_result getOrDefault ["committed", false]) exitWith {
    [format ["Weapon acquisition idempotent UID=%1 operation=%2 canonical=%3 code=%4", _uid, toUpper _operation, _result getOrDefault ["canonicalClass", ""], _result getOrDefault ["code", "UNKNOWN"]]] call bn_koth_fnc_common_log;
    _result
};

_progression set ["cash", _result getOrDefault ["cash", _progression getOrDefault ["cash", 0]]];
_progression set ["ownedWeapons", _result getOrDefault ["nextOwnedWeapons", []]];
_progression set ["rentedWeapons", _result getOrDefault ["nextRentedWeapons", []]];
_progressionByUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];

[_uid, "acquisition", 0, toLower _operation] call bn_koth_fnc_progression_publishUpdate;
[format ["Weapon acquisition committed UID=%1 operation=%2 canonical=%3 charged=%4 cash=%5", _uid, toUpper _operation, _result getOrDefault ["canonicalClass", ""], _result getOrDefault ["charged", 0], _result getOrDefault ["cash", -1]]] call bn_koth_fnc_common_log;

_result

/*
    File: fn_backendSavePlayer.sqf
    Author: Legend
    Description: Saves one persistent projection through the configured backend adapter.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]], ["_projection", createHashMap, [createHashMap]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_uid isEqualTo "" || {!(_projection isEqualType createHashMap)}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_SAVE_REQUEST"], ["uid", _uid]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"], ["uid", _uid]]};
if (missionNamespace getVariable ["BN_KOTH_persistenceTestFailSave", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_SAVE_FAILED"], ["uid", _uid]]};

private _backend = missionNamespace getVariable ["BN_KOTH_persistenceBackend", ""];
if (_backend isEqualTo "EXTDB3") exitWith {
    private _uidDigits = toArray "0123456789";
    if (({!(_x in _uidDigits)} count (toArray _uid)) > 0) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_STEAM_UID"], ["uid", _uid]]};
    private _schemaVersion = _projection getOrDefault ["schemaVersion", -1];
    private _xp = _projection getOrDefault ["xp", -1];
    private _cash = _projection getOrDefault ["cash", -1];
    if !(_schemaVersion isEqualType 0 && {finite _schemaVersion} && {_schemaVersion >= 0} && {_schemaVersion isEqualTo floor _schemaVersion} && {_xp isEqualType 0} && {finite _xp} && {_xp >= 0} && {_xp isEqualTo floor _xp} && {_cash isEqualType 0} && {finite _cash} && {_cash >= 0} && {_cash isEqualTo floor _cash}) exitWith {
        createHashMapFromArray [["success", false], ["code", "INVALID_PERSISTENT_NUMERIC_FIELDS"], ["uid", _uid]]
    };
    private _owned = [_projection getOrDefault ["ownedWeapons", []]] call bn_koth_fnc_persistence_serializeOwnedWeapons;
    private _kills = [_projection getOrDefault ["weaponKills", createHashMap]] call bn_koth_fnc_persistence_serializeWeaponKills;
    if !(_owned getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _owned getOrDefault ["code", "SERIALIZATION_FAILED"]], ["uid", _uid]]};
    if !(_kills getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _kills getOrDefault ["code", "SERIALIZATION_FAILED"]], ["uid", _uid]]};
    private _query = ["savePlayer", [
        _uid,
        _schemaVersion,
        _xp,
        _cash,
        _owned get "value",
        _kills get "value"
    ]] call bn_koth_fnc_persistence_extdbCall;
    if !(_query getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _query getOrDefault ["code", "BACKEND_SAVE_FAILED"]], ["uid", _uid]]};
    createHashMapFromArray [["success", true], ["code", "SAVED"], ["uid", _uid]]
};
if !(_backend isEqualTo "MEMORY") exitWith {createHashMapFromArray [["success", false], ["code", "UNSUPPORTED_BACKEND"], ["uid", _uid]]};

private _records = missionNamespace getVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
if !(_records isEqualType createHashMap) then {_records = createHashMap};
_records set [_uid, _projection];
missionNamespace setVariable ["BN_KOTH_persistenceMemoryBackend", _records];

createHashMapFromArray [["success", true], ["code", "SAVED"], ["uid", _uid]]

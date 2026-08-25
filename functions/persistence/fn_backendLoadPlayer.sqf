/*
    File: fn_backendLoadPlayer.sqf
    Author: Legend
    Description: Loads one raw record through the configured persistence backend adapter.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_uid isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_UID"]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"], ["uid", _uid]]};
if (missionNamespace getVariable ["BN_KOTH_persistenceTestFailLoad", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_LOAD_FAILED"], ["uid", _uid]]};

private _backend = missionNamespace getVariable ["BN_KOTH_persistenceBackend", ""];
if (_backend isEqualTo "EXTDB3") exitWith {
    private _uidDigits = toArray "0123456789";
    if (({!(_x in _uidDigits)} count (toArray _uid)) > 0) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_STEAM_UID"], ["uid", _uid]]};
    private _query = ["loadPlayer", [_uid]] call bn_koth_fnc_persistence_extdbCall;
    if !(_query getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _query getOrDefault ["code", "BACKEND_LOAD_FAILED"]], ["uid", _uid]]};
    private _rows = _query getOrDefault ["rows", []];
    if !(_rows isEqualType []) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_LOAD_ROWS"], ["uid", _uid]]};
    if ((count _rows) isEqualTo 0) exitWith {createHashMapFromArray [["success", true], ["code", "NOT_FOUND"], ["uid", _uid], ["found", false]]};
    if ((count _rows) != 1) exitWith {createHashMapFromArray [["success", false], ["code", "DUPLICATE_PLAYER_ROWS"], ["uid", _uid]]};
    private _row = _rows select 0;
    if !(_row isEqualType [] && {(count _row) isEqualTo 6}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_LOAD_ROW"], ["uid", _uid]]};
    _row params ["_recordUid", "_schemaVersion", "_xp", "_cash", "_ownedText", "_killsText"];
    if !(_recordUid isEqualType "" && {_schemaVersion isEqualType 0} && {_xp isEqualType 0} && {_cash isEqualType 0} && {_ownedText isEqualType ""} && {_killsText isEqualType ""}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_LOAD_TYPES"], ["uid", _uid]]};
    if !(_recordUid isEqualTo _uid) exitWith {createHashMapFromArray [["success", false], ["code", "UID_MISMATCH"], ["uid", _uid]]};
    if (!(finite _schemaVersion) || {_schemaVersion < 0} || {_schemaVersion != floor _schemaVersion} || {!(finite _xp)} || {_xp < 0} || {_xp != floor _xp} || {!(finite _cash)} || {_cash < 0} || {_cash != floor _cash}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_NUMERIC_FIELDS"], ["uid", _uid]]};
    private _owned = [_ownedText] call bn_koth_fnc_persistence_deserializeOwnedWeapons;
    private _kills = [_killsText] call bn_koth_fnc_persistence_deserializeWeaponKills;
    if !(_owned getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _owned getOrDefault ["code", "MALFORMED_OWNED_WEAPONS"]], ["uid", _uid]]};
    if !(_kills getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _kills getOrDefault ["code", "MALFORMED_WEAPON_KILLS"]], ["uid", _uid]]};
    private _record = createHashMapFromArray [
        ["uid", _recordUid], ["schemaVersion", _schemaVersion], ["xp", _xp], ["cash", _cash],
        ["ownedWeapons", _owned get "value"], ["weaponKills", _kills get "value"]
    ];
    createHashMapFromArray [["success", true], ["code", "LOADED"], ["uid", _uid], ["found", true], ["record", _record]]
};
if !(_backend isEqualTo "MEMORY") exitWith {createHashMapFromArray [["success", false], ["code", "UNSUPPORTED_BACKEND"], ["uid", _uid]]};

private _records = missionNamespace getVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
if !(_records isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_STATE_INVALID"], ["uid", _uid]]};
if (isNil {_records get _uid}) exitWith {createHashMapFromArray [["success", true], ["code", "NOT_FOUND"], ["uid", _uid], ["found", false]]};

createHashMapFromArray [["success", true], ["code", "LOADED"], ["uid", _uid], ["found", true], ["record", _records get _uid]]

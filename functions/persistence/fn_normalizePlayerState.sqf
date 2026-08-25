/*
    File: fn_normalizePlayerState.sqf
    Author: Legend
    Description: Validates and normalizes one backend record into the current session schema.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]], ["_raw", createHashMap, [createHashMap]]];

private _fail = {
    params ["_code", "_message"];
    createHashMapFromArray [["success", false], ["code", _code], ["message", _message], ["uid", _uid]]
};

if (!isServer) exitWith {["NOT_SERVER", "Persistence normalization is server-only."] call _fail};
if (_uid isEqualTo "") exitWith {["INVALID_UID", "A UID is required."] call _fail};
if !(_raw isEqualType createHashMap) exitWith {["MALFORMED_RECORD", "Backend record is not a HashMap."] call _fail};

private _currentVersion = missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1];
private _missingVersion = isNil {_raw get "schemaVersion"};
private _version = if (_missingVersion) then {0} else {_raw getOrDefault ["schemaVersion", -1]};
if !(_version isEqualType 0 && {finite _version}) exitWith {["MALFORMED_SCHEMA_VERSION", "schemaVersion is not numeric."] call _fail};
_version = floor _version;
if (_version > _currentVersion) exitWith {["UNSUPPORTED_FUTURE_SCHEMA", format ["Record schema %1 is newer than supported schema %2.", _version, _currentVersion]] call _fail};
if (_version < 0) exitWith {["MALFORMED_SCHEMA_VERSION", "schemaVersion is negative."] call _fail};

private _recordUid = _raw getOrDefault ["uid", _uid];
if !(_recordUid isEqualType "") exitWith {["MALFORMED_UID", "Record UID is not text."] call _fail};
if !(_recordUid isEqualTo "" || {_recordUid isEqualTo _uid}) exitWith {["UID_MISMATCH", "Backend record UID does not match the requested UID."] call _fail};

private _warnings = [];
if (_missingVersion) then {_warnings pushBack "MISSING_SCHEMA_VERSION_LEGACY"};

private _xp = _raw getOrDefault ["xp", 0];
if !(_xp isEqualType 0 && {finite _xp} && {_xp >= 0}) then {
    _xp = 0;
    _warnings pushBack "NORMALIZED_XP";
};

private _cash = _raw getOrDefault ["cash", missionNamespace getVariable ["BN_KOTH_startingCash", 1000]];
if !(_cash isEqualType 0 && {finite _cash} && {_cash >= 0}) then {
    _cash = missionNamespace getVariable ["BN_KOTH_startingCash", 1000];
    _warnings pushBack "NORMALIZED_CASH";
};

private _owned = _raw getOrDefault ["ownedWeapons", []];
if !(_owned isEqualType []) then {
    _owned = [];
    _warnings pushBack "NORMALIZED_OWNED_WEAPONS";
};
private _normalizedOwned = [];
{
    if (_x isEqualType "" && {!(_x isEqualTo "")}) then {
        _normalizedOwned pushBackUnique (toLower _x);
    } else {
        _warnings pushBackUnique "NORMALIZED_OWNED_WEAPON_ENTRY";
    };
} forEach _owned;

private _rawKills = _raw getOrDefault ["weaponKills", createHashMap];
if !(_rawKills isEqualType createHashMap) then {
    _rawKills = createHashMap;
    _warnings pushBack "NORMALIZED_WEAPON_KILLS";
};
private _weaponKills = createHashMap;
{
    private _count = _rawKills get _x;
    if (_x isEqualType "" && {!(_x isEqualTo "")} && {_count isEqualType 0} && {finite _count} && {_count >= 0}) then {
        _weaponKills set [toLower _x, floor _count];
    } else {
        _warnings pushBackUnique "NORMALIZED_WEAPON_KILL_ENTRY";
    };
} forEach (keys _rawKills);

private _state = createHashMapFromArray [
    ["schemaVersion", _currentVersion],
    ["uid", _uid],
    ["xp", _xp],
    ["level", [_xp] call bn_koth_fnc_progression_xp_getLevel],
    ["cash", _cash],
    ["ownedWeapons", _normalizedOwned],
    ["rentedWeapons", []],
    ["weaponKills", _weaponKills]
];

createHashMapFromArray [
    ["success", true],
    ["code", if (_missingVersion) then {"NORMALIZED_LEGACY"} else {"NORMALIZED_CURRENT"}],
    ["uid", _uid],
    ["state", _state],
    ["warnings", _warnings]
]


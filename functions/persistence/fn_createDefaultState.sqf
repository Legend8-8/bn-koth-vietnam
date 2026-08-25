/*
    File: fn_createDefaultState.sqf
    Author: Legend
    Description: Builds the authoritative first-time session progression state.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMap};

private _xp = 0;
createHashMapFromArray [
    ["schemaVersion", missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1]],
    ["uid", _uid],
    ["xp", _xp],
    ["level", [_xp] call bn_koth_fnc_progression_xp_getLevel],
    ["cash", missionNamespace getVariable ["BN_KOTH_startingCash", 1000]],
    ["ownedWeapons", []],
    ["rentedWeapons", []],
    ["weaponKills", createHashMap]
]


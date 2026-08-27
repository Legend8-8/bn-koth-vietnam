/*
    File: fn_projectPlayerState.sqf
    Author: Legend
    Description: Projects authoritative session state into the persistent schema.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]], ["_state", createHashMap, [createHashMap]]];

if (!isServer || {_uid isEqualTo ""} || {!(_state isEqualType createHashMap)}) exitWith {createHashMap};

private _kills = _state getOrDefault ["weaponKills", createHashMap];
private _projectedKills = createHashMap;
if (_kills isEqualType createHashMap) then {
    {_projectedKills set [_x, _kills get _x]} forEach (keys _kills);
};

createHashMapFromArray [
    ["schemaVersion", missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1]],
    ["uid", _uid],
    ["xp", _state getOrDefault ["xp", 0]],
    ["cash", _state getOrDefault ["cash", missionNamespace getVariable ["BN_KOTH_startingCash", 1000]]],
    ["ownedWeapons", +(_state getOrDefault ["ownedWeapons", []])],
    ["weaponKills", _projectedKills]
]


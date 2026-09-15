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
private _vehicleMastery = _state getOrDefault ["vehicleMastery", createHashMap];
private _projectedVehicleMastery = createHashMap;
if (_vehicleMastery isEqualType createHashMap) then {
    {
        private _counters = _vehicleMastery get _x;
        private _projectedCounters = createHashMap;
        if (_counters isEqualType createHashMap) then {
            {_projectedCounters set [_x, _counters get _x]} forEach (keys _counters);
        };
        _projectedVehicleMastery set [_x, _projectedCounters];
    } forEach (keys _vehicleMastery);
};

createHashMapFromArray [
    ["schemaVersion", missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1]],
    ["uid", _uid],
    ["xp", _state getOrDefault ["xp", 0]],
    ["cash", _state getOrDefault ["cash", missionNamespace getVariable ["BN_KOTH_startingCash", 1000]]],
    ["ownedWeapons", +(_state getOrDefault ["ownedWeapons", []])],
    ["ownedPerks", +(_state getOrDefault ["ownedPerks", []])],
    ["activePerks", +(_state getOrDefault ["activePerks", []])],
    ["savedKits", +(_state getOrDefault ["savedKits", []])],
    ["preferredSavedKitId", _state getOrDefault ["preferredSavedKitId", ""]],
    ["savedKitsInitialized", _state getOrDefault ["savedKitsInitialized", false]],
    ["weaponKills", _projectedKills],
    ["ownedVehicleFamilies", +(_state getOrDefault ["ownedVehicleFamilies", []])],
    ["vehicleFirstSpawnsUsed", +(_state getOrDefault ["vehicleFirstSpawnsUsed", []])],
    ["vehicleMastery", _projectedVehicleMastery]
]

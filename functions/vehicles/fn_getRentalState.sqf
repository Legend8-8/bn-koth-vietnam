/*
    File: fn_getRentalState.sqf
    Author: Legend
    Description: Projects one UID's transient server-owned personal vehicle life
        plus durable family ownership/mastery for targeted Store presentation.
    Execution: Server
    Public: No
*/
params [["_uid","",[""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMap};
private _active = (missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal",createHashMap]) getOrDefault [_uid,createHashMap];
private _vehicle = _active getOrDefault ["vehicle",objNull];
private _cooldownUntil = (missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns",createHashMap]) getOrDefault [_uid,0];
private _progression = (missionNamespace getVariable ["BN_KOTH_playerProgression",createHashMap]) getOrDefault [_uid,createHashMap];
createHashMapFromArray [
    ["activeClass",if (!isNull _vehicle && {alive _vehicle}) then {_active getOrDefault ["vehicleClass",""]} else {""}],
    ["activeNetId",if (!isNull _vehicle && {alive _vehicle}) then {netId _vehicle} else {""}],
    ["accessMode",_active getOrDefault ["accessMode","OWNER_ONLY"]],
    ["lifeType",_active getOrDefault ["lifeType",""]],
    ["activeFamilyId",_active getOrDefault ["familyId",""]],
    ["activeLoadoutId",_active getOrDefault ["loadoutId",""]],
    ["cooldownUntil",_cooldownUntil],
    ["cooldownRemaining",ceil ((_cooldownUntil-serverTime) max 0)],
    ["ownedVehicleFamilies",+(_progression getOrDefault ["ownedVehicleFamilies",[]])],
    ["vehicleFirstSpawnsUsed",+(_progression getOrDefault ["vehicleFirstSpawnsUsed",[]])],
    ["vehicleMastery",_progression getOrDefault ["vehicleMastery",createHashMap]]
]

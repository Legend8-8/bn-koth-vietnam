/*
    File: fn_getRentalState.sqf
    Author: Legend
    Description: Projects one UID's transient server-owned one-life vehicle rental state.
    Execution: Server
    Public: No
*/
params [["_uid","",[""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMap};
private _active = (missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap]) getOrDefault [_uid,createHashMap];
private _vehicle = _active getOrDefault ["vehicle",objNull];
private _cooldownUntil = (missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",createHashMap]) getOrDefault [_uid,0];
createHashMapFromArray [
    ["activeClass",if (!isNull _vehicle && {alive _vehicle}) then {_active getOrDefault ["vehicleClass",""]} else {""}],
    ["activeNetId",if (!isNull _vehicle && {alive _vehicle}) then {netId _vehicle} else {""}],
    ["accessMode",_active getOrDefault ["accessMode","OWNER_ONLY"]],
    ["cooldownUntil",_cooldownUntil],
    ["cooldownRemaining",ceil ((_cooldownUntil-serverTime) max 0)]
]

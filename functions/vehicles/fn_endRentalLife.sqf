/*
    File: fn_endRentalLife.sqf
    Author: Legend
    Description: Ends one active rented vehicle life without restoring entitlement.
    Execution: Server
    Public: No
*/
params [["_uid","",[""]],["_vehicle",objNull,[objNull]],["_reason","UNKNOWN",[""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {false};
private _active=missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap];
private _record=_active getOrDefault [_uid,createHashMap];
// Identity, not existence: a vehicle deleted during fn_rentVehicle.sqf's pre-commit rollback (spendCash failed before
// this UID was ever registered here) can never match, so its Deleted/Killed EH becomes an inert no-op below.
if !((_record getOrDefault ["vehicle",objNull]) isEqualTo _vehicle) exitWith {false};
_active deleteAt _uid; missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals",_active];
private _cfg=missionConfigFile >> "CfgBnKothVehicles";
private _seconds=(getNumber (_cfg >> "rentalCooldownSeconds")) max 0;
private _cooldowns=missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",createHashMap];
_cooldowns set [_uid,serverTime+_seconds]; missionNamespace setVariable ["BN_KOTH_vehicleRentalCooldowns",_cooldowns];
[format ["Rented vehicle life ended UID=%1 class=%2 reason=%3 cooldown=%4",_uid,typeOf _vehicle,_reason,_seconds],"INFO"] call bn_koth_fnc_common_log;
private _ownerPlayer=objNull;
{if (getPlayerUID _x isEqualTo _uid) exitWith {_ownerPlayer=_x}} forEach allPlayers;
if (!isNull _ownerPlayer) then {
    private _result=createHashMapFromArray [["success",true],["code","VEHICLE_LIFE_ENDED"],["message","Rented vehicle life ended."],["rentalState",[_uid] call bn_koth_fnc_vehicles_getRentalState]];
    [_result] remoteExecCall ["bn_koth_fnc_vehicles_receiveRentalResult",owner _ownerPlayer];
};
true

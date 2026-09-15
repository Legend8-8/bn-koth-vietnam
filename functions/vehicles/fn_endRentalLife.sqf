/*
    File: fn_endRentalLife.sqf
    Author: Legend
    Description: Ends one active personal paid vehicle life. Genuine loss
        reasons start the config-authored cooldown; forced mission lifecycle
        cleanup removes state without penalizing the player.
    Execution: Server
    Public: No
*/
params [["_uid","",[""]],["_vehicle",objNull,[objNull]],["_reason","UNKNOWN",[""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {false};
private _active=missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal",createHashMap];
private _record=_active getOrDefault [_uid,createHashMap];
// Identity, not existence: a vehicle deleted during fn_rentVehicle.sqf's pre-commit rollback (spendCash failed before
// this UID was ever registered here) can never match, so its Deleted/Killed EH becomes an inert no-op below.
if !((_record getOrDefault ["vehicle",objNull]) isEqualTo _vehicle) exitWith {false};
_active deleteAt _uid; missionNamespace setVariable ["BN_KOTH_vehicleActivePersonal",_active];
private _seconds=(_record getOrDefault ["cooldownSeconds",90]) max 0;
private _cooldowns=missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns",createHashMap];
private _forcedCleanupReasons=["AO_RESET","ROUND_RESET","RETURNED_TO_LOBBY","MISSION_RESET","MISSION_END"];
private _startsCooldown=!(toUpper _reason in _forcedCleanupReasons);
if (_startsCooldown) then {
    _cooldowns set [_uid,serverTime+_seconds];
} else {
    _cooldowns deleteAt _uid;
};
missionNamespace setVariable ["BN_KOTH_vehiclePersonalCooldowns",_cooldowns];
[format ["Personal vehicle life ended UID=%1 class=%2 type=%3 reason=%4 cooldownApplied=%5 cooldown=%6",_uid,typeOf _vehicle,_record getOrDefault ["lifeType",""],_reason,_startsCooldown,if (_startsCooldown) then {_seconds} else {0}],"INFO"] call bn_koth_fnc_common_log;
private _ownerPlayer=objNull;
{if (getPlayerUID _x isEqualTo _uid) exitWith {_ownerPlayer=_x}} forEach allPlayers;
if (!isNull _ownerPlayer) then {
    private _result=createHashMapFromArray [["success",true],["code","VEHICLE_LIFE_ENDED"],["message",if (_startsCooldown) then {"Personal vehicle life ended; replacement cooldown started."} else {"Personal vehicle removed for mission lifecycle cleanup; no cooldown applied."}],["personalVehicleState",[_uid] call bn_koth_fnc_vehicles_getRentalState]];
    [_result] remoteExecCall ["bn_koth_fnc_vehicles_receiveRentalResult",owner _ownerPlayer];
};
true

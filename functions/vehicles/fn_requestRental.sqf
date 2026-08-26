/* Author: Legend; Description: Remote intent endpoint for one-step vehicle rental and owner access changes. Execution: Client/Server; Public: Yes */
params [["_operation","",[""]],["_vehicleClass","",[""]],["_accessMode","",[""]]];
if (hasInterface && {!isServer}) exitWith {[_operation,_vehicleClass,_accessMode] remoteExecCall ["bn_koth_fnc_vehicles_requestRental",2]};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {[_operation,_vehicleClass,_accessMode] remoteExecCall ["bn_koth_fnc_vehicles_requestRental",2]};
if (!isServer) exitWith {};
private _ownerId=remoteExecutedOwner;if (_ownerId<=0) exitWith {};
private _playerObj=[_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;private _uid=if (isNull _playerObj) then {""} else {getPlayerUID _playerObj};
private _result=if (_uid isEqualTo "") then {createHashMapFromArray [["success",false],["code","PLAYER_NOT_REGISTERED"],["message","Player state is not ready."]]} else {
    private _records=missionNamespace getVariable ["BN_KOTH_playerRecords",createHashMap];private _record=_records getOrDefault [_uid,createHashMap];private _now=serverTime;private _last=_record getOrDefault ["lastVehicleRentalRequestAt",-999];private _threshold=(getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "vehicleRentalRequestCooldownSeconds")) max 0.1;
    if ((_now-_last)<_threshold) then {createHashMapFromArray [["success",false],["code","THROTTLED"],["message","Vehicle request was sent too quickly."]]} else {_record set ["lastVehicleRentalRequestAt",_now];_records set [_uid,_record];missionNamespace setVariable ["BN_KOTH_playerRecords",_records];switch (toUpper _operation) do {case "RENT":{[_uid,_vehicleClass] call bn_koth_fnc_vehicles_rentVehicle};case "ACCESS":{[_uid,_accessMode] call bn_koth_fnc_vehicles_setRentalAccess};default {createHashMapFromArray [["success",false],["code","INVALID_OPERATION"],["message","Invalid vehicle operation."]]}}}
};
_result set ["rentalState",[_uid] call bn_koth_fnc_vehicles_getRentalState];[_result] remoteExecCall ["bn_koth_fnc_vehicles_receiveRentalResult",_ownerId];

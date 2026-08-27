/* Author: Legend; Description: Changes one active rental's logical access mode after owner validation. Execution: Server; Public: No */
params [["_uid","",[""]],["_mode","",[""]]];
private _fail={params["_c","_m"];createHashMapFromArray [["success",false],["code",_c],["message",_m]]};
if (!isServer) exitWith {["NOT_SERVER","Server authority required."] call _fail};
_mode=toUpper _mode;if !(_mode in ["OWNER_ONLY","GROUP","PUBLIC"]) exitWith {["INVALID_ACCESS_MODE","Invalid vehicle access mode."] call _fail};
private _active=missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap];private _record=_active getOrDefault [_uid,createHashMap];private _vehicle=_record getOrDefault ["vehicle",objNull];
if (isNull _vehicle || {!alive _vehicle}) exitWith {["NO_ACTIVE_VEHICLE","No active rented vehicle exists."] call _fail};
private _ownerObj=objNull;
{if (getPlayerUID _x isEqualTo _uid) exitWith {_ownerObj=_x}} forEach allPlayers;
if (_mode isEqualTo "GROUP" && {isNull _ownerObj || {count units group _ownerObj <= 1}}) exitWith {["GROUP_UNAVAILABLE","No meaningful current group exists."] call _fail};
_record set ["accessMode",_mode];_active set [_uid,_record];missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals",_active];_vehicle setVariable ["BN_KOTH_rentalAccessMode",_mode,true];
createHashMapFromArray [["success",true],["code","ACCESS_UPDATED"],["message",format ["Vehicle access set to %1.",_mode]],["accessMode",_mode]]

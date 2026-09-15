/*
    File: fn_addRentalOwnerActions.sqf
    Author: Legend
    Description: Adds owner-only, conditionally visible access controls once.
    Execution: Owning client
    Public: Yes
*/
params [["_vehicle",objNull,[objNull]]];
if (!hasInterface || {remoteExecutedOwner != 2} || {isNull _vehicle}) exitWith {};
if (_vehicle getVariable ["BN_KOTH_personalActionsAdded",false]) exitWith {};
_vehicle setVariable ["BN_KOTH_personalActionsAdded",true];
private _ownerCondition="getPlayerUID player isEqualTo (_target getVariable ['BN_KOTH_personalOwnerUid',''])";
_vehicle addAction ["LOCK TO ME",{params["_target"];['ACCESS','', 'OWNER_ONLY'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition,8];
_vehicle addAction ["UNLOCK FOR GROUP",{params["_target"];['ACCESS','', 'GROUP'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition + " && {count units group player > 1}",8];
_vehicle addAction ["UNLOCK VEHICLE",{params["_target"];['ACCESS','', 'PUBLIC'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition,8];

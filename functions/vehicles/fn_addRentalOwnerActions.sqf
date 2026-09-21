/*
    File: fn_addRentalOwnerActions.sqf
    Author: Legend
    Description: Adds owner-only access/service controls once and, when
        server-authorized, places the owner in an airborne jet's pilot seat.
    Execution: Owning client
    Parameters: 0: vehicle <OBJECT>, 1: move owner into driver seat <BOOL>,
        2: store category <STRING>, 3: actual spawn position <ARRAY>,
        4: friendly service position <ARRAY>
    Public: Yes
*/
params [
    ["_vehicle",objNull,[objNull]], ["_moveToDriver",false,[true]],
    ["_category","",[""]], ["_spawnPosition",[],[[]]],
    ["_servicePosition",[],[[]]]
];
if (!hasInterface || {remoteExecutedOwner != 2} || {isNull _vehicle}) exitWith {};
if !((getPlayerUID player) isEqualTo (_vehicle getVariable ["BN_KOTH_personalOwnerUid",""])) exitWith {};
if (_moveToDriver && {alive player} && {alive _vehicle}) then {
    [] call bn_koth_fnc_menu_close;
    player moveInDriver _vehicle;
};
if ((toUpper _category) isEqualTo "ROTARY") then {
    [
        "SET",
        _vehicle,
        _spawnPosition,
        _servicePosition,
        _vehicle getVariable ["BN_KOTH_personalServicePrice", -1],
        _vehicle getVariable ["BN_KOTH_personalServiceAreaRadius", 0]
    ] call bn_koth_fnc_vehicles_setPersonalGuidance;
};
if (_vehicle getVariable ["BN_KOTH_personalActionsAdded",false]) exitWith {};
_vehicle setVariable ["BN_KOTH_personalActionsAdded",true];
private _ownerCondition="(_target getVariable ['BN_KOTH_isPersonalPaidVehicle',false]) && {getPlayerUID player isEqualTo (_target getVariable ['BN_KOTH_personalOwnerUid',''])}";
_vehicle addAction ["LOCK TO ME",{params["_target"];['ACCESS','', 'OWNER_ONLY'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition,8];
_vehicle addAction ["UNLOCK FOR GROUP",{params["_target"];['ACCESS','', 'GROUP'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition + " && {count units group player > 1}",8];
_vehicle addAction ["UNLOCK VEHICLE",{params["_target"];['ACCESS','', 'PUBLIC'] call bn_koth_fnc_vehicles_requestRental},nil,1.5,false,true,"",_ownerCondition,8];
private _servicePrice = _vehicle getVariable ["BN_KOTH_personalServicePrice",-1];
if ((_vehicle getVariable ["BN_KOTH_personalServiceEnabled",false]) && {_servicePrice > 0}) then {
    private _serviceCondition = _ownerCondition + " && {_this isEqualTo driver _target} && {alive _target} && {!(_target getVariable ['BN_KOTH_personalServiceActive',false])} && {(missionNamespace getVariable ['BN_KOTH_roundState','']) isEqualTo 'ACTIVE'} && {private _mode=_target getVariable ['BN_KOTH_personalServiceMode','NONE']; _mode isEqualTo 'AIR_GATE' || {_mode isEqualTo 'SERVICE_PAD' && {private _pad=_target getVariable ['BN_KOTH_personalServicePadPosition',[]]; count _pad >= 2 && {_target distance2D _pad <= (_target getVariable ['BN_KOTH_personalServiceAreaRadius',35])} && {abs speed _target <= (_target getVariable ['BN_KOTH_personalServiceMaxSpeed',5])} && {!(_target getVariable ['BN_KOTH_personalServiceRequireEngineOff',false]) || {!isEngineOn _target}}}}}";
    _vehicle addAction [format ["REPAIR & REARM - $%1",_servicePrice],{params["_target"];[_target] call bn_koth_fnc_vehicles_requestService},nil,1.6,false,true,"",_serviceCondition,8];
};
if (_vehicle getVariable ["BN_KOTH_personalReturnEnabled", false]) then {
    private _returnCondition = _ownerCondition + " && {_this isEqualTo driver _target} && {alive _target} && {!(_target getVariable ['BN_KOTH_personalServiceActive',false])} && {(missionNamespace getVariable ['BN_KOTH_roundState','']) isEqualTo 'ACTIVE'} && {private _mode=_target getVariable ['BN_KOTH_personalReturnMode','NONE']; _mode isEqualTo 'AIR_GATE' || {_mode isEqualTo 'SERVICE_PAD' && {private _pad=_target getVariable ['BN_KOTH_personalServicePadPosition',[]]; count _pad >= 2 && {_target distance2D _pad <= (_target getVariable ['BN_KOTH_personalServiceAreaRadius',35])} && {abs speed _target <= (_target getVariable ['BN_KOTH_personalServiceMaxSpeed',5])}}}}";
    _vehicle addAction ["RETURN VEHICLE",{params["_target"];[_target,"RETURN"] call bn_koth_fnc_vehicles_requestService},nil,1.55,false,true,"",_returnCondition,8];
};

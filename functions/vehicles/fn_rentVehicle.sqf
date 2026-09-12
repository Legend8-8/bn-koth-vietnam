/*
    File: fn_rentVehicle.sqf
    Author: Legend
    Description: Single-step server-authoritative vehicle rental. Validates
        eligibility/affordability, resolves a safe authored pad or fallback,
        creates and sanitizes the vehicle, installs access/lifecycle state,
        and only then charges cash exactly once. Any failure after this point
        leaves no vehicle, no active record, and no charge.
    Execution: Server
    Public: No
*/
params [["_uid","",[""]],["_vehicleClass","",[""]]];
private _fail={
    params["_code","_message"];
    [format ["Vehicle rental FAILED UID=%1 requested=%2 code=%3 reason=%4",_uid,toLower _vehicleClass,_code,_message],"WARN"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success",false],["code",_code],["message",_message],["vehicleClass",toLower _vehicleClass]]
};
if (!isServer) exitWith {["NOT_SERVER","Server authority required."] call _fail};
private _records=missionNamespace getVariable ["BN_KOTH_playerRecords",createHashMap];
private _record=_records getOrDefault [_uid,createHashMap];
private _mapboardAccessDistance=(getNumber (missionConfigFile >> "CfgBnKothInteractions" >> "teamMapboardAccessDistance")) max 1;
if !(_record isEqualType createHashMap) exitWith {["PLAYER_NOT_REGISTERED","Player state is not ready."] call _fail};
private _playerObj=_record getOrDefault ["currentUnit",objNull];
if (isNull _playerObj || {!alive _playerObj} || {!((_record getOrDefault ["deployed",false]))} || {!((_record getOrDefault ["state",""]) isEqualTo "ACTIVE")} || {!((missionNamespace getVariable ["BN_KOTH_roundState",""]) isEqualTo "ACTIVE")}) exitWith {
    ["NOT_DEPLOYED","Vehicle rental requires an alive, actively deployed player."] call _fail
};
if !((getPlayerUID _playerObj) isEqualTo _uid) exitWith {["PLAYER_NOT_REGISTERED","Current player representation does not match the rental owner."] call _fail};

private _activeMap=missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals",createHashMap];
private _activeRecord=_activeMap getOrDefault [_uid,createHashMap];
private _activeVehicle=_activeRecord getOrDefault ["vehicle",objNull];
if (!isNull _activeVehicle && {alive _activeVehicle}) exitWith {["VEHICLE_ALREADY_ACTIVE","Your rented vehicle is still active."] call _fail};

private _cooldown=(missionNamespace getVariable ["BN_KOTH_vehicleRentalCooldowns",createHashMap]) getOrDefault [_uid,0];
if (serverTime < _cooldown) exitWith {["RENTAL_COOLDOWN",format ["Available in %1 seconds.",ceil (_cooldown-serverTime)]] call _fail};

private _metadata=[_vehicleClass] call bn_koth_fnc_vehicles_getProgressionMetadata;
if !(_metadata getOrDefault ["success",false]) exitWith {["INVALID_VEHICLE","Vehicle product is invalid."] call _fail};
private _canonical=_metadata getOrDefault ["canonicalClass",""];

private _sideToken=if ((_record getOrDefault ["assignedSide",sideUnknown]) isEqualTo west) then {"WEST"} else {if ((_record getOrDefault ["assignedSide",sideUnknown]) isEqualTo east) then {"EAST"} else {""}};
private _progressions=missionNamespace getVariable ["BN_KOTH_playerProgression",createHashMap];
private _progression=_progressions getOrDefault [_uid,createHashMap];
private _level=[_progression getOrDefault ["xp",0]] call bn_koth_fnc_progression_xp_getLevel;
private _rules=[_sideToken,_level,_progression getOrDefault ["activePerks", _progression getOrDefault ["perks",[]]],_metadata] call bn_koth_fnc_vehicles_evaluateProgressionRules;
if !(_rules getOrDefault ["eligible",false]) exitWith {[_rules getOrDefault ["code","INVALID_VEHICLE"],_rules getOrDefault ["message","Vehicle unavailable."]] call _fail};

private _price=_metadata getOrDefault ["rentalPrice",-1];
if (_price < 0) exitWith {["UNCONFIGURED_RENTAL","Vehicle rental price is not configured."] call _fail};

private _cash=[_uid] call bn_koth_fnc_progression_cash_getCash;
if (_cash < 0 || {_cash < _price}) exitWith {["INSUFFICIENT_CASH","Insufficient cash for this rental."] call _fail};

if ((missionNamespace getVariable ["BN_KOTH_activeLocationId",""]) isEqualTo "") exitWith {["NOT_DEPLOYED","Vehicle rental requires an active deployed location."] call _fail};

private _category=_metadata getOrDefault ["storeCategory","GROUND"];
private _padCategory=if (_category isEqualTo "GROUND") then {"GROUND"} else {if (_category in ["ROTARY","FIXED_WING"]) then {"AIR"} else {"SEA"}};
if (_padCategory isEqualTo "SEA") exitWith {["NO_SAFE_SPAWN","No curated sea rental products/policy are available."] call _fail};

private _activeLocation=toLower (missionNamespace getVariable ["BN_KOTH_activeLocationId",""]);
private _locationData=[_activeLocation] call bn_koth_fnc_zone_getLocationData;
private _boardRef=if (_sideToken isEqualTo "WEST") then {_locationData getOrDefault ["westCommand_mapboard",""]} else {_locationData getOrDefault ["eastCommand_mapboard",""]};
private _boardTarget=missionNamespace getVariable [_boardRef,objNull];
if (isNull _boardTarget && {!(_boardRef isEqualTo "")} && {!((markerShape _boardRef) isEqualTo "")}) then {
    private _boardPos=markerPos _boardRef;
    private _boardCandidates=nearestObjects [_boardPos,["Static","Thing","House","LandVehicle"],_mapboardAccessDistance];
    if !(_boardCandidates isEqualTo []) then {
        _boardCandidates=[_boardCandidates,[],{_boardPos distance2D _x},"ASCEND"] call BIS_fnc_sortBy;
        _boardTarget=_boardCandidates select 0;
    };
};
if (isNull _boardTarget || {(_playerObj distance2D _boardTarget)>_mapboardAccessDistance}) exitWith {["NOT_AT_TEAM_MAPBOARD","Vehicle rental requires access through your active team mapboard."] call _fail};
private _capabilities=[_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
private _sideCapabilities=(_capabilities getOrDefault ["sides",createHashMap]) getOrDefault [_sideToken,createHashMap];
private _family=(_sideCapabilities getOrDefault ["families",createHashMap]) getOrDefault [_category,createHashMap];
if !(_family getOrDefault ["paid",false]) exitWith {["DISABLED_FOR_AO","This vehicle category is disabled for the active AO."] call _fail};
private _reservations=missionNamespace getVariable ["BN_KOTH_vehiclePaidPadReservations",createHashMap];
private _radius=(getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidSpawnClearanceMeters")) max 1;
private _pads=(missionNamespace getVariable ["BN_KOTH_vehiclePaidPads",[]]) select {
    (_x getOrDefault ["side",""]) isEqualTo _sideToken && {(_x getOrDefault ["category",""]) isEqualTo _padCategory} &&
    {_activeLocation isEqualTo "" || {(_x getOrDefault ["location",""]) isEqualTo _activeLocation}} &&
    {isNil {_reservations get (_x getOrDefault ["id",""])}}
};
private _chosen=createHashMap;
{
    private _check=[_x getOrDefault ["position",[0,0,0]],_radius,objNull,true,true] call bn_koth_fnc_vehicles_isSpawnAreaClear;
    if (_check getOrDefault ["isClear",false]) exitWith {_chosen=_x};
} forEach _pads;
private _spawnPos=[]; private _spawnDir=0; private _reservationId="";
if ((count _chosen)>0) then {
    _spawnPos=_chosen get "position"; _spawnDir=_chosen get "direction"; _reservationId=_chosen get "id";
} else {
    private _anchor=if ((count _pads)>0) then {(_pads select 0) getOrDefault ["position",[]]} else {
        private _all=(missionNamespace getVariable ["BN_KOTH_vehiclePaidPads",[]]) select {(_x getOrDefault ["side",""]) isEqualTo _sideToken && {(_x getOrDefault ["category",""]) isEqualTo _padCategory} && {_activeLocation isEqualTo "" || {(_x getOrDefault ["location",""]) isEqualTo _activeLocation}}};
        if ((count _all)>0) then {(_all select 0) getOrDefault ["position",[]]} else {[]}
    };
    if ((count _anchor)>0) then {
        private _fallbackRadius=(getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidFallbackSpawnRadiusMeters")) max 1;
        _spawnPos=_anchor findEmptyPosition [_radius,_fallbackRadius,_canonical];
        private _minNormal=(getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "paidSpawnMinimumSurfaceNormalZ")) max 0 min 1;
        if ((count _spawnPos)>0 && {!surfaceIsWater _spawnPos} && {(surfaceNormal _spawnPos select 2)>=_minNormal}) then {
            private _check=[_spawnPos,_radius,objNull,true,true] call bn_koth_fnc_vehicles_isSpawnAreaClear;
            if !(_check getOrDefault ["isClear",false]) then {_spawnPos=[]};
        } else {
            _spawnPos=[];
        };
    };
};
if ((count _spawnPos) isEqualTo 0) exitWith {["NO_SAFE_SPAWN","No safe rental position is currently available."] call _fail};

if !(_reservationId isEqualTo "") then {_reservations set [_reservationId,_uid]; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations",_reservations]};
private _vehicle=createVehicle [_canonical,_spawnPos,[],0,"NONE"];
if (isNull _vehicle) exitWith {
    if !(_reservationId isEqualTo "") then {_reservations deleteAt _reservationId; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations",_reservations]};
    ["SPAWN_FAILED","Vehicle creation failed; no charge was made."] call _fail
};
_vehicle setDir _spawnDir; _vehicle setPosATL _spawnPos;
clearWeaponCargoGlobal _vehicle; clearMagazineCargoGlobal _vehicle; clearItemCargoGlobal _vehicle; clearBackpackCargoGlobal _vehicle;
_vehicle setVariable ["BN_KOTH_isRentedVehicle",true,true];
_vehicle setVariable ["BN_KOTH_rentalOwnerUid",_uid,true];
_vehicle setVariable ["BN_KOTH_rentalVehicleClass",_canonical,true];
_vehicle setVariable ["BN_KOTH_rentalAccessMode","OWNER_ONLY",true];
_vehicle addEventHandler ["Killed",{params["_vehicle"];[_vehicle getVariable ["BN_KOTH_rentalOwnerUid",""],_vehicle,"DESTROYED"] call bn_koth_fnc_vehicles_endRentalLife; private _delay=(getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "rentedWreckCleanupSeconds")) max 0; [_vehicle,_delay] spawn {params["_wreck","_delay"];sleep _delay;if (!isNull _wreck) then {deleteVehicle _wreck}};}];
_vehicle addEventHandler ["Deleted",{params["_vehicle"];[_vehicle getVariable ["BN_KOTH_rentalOwnerUid",""],_vehicle,"DELETED"] call bn_koth_fnc_vehicles_endRentalLife;}];
_vehicle addEventHandler ["GetIn",{params["_vehicle","_role","_unit"];if (!isPlayer _unit) exitWith {};private _ownerUid=_vehicle getVariable ["BN_KOTH_rentalOwnerUid",""];private _mode=_vehicle getVariable ["BN_KOTH_rentalAccessMode","OWNER_ONLY"];private _allowed=(getPlayerUID _unit) isEqualTo _ownerUid;if (_mode isEqualTo "PUBLIC") then {_allowed=true};if (_mode isEqualTo "GROUP") then {private _ownerObj=objNull;{if (getPlayerUID _x isEqualTo _ownerUid) exitWith {_ownerObj=_x}} forEach allPlayers;_allowed=_allowed || {!isNull _ownerObj && {group _unit isEqualTo group _ownerObj}}};if (!_allowed) then {[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_forceOutRentalVehicle",owner _unit]};}];

private _spent=[_uid,_price,format ["vehicle_rental:%1",_canonical]] call bn_koth_fnc_progression_cash_spendCash;
if !(_spent getOrDefault ["success",false]) exitWith {
    // Affordability was pre-validated; state changed between check and spend, so undo the spawn rather than leave a paid-but-uncharged vehicle.
    // This vehicle was never written to BN_KOTH_vehicleActiveRentals, so the Deleted EH it fires below cannot pass
    // fn_endRentalLife's active-record identity check: no cooldown, no notification, no stale state (see that file).
    deleteVehicle _vehicle;
    if !(_reservationId isEqualTo "") then {_reservations deleteAt _reservationId; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations",_reservations]};
    [_spent getOrDefault ["code","INSUFFICIENT_CASH"],"Insufficient cash for this rental."] call _fail
};

_activeMap set [_uid,createHashMapFromArray [["vehicle",_vehicle],["vehicleClass",_canonical],["accessMode","OWNER_ONLY"],["spawnedAt",serverTime],["ownerUid",_uid],["emptySince",-1],["disconnectedSince",-1]]];
missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals",_activeMap];
private _ownerUnit=_record getOrDefault ["currentUnit",objNull];
if (!isNull _ownerUnit && {owner _ownerUnit > 0}) then {[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_addRentalOwnerActions",owner _ownerUnit]};
if !(_reservationId isEqualTo "") then {_reservations deleteAt _reservationId; missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations",_reservations]};
[format [
    "Vehicle rental SUCCEEDED UID=%1 class=%2 pad=%3 pos=%4 netId=%5 charged=%6",
    _uid, _canonical, if (_reservationId isEqualTo "") then {"FALLBACK"} else {_reservationId}, _spawnPos, netId _vehicle, _price
]] call bn_koth_fnc_common_log;
createHashMapFromArray [["success",true],["code","RENTED"],["message","Vehicle rented and active."],["vehicleClass",_canonical],["netId",netId _vehicle],["charged",_price]]

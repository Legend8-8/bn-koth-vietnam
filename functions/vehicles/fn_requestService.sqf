/*
    File: fn_requestService.sqf
    Author: Legend
    Description: Validates owner intent for config-driven personal vehicle
        service or voluntary return. Pad operations complete immediately;
        fixed-wing operations create one shared server-owned AO-relative gate.
    Execution: Client request / Server authority
    Parameters: 0: Personal vehicle object <OBJECT>,
        1: SERVICE | RETURN purpose <STRING>
    Returns: None
    Public: Yes
*/

params [["_vehicle", objNull, [objNull]], ["_purpose", "SERVICE", [""]]];
_purpose = toUpper _purpose;
if !(_purpose in ["SERVICE", "RETURN"]) exitWith {};
if (hasInterface && {!isServer}) exitWith {[_vehicle, _purpose] remoteExecCall ["bn_koth_fnc_vehicles_requestService", 2]};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {[_vehicle, _purpose] remoteExecCall ["bn_koth_fnc_vehicles_requestService", 2]};
if (!isServer) exitWith {};
private _operationLabel = if (_purpose isEqualTo "RETURN") then {"Vehicle return"} else {"Vehicle service"};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {};
private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
private _uid = if (isNull _playerObj) then {""} else {getPlayerUID _playerObj};
private _notify = {
    params ["_title", "_body"];
    [_ownerId, createHashMapFromArray [["title", _title], ["body", _body], ["footer", ""]]] call bn_koth_fnc_teams_notifyPlayer;
};
private _reject = {
    params ["_code", "_message"];
    [if (_purpose isEqualTo "RETURN") then {"RETURN VEHICLE FAILED"} else {"REPAIR & REARM FAILED"}, _message] call _notify;
    [format ["Vehicle air operation REJECTED UID=%1 purpose=%2 code=%3 class=%4 reason=%5", _uid, _purpose, _code, if (isNull _vehicle) then {"NULL"} else {typeOf _vehicle}, _message], "WARN"] call bn_koth_fnc_common_log;
};

if (_uid isEqualTo "") exitWith {["PLAYER_NOT_REGISTERED", "Player state is not ready."] call _reject};
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap
    && {(_record getOrDefault ["ownerId", -1]) isEqualTo _ownerId}
    && {(_record getOrDefault ["currentUnit", objNull]) isEqualTo _playerObj}
    && {(_record getOrDefault ["deployed", false])}
    && {(_record getOrDefault ["state", ""]) isEqualTo "ACTIVE"}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE"}
) exitWith {["NOT_DEPLOYED", format ["%1 requires an alive, actively deployed owner.", _operationLabel]] call _reject};
if (isNull _vehicle || {!alive _vehicle} || {!alive _playerObj}) exitWith {["VEHICLE_LOST", "The personal vehicle is no longer available."] call _reject};
if !((driver _vehicle) isEqualTo _playerObj) exitWith {["NOT_PILOT", format ["Only the personal vehicle owner in the pilot seat may request %1.", toLower _operationLabel]] call _reject};

private _lastRequest = _record getOrDefault ["lastVehicleServiceRequestAt", -999];
private _throttle = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "vehicleServiceRequestCooldownSeconds")) max 0.1;
if ((serverTime - _lastRequest) < _throttle) exitWith {["THROTTLED", format ["%1 request was sent too quickly.", _operationLabel]] call _reject};
_record set ["lastVehicleServiceRequestAt", serverTime];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _active = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
private _activeRecord = _active getOrDefault [_uid, createHashMap];
if !(_activeRecord isEqualType createHashMap && {(_activeRecord getOrDefault ["vehicle", objNull]) isEqualTo _vehicle}) exitWith {["VEHICLE_IDENTITY_MISMATCH", "The vehicle is not your current personal paid vehicle."] call _reject};
if !((_vehicle getVariable ["BN_KOTH_personalOwnerUid", ""]) isEqualTo _uid) exitWith {["VEHICLE_OWNER_MISMATCH", "The vehicle owner could not be verified."] call _reject};

private _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
if !(isNil {_sessions get _uid}) exitWith {["AIR_GATE_ALREADY_ACTIVE", "An aircraft service or return gate is already active."] call _reject};
private _metadata = [_activeRecord getOrDefault ["vehicleClass", typeOf _vehicle]] call bn_koth_fnc_vehicles_getProgressionMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {["INVALID_VEHICLE", "Vehicle service/return configuration is invalid."] call _reject};
private _displayName = _metadata getOrDefault ["displayName", typeOf _vehicle];
private _mode = if (_purpose isEqualTo "RETURN") then {_metadata getOrDefault ["returnMode", "NONE"]} else {_metadata getOrDefault ["serviceMode", "NONE"]};
private _price = if (_purpose isEqualTo "RETURN") then {0} else {_metadata getOrDefault ["repairRearmPrice", -1]};
if (_purpose isEqualTo "RETURN" && {!(_metadata getOrDefault ["returnEnabled", false])}) exitWith {["RETURN_DISABLED", "Voluntary return is not configured for this vehicle."] call _reject};
if (_purpose isEqualTo "SERVICE" && {!(_metadata getOrDefault ["serviceEnabled", false])}) exitWith {["SERVICE_DISABLED", "Repair and rearm is not configured for this vehicle."] call _reject};
if !(_mode in ["AIR_GATE", "SERVICE_PAD"]) exitWith {["OPERATION_POLICY_INVALID", "Aircraft service/return policy is not configured."] call _reject};
if (_purpose isEqualTo "SERVICE" && {_price <= 0}) exitWith {["SERVICE_POLICY_INVALID", "Repair and rearm price is not configured."] call _reject};
if (_purpose isEqualTo "SERVICE" && {!([_vehicle] call bn_koth_fnc_vehicles_requiresService)}) exitWith {
    ["REPAIR & REARM", "No repair or rearm is currently required."] call _notify;
    [format ["Vehicle service NOT REQUIRED UID=%1 mode=%2 loadout=%3 class=%4", _uid, _mode, _metadata getOrDefault ["loadoutId", ""], typeOf _vehicle], "INFO"] call bn_koth_fnc_common_log;
};
private _loadedUids = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
if (_purpose isEqualTo "SERVICE" && {_loadedUids isEqualType createHashMap} && {(_loadedUids getOrDefault [_uid, ""]) isEqualTo "SESSION_FALLBACK"}) exitWith {["PERSISTENCE_UNAVAILABLE", "Cash transactions are unavailable for this session."] call _reject};
if (_purpose isEqualTo "SERVICE" && {([_uid] call bn_koth_fnc_progression_cash_getCash) < _price}) exitWith {["INSUFFICIENT_CASH", format ["Repair and rearm requires $%1.", _price]] call _reject};

private _activeLocation = toLower (missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]);
private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (_activeLocation isEqualTo "" || {_activeMarker isEqualTo ""} || {(markerShape _activeMarker) isEqualTo ""}) exitWith {["AO_UNAVAILABLE", format ["The active AO is not ready for %1.", toLower _operationLabel]] call _reject};
[format ["Vehicle air operation REQUESTED UID=%1 purpose=%2 mode=%3 price=%4 loadout=%5 class=%6", _uid, _purpose, _mode, _price, _metadata getOrDefault ["loadoutId", ""], typeOf _vehicle], "INFO"] call bn_koth_fnc_common_log;

if (_mode isEqualTo "SERVICE_PAD") exitWith {
    private _serviceCategory = _metadata getOrDefault ["serviceCategory", "NONE"];
    if !(_serviceCategory in ["GROUND", "AIR", "SEA"]) exitWith {["SERVICE_POLICY_INVALID", "Service-pad category is not valid for this vehicle."] call _reject};
    private _sideToken = if ((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo west) then {"WEST"} else {if ((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo east) then {"EAST"} else {""}};
    private _pads = (missionNamespace getVariable ["BN_KOTH_vehiclePaidPads", []]) select {
        (_x getOrDefault ["location", ""]) isEqualTo _activeLocation
        && {(_x getOrDefault ["side", ""]) isEqualTo _sideToken}
        && {(_x getOrDefault ["category", ""]) isEqualTo _serviceCategory}
    };
    if ((count _pads) <= 0) exitWith {["SERVICE_AREA_MISSING", "Friendly air service area is unavailable."] call _reject};
    private _padPosition = (_pads select 0) getOrDefault ["position", []];
    private _areaRadius = _metadata getOrDefault ["serviceAreaRadius", 35];
    if ((count _padPosition) < 2 || {(_vehicle distance2D _padPosition) > _areaRadius}) exitWith {["NOT_IN_SERVICE_AREA", "Return to the friendly air service area."] call _reject};
    if ((abs speed _vehicle) > (_metadata getOrDefault ["serviceMaxSpeed", 5])) exitWith {["VEHICLE_MOVING", format ["Stop the aircraft before requesting %1.", toLower _operationLabel]] call _reject};
    if (_purpose isEqualTo "SERVICE" && {(_metadata getOrDefault ["serviceRequireEngineOff", false])} && {isEngineOn _vehicle}) exitWith {["ENGINE_RUNNING", "Turn the engine off before requesting service."] call _reject};

    if (_purpose isEqualTo "RETURN") exitWith {
        private _ended = [_uid, _vehicle, "VOLUNTARY_RETURN"] call bn_koth_fnc_vehicles_endRentalLife;
        if (!_ended) exitWith {["RETURN_FAILED", "The active personal vehicle changed before return completed."] call _reject};
        [_vehicle, _padPosition vectorAdd [0, 0, 0.5]] remoteExecCall ["bn_koth_fnc_vehicles_forceOutRentalVehicle", _ownerId];
        deleteVehicle _vehicle;
        [format ["Personal vehicle RETURNED UID=%1 mode=SERVICE_PAD loadout=%2 class=%3", _uid, _metadata getOrDefault ["loadoutId", ""], typeOf _vehicle], "INFO"] call bn_koth_fnc_common_log;
    };

    _sessions set [_uid, createHashMapFromArray [["state", "COMPLETING"], ["purpose", "SERVICE"], ["vehicle", _vehicle], ["price", _price], ["mode", _mode]]];
    missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
    private _spent = [_uid, _price, format ["Vehicle service: %1", _displayName]] call bn_koth_fnc_progression_cash_spendCash;
    _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
    _sessions deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
    if !(_spent getOrDefault ["success", false]) exitWith {["PAYMENT_FAILED", "Payment failed. No service was applied."] call _reject};
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        [format ["Vehicle service post-payment vehicle loss UID=%1 class=%2 price=%3", _uid, typeOf _vehicle, _price], "ERROR"] call bn_koth_fnc_common_log;
        ["REPAIR & REARM FAILED", "Vehicle was lost during service. An operator must inspect the cash transaction."] call _notify;
    };
    _vehicle setDamage 0;
    [_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_applyServiceLocal", 0];
    ["REPAIR & REARM COMPLETE", format ["%1 repaired and authored ammunition restored. $%2 deducted.", _displayName, _price]] call _notify;
    [format ["Vehicle service COMPLETED UID=%1 mode=SERVICE_PAD price=%2 loadout=%3 class=%4", _uid, _price, _metadata getOrDefault ["loadoutId", ""], typeOf _vehicle], "INFO"] call bn_koth_fnc_common_log;
};

if !((_metadata getOrDefault ["storeCategory", ""]) isEqualTo "FIXED_WING") exitWith {["SERVICE_POLICY_INVALID", "Air-gate mode is not valid for this vehicle."] call _reject};
private _returnPosition = _vehicle getVariable ["BN_KOTH_personalServicePadPosition", []];
if (_purpose isEqualTo "RETURN" && {(count _returnPosition) < 2}) exitWith {["RETURN_AREA_MISSING", "A safe friendly aircraft return position is unavailable."] call _reject};
private _gate = [
    markerPos _activeMarker,
    _metadata getOrDefault ["serviceGateDistanceMin", 0],
    _metadata getOrDefault ["serviceGateDistanceMax", 0],
    _metadata getOrDefault ["serviceGateAltitudeAGL", 0],
    0
] call bn_koth_fnc_vehicles_findAirPosition;
if ((count _gate) <= 0) exitWith {["GATE_POSITION_FAILED", format ["No safe %1 gate position is currently available.", toLower _operationLabel]] call _reject};

private _counter = (missionNamespace getVariable ["BN_KOTH_vehicleServiceCounter", 0]) + 1;
missionNamespace setVariable ["BN_KOTH_vehicleServiceCounter", _counter];
private _sessionId = format ["%1:%2", _uid, _counter];
private _gatePosition = _gate get "positionASL";
private _radius = _metadata getOrDefault ["serviceGateRadius", 0];
private _session = createHashMapFromArray [
    ["sessionId", _sessionId], ["state", "ACTIVE"], ["uid", _uid], ["ownerId", _ownerId],
    ["purpose", _purpose], ["displayName", _displayName],
    ["vehicle", _vehicle], ["vehicleClass", _metadata getOrDefault ["canonicalClass", typeOf _vehicle]],
    ["familyId", _metadata getOrDefault ["familyId", ""]], ["loadoutId", _metadata getOrDefault ["loadoutId", ""]],
    ["mode", "AIR_GATE"], ["price", _price], ["gatePositionASL", _gatePosition],
    ["gateRadius", _radius], ["verticalTolerance", _metadata getOrDefault ["serviceGateVerticalTolerance", 0]],
    ["startedAt", serverTime], ["expiresAt", serverTime + (_metadata getOrDefault ["serviceGateTimeout", 0])],
    ["locationId", _activeLocation], ["zoneMarker", _activeMarker], ["lastPositionASL", getPosASL _vehicle],
    ["returnPositionATL", +_returnPosition]
];
_sessions set [_uid, _session];
missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
_vehicle setVariable ["BN_KOTH_personalServiceActive", true, true];
["SET", _sessionId, _gatePosition, _radius, _price, _gate getOrDefault ["heading", 0], _purpose, _displayName] remoteExecCall ["bn_koth_fnc_vehicles_setServicePresentation", _ownerId];
if (_purpose isEqualTo "RETURN") then {
    ["RETURN VEHICLE", format ["Return gate marked for %1. Fly through it to retire the aircraft.", _displayName]] call _notify;
} else {
    ["REPAIR & REARM", format ["Service point marked for %1. $%2 will be charged after successful service.", _displayName, _price]] call _notify;
};
[format ["Vehicle air operation CREATED UID=%1 purpose=%2 mode=AIR_GATE price=%3 loadout=%4 class=%5 location=%6", _uid, _purpose, _price, _metadata getOrDefault ["loadoutId", ""], typeOf _vehicle, _activeLocation], "INFO"] call bn_koth_fnc_common_log;

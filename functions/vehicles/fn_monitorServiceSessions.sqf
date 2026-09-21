/*
    File: fn_monitorServiceSessions.sqf
    Author: Legend
    Description: Performs one bounded server pass over active personal jet
        service gates. It is called by the existing shared vehicle manager.
    Execution: Server
    Parameters: None
    Returns: None
    Public: No
*/

if (!isServer) exitWith {};
private _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
{
    private _uid = _x;
    private _session = _sessions getOrDefault [_uid, createHashMap];
    if !(_session isEqualType createHashMap && {(_session getOrDefault ["state", ""]) isEqualTo "ACTIVE"}) then {continue};
    private _vehicle = _session getOrDefault ["vehicle", objNull];
    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    private _record = _records getOrDefault [_uid, createHashMap];
    private _playerObj = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    private _activeRecord = (missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap]) getOrDefault [_uid, createHashMap];
    private _activeLocation = toLower (missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]);
    private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
    private _reason = "";
    if (serverTime >= (_session getOrDefault ["expiresAt", 0])) then {_reason = "TIMEOUT"};
    if (_reason isEqualTo "" && {_activeLocation isNotEqualTo (_session getOrDefault ["locationId", ""])}) then {_reason = "AO_CHANGED"};
    if (_reason isEqualTo "" && {_activeMarker isEqualTo "" || {_activeMarker isNotEqualTo (_session getOrDefault ["zoneMarker", ""])} || {(markerShape _activeMarker) isEqualTo ""}}) then {_reason = "AO_CHANGED"};
    if (_reason isEqualTo "" && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isNotEqualTo "ACTIVE"}) then {_reason = "ROUND_CHANGED"};
    if (_reason isEqualTo "" && {isNull _vehicle || {!alive _vehicle} || {!((_activeRecord getOrDefault ["vehicle", objNull]) isEqualTo _vehicle)}}) then {_reason = "VEHICLE_LOST"};
    if (_reason isEqualTo "" && {isNull _playerObj || {!alive _playerObj} || {!((getPlayerUID _playerObj) isEqualTo _uid)}}) then {_reason = "PLAYER_LOST"};
    if (_reason isEqualTo "" && {!((driver _vehicle) isEqualTo _playerObj)}) then {_reason = "PILOT_LEFT"};
    if !(_reason isEqualTo "") then {
        [_uid, _reason] call bn_koth_fnc_vehicles_cancelService;
        continue;
    };

    private _gate = _session getOrDefault ["gatePositionASL", []];
    private _current = getPosASL _vehicle;
    private _previous = _session getOrDefault ["lastPositionASL", _current];
    private _dx = (_current select 0) - (_previous select 0);
    private _dy = (_current select 1) - (_previous select 1);
    private _lengthSquared = (_dx * _dx) + (_dy * _dy);
    private _fraction = if (_lengthSquared <= 0.001) then {1} else {
        ((((_gate select 0) - (_previous select 0)) * _dx) + (((_gate select 1) - (_previous select 1)) * _dy)) / _lengthSquared
    };
    _fraction = (_fraction max 0) min 1;
    private _closest = [
        (_previous select 0) + (_dx * _fraction),
        (_previous select 1) + (_dy * _fraction),
        (_previous select 2) + (((_current select 2) - (_previous select 2)) * _fraction)
    ];
    private _inside = (_closest distance2D _gate) <= (_session getOrDefault ["gateRadius", 0])
        && {abs ((_closest select 2) - (_gate select 2)) <= (_session getOrDefault ["verticalTolerance", 0])};
    if (!_inside) then {
        _session set ["lastPositionASL", _current];
        _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
        if !(isNil {_sessions get _uid}) then {_sessions set [_uid, _session]; missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions]};
        continue;
    };

    _session set ["state", "COMPLETING"];
    _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
    _sessions set [_uid, _session];
    missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
    private _purpose = _session getOrDefault ["purpose", "SERVICE"];
    private _ownerId = _session getOrDefault ["ownerId", -1];
    if (_purpose isEqualTo "RETURN") then {
        _sessions deleteAt _uid;
        missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
        _vehicle setVariable ["BN_KOTH_personalServiceActive", false, true];
        if (_ownerId > 0) then {
            ["CLEAR", _session getOrDefault ["sessionId", ""], [], 0, 0, 0, "RETURN", ""] remoteExecCall ["bn_koth_fnc_vehicles_setServicePresentation", _ownerId];
        };
        private _ended = [_uid, _vehicle, "VOLUNTARY_RETURN"] call bn_koth_fnc_vehicles_endRentalLife;
        if (_ended) then {
            private _returnPosition = _session getOrDefault ["returnPositionATL", []];
            if (_ownerId > 0 && {(count _returnPosition) >= 2}) then {
                [_vehicle, _returnPosition vectorAdd [0, 0, 0.5]] remoteExecCall ["bn_koth_fnc_vehicles_forceOutRentalVehicle", _ownerId];
            };
            deleteVehicle _vehicle;
            [format ["Personal vehicle RETURNED UID=%1 mode=AIR_GATE loadout=%2 class=%3", _uid, _session getOrDefault ["loadoutId", ""], _session getOrDefault ["vehicleClass", ""]], "INFO"] call bn_koth_fnc_common_log;
        } else {
            if (_ownerId > 0) then {
                [_ownerId, createHashMapFromArray [["title", "RETURN VEHICLE FAILED"], ["body", "The active personal vehicle changed before return completed."], ["footer", ""]]] call bn_koth_fnc_teams_notifyPlayer;
            };
        };
        continue;
    };

    private _price = _session getOrDefault ["price", -1];
    private _loadedUids = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
    if (_price <= 0 || {_loadedUids isEqualType createHashMap && {(_loadedUids getOrDefault [_uid, ""]) isEqualTo "SESSION_FALLBACK"}}) then {
        [_uid, "PAYMENT_FAILED"] call bn_koth_fnc_vehicles_cancelService;
        continue;
    };
    private _spent = [_uid, _price, format ["Vehicle service: %1", _session getOrDefault ["displayName", _session getOrDefault ["vehicleClass", "Aircraft"]]]] call bn_koth_fnc_progression_cash_spendCash;
    if !(_spent getOrDefault ["success", false]) then {
        [_uid, "PAYMENT_FAILED"] call bn_koth_fnc_vehicles_cancelService;
        continue;
    };
    _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
    _sessions deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
    _vehicle setVariable ["BN_KOTH_personalServiceActive", false, true];
    _vehicle setDamage 0;
    [_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_applyServiceLocal", 0];
    if (_ownerId > 0) then {
        ["CLEAR", _session getOrDefault ["sessionId", ""], [], 0, 0, 0] remoteExecCall ["bn_koth_fnc_vehicles_setServicePresentation", _ownerId];
        [_ownerId, createHashMapFromArray [["title", "REPAIR & REARM COMPLETE"], ["body", format ["%1 repaired and authored ammunition restored. $%2 deducted.", _session getOrDefault ["displayName", "Aircraft"], _price]], ["footer", ""]]] call bn_koth_fnc_teams_notifyPlayer;
    };
    [format ["Vehicle service COMPLETED UID=%1 mode=AIR_GATE price=%2 loadout=%3 class=%4", _uid, _price, _session getOrDefault ["loadoutId", ""], _session getOrDefault ["vehicleClass", ""]], "INFO"] call bn_koth_fnc_common_log;
} forEach +(keys _sessions);

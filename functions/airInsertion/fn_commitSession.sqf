/*
    File: fn_commitSession.sqf
    Author: Legend
    Description: Freezes, revalidates, seats, charges, and launches one player-flown insertion session.
    Execution: Server (scheduled)
    Parameters: 0: Session ID <STRING>
    Returns: True on committed departure <BOOL>
    Public: No
*/

params [["_sessionId", "", [""]]];
if (!isServer || {_sessionId isEqualTo ""} || {!canSuspend}) exitWith {false};

private _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
private _session = _sessions getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap && {(_session getOrDefault ["state", ""]) isEqualTo "OPEN"}) exitWith {false};

_session set ["state", "COMMITTING"];
_sessions set [_sessionId, _session];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _playerSessions = missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
private _initiatorUid = _session getOrDefault ["initiatorUid", ""];
private _side = _session getOrDefault ["side", sideUnknown];
private _validPassengers = [];
{
    private _passengerUid = _x;
    private _record = _records getOrDefault [_passengerUid, createHashMap];
    private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    private _eligibility = [_unit, _side] call bn_koth_fnc_airInsertion_evaluatePlayer;
    if (_eligibility getOrDefault ["success", false]) then {
        _validPassengers pushBack _passengerUid;
    } else {
        _playerSessions deleteAt _passengerUid;
        private _ownerId = if (_record isEqualType createHashMap) then {_record getOrDefault ["ownerId", -1]} else {-1};
        if (_ownerId > 0) then {
            [createHashMap] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _ownerId];
            [_ownerId, _eligibility getOrDefault ["message", "You are no longer eligible for this insertion."]] call bn_koth_fnc_teams_notifyPlayer;
        };
    };
} forEach +(_session getOrDefault ["passengerUids", []]);
missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];

if !(_initiatorUid in _validPassengers) exitWith {
    [_sessionId, "INITIATOR_INELIGIBLE", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};
_validPassengers = [_initiatorUid] + (_validPassengers - [_initiatorUid]);
_session set ["passengerUids", _validPassengers];

{
    if !(_x in _validPassengers) then {
        private _record = _records getOrDefault [_x, createHashMap];
        if (_record isEqualType createHashMap && {(_record getOrDefault ["ownerId", -1]) > 0}) then {
            [createHashMap] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _record get "ownerId"];
        };
    };
} forEach +(_session getOrDefault ["invitedUids", []]);
_session set ["invitedUids", []];
_sessions set [_sessionId, _session];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
[_sessionId] call bn_koth_fnc_airInsertion_publishSession;

private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (([] call bn_koth_fnc_round_getState) isNotEqualTo "ACTIVE" || {_activeMarker isEqualTo ""} || {(markerShape _activeMarker) isEqualTo ""}) exitWith {
    [_sessionId, "ROUND_OR_AO_INVALID", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

private _cfg = missionConfigFile >> "CfgBnKothAirInsertion";
private _aircraftClass = getText (_cfg >> "aircraftClass");
if !(missionNamespace getVariable ["BN_KOTH_airInsertionEnabled", false]) exitWith {
    [_sessionId, "SERVICE_DISABLED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};
if !(isClass (configFile >> "CfgVehicles" >> _aircraftClass)) exitWith {
    [_sessionId, "AIRCRAFT_CLASS_INVALID", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};
private _transform = [markerPos _activeMarker] call bn_koth_fnc_airInsertion_getTransform;
if ((count _transform) <= 0) exitWith {[_sessionId, "TRANSFORM_FAILED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession; false};

private _spawnAsl = _transform get "spawnASL";
private _createPosition = [_spawnAsl select 0, _spawnAsl select 1, _transform get "altitudeAGL"];
private _aircraft = createVehicle [_aircraftClass, _createPosition, [], 0, "FLY"];
if (isNull _aircraft) exitWith {[_sessionId, "AIRCRAFT_CREATE_FAILED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession; false};
_aircraft enableSimulationGlobal false;
_aircraft allowDamage false;
_aircraft setDir (_transform get "heading");
_aircraft setPosASL _spawnAsl;
_aircraft engineOn true;
_aircraft setVelocityModelSpace [0, (getNumber (_cfg >> "flightSpeed")) max 30, 0];

_session set ["aircraft", _aircraft];
_sessions set [_sessionId, _session];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

private _availableSeats = (fullCrew [_aircraft, "", true]) select {isNull (_x select 0)};
private _driverSeatIndex = _availableSeats findIf {(toLower (_x select 1)) isEqualTo "driver"};
if (_driverSeatIndex < 0) exitWith {
    [_sessionId, "NO_PILOT_SEAT", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};
private _driverSeat = _availableSeats select _driverSeatIndex;
private _crewSeats = _availableSeats select {
    private _role = toLower (_x select 1);
    !(_role in ["driver", "cargo"])
};
private _cargoSeats = _availableSeats select {(toLower (_x select 1)) isEqualTo "cargo"};
_crewSeats = [_crewSeats, [], {str (_x select 3)}, "ASCEND"] call BIS_fnc_sortBy;
_cargoSeats = [_cargoSeats, [], {_x select 2}, "ASCEND"] call BIS_fnc_sortBy;
private _seatPlan = [_driverSeat] + _crewSeats + _cargoSeats;
private _actualCapacity = count _seatPlan;
if (_actualCapacity < count _validPassengers) exitWith {
    [_sessionId, "CAPACITY_CHANGED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

private _backpackStates = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
private _newBackpackUids = [];
private _preparationStarted = true;
{
    private _record = _records getOrDefault [_x, createHashMap];
    private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    if (isNull _unit || {!alive _unit} || {!isNil {_backpackStates get _x}}) exitWith {
        _preparationStarted = false;
    };
    private _physicalLoadout = getUnitLoadout _unit;
    if ((count _physicalLoadout) <= 5) exitWith {_preparationStarted = false};
    private _originalSlot = +(_physicalLoadout select 5);
    _backpackStates set [_x, createHashMapFromArray [
        ["uid", _x], ["sessionId", _sessionId], ["unit", _unit],
        ["originalSlot", _originalSlot], ["phase", "PREPARING"],
        ["restoreAttempts", 0]
    ]];
    _newBackpackUids pushBack _x;
    ["PREPARE", _sessionId, [], _unit] remoteExec ["bn_koth_fnc_airInsertion_applyBackpack", owner _unit];
} forEach _validPassengers;
missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _backpackStates];

if (!_preparationStarted || {(count _newBackpackUids) isNotEqualTo (count _validPassengers)}) exitWith {
    {[_x, "RESTORE", "PREPARATION_START_FAILED"] call bn_koth_fnc_airInsertion_cleanupBackpack} forEach _newBackpackUids;
    [_sessionId, "PARACHUTE_PREPARATION_FAILED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

sleep ((getNumber (_cfg >> "boardingGraceSeconds")) max 0.5);
_backpackStates = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
private _parachuteClass = getText (_cfg >> "parachuteBackpackClass");
private _allPrepared = true;
{
    private _backpackState = _backpackStates getOrDefault [_x, createHashMap];
    private _record = _records getOrDefault [_x, createHashMap];
    private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    if !(_backpackState isEqualType createHashMap
        && {(_backpackState getOrDefault ["sessionId", ""]) isEqualTo _sessionId}
        && {(_backpackState getOrDefault ["phase", ""]) isEqualTo "READY"}
        && {!isNull _unit}
        && {alive _unit}
        && {(backpack _unit) isEqualTo _parachuteClass}) exitWith {_allPrepared = false};
} forEach _validPassengers;
if (!_allPrepared) exitWith {
    {[_x, "RESTORE", "PREPARATION_VERIFY_FAILED"] call bn_koth_fnc_airInsertion_cleanupBackpack} forEach _newBackpackUids;
    [_sessionId, "PARACHUTE_PREPARATION_FAILED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

private _originalPositions = createHashMap;
{
    private _record = _records getOrDefault [_x, createHashMap];
    private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    private _seat = _seatPlan select _forEachIndex;
    private _seatDescriptor = [toLower (_seat select 1), _seat select 2, _seat select 3];
    _originalPositions set [_x, getPosASL _unit];
    ["BOARD", _aircraft, _seatDescriptor, _sessionId] remoteExecCall ["bn_koth_fnc_airInsertion_applyPassengerMove", owner _unit];
} forEach _validPassengers;

_session set ["capacity", _actualCapacity];
_session set ["originalPositionsASL", _originalPositions];
_sessions set [_sessionId, _session];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

sleep ((getNumber (_cfg >> "boardingGraceSeconds")) max 0.5);
_sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
_session = _sessions getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap && {(_session getOrDefault ["state", ""]) isEqualTo "COMMITTING"} && {(_session getOrDefault ["aircraft", objNull]) isEqualTo _aircraft}) exitWith {false};

private _allBoarded = true;
{
    private _record = _records getOrDefault [_x, createHashMap];
    private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
    if (isNull _unit || {!alive _unit} || {!((vehicle _unit) isEqualTo _aircraft)}) exitWith {_allBoarded = false};
    if (_forEachIndex isEqualTo 0 && {!((driver _aircraft) isEqualTo _unit)}) exitWith {_allBoarded = false};
} forEach _validPassengers;
if (!_allBoarded || {(crew _aircraft) findIf {!isPlayer _x} >= 0}) exitWith {
    [_sessionId, "BOARDING_FAILED", "RETURN"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

private _cost = (getNumber (_cfg >> "cost")) max 1;
private _spent = [_initiatorUid, _cost, "air_insertion"] call bn_koth_fnc_progression_cash_spendCash;
if !(_spent getOrDefault ["success", false]) exitWith {
    private _initiatorRecord = _records getOrDefault [_initiatorUid, createHashMap];
    private _initiatorOwner = if (_initiatorRecord isEqualType createHashMap) then {_initiatorRecord getOrDefault ["ownerId", -1]} else {-1};
    if (_initiatorOwner > 0) then {
        [_initiatorOwner, "Air insertion payment failed; no cash was charged."] call bn_koth_fnc_teams_notifyPlayer;
    };
    [_sessionId, "PAYMENT_FAILED", "RETURN"] call bn_koth_fnc_airInsertion_cleanupSession;
    false
};

_aircraft setVariable ["BN_KOTH_airInsertionSessionId", _sessionId, true];
_aircraft addEventHandler ["GetIn", {
    params ["_vehicle", "_role", "_unit"];
    if (!isServer || {!isPlayer _unit}) exitWith {};
    private _sessionId = _vehicle getVariable ["BN_KOTH_airInsertionSessionId", ""];
    private _session = (missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap]) getOrDefault [_sessionId, createHashMap];
    private _uid = [_unit, missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]] call bn_koth_fnc_common_resolvePlayerUid;
    if !(_session isEqualType createHashMap && {_uid in (_session getOrDefault ["aboardUids", []])}) then {
        [_unit] remoteExecCall ["bn_koth_fnc_respawn_forceExitVehicle", owner _unit];
    };
}];
_aircraft addEventHandler ["GetOut", {_this call bn_koth_fnc_airInsertion_handleAircraftGetOut}];
_aircraft addEventHandler ["Killed", {params ["_vehicle"]; [_vehicle getVariable ["BN_KOTH_airInsertionSessionId", ""], "AIRCRAFT_DESTROYED", "NONE"] spawn bn_koth_fnc_airInsertion_cleanupSession}];
_aircraft addEventHandler ["Deleted", {params ["_vehicle"]; [_vehicle getVariable ["BN_KOTH_airInsertionSessionId", ""], "AIRCRAFT_DELETED", "NONE"] spawn bn_koth_fnc_airInsertion_cleanupSession}];

_session set ["state", "AIRBORNE"];
_session set ["aboardUids", +_validPassengers];
_sessions set [_sessionId, _session];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

_aircraft enableSimulationGlobal true;
_aircraft allowDamage true;
[_sessionId] call bn_koth_fnc_airInsertion_publishSession;

[_sessionId, (getNumber (_cfg >> "hardCleanupTimeout")) max 30] spawn {
    params ["_id", "_timeout"];
    sleep _timeout;
    [_id, "HARD_TIMEOUT", "EJECT"] call bn_koth_fnc_airInsertion_cleanupSession;
};
true

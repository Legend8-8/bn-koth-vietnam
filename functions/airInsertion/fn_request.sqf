/*
    File: fn_request.sqf
    Author: Legend
    Description: Accepts narrow client air-insertion intent and mutates server sessions after validation.
    Execution: Server (RemoteExec from owning client)
    Parameters:
        0: START_SOLO, START_GROUP, JOIN, LEAVE, or CANCEL <STRING>
        1: Session ID for an existing-session operation <STRING>
    Returns: None
    Public: Yes
*/

params [["_operation", "", [""]], ["_sessionId", "", [""]]];
if (!isServer) exitWith {};

_operation = toUpper _operation;
private _ownerId = remoteExecutedOwner;
private _player = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _player) exitWith {};
private _uid = getPlayerUID _player;

private _notify = {
    params ["_message"];
    [_ownerId, _message] call bn_koth_fnc_teams_notifyPlayer;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _requestRecord = _records getOrDefault [_uid, createHashMap];
if !(_requestRecord isEqualType createHashMap) exitWith {["Player state is not ready."] call _notify};
private _lastRequest = _requestRecord getOrDefault ["lastAirInsertionRequestAt", -999];
if ((serverTime - _lastRequest) < 0.35) exitWith {["Please wait a moment."] call _notify};
_requestRecord set ["lastAirInsertionRequestAt", serverTime];
_records set [_uid, _requestRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _cfg = missionConfigFile >> "CfgBnKothAirInsertion";
if !(missionNamespace getVariable ["BN_KOTH_airInsertionEnabled", false]) exitWith {["Air insertion is unavailable."] call _notify};

private _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
private _playerSessions = missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
private _clearOtherInvites = {
    params ["_targetUid", "_keptSessionId"];
    private _changedSessionIds = [];
    {
        private _otherSessionId = _x;
        if (_otherSessionId isEqualTo _keptSessionId) then {continue};
        private _otherSession = _sessions getOrDefault [_otherSessionId, createHashMap];
        if !(_otherSession isEqualType createHashMap) then {continue};
        private _otherInvited = +(_otherSession getOrDefault ["invitedUids", []]);
        if !(_targetUid in _otherInvited) then {continue};
        _otherSession set ["invitedUids", _otherInvited - [_targetUid]];
        _sessions set [_otherSessionId, _otherSession];
        _changedSessionIds pushBack _otherSessionId;
    } forEach (keys _sessions);
    if !(_changedSessionIds isEqualTo []) then {
        missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
        {[_x] call bn_koth_fnc_airInsertion_publishSession} forEach _changedSessionIds;
    };
};

if (_operation in ["START_SOLO", "START_GROUP"]) exitWith {
    private _eligibility = [_player, sideUnknown] call bn_koth_fnc_airInsertion_evaluatePlayer;
    if !(_eligibility getOrDefault ["success", false]) exitWith {[_eligibility getOrDefault ["message", "Air insertion unavailable."]] call _notify};
    if !((_playerSessions getOrDefault [_uid, ""]) isEqualTo "") exitWith {["You are already assigned to an air insertion."] call _notify};

    private _side = _eligibility get "side";
    private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
    private _locationData = [_activeLocationId] call bn_koth_fnc_zone_getLocationData;
    private _boardRef = if (_side isEqualTo west) then {_locationData getOrDefault ["westCommand_mapboard", ""]} else {_locationData getOrDefault ["eastCommand_mapboard", ""]};
    private _board = missionNamespace getVariable [_boardRef, objNull];
    if (isNull _board && {!(_boardRef isEqualTo "")} && {!((markerShape _boardRef) isEqualTo "")}) then {
        private _boardPos = markerPos _boardRef;
        private _candidates = nearestObjects [_boardPos, ["Static", "Thing", "House", "LandVehicle"], 8];
        if !(_candidates isEqualTo []) then {
            _candidates = [_candidates, [], {_boardPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
            _board = _candidates select 0;
        };
    };
    if (isNull _board || {(_player distance2D _board) > 8}) exitWith {["Use your team mapboard."] call _notify};

    private _aircraftClass = getText (_cfg >> "aircraftClass");
    private _aircraftCfg = configFile >> "CfgVehicles" >> _aircraftClass;
    if !(isClass _aircraftCfg) exitWith {["Air insertion is unavailable."] call _notify};
    private _driverSeats = if ((getNumber (_aircraftCfg >> "hasDriver")) > 0) then {1} else {0};
    private _turretSeats = count ([_aircraftClass, false] call BIS_fnc_allTurrets);
    private _capacity = _driverSeats + _turretSeats + ((getNumber (_aircraftCfg >> "transportSoldier")) max 0);
    if (_capacity <= 0) exitWith {["Air insertion is unavailable."] call _notify};

    private _cost = (getNumber (_cfg >> "cost")) max 1;
    private _cash = [_uid] call bn_koth_fnc_progression_cash_getCash;
    if (_cash < _cost) exitWith {["Not enough cash."] call _notify};

    private _nextId = missionNamespace getVariable ["BN_KOTH_airInsertionNextId", 1];
    _sessionId = format ["AIR_%1_%2", floor (serverTime * 1000), _nextId];
    missionNamespace setVariable ["BN_KOTH_airInsertionNextId", _nextId + 1];
    private _isGroup = _operation isEqualTo "START_GROUP";
    private _delay = if (_isGroup) then {(getNumber (_cfg >> "joinDuration")) max 1} else {(getNumber (_cfg >> "soloDepartureDelay")) max 0.25};
    private _invited = [];

    if (_isGroup) then {
        {
            private _candidateUid = _x;
            if (_candidateUid isEqualTo _uid || {!((_playerSessions getOrDefault [_candidateUid, ""]) isEqualTo "")}) then {continue};
            private _alreadyInvited = false;
            {
                private _otherSession = _sessions getOrDefault [_x, createHashMap];
                if (_otherSession isEqualType createHashMap && {_candidateUid in (_otherSession getOrDefault ["invitedUids", []])}) exitWith {
                    _alreadyInvited = true;
                };
            } forEach (keys _sessions);
            if (_alreadyInvited) then {continue};
            private _candidateRecord = _records getOrDefault [_candidateUid, createHashMap];
            if !(_candidateRecord isEqualType createHashMap) then {continue};
            private _candidate = _candidateRecord getOrDefault ["currentUnit", objNull];
            private _candidateEligibility = [_candidate, _side] call bn_koth_fnc_airInsertion_evaluatePlayer;
            if (_candidateEligibility getOrDefault ["success", false]) then {_invited pushBack _candidateUid};
        } forEach (keys _records);
    };

    [_uid, ""] call _clearOtherInvites;

    private _session = createHashMapFromArray [
        ["id", _sessionId], ["state", "OPEN"], ["initiatorUid", _uid],
        ["side", _side],
        ["departureAt", serverTime + _delay], ["passengerUids", [_uid]],
        ["aboardUids", []], ["invitedUids", _invited], ["capacity", _capacity],
        ["aircraft", objNull],
        ["originalPositionsASL", createHashMap]
    ];
    _sessions set [_sessionId, _session];
    _playerSessions set [_uid, _sessionId];
    missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
    missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];
    [_sessionId] call bn_koth_fnc_airInsertion_publishSession;
    [_sessionId, _delay] spawn {
        params ["_id", "_delay"];
        sleep _delay;
        [_id] call bn_koth_fnc_airInsertion_commitSession;
    };
};

private _session = _sessions getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap) exitWith {["Air insertion is unavailable."] call _notify};
private _state = _session getOrDefault ["state", ""];
private _passengers = +(_session getOrDefault ["passengerUids", []]);
private _initiatorUid = _session getOrDefault ["initiatorUid", ""];

switch (_operation) do {
    case "JOIN": {
        if !(_state isEqualTo "OPEN") exitWith {["That insertion is already departing."] call _notify};
        if !(_uid in (_session getOrDefault ["invitedUids", []])) exitWith {["No active invitation."] call _notify};
        if (_uid in _passengers) exitWith {["You already joined."] call _notify};
        if !((_playerSessions getOrDefault [_uid, ""]) isEqualTo "") exitWith {["You are already assigned to an air insertion."] call _notify};
        private _eligibility = [_player, _session getOrDefault ["side", sideUnknown]] call bn_koth_fnc_airInsertion_evaluatePlayer;
        if !(_eligibility getOrDefault ["success", false]) exitWith {[_eligibility getOrDefault ["message", "Join rejected."]] call _notify};
        if ((count _passengers) >= (_session getOrDefault ["capacity", 0])) exitWith {["Aircraft full."] call _notify};

        [_uid, _sessionId] call _clearOtherInvites;
        _passengers pushBack _uid;
        _session set ["passengerUids", _passengers];
        _sessions set [_sessionId, _session];
        _playerSessions set [_uid, _sessionId];
        missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
        missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];
        [_sessionId] call bn_koth_fnc_airInsertion_publishSession;
    };
    case "LEAVE": {
        if !(_state isEqualTo "OPEN") exitWith {["Insertion already departing."] call _notify};
        if (_uid isEqualTo _initiatorUid) exitWith {["Cancel the insertion instead."] call _notify};
        if !(_uid in _passengers) exitWith {["You are not aboard."] call _notify};
        _session set ["passengerUids", _passengers - [_uid]];
        _sessions set [_sessionId, _session];
        _playerSessions deleteAt _uid;
        missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
        missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];
        [createHashMap] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _ownerId];
        [_sessionId] call bn_koth_fnc_airInsertion_publishSession;
    };
    case "CANCEL": {
        if !(_state isEqualTo "OPEN") exitWith {["Insertion already departing."] call _notify};
        if !(_uid isEqualTo _initiatorUid) exitWith {["Only the initiator may cancel this insertion."] call _notify};
        [_sessionId, "INITIATOR_CANCELLED", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    };
    default {["Air insertion is unavailable."] call _notify};
};

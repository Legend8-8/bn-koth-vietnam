/*
    File: fn_publishSession.sqf
    Author: Legend
    Description: Sends requester-specific presentation for one authoritative insertion session.
    Execution: Server
    Parameters: 0: Session ID <STRING>
    Returns: Number of targeted clients <NUMBER>
    Public: No
*/

params [["_sessionId", "", [""]]];
if (!isServer || {_sessionId isEqualTo ""}) exitWith {0};

private _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
private _session = _sessions getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap) exitWith {0};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _passengers = _session getOrDefault ["passengerUids", []];
private _aboard = _session getOrDefault ["aboardUids", []];
private _invited = _session getOrDefault ["invitedUids", []];
private _state = _session getOrDefault ["state", "OPEN"];
private _initiatorUid = _session getOrDefault ["initiatorUid", ""];
private _initiatorRecord = _records getOrDefault [_initiatorUid, createHashMap];
private _initiatorName = if (_initiatorRecord isEqualType createHashMap) then {_initiatorRecord getOrDefault ["name", "Teammate"]} else {"Teammate"};
private _recipients = (_passengers + _invited) arrayIntersect (_passengers + _invited);
private _sent = 0;

{
    private _uid = _x;
    private _record = _records getOrDefault [_uid, createHashMap];
    if !(_record isEqualType createHashMap) then {continue};
    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) then {continue};

    private _role = "";
    if (_uid isEqualTo _initiatorUid && {_uid in _passengers}) then {
        _role = "INITIATOR";
    } else {
        if (_uid in _passengers) then {_role = "PASSENGER"} else {if (_state isEqualTo "OPEN" && {_uid in _invited}) then {_role = "INVITED"}};
    };
    if (_state isEqualTo "AIRBORNE" && {!(_uid in _aboard)}) then {_role = ""};
    if (_role isEqualTo "") then {continue};

    [createHashMapFromArray [
        ["id", _sessionId], ["state", _state], ["role", _role],
        ["mode", _session getOrDefault ["mode", "GROUP"]],
        ["cost", _session getOrDefault ["cost", 0]],
        ["departureAt", _session getOrDefault ["departureAt", -1]],
        ["passengerCount", count _passengers], ["capacity", _session getOrDefault ["capacity", 0]],
        ["initiatorName", _initiatorName]
    ]] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _ownerId];
    _sent = _sent + 1;
} forEach _recipients;

_sent

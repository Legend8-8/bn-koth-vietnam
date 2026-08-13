/*
    File: fn_requestVote.sqf
    Author: Legend
    Description: Handles per-player AO vote requests during WAITING lobby vote.
    Execution: Client/Server
    Parameters:
        0: Requested location ID or candidate index <STRING/NUMBER>
    Returns:
        None
    Public: Yes
*/

params [["_requested", "", ["", 0]]];

if (hasInterface && {!isServer}) exitWith {
    [_requested] remoteExecCall ["bn_koth_fnc_round_requestVote", 2];
};

if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [_requested] remoteExecCall ["bn_koth_fnc_round_requestVote", 2];
};

if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected vote request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {
    [format ["Rejected vote request: no player for owner %1", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _playerObj;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
private _voteOpen = missionNamespace getVariable ["BN_KOTH_voteOpen", false];
if !(_roundState isEqualTo "WAITING" && {_voteOpen}) exitWith {
    [_ownerId, "Voting is not currently open."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected vote outside WAITING/open window from UID %1", _uid], "WARN"] call bn_koth_fnc_common_log;
};

private _state = _record getOrDefault ["state", "LOBBY"];
private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !(_state isEqualTo "TEAM_SELECTED") exitWith {
    [_ownerId, "Select a team before voting."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected vote from non-selected UID=%1 state=%2", _uid, _state], "WARN"] call bn_koth_fnc_common_log;
};

if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    [_ownerId, "Your current team selection is not valid for voting."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected vote from UID=%1 with invalid assigned side %2", _uid, _assignedSide], "WARN"] call bn_koth_fnc_common_log;
};

private _now = serverTime;
private _lastVoteRequestAt = _record getOrDefault ["lastVoteRequestAt", -999];
if ((_now - _lastVoteRequestAt) < 0.25) exitWith {
    [format ["Throttled rapid vote request from UID %1", _uid], "WARN"] call bn_koth_fnc_common_log;
};
_record set ["lastVoteRequestAt", _now];

private _candidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
private _requestedLocationId = "";
if (_requested isEqualType 0) then {
    if (_requested >= 0 && {_requested < count _candidates}) then {
        _requestedLocationId = _candidates select _requested;
    };
} else {
    _requestedLocationId = _requested;
};

if !(_requestedLocationId in _candidates) exitWith {
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    [_ownerId, "Vote rejected: requested AO is not in current candidates."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected invalid vote UID=%1 raw=%2 resolved=%3", _uid, _requested, _requestedLocationId], "WARN"] call bn_koth_fnc_common_log;
};

private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if !(_votesByUid isEqualType createHashMap) then {
    _votesByUid = createHashMap;
};

private _previous = _votesByUid getOrDefault [_uid, ""];
_votesByUid set [_uid, _requestedLocationId];
["BN_KOTH_votesByUid", _votesByUid] call bn_koth_fnc_common_publicState;

_record set ["voteLocationId", _requestedLocationId];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

[] call bn_koth_fnc_round_updateVoteTotals;

if (_previous isEqualTo "") then {
    [] call bn_koth_fnc_round_maybeShortenVoteDeadline;
    [format ["Vote accepted UID=%1 AO=%2", _uid, _requestedLocationId]] call bn_koth_fnc_common_log;
} else {
    [format ["Vote changed UID=%1 from=%2 to=%3", _uid, _previous, _requestedLocationId]] call bn_koth_fnc_common_log;
};

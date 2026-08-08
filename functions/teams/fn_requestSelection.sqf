/*
    File: fn_requestSelection.sqf
    Author: Legend
    Description: Handles client team selection requests with authoritative balance validation.
    Execution: Client/Server
    Parameters:
        0: Requested side name (WEST/EAST) <STRING>
    Returns:
        None
    Public: Yes
*/

params [["_requestedSideName", "", [""]]];

if (hasInterface && {!isServer}) exitWith {
    [_requestedSideName] remoteExecCall ["bn_koth_fnc_teams_requestSelection", 2];
};

if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [_requestedSideName] remoteExecCall ["bn_koth_fnc_teams_requestSelection", 2];
};

if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected team request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {
    [format ["Rejected team request: no player for owner %1", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _playerObj;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState in ["WAITING", "ACTIVE"]) exitWith {
    [_ownerId, "Team selection is currently locked for this round phase."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected team request outside WAITING/ACTIVE from UID %1 state=%2", _uid, _roundState], "WARN"] call bn_koth_fnc_common_log;
};

private _playerState = _record getOrDefault ["state", "LOBBY"];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if (_uid in _activeParticipants || {_playerState in ["ACTIVE", "DEPLOYING", "RETURNING"]}) exitWith {
    [_ownerId, "Team change rejected: already deployed in the current round."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected team swap for already active/deploying UID=%1 logicalState=%2", _uid, _playerState], "WARN"] call bn_koth_fnc_common_log;
};

if (_roundState isEqualTo "ACTIVE" && {!(_playerState isEqualTo "LOBBY")}) exitWith {
    [_ownerId, "Active-round joining requires lobby state before side selection."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected ACTIVE JIP team request for non-lobby UID=%1 logicalState=%2", _uid, _playerState], "WARN"] call bn_koth_fnc_common_log;
};

private _now = serverTime;
private _lastRequestAt = _record getOrDefault ["lastTeamRequestAt", -999];
if ((_now - _lastRequestAt) < 0.25) exitWith {
    [format ["Throttled rapid team request from UID %1", _uid], "WARN"] call bn_koth_fnc_common_log;
};
_record set ["lastTeamRequestAt", _now];

private _requestedSide = sideUnknown;
switch (toUpper _requestedSideName) do {
    case "WEST": {_requestedSide = west;};
    case "EAST": {_requestedSide = east;};
    case "RESISTANCE": {_requestedSide = resistance;};
    case "GUER": {_requestedSide = resistance;};
};

if !([_requestedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    [_ownerId, "Requested side is not a configured playable side."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected invalid team request side '%1' from UID %2", _requestedSideName, _uid], "WARN"] call bn_koth_fnc_common_log;
};

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _sideA = _playableSides select 0;
private _sideB = _playableSides select 1;

private _teamCounts = createHashMapFromArray [[_sideA, 0], [_sideB, 0]];
{
    private _otherUid = _x;
    private _otherRecord = _records get _otherUid;
    if !(_otherRecord isEqualType createHashMap) then {
        continue;
    };

    private _otherAssigned = _otherRecord getOrDefault ["assignedSide", sideUnknown];
    if (_otherUid isEqualTo _uid) then {
        _otherAssigned = sideUnknown;
    };

    if (_otherAssigned in _playableSides) then {
        private _current = _teamCounts getOrDefault [_otherAssigned, 0];
        _teamCounts set [_otherAssigned, _current + 1];
    };
} forEach (keys _records);

private _requestedCount = (_teamCounts getOrDefault [_requestedSide, 0]) + 1;
private _opposingSide = if (_requestedSide isEqualTo _sideA) then {_sideB} else {_sideA};
private _opposingCount = _teamCounts getOrDefault [_opposingSide, 0];

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _maxDiff = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxTeamDifference")} else {1};
if (_maxDiff < 0) then {
    _maxDiff = 0;
};

if (abs (_requestedCount - _opposingCount) > _maxDiff) exitWith {
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

    [_ownerId, format ["Team request rejected by balance rule (max difference %1).", _maxDiff]] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected team assignment UID=%1 requested=%2 counts=%3/%4", _uid, _requestedSide, _requestedCount, _opposingCount], "WARN"] call bn_koth_fnc_common_log;
};

_record set ["assignedSide", _requestedSide];
_record set ["state", "TEAM_SELECTED"];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

[] call bn_koth_fnc_teams_publishState;

if (_roundState isEqualTo "ACTIVE") then {
    [format ["ACTIVE JIP team request accepted UID=%1 side=%2", _uid, _requestedSide], "INFO"] call bn_koth_fnc_common_log;
    [_uid, _ownerId, _requestedSide] spawn {
        params ["_deployUid", "_deployOwnerId", "_deployRequestedSide"];

        private _deployed = [_deployUid, "ACTIVE"] call bn_koth_fnc_teams_deploySelectedPlayer;
        if (_deployed) then {
            [_deployOwnerId, format ["Team assignment/deployment accepted: %1", _deployRequestedSide]] call bn_koth_fnc_teams_notifyPlayer;
            [format ["ACTIVE JIP deployment success UID=%1 side=%2", _deployUid, _deployRequestedSide], "INFO"] call bn_koth_fnc_common_log;
        } else {
            private _activeRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
            private _activeRecord = _activeRecords getOrDefault [_deployUid, createHashMap];

            if (_activeRecord isEqualType createHashMap) then {
                _activeRecord set ["assignedSide", sideUnknown];
                _activeRecord set ["state", "LOBBY"];
                _activeRecords set [_deployUid, _activeRecord];
                missionNamespace setVariable ["BN_KOTH_playerRecords", _activeRecords];
            };

            [_deployUid] call bn_koth_fnc_teams_assignLobbyRepresentation;
            [] call bn_koth_fnc_teams_publishState;

            [_deployOwnerId, "Active-round deployment failed; returned to CIV lobby state."] call bn_koth_fnc_teams_notifyPlayer;
            [format ["ACTIVE JIP rejection/deploy failure UID=%1 side=%2", _deployUid, _deployRequestedSide], "WARN"] call bn_koth_fnc_common_log;
        };
    };
} else {
    private _voteOpen = missionNamespace getVariable ["BN_KOTH_voteOpen", false];
    if (!_voteOpen) then {
        private _eligibleCount = count ([] call bn_koth_fnc_teams_getEligibleSelectedUids);
        private _requiredEligible = 1;

        if (_eligibleCount >= _requiredEligible) then {
            [format ["First eligible team-selected participant(s) present (%1); opening vote.", _eligibleCount], "INFO"] call bn_koth_fnc_common_log;
            [] call bn_koth_fnc_round_openVote;
        };
    };

    [_ownerId, format ["Team assignment accepted: %1", _requestedSide]] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Team assignment accepted UID=%1 side=%2", _uid, _requestedSide]] call bn_koth_fnc_common_log;
};

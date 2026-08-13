/*
    File: fn_returnSelectedPlayerToLobby.sqf
    Author: Legend
    Description: Returns one connected team-selected player to the authoritative neutral lobby state.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        True on success, otherwise false <BOOL>
    Public:
        Yes
*/

params ["_uid"];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
if (_ownerId <= 0) exitWith {
    [format ["returnSelectedPlayerToLobby rejected: invalid owner for UID=%1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "WAITING") exitWith {
    [format ["returnSelectedPlayerToLobby rejected: invalid round state=%1 UID=%2", _roundState, _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _state = _record getOrDefault ["state", "LOBBY"];
private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !(_state isEqualTo "TEAM_SELECTED") exitWith {
    [_ownerId, "Return to lobby rejected: you are not currently team selected."] call bn_koth_fnc_teams_notifyPlayer;
    false
};

if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    [_ownerId, "Return to lobby rejected: no valid team is currently assigned."] call bn_koth_fnc_teams_notifyPlayer;
    false
};

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if (_uid in _activeParticipants) exitWith {
    [_ownerId, "Return to lobby rejected: you are currently deployed."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["returnSelectedPlayerToLobby rejected: active participant UID=%1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _lobbyOk = [_uid] call bn_koth_fnc_teams_assignLobbyRepresentation;
if (!_lobbyOk) exitWith {
    [_ownerId, "Return to lobby failed: lobby representation is not ready."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["returnSelectedPlayerToLobby failed: lobby handoff UID=%1", _uid], "ERROR"] call bn_koth_fnc_common_log;
    false
};

_record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

_record set ["assignedSide", sideUnknown];
_record set ["state", "LOBBY"];
_record set ["deployed", false];
_record set ["voteLocationId", ""];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if (_votesByUid isEqualType createHashMap) then {
    _votesByUid deleteAt _uid;
    ["BN_KOTH_votesByUid", _votesByUid] call bn_koth_fnc_common_publicState;
};

[] call bn_koth_fnc_round_updateVoteTotals;
[] call bn_koth_fnc_teams_publishState;

[_ownerId, "You returned to the lobby."] call bn_koth_fnc_teams_notifyPlayer;
[format ["Player returned to lobby UID=%1", _uid], "INFO"] call bn_koth_fnc_common_log;
true

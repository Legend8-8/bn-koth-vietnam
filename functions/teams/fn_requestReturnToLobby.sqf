/*
    File: fn_requestReturnToLobby.sqf
    Author: Legend
    Description: Handles a client request to leave active battlefield
        participation and return to the neutral BN KOTH lobby. Resolves the
        registered UID from the remote-executed owner, never a client-supplied
        value, then dispatches to the state-appropriate existing return path.
        The actual transition is spawned because it calls into
        fn_transferRepresentation.sqf's waitUntil, which cannot suspend in
        this unscheduled remoteExec context. A pending-UID guard keeps
        duplicate clicks safe while that spawned transition is in flight.
    Execution: Client/Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (hasInterface && {!isServer}) exitWith {
    [] remoteExecCall ["bn_koth_fnc_teams_requestReturnToLobby", 2];
};

if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [] remoteExecCall ["bn_koth_fnc_teams_requestReturnToLobby", 2];
};

if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected return-to-lobby request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {
    [format ["Rejected return-to-lobby request: no player for owner %1", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _playerObj;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [_ownerId, "Return to lobby failed: player is not registered."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Rejected return-to-lobby request: unregistered UID for owner %1", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _pending = missionNamespace getVariable ["BN_KOTH_returnToLobbyPending", []];
if (_uid in _pending) exitWith {
    [_ownerId, "Return to lobby request is already in progress."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["Ignored duplicate return-to-lobby request while pending UID=%1", _uid], "INFO"] call bn_koth_fnc_common_log;
};

private _spawnTransition = {
    params ["_transitionUid", "_transitionFunction"];
    private _pending = missionNamespace getVariable ["BN_KOTH_returnToLobbyPending", []];
    _pending pushBackUnique _transitionUid;
    missionNamespace setVariable ["BN_KOTH_returnToLobbyPending", _pending];

    [_transitionUid, _transitionFunction] spawn {
        params ["_uid", "_function"];
        [_uid] call _function;

        private _pending = missionNamespace getVariable ["BN_KOTH_returnToLobbyPending", []];
        missionNamespace setVariable ["BN_KOTH_returnToLobbyPending", _pending - [_uid]];
    };
};

private _state = _record getOrDefault ["state", "LOBBY"];
switch (true) do {
    case (_state isEqualTo "LOBBY"): {
        [_ownerId, "You are already in the lobby."] call bn_koth_fnc_teams_notifyPlayer;
    };
    case (_state isEqualTo "TEAM_SELECTED"): {
        [_uid, bn_koth_fnc_teams_returnSelectedPlayerToLobby] call _spawnTransition;
    };
    case (_state in ["ACTIVE", "DEPLOYING"]): {
        [_uid, bn_koth_fnc_teams_returnDeployedPlayerToLobby] call _spawnTransition;
    };
    default {
        [_ownerId, "Return to lobby is not available right now."] call bn_koth_fnc_teams_notifyPlayer;
        [format ["Rejected return-to-lobby request: state=%1 UID=%2", _state, _uid], "WARN"] call bn_koth_fnc_common_log;
    };
};


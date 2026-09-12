/*
    File: fn_registerPlayer.sqf
    Author: Legend
    Description: Registers or refreshes a connected player in server-owned lobby state.
    Execution: Server
    Parameters:
        0: Player object <OBJECT>
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

params ["_player"];

if (!isServer) exitWith {false};
if (isNull _player) exitWith {
    ["registerPlayer rejected: null player object", "WARN"] call bn_koth_fnc_common_log;
    false
};

if ((owner _player) <= 0) exitWith {
    ["registerPlayer deferred: player owner not ready", "INFO"] call bn_koth_fnc_common_log;
    false
};

private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {
    [format ["registerPlayer deferred: UID not ready for owner=%1", owner _player], "INFO"] call bn_koth_fnc_common_log;
    false
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) then {
    _record = createHashMap;
};

private _lobbySpawnPosAsl = _record getOrDefault ["lobbySpawnPosASL", getPosASL _player];
private _lobbySpawnDir = _record getOrDefault ["lobbySpawnDir", getDir _player];

private _roundState = [] call bn_koth_fnc_round_getState;
private _assignedSide = if (_roundState isEqualTo "WAITING") then {
    _record getOrDefault ["assignedSide", sideUnknown]
} else {
    sideUnknown
};

_record set ["uid", _uid];
_record set ["name", name _player];
_record set ["ownerId", owner _player];
_record set ["currentUnit", _player];
_record set ["state", "LOBBY"];
_record set ["assignedSide", _assignedSide];
_record set ["voteLocationId", ""];
_record set ["lastTeamRequestAt", -999];
_record set ["lastVoteRequestAt", -999];
_record set ["lobbySpawnPosASL", _lobbySpawnPosAsl];
_record set ["lobbySpawnDir", _lobbySpawnDir];
_record set ["deployed", false];

_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _loadResult = [_uid] call bn_koth_fnc_persistence_loadPlayer;
if !(_loadResult getOrDefault ["success", false]) exitWith {
    [format ["registerPlayer deferred: persistence could not establish state UID=%1 code=%2", _uid, _loadResult getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _careerIdentity = [_uid, name _player] call bn_koth_fnc_career_registerSession;
if !(_careerIdentity getOrDefault ["success", false]) then {
    [format ["Career identity unavailable UID=%1 code=%2", _uid, _careerIdentity getOrDefault ["code", "UNKNOWN"]], "WARN"] call bn_koth_fnc_common_log;
};

private _assignedLobby = [_uid] call bn_koth_fnc_teams_assignLobbyRepresentation;
if (!_assignedLobby) exitWith {
    [format ["registerPlayer deferred: lobby representation handoff not ready for UID=%1", _uid], "INFO"] call bn_koth_fnc_common_log;
    false
};

[format ["Player entered lobby registry UID=%1 owner=%2", _uid, owner _player]] call bn_koth_fnc_common_log;
[] call bn_koth_fnc_teams_publishState;
if (([] call bn_koth_fnc_round_getState) isEqualTo "WAITING") then {
    [count ([] call bn_koth_fnc_teams_getConnectedHumanUids)] call bn_koth_fnc_round_reconcileVoteCandidates;
};

true

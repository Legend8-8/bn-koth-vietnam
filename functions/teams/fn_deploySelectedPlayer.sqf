/*
    File: fn_deploySelectedPlayer.sqf
    Author: Legend
    Description: Deploys one TEAM_SELECTED player to the current active AO using faction-correct representation.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Target logical state after handoff <STRING> (default: "ACTIVE")
        2: Allowed source states before deployment <ARRAY> (default: ["TEAM_SELECTED"])
    Returns:
        True on successful deployment, otherwise false <BOOL>
    Public: Yes
*/

params ["_uid", ["_targetState", "ACTIVE", [""]], ["_allowedSourceStates", ["TEAM_SELECTED"], [[]]]];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
if (_activeLocationId isEqualTo "") exitWith {
    [format ["Single-player deployment blocked for UID %1: no active AO", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _westRespawn = missionNamespace getVariable ["BN_KOTH_activeRespawnWestMarker", ""];
private _eastRespawn = missionNamespace getVariable ["BN_KOTH_activeRespawnEastMarker", ""];
if (_westRespawn isEqualTo "" || {_eastRespawn isEqualTo ""}) exitWith {
    [format ["Single-player deployment blocked for UID %1: missing AO respawn markers", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
private _state = _record getOrDefault ["state", "LOBBY"];
private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];

if (_ownerId <= 0 || {!(_state in _allowedSourceStates)}) exitWith {
    [format ["Single-player deployment blocked for UID %1: invalid owner/state (%2)", _uid, _state], "WARN"] call bn_koth_fnc_common_log;
    false
};

if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    [format ["Single-player deployment blocked for UID %1: invalid side %2", _uid, _assignedSide], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if (_uid in _activeParticipants) exitWith {
    [format ["Single-player deployment rejected for UID %1: already active participant", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _ownerPlayer = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _ownerPlayer) exitWith {
    [format ["Single-player deployment blocked for UID %1: owner player not resolved", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _unitClass = [_assignedSide] call bn_koth_fnc_teams_getDefaultUnitClass;
if (_unitClass isEqualTo "") exitWith {
    [format ["Single-player deployment blocked for UID %1: invalid unit class for side %2", _uid, _assignedSide], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _respawnMarker = if (_assignedSide isEqualTo west) then {_westRespawn} else {_eastRespawn};
if ((markerShape _respawnMarker) isEqualTo "") exitWith {
    [format ["Single-player deployment blocked for UID %1: missing respawn marker %2", _uid, _respawnMarker], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _spawnPos = markerPos _respawnMarker;
private _spawnDir = markerDir _respawnMarker;

private _group = createGroup [_assignedSide, true];
private _gameplayUnit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
_gameplayUnit setDir _spawnDir;

private _transferOk = [_uid, _gameplayUnit, _targetState, true] call bn_koth_fnc_teams_transferRepresentation;
if (!_transferOk) exitWith {
    deleteVehicle _gameplayUnit;
    deleteGroup _group;
    [format ["Single-player deployment transfer failed for UID %1", _uid], "ERROR"] call bn_koth_fnc_common_log;
    false
};

_gameplayUnit setPosATL _spawnPos;

_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_record = _records getOrDefault [_uid, createHashMap];
if (_record isEqualType createHashMap) then {
    _record set ["deployed", true];
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
};

_activeParticipants pushBackUnique _uid;
["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_teams_publishState;

[format ["Single-player deployment success UID=%1 side=%2 AO=%3", _uid, _assignedSide, _activeLocationId], "INFO"] call bn_koth_fnc_common_log;
true

/*
    File: fn_deployRoundParticipants.sqf
    Author: Legend
    Description: Creates faction-correct gameplay units and deploys selected players.
    Execution: Server
    Parameters:
        None
    Returns:
        Deployed player count <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "PREPARING") exitWith {0};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
if (_activeLocationId isEqualTo "") exitWith {
    ["Deployment blocked: no active location selected.", "ERROR"] call bn_koth_fnc_common_log;
    0
};

private _westRespawn = missionNamespace getVariable ["BN_KOTH_activeRespawnWestMarker", ""];
private _eastRespawn = missionNamespace getVariable ["BN_KOTH_activeRespawnEastMarker", ""];
if (_westRespawn isEqualTo "" || {_eastRespawn isEqualTo ""}) exitWith {
    ["Deployment blocked: missing respawn markers for active location.", "ERROR"] call bn_koth_fnc_common_log;
    0
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _activeParticipants = [];

{
    private _uid = _x;
    private _record = _records get _uid;

    if !(_record isEqualType createHashMap) then {
        continue;
    };

    private _ownerId = _record getOrDefault ["ownerId", -1];
    private _state = _record getOrDefault ["state", "LOBBY"];
    private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];

    if (_ownerId <= 0 || {!(_state isEqualTo "TEAM_SELECTED")}) then {
        continue;
    };

    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
        continue;
    };

    private _ownerPlayer = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (isNull _ownerPlayer) then {
        continue;
    };

    private _unitClass = [_assignedSide] call bn_koth_fnc_teams_getDefaultUnitClass;
    if (_unitClass isEqualTo "") then {
        [format ["Deployment rejected for UID %1: invalid unit class for side %2", _uid, _assignedSide], "ERROR"] call bn_koth_fnc_common_log;
        continue;
    };

    private _respawnMarker = if (_assignedSide isEqualTo west) then {_westRespawn} else {_eastRespawn};
    if ((markerShape _respawnMarker) isEqualTo "") then {
        [format ["Deployment rejected for UID %1: respawn marker missing %2", _uid, _respawnMarker], "ERROR"] call bn_koth_fnc_common_log;
        continue;
    };

    private _spawnPos = markerPos _respawnMarker;
    private _spawnDir = markerDir _respawnMarker;

    private _group = createGroup [_assignedSide, true];
    private _gameplayUnit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
    _gameplayUnit setDir _spawnDir;

    private _transferOk = [_uid, _gameplayUnit, "DEPLOYING", true] call bn_koth_fnc_teams_transferRepresentation;
    if (!_transferOk) then {
        deleteVehicle _gameplayUnit;
        deleteGroup _group;
        [format ["Deployment transfer failed for UID %1", _uid], "ERROR"] call bn_koth_fnc_common_log;
        continue;
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

    [format ["Gameplay representation assigned and deployed UID=%1 side=%2 AO=%3", _uid, _assignedSide, _activeLocationId]] call bn_koth_fnc_common_log;
} forEach (keys _records);

["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_teams_publishState;

count _activeParticipants

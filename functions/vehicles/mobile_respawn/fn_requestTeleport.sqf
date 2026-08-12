/*
    File: fn_requestTeleport.sqf
    Author: tylervip
    Description: Server-authoritative validation for command mapboard teleport requests.
    Execution: Server
    Parameters:
        0: Side token ("WEST" or "EAST") <STRING>
    Returns:
        None
    Public: Yes
*/

params [["_sideToken", "", [""]]];

if (!isServer) exitWith {};

private _player = [remoteExecutedOwner] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _player || {!alive _player}) exitWith {};

private _requestedSide = switch (_sideToken) do {
    case "WEST": {west};
    case "EAST": {east};
    default {sideUnknown};
};

if (_requestedSide isEqualTo sideUnknown) exitWith {
    ["Invalid command board request."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

if !((side _player) isEqualTo _requestedSide) exitWith {
    ["You can only use your team command board."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _teleportCooldownSeconds = (missionNamespace getVariable ["BN_KOTH_commandTeleportRequestCooldownSeconds", 10]) max 1;
private _lastRequestAt = _player getVariable ["BN_KOTH_lastCommandTeleportRequestAt", -999999];
if ((serverTime - _lastRequestAt) < _teleportCooldownSeconds) exitWith {
    ["Please wait a moment before teleporting again."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
private _activeCfg = missionConfigFile >> "CfgBnKothLocations" >> _activeLocationId;
if !(isClass _activeCfg) exitWith {
    ["The active command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _boardRef = switch (_requestedSide) do {
    case west: {getText (_activeCfg >> "westCommand_mapboard")};
    case east: {getText (_activeCfg >> "eastCommand_mapboard")};
    default {""};
};

if (_boardRef isEqualTo "") exitWith {
    ["This command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _boardTarget = missionNamespace getVariable [_boardRef, objNull];
if (isNull _boardTarget) then {
    if ((markerShape _boardRef) isEqualTo "") exitWith {
        ["This command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
    };
    private _boardPos = markerPos _boardRef;
    private _boardCandidates = nearestObjects [_boardPos, ["Static", "Thing", "House", "LandVehicle"], 8];
    if (_boardCandidates isEqualTo []) exitWith {
        ["This command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
    };
    _boardCandidates = [_boardCandidates, [], {_boardPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
    _boardTarget = _boardCandidates select 0;
};

if (isNull _boardTarget || {(_player distance2D _boardTarget) > 8}) exitWith {
    ["You must stand at the active team mapboard to use this teleport."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _vehiclesBySide = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
private _vehicle = _vehiclesBySide getOrDefault [_sideToken, objNull];

if (isNull _vehicle || {!alive _vehicle}) exitWith {
    ["Command vehicle is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

if !([_vehicle] call bn_koth_fnc_vehicles_mobileRespawn_isTentDeployed) exitWith {
    ["Command vehicle tent is not deployed."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

if ((fullCrew [_vehicle, "cargo", true]) findIf {isNull (_x select 0)} < 0) exitWith {
    ["Command vehicle cargo seats are full."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

_player setVariable ["BN_KOTH_lastCommandTeleportRequestAt", serverTime, false];
[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_mobileRespawn_executeTeleport", owner _player];

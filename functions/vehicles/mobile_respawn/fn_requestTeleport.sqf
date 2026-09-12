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
if ([_player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {
    ["Command vehicle teleport is unavailable while incapacitated."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _uid = getPlayerUID _player;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
private _mapboardAccessDistance = (getNumber (missionConfigFile >> "CfgBnKothInteractions" >> "teamMapboardAccessDistance")) max 1;
if !(_record isEqualType createHashMap) exitWith {};
if !((_record getOrDefault ["currentUnit", objNull]) isEqualTo _player) exitWith {};
if !((_record getOrDefault ["deployed", false])
    && {(_record getOrDefault ["state", ""]) isEqualTo "ACTIVE"}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE"}) exitWith {};

private _requestedSide = switch (_sideToken) do {
    case "WEST": {west};
    case "EAST": {east};
    default {sideUnknown};
};

if (_requestedSide isEqualTo sideUnknown) exitWith {
    ["Invalid command board request."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !(_assignedSide isEqualTo _requestedSide && {(side group _player) isEqualTo _assignedSide}) exitWith {
    ["You can only use your team command board."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

// Bound malformed/temporarily invalid request work separately from the
// successful-use cooldown. Failed validation should not consume ten seconds.
private _validationThrottle = (getNumber (missionConfigFile >> "CfgBnKothVehicles" >> "commandTeleportValidationThrottleSeconds")) max 0.1;
private _lastValidationAt = _record getOrDefault ["lastCommandTeleportValidationAt", -999999];
if ((serverTime - _lastValidationAt) < _validationThrottle) exitWith {};
_record set ["lastCommandTeleportValidationAt", serverTime];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _teleportCooldownSeconds = (missionNamespace getVariable ["BN_KOTH_commandTeleportRequestCooldownSeconds", 10]) max 1;
private _lastRequestAt = _record getOrDefault ["lastCommandTeleportRequestAt", -999999];
if ((serverTime - _lastRequestAt) < _teleportCooldownSeconds) exitWith {
    ["Please wait a moment before teleporting again."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
private _locationData = [_activeLocationId] call bn_koth_fnc_zone_getLocationData;
if !(_locationData isEqualType createHashMap) exitWith {
    ["The active command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _capabilities = [_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
private _sideCapabilities = (_capabilities getOrDefault ["sides", createHashMap]) getOrDefault [_sideToken, createHashMap];
private _commandCapability = (_sideCapabilities getOrDefault ["families", createHashMap]) getOrDefault ["COMMAND", createHashMap];
if !(_commandCapability getOrDefault ["spawn", false]) exitWith {
    ["Command vehicle teleport is disabled for this AO."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
};

private _boardRef = switch (_requestedSide) do {
    case west: {_locationData getOrDefault ["westCommand_mapboard", ""]};
    case east: {_locationData getOrDefault ["eastCommand_mapboard", ""]};
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
    private _boardCandidates = nearestObjects [_boardPos, ["Static", "Thing", "House", "LandVehicle"], _mapboardAccessDistance];
    if (_boardCandidates isEqualTo []) exitWith {
        ["This command board is unavailable."] remoteExecCall ["bn_koth_fnc_ui_notify", owner _player];
    };
    _boardCandidates = [_boardCandidates, [], {_boardPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
    _boardTarget = _boardCandidates select 0;
};

if (isNull _boardTarget || {(_player distance2D _boardTarget) > _mapboardAccessDistance}) exitWith {
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

_record set ["lastCommandTeleportRequestAt", serverTime];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_mobileRespawn_executeTeleport", owner _player];

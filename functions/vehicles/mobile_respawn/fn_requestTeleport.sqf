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
if (isNull _player) exitWith {};

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

[_vehicle] remoteExecCall ["bn_koth_fnc_vehicles_mobileRespawn_executeTeleport", owner _player];

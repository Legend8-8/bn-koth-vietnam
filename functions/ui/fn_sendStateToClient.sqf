/*
    File: fn_sendStateToClient.sqf
    Description: Sends a mission snapshot from server to one client.
    Execution: Server
*/

params ["_targetPlayer"];

if (!isServer) exitWith {};
if (isNull _targetPlayer) exitWith {};

private _payload = createHashMapFromArray [
    ["roundState", missionNamespace getVariable ["BN_KOTH_roundState", "WAITING"]],
    ["zoneState", missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"]],
    ["zoneController", missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown]],
    ["zonePopulation", missionNamespace getVariable ["BN_KOTH_zonePopulation", [0, 0]]],
    ["teamScores", missionNamespace getVariable ["BN_KOTH_teamScores", createHashMapFromArray [[west, 0], [east, 0]]]],
    ["scoreLimit", missionNamespace getVariable ["BN_KOTH_scoreLimit", 100]]
];

[_payload] remoteExecCall ["bn_koth_fnc_ui_receiveState", owner _targetPlayer];

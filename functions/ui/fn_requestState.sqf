/*
    File: fn_requestState.sqf
    Description: Requests current authoritative state from server.
    Execution: Client
*/

if (!hasInterface) exitWith {};

[player] remoteExecCall ["bn_koth_fnc_ui_sendStateToClient", 2];

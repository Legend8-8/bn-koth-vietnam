/*
    File: fn_initPlayerServer.sqf
    Description: Prepares server-side player state for respawn system.
    Execution: Server
*/

params ["_player"];

if (!isServer) exitWith {};
if (isNull _player) exitWith {};

_player setVariable ["BN_KOTH_teamSide", side group _player, true];

// Placeholder: add spawn protection and validated spawn selection logic.

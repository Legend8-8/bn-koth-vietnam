/*
    File: fn_initPlayerServer.sqf
    Author: tylervip
    Description: Prepares server-side player state for respawn system.
    Execution: Server
    Parameters:
        0: Player object <OBJECT>
    Returns:
        None
    Public: Yes
*/

params ["_player"];

if (!isServer) exitWith {};
if (isNull _player) exitWith {};

_player setVariable ["BN_KOTH_teamSide", side group _player, true];

// Placeholder: add spawn protection and validated spawn selection logic.

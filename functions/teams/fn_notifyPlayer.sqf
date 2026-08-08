/*
    File: fn_notifyPlayer.sqf
    Author: Legend
    Description: Sends a local notification message to one connected owner.
    Execution: Server
    Parameters:
        0: Owner ID <NUMBER>
        1: Message <STRING>
    Returns:
        None
    Public: Yes
*/

params ["_ownerId", "_message"];

if (!isServer) exitWith {};
if (_ownerId <= 0) exitWith {};
if (_message isEqualTo "") exitWith {};

[_message] remoteExecCall ["bn_koth_fnc_ui_notify", _ownerId];

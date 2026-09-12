/*
    File: fn_notifyPlayer.sqf
    Author: Legend
    Description: Sends a local notification message to one connected owner.
    Execution: Server
    Parameters:
        0: Owner ID <NUMBER>
        1: Message <STRING> or structured notification <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params ["_ownerId", ["_notification", "", ["", createHashMap]]];

if (!isServer) exitWith {};
if (_ownerId <= 0) exitWith {};
if (_notification isEqualType "" && {_notification isEqualTo ""}) exitWith {};

[_notification] remoteExecCall ["bn_koth_fnc_ui_notify", _ownerId];

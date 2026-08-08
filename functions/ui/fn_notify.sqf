/*
    File: fn_notify.sqf
    Author: Legend
    Description: Displays a short local message from authoritative server events.
    Execution: Client
    Parameters:
        0: Message text <STRING>
    Returns:
        None
    Public: Yes
*/

params ["_message"];

if (!hasInterface) exitWith {};
if (_message isEqualTo "") exitWith {};

systemChat format ["[BN_KOTH] %1", _message];

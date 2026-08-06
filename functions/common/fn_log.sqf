/*
    File: fn_log.sqf
    Author: tylervip
    Description: Minimal logging helper with mission prefix.
    Execution: Any
    Parameters:
        0: Message text <STRING>
        1: Log level <STRING> (default: "INFO")
    Returns:
        None
    Public: Yes
*/

params ["_message", ["_level", "INFO"]];

diag_log format ["[BN_KOTH][%1] %2", _level, _message];

/*
    File: fn_log.sqf
    Description: Minimal logging helper with mission prefix.
    Execution: Any
*/

params ["_message", ["_level", "INFO"]];

diag_log format ["[BN_KOTH][%1] %2", _level, _message];

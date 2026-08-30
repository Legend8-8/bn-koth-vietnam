/*
    File: fn_log.sqf
    Author: Mango Mongo
    Description: Emits optional traversal diagnostics through the mission logger.
    Execution: Any
    Parameters:
        0: Log level <STRING>
        1: Message <STRING>
    Returns:
        True <BOOL>
    Public: Yes
*/

params [
    ["_level", "INFO", [""]],
    ["_message", "", [""]]
];

private _diagnosticsCfg = missionConfigFile >> "CfgBnKothTraversal" >> "Diagnostics";
private _debugEnabled = (getNumber (_diagnosticsCfg >> "debugDraw")) > 0;
private _verboseEnabled = (getNumber (_diagnosticsCfg >> "verboseLogging")) > 0;

if (_debugEnabled || {_verboseEnabled} || {_level in ["WARN", "ERROR"]}) then {
    [format ["[TRAVERSAL] %1", _message], _level] call bn_koth_fnc_common_log;
};

true

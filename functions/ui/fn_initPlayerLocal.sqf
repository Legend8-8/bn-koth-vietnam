/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Initializes local UI hooks.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _debugCfg = missionConfigFile >> "CfgBnKothDebug";
private _debugEnabled = if (isClass _debugCfg) then {(getNumber (_debugCfg >> "enabled")) > 0} else {false};

missionNamespace setVariable ["BN_KOTH_debugEnabled", _debugEnabled];

[_debugEnabled] call bn_koth_fnc_ui_toggleDebugDisplay;

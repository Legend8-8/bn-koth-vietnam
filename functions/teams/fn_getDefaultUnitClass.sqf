/*
    File: fn_getDefaultUnitClass.sqf
    Author: Legend
    Description: Resolves configured default gameplay unit class for a playable side.
    Execution: Server
    Parameters:
        0: Side <SIDE>
    Returns:
        Unit class name or empty string <STRING>
    Public: Yes
*/

params ["_side"];

private _teamCfg = missionConfigFile >> "CfgBnKothTeams";
if !(isClass _teamCfg) exitWith {""};

private _className = switch (_side) do {
    case west: {"West"};
    case east: {"East"};
    case resistance: {"Resistance"};
    case civilian: {"Civilian"};
    default {""};
};

if (_className isEqualTo "") exitWith {""};

private _sideCfg = _teamCfg >> _className;
if !(isClass _sideCfg) exitWith {""};

private _unitClass = getText (_sideCfg >> "defaultUnitClass");
if (_unitClass isEqualTo "") exitWith {""};
if !(isClass (configFile >> "CfgVehicles" >> _unitClass)) exitWith {""};

_unitClass

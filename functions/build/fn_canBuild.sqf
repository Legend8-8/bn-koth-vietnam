/*
    File: fn_canBuild.sqf
    Author: tylervip
    Description: Shared build-eligibility checks for client open and placement actions.
    Execution: Client
    Parameters: None
    Returns: <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _buildCfg = missionConfigFile >> "CfgBnKothBuild";
if !(isClass _buildCfg) exitWith {false};

if ((getNumber (_buildCfg >> "enabled")) <= 0) exitWith {false};
if !(alive player) exitWith {false};
if !(isNull objectParent player) exitWith {false};
if (dialog && {isNull (findDisplay 6900)}) exitWith {false};
if (isNull (findDisplay 46)) exitWith {false};
if !(missionNamespace getVariable ["BN_KOTH_buildEnabled", true]) exitWith {false};

true

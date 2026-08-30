/*
    File: fn_initPlayerLocal.sqf
    Author: Mango Mongo
    Description: Initializes owning-client traversal state and optional debug drawing.
    Execution: Client
    Parameters:
        None
    Returns:
        True when traversal is enabled on an interface client, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _cfg = missionConfigFile >> "CfgBnKothTraversal";
if !(isClass _cfg) exitWith {
    ["ERROR", "CfgBnKothTraversal is missing; traversal was not initialized."] call bn_koth_fnc_traversal_log;
    false
};
if ((getNumber (_cfg >> "enabled")) <= 0) exitWith {false};

missionNamespace setVariable [
    "BN_KOTH_traversalLastRequestTime",
    missionNamespace getVariable ["BN_KOTH_traversalLastRequestTime", -1000]
];
missionNamespace setVariable [
    "BN_KOTH_traversalLastResult",
    missionNamespace getVariable ["BN_KOTH_traversalLastResult", createHashMap]
];

private _diagnosticsCfg = _cfg >> "Diagnostics";
private _debugEnabled = (getNumber (_diagnosticsCfg >> "debugDraw")) > 0;
private _existingHandler = missionNamespace getVariable ["BN_KOTH_traversalDebugDrawEh", -1];
if (_debugEnabled && {_existingHandler < 0}) then {
    private _handlerId = addMissionEventHandler ["Draw3D", {
        [] call bn_koth_fnc_traversal_debugDraw;
    }];
    missionNamespace setVariable ["BN_KOTH_traversalDebugDrawEh", _handlerId];
};

["INFO", "Owning-client traversal initialized; bind Advanced Climb in GAMEMODE KEYBINDINGS."] call bn_koth_fnc_traversal_log;
true

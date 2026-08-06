/*
    File: fn_toggleDebugDisplay.sqf
    Author: tylervip
    Description: Enables or disables the local development debug display.
    Execution: Client
    Parameters:
        0: Enabled state override <BOOL> (optional)
    Returns:
        New enabled state <BOOL>
    Public: Yes
*/

params [["_enabled", objNull, [true, objNull]]];

if (!hasInterface) exitWith {false};

private _newState = if (_enabled isEqualType true) then {
    _enabled
} else {
    !(missionNamespace getVariable ["BN_KOTH_debugEnabled", false])
};

missionNamespace setVariable ["BN_KOTH_debugEnabled", _newState];

if (!_newState) exitWith {
    missionNamespace setVariable ["BN_KOTH_debugLoopRunning", false];
    hintSilent "";
    true
};

private _existingHandle = missionNamespace getVariable ["BN_KOTH_debugLoopHandle", scriptNull];
private _loopAlive = (_existingHandle isEqualType scriptNull) && {!scriptDone _existingHandle};

if (_loopAlive) exitWith {true};

missionNamespace setVariable ["BN_KOTH_debugLoopRunning", true];
private _newHandle = [] spawn bn_koth_fnc_ui_debugDisplayLoop;
missionNamespace setVariable ["BN_KOTH_debugLoopHandle", _newHandle];

true

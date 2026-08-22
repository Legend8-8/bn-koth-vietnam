/*
    File: fn_keybinds_handleKeyDown.sqf
    Author: tylervip
    Description: Dispatches bound key-down actions.
    Execution: Client
    Parameters:
        Display/key event params
    Returns:
        True when consumed <BOOL>
    Public: Yes
*/

params ["_display", "_dikCode", ["_shift", false], ["_ctrl", false], ["_alt", false]];

if (!hasInterface) exitWith {false};
if (dialog) exitWith {false};

private _lookup = format ["BN_KOTH_escMenu_keyDown_%1_%2_%3_%4", _dikCode, _shift, _ctrl, _alt];
private _functionName = missionNamespace getVariable [_lookup, ""];
if (_functionName isEqualTo "") exitWith {false};

private _function = missionNamespace getVariable [_functionName, {}];
if (_function isEqualTo {}) exitWith {false};

private _result = call _function;
if (_result isEqualType false) exitWith {_result};
true

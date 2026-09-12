/*
    File: fn_keybinds_changeBind.sqf
    Author: tylervip
    Description: Changes one keybind and rebuilds runtime mapping.
    Execution: Client
    Parameters:
        0: Action config name <STRING>
        1: DIK key code <NUMBER>
        2: Shift <BOOL>
        3: Ctrl <BOOL>
        4: Alt <BOOL>
        5: Persist profile (optional, default true) <BOOL>
    Returns:
        True when changed <BOOL>
    Public: Yes
*/

params [
    ["_action", "", [""]],
    ["_key", 0, [0]],
    ["_shift", false, [false]],
    ["_ctrl", false, [false]],
    ["_alt", false, [false]],
    ["_persist", true, [true]]
];

if (_action isEqualTo "") exitWith {false};
if !(isClass (missionConfigFile >> "CfgBnKothEscMenuKeybinds" >> _action)) exitWith {false};

profileNamespace setVariable [format ["BN_KOTH_escMenuKeybind_%1", _action], [_key, _shift, _ctrl, _alt]];
if (_persist) then {
    saveProfileNamespace;
};

[] call bn_koth_fnc_escMenu_keybinds_init;
true

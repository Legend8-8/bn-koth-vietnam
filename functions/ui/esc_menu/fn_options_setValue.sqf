/*
    File: fn_options_setValue.sqf
    Author: tylervip
    Description: Stores one ESC option and runs its onChange handler.
    Execution: Client
    Parameters:
        0: Option config name <STRING>
        1: Value <NUMBER>
        2: Persist profile (optional, default true) <BOOL>
    Returns:
        True when applied <BOOL>
    Public: Yes
*/

params [
    ["_option", "", [""]],
    ["_value", 0, [0]],
    ["_persist", true, [true]]
];

if (_option isEqualTo "") exitWith {false};
if !(isClass (missionConfigFile >> "CfgBnKothEscMenuOptions" >> _option)) exitWith {false};

private _profileKey = format ["BN_KOTH_escMenuOption_%1", _option];
if (_persist) then {
    profileNamespace setVariable [_profileKey, _value];
    saveProfileNamespace;
};

private _handlers = localNamespace getVariable ["BN_KOTH_escMenuOptionHandlers", createHashMap];
private _handler = _handlers getOrDefault [_option, {}];
if !(_handler isEqualTo {}) then {
    private _newValue = _value;
    call _handler;
};

true

/*
    File: fn_keybinds_getBind.sqf
    Author: tylervip
    Description: Returns one effective keybind from profile/default config.
    Execution: Client
    Parameters:
        0: Action config name <STRING>
    Returns:
        [key, shift, ctrl, alt] <ARRAY>
    Public: Yes
*/

params [["_action", "", [""]]];
if (_action isEqualTo "") exitWith {[]};

private _cfg = missionConfigFile >> "CfgBnKothEscMenuKeybinds" >> _action;
if !(isClass _cfg) exitWith {[]};

private _default = [
    getNumber (_cfg >> "defaultKey"),
    (toLower (getText (_cfg >> "shift"))) isEqualTo "true",
    (toLower (getText (_cfg >> "ctrl"))) isEqualTo "true",
    (toLower (getText (_cfg >> "alt"))) isEqualTo "true"
];

private _profileKey = format ["BN_KOTH_escMenuKeybind_%1", _action];
private _bind = profileNamespace getVariable [_profileKey, _default];

if (_bind isEqualType 0) then {
    _bind = [_bind, false, false, false];
};
if !(_bind isEqualType [] && {(count _bind) >= 4}) exitWith {_default};

[
    _bind param [0, _default select 0, [0]],
    (_bind param [1, _default select 1]) isEqualTo true,
    (_bind param [2, _default select 2]) isEqualTo true,
    (_bind param [3, _default select 3]) isEqualTo true
]

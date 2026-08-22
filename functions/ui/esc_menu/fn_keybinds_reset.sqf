/*
    File: fn_keybinds_reset.sqf
    Author: tylervip
    Description: Resets keybinds in the open menu to config defaults.
    Execution: Client
    Parameters:
        0: Reset button control <CONTROL>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\esc_menu\idcs.hpp"

params ["_button"];

private _display = ctrlParent _button;
if (isNull _display) exitWith {};

disableSerialization;

private _list = _display displayCtrl BN_KOTH_IDC_ESC_KEYBINDS_LIST;
private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuKeybinds";
private _usedBinds = [];

for "_row" from 0 to ((lnbSize _list select 0) - 1) do {
    private _action = _list lnbData [_row, 0];
    if (_action isEqualTo "") then {
        _usedBinds pushBack [0, false, false, false];
        continue;
    };

    private _cfg = _cfgRoot >> _action;
    private _bind = [
        getNumber (_cfg >> "defaultKey"),
        (toLower (getText (_cfg >> "shift"))) isEqualTo "true",
        (toLower (getText (_cfg >> "ctrl"))) isEqualTo "true",
        (toLower (getText (_cfg >> "alt"))) isEqualTo "true"
    ];

    _usedBinds pushBack _bind;

    private _keyName = keyName (_bind select 0);
    if (_keyName isEqualTo "") then {
        _keyName = str (_bind select 0);
    };

    if (_bind select 3) then {_keyName = "ALT+" + _keyName;};
    if (_bind select 2) then {_keyName = "CTRL+" + _keyName;};
    if (_bind select 1) then {_keyName = "SHIFT+" + _keyName;};

    _list lnbSetText [[_row, 1], _keyName];
};

_display setVariable ["BN_KOTH_escMenuUsedBinds", _usedBinds];

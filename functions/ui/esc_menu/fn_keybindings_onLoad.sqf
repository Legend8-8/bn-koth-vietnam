/*
    File: fn_keybindings_onLoad.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Populates keybindings menu rows and event handlers.
    Execution: Client
    Parameters:
        0: Display <DISPLAY>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\esc_menu\idcs.hpp"

params ["_display"];
if (isNull _display) exitWith {};

disableSerialization;

private _list = _display displayCtrl BN_KOTH_IDC_ESC_KEYBINDS_LIST;
lnbClear _list;

private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuKeybinds";
private _configs = "getNumber(_x >> 'access') > 0" configClasses _cfgRoot;
private _usedBinds = [];

{
    private _action = configName _x;
    private _label = getText (_x >> "displayName");
    private _bind = [_action] call bn_koth_fnc_escMenu_keybinds_getBind;

    private _keyId = _bind param [0, 0];
    private _shift = _bind param [1, false];
    private _ctrl = _bind param [2, false];
    private _alt = _bind param [3, false];

    private _keyName = if (_keyId <= 0) then {"UNBOUND"} else {keyName _keyId};
    if (_keyName isEqualTo "") then {
        _keyName = str _keyId;
    };

    if (_alt) then {_keyName = "ALT+" + _keyName;};
    if (_ctrl) then {_keyName = "CTRL+" + _keyName;};
    if (_shift) then {_keyName = "SHIFT+" + _keyName;};

    private _row = _list lnbAddRow [_label, _keyName];
    _list lnbSetData [[_row, 0], _action];
    _usedBinds pushBack [_keyId, _shift, _ctrl, _alt];
} forEach _configs;

_display setVariable ["BN_KOTH_escMenuUsedBinds", _usedBinds];

_list ctrlAddEventHandler ["LBSelChanged", {
    _this params ["_list", "_row"];
    if (_row >= 0) then {
        _list lnbSetText [[_row, 1], "PRESS A KEY..."];
        [_list, _row] call bn_koth_fnc_escMenu_keybindings_captureInput;
    };
}];

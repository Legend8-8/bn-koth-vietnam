/*
    File: fn_keybindings_captureInput.sqf
    Author: tylervip
    Description: Starts or handles key-capture for one keybind row.
    Execution: Client
    Parameters:
        LBDblClick or KeyDown handler payload
    Returns:
        True when key input is consumed <BOOL>
    Public: Yes
*/

#include "\a3\ui_f\hpp\definedikcodes.inc"

if ((count _this) >= 6) exitWith {
    _this params ["_list", "_key", "_shift", "_ctrl", "_alt", "_row"];

    private _captureEh = _list getVariable ["BN_KOTH_escMenuCaptureEh", -1];
    if (_captureEh >= 0) then {
        _list ctrlRemoveEventHandler ["KeyDown", _captureEh];
        _list setVariable ["BN_KOTH_escMenuCaptureEh", -1];
    };

    private _forbidden = [DIK_LSHIFT, DIK_RSHIFT, DIK_LCONTROL, DIK_RCONTROL, DIK_LMENU, DIK_RMENU];
    if (_key in _forbidden) exitWith {true};
    if (_key isEqualTo DIK_ESCAPE) exitWith {true};

    private _display = ctrlParent _list;
    private _usedBinds = _display getVariable ["BN_KOTH_escMenuUsedBinds", []];
    if (_row >= 0 && {_row < (count _usedBinds)}) then {
        _usedBinds set [_row, [_key, _shift, _ctrl, _alt]];
        _display setVariable ["BN_KOTH_escMenuUsedBinds", _usedBinds];

        private _keyName = keyName _key;
        if (_keyName isEqualTo "") then {
            _keyName = str _key;
        };
        if (_alt) then {_keyName = "ALT+" + _keyName;};
        if (_ctrl) then {_keyName = "CTRL+" + _keyName;};
        if (_shift) then {_keyName = "SHIFT+" + _keyName;};

        _list lnbSetText [[_row, 1], _keyName];
    };

    true
};

_this params ["_list", "_row"];

private _captureEh = _list getVariable ["BN_KOTH_escMenuCaptureEh", -1];
if (_captureEh >= 0) then {
    _list ctrlRemoveEventHandler ["KeyDown", _captureEh];
};

private _newEh = _list ctrlAddEventHandler [
    "KeyDown",
    format ["(_this + [%1]) call bn_koth_fnc_escMenu_keybindings_captureInput;", _row]
];

_list setVariable ["BN_KOTH_escMenuCaptureEh", _newEh];
true

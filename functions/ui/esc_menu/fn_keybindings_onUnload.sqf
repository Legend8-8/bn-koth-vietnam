/*
    File: fn_keybindings_onUnload.sqf
    Author: tylervip
    Description: Persists keybind changes when keybind menu closes with OK.
    Execution: Client
    Parameters:
        0: Display <DISPLAY>
        1: Exit code <NUMBER>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\esc_menu\idcs.hpp"

params ["_display", "_exitCode"];
if (_exitCode isNotEqualTo 1) exitWith {};

disableSerialization;

private _list = _display displayCtrl BN_KOTH_IDC_ESC_KEYBINDS_LIST;
private _usedBinds = _display getVariable ["BN_KOTH_escMenuUsedBinds", []];

for "_row" from 0 to ((lnbSize _list select 0) - 1) do {
    private _action = _list lnbData [_row, 0];
    if (_action isEqualTo "") then {continue;};

    private _bind = _usedBinds param [_row, []];
    if !(_bind isEqualType [] && {(count _bind) >= 4}) then {continue;};

    [_action, _bind select 0, _bind select 1, _bind select 2, _bind select 3, false] call bn_koth_fnc_escMenu_keybinds_changeBind;
};

saveProfileNamespace;
[] call bn_koth_fnc_escMenu_keybinds_init;

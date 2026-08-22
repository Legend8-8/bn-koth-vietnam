/*
    File: fn_options_onSliderPosChanged.sqf
    Author: tylervip
    Description: Updates pending slider value in the options menu.
    Execution: Client
    Parameters:
        0: Slider control <CONTROL>
        1: New slider value <NUMBER>
    Returns:
        None
    Public: Yes
*/

params ["_control", "_newValue"];

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _option = _control getVariable ["BN_KOTH_escMenuOption", ""];
if (_option isEqualTo "") exitWith {};

private _valueCtrlIdc = _control getVariable ["BN_KOTH_escMenuValueIdc", -1];
if (_valueCtrlIdc >= 0) then {
    private _valueCtrl = _display displayCtrl _valueCtrlIdc;
    if (!isNull _valueCtrl) then {
        _valueCtrl ctrlSetText format ["%1%%", round (_newValue * 100)];
    };
};

private _pending = _display getVariable ["BN_KOTH_escMenuPendingOptions", createHashMap];
_pending set [_option, _newValue];
_display setVariable ["BN_KOTH_escMenuPendingOptions", _pending];

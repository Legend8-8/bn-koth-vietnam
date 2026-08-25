/*
    File: fn_options_onLoad.sqf
    Author: tylervip
    Description: Initializes options slider controls from saved values.
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

private _groundSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_GROUND_SLIDER;
private _vehicleSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_SLIDER;
private _player3DCheckBox = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_CHECKBOX;
private _player3DAlphaSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_SLIDER;

private _groundCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "earplugVolumeGround";
private _vehicleCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "earplugVolumeVehicle";
private _player3DCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "player3DIconsEnabled";
private _player3DAlphaCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "player3DIconsAlpha";

private _groundRange = getArray (_groundCfg >> "range");
private _vehicleRange = getArray (_vehicleCfg >> "range");
private _player3DAlphaRange = getArray (_player3DAlphaCfg >> "range");

private _groundStep = getNumber (_groundCfg >> "step");
private _vehicleStep = getNumber (_vehicleCfg >> "step");
private _player3DAlphaStep = getNumber (_player3DAlphaCfg >> "step");

private _groundValue = ["earplugVolumeGround"] call bn_koth_fnc_escMenu_options_getValue;
private _vehicleValue = ["earplugVolumeVehicle"] call bn_koth_fnc_escMenu_options_getValue;
private _player3DValue = ["player3DIconsEnabled"] call bn_koth_fnc_escMenu_options_getValue;
private _player3DAlphaValue = ["player3DIconsAlpha"] call bn_koth_fnc_escMenu_options_getValue;

_groundSlider sliderSetRange _groundRange;
_groundSlider sliderSetSpeed [_groundStep, _groundStep];
_groundSlider sliderSetPosition _groundValue;
_groundSlider setVariable ["BN_KOTH_escMenuOption", "earplugVolumeGround"];
_groundSlider setVariable ["BN_KOTH_escMenuValueIdc", BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE];
_groundSlider ctrlAddEventHandler ["SliderPosChanged", {
    _this call bn_koth_fnc_escMenu_options_onSliderPosChanged;
}];

_vehicleSlider sliderSetRange _vehicleRange;
_vehicleSlider sliderSetSpeed [_vehicleStep, _vehicleStep];
_vehicleSlider sliderSetPosition _vehicleValue;
_vehicleSlider setVariable ["BN_KOTH_escMenuOption", "earplugVolumeVehicle"];
_vehicleSlider setVariable ["BN_KOTH_escMenuValueIdc", BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE];
_vehicleSlider ctrlAddEventHandler ["SliderPosChanged", {
    _this call bn_koth_fnc_escMenu_options_onSliderPosChanged;
}];

_player3DCheckBox ctrlSetChecked (_player3DValue > 0);
_player3DCheckBox setVariable ["BN_KOTH_escMenuOption", "player3DIconsEnabled"];
_player3DCheckBox setVariable ["BN_KOTH_escMenuValueIdc", BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE];
_player3DCheckBox ctrlAddEventHandler ["CheckedChanged", {
    params ["_control", "_checked"];
    private _display = ctrlParent _control;
    if (isNull _display) exitWith {};

    private _option = _control getVariable ["BN_KOTH_escMenuOption", ""];
    if (_option isEqualTo "") exitWith {};

    private _pending = _display getVariable ["BN_KOTH_escMenuPendingOptions", createHashMap];
    _pending set [_option, if (_checked > 0) then {1} else {0}];
    _display setVariable ["BN_KOTH_escMenuPendingOptions", _pending];

    private _valueCtrlIdc = _control getVariable ["BN_KOTH_escMenuValueIdc", -1];
    if (_valueCtrlIdc >= 0) then {
        private _valueCtrl = _display displayCtrl _valueCtrlIdc;
        if (!isNull _valueCtrl) then {
            _valueCtrl ctrlSetText (if (_checked > 0) then {"ON"} else {"OFF"});
        };
    };
}];

_player3DAlphaSlider sliderSetRange _player3DAlphaRange;
_player3DAlphaSlider sliderSetSpeed [_player3DAlphaStep, _player3DAlphaStep];
_player3DAlphaSlider sliderSetPosition _player3DAlphaValue;
_player3DAlphaSlider setVariable ["BN_KOTH_escMenuOption", "player3DIconsAlpha"];
_player3DAlphaSlider setVariable ["BN_KOTH_escMenuValueIdc", BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE];
_player3DAlphaSlider ctrlAddEventHandler ["SliderPosChanged", {
    _this call bn_koth_fnc_escMenu_options_onSliderPosChanged;
}];

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE) ctrlSetText format ["%1%%", round (_groundValue * 100)];
(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE) ctrlSetText format ["%1%%", round (_vehicleValue * 100)];
(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE) ctrlSetText (if (_player3DValue > 0.5) then {"ON"} else {"OFF"});
(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE) ctrlSetText format ["%1%%", round (_player3DAlphaValue * 100)];

private _pending = createHashMapFromArray [
    ["earplugVolumeGround", _groundValue],
    ["earplugVolumeVehicle", _vehicleValue],
    ["player3DIconsEnabled", _player3DValue],
    ["player3DIconsAlpha", _player3DAlphaValue]
];
_display setVariable ["BN_KOTH_escMenuPendingOptions", _pending];

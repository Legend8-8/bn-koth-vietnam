/*
    File: fn_options_reset.sqf
    Author: tylervip
    Description: Resets all ESC menu options to their config defaults.
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

private _cfgRoot = missionConfigFile >> "CfgBnKothEscMenuOptions";
private _pending = createHashMap;

{
    private _name = configName _x;
    private _default = getNumber (_x >> "default");
    _pending set [_name, _default];
    [_name, _default, true] call bn_koth_fnc_escMenu_options_setValue;
} forEach ("true" configClasses _cfgRoot);

_display setVariable ["BN_KOTH_escMenuPendingOptions", _pending];
[] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;

private _groundValue = _pending getOrDefault ["earplugVolumeGround", 1];
private _vehicleValue = _pending getOrDefault ["earplugVolumeVehicle", 1];
private _player3DValue = _pending getOrDefault ["player3DIconsEnabled", 1];
private _player3DAlphaValue = _pending getOrDefault ["player3DIconsAlpha", 1];

private _groundSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_GROUND_SLIDER;
private _vehicleSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_SLIDER;
private _player3DCheckBox = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_CHECKBOX;
private _player3DAlphaSlider = _display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_SLIDER;

_groundSlider sliderSetPosition _groundValue;
_vehicleSlider sliderSetPosition _vehicleValue;
_player3DCheckBox ctrlSetChecked (_player3DValue > 0);
_player3DAlphaSlider sliderSetPosition _player3DAlphaValue;

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE)
    ctrlSetText format ["%1%%", round (_groundValue * 100)];

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE)
    ctrlSetText format ["%1%%", round (_vehicleValue * 100)];

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE)
    ctrlSetText (if (_player3DValue > 0.5) then {"ON"} else {"OFF"});

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE)
    ctrlSetText format ["%1%%", round (_player3DAlphaValue * 100)];

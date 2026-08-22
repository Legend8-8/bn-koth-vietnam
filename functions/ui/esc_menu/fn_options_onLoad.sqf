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

private _groundCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "earplugVolumeGround";
private _vehicleCfg = missionConfigFile >> "CfgBnKothEscMenuOptions" >> "earplugVolumeVehicle";

private _groundRange = getArray (_groundCfg >> "range");
private _vehicleRange = getArray (_vehicleCfg >> "range");

private _groundStep = getNumber (_groundCfg >> "step");
private _vehicleStep = getNumber (_vehicleCfg >> "step");

private _groundValue = ["earplugVolumeGround"] call bn_koth_fnc_escMenu_options_getValue;
private _vehicleValue = ["earplugVolumeVehicle"] call bn_koth_fnc_escMenu_options_getValue;

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

(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE) ctrlSetText format ["%1%%", round (_groundValue * 100)];
(_display displayCtrl BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE) ctrlSetText format ["%1%%", round (_vehicleValue * 100)];

private _pending = createHashMapFromArray [
    ["earplugVolumeGround", _groundValue],
    ["earplugVolumeVehicle", _vehicleValue]
];
_display setVariable ["BN_KOTH_escMenuPendingOptions", _pending];

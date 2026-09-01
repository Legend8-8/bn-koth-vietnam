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

closeDialog 3;
createDialog "BN_KOTH_RscEscMenuOptions";

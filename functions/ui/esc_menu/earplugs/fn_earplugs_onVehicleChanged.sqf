/*
    File: fn_earplugs_onVehicleChanged.sqf
    Author: tylervip
    Description: Reapplies earplug attenuation when vehicle state changes.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _enabled = localNamespace getVariable ["BN_KOTH_earplugsEnabled", false];
[_enabled] call bn_koth_fnc_escMenu_earplugs_apply;

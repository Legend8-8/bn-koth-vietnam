/*
    File: fn_earplugs_init.sqf
    Author: tylervip
    Description: Initializes local earplug state and option-backed volume values.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _groundVolume = ["earplugVolumeGround"] call bn_koth_fnc_escMenu_options_getValue;
private _vehicleVolume = ["earplugVolumeVehicle"] call bn_koth_fnc_escMenu_options_getValue;

missionNamespace setVariable ["BN_KOTH_earplugsVolumeGround", _groundVolume];
missionNamespace setVariable ["BN_KOTH_earplugsVolumeVehicle", _vehicleVolume];

if (isNil {localNamespace getVariable "BN_KOTH_earplugsEnabled"}) then {
    localNamespace setVariable ["BN_KOTH_earplugsEnabled", false];
};

[] call bn_koth_fnc_escMenu_earplugs_onVehicleChanged;

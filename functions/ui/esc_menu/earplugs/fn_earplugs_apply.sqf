/*
    File: fn_earplugs_apply.sqf
    Author: tylervip
    Description: Applies current earplug state to local sound volume.
    Execution: Client
    Parameters:
        0: Earplug enabled (optional) <BOOL>
    Returns:
        True when applied <BOOL>
    Public: Yes
*/

params [["_enabled", localNamespace getVariable ["BN_KOTH_earplugsEnabled", false], [false]]];

if (!hasInterface) exitWith {false};

localNamespace setVariable ["BN_KOTH_earplugsEnabled", _enabled];

private _volume = 1;
if (_enabled) then {
    private _inVehicle = !(vehicle player isEqualTo player);
    _volume = if (_inVehicle) then {
        missionNamespace getVariable ["BN_KOTH_earplugsVolumeVehicle", 0.5]
    } else {
        missionNamespace getVariable ["BN_KOTH_earplugsVolumeGround", 0.5]
    };
};

_volume fadeSound _volume;
true

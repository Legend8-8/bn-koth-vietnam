/*
    File: fn_applyVehicleProtection.sqf
    Author: Mongo
    Description: Applies vehicle-safe-zone enforcement on the machine that owns the vehicle.
    Execution: Vehicle locality owner
    Parameters:
        0: Vehicle <OBJECT>
        1: Protection enabled <BOOL>
    Returns:
        True when applied locally <BOOL>
    Public: Yes
*/

params [
    ["_vehicle", objNull, [objNull]],
    ["_protected", false, [false]]
];

if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {false};
if (isNull _vehicle || {!local _vehicle}) exitWith {false};

if !(_vehicle getVariable ["BN_KOTH_safeZoneVehicleDamageEhLocal", false]) then {
    _vehicle addEventHandler ["HandleDamage", {
        _this call bn_koth_fnc_respawn_handleDamage
    }];
    _vehicle setVariable ["BN_KOTH_safeZoneVehicleDamageEhLocal", true, false];
};

if !(_vehicle getVariable ["BN_KOTH_safeZoneVehicleFiredEhLocal", false]) then {
    _vehicle addEventHandler ["Fired", {
        _this call bn_koth_fnc_respawn_handleFired
    }];
    _vehicle setVariable ["BN_KOTH_safeZoneVehicleFiredEhLocal", true, false];
};

_vehicle allowDamage (!_protected);
_vehicle setVariable ["BN_KOTH_safeZoneVehicleProtectionAppliedLocal", _protected, false];
true

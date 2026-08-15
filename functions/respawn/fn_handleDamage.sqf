/*
    File: fn_handleDamage.sqf
    Author: Mongo
    Description: Enforces safe-zone incoming and outgoing damage rules at entity locality.
    Execution: Local to damaged entity
    Parameters:
        HandleDamage event payload <ARRAY>
    Returns:
        Damage value to apply <NUMBER>
    Public: Yes
*/

params [
    ["_target", objNull, [objNull]],
    ["_selection", "", [""]],
    ["_damage", 0, [0]],
    ["_source", objNull, [objNull]],
    ["_projectile", "", [""]],
    ["_hitIndex", -1, [0]],
    ["_instigator", objNull, [objNull]],
    ["_hitPoint", "", [""]],
    ["_directHit", false, [false]]
];

if (isNull _target) exitWith {_damage};

private _currentDamage = damage _target;
if !(_hitPoint in ["", "?"]) then {
    private _hitPointDamage = _target getHitPointDamage _hitPoint;
    if (_hitPointDamage >= 0) then {
        _currentDamage = _hitPointDamage;
    };
} else {
    if !(_selection in ["", "?"]) then {
        _currentDamage = _target getHit _selection;
    };
};

private _targetProtected = _target getVariable ["BN_KOTH_safeZoneProtected", false]
    || {_target getVariable ["BN_KOTH_safeZoneVehicleProtected", false]};
if (_targetProtected) exitWith {_currentDamage};

private _sourceVehicle = if (isNull _source) then {objNull} else {vehicle _source};
private _instigatorVehicle = if (isNull _instigator) then {objNull} else {vehicle _instigator};
private _collisionSourceProtected = (!isNull _sourceVehicle && {_sourceVehicle != _source} && {
    _sourceVehicle getVariable ["BN_KOTH_safeZoneVehicleProtected", false]
}) || {
    !isNull _source && {!(_source isKindOf "Man")} && {
        _source getVariable ["BN_KOTH_safeZoneVehicleProtected", false]
    }
};

// The sole protected outgoing-damage exception is running over an intruder in that safe zone.
private _intruderCollision = (_target getVariable ["BN_KOTH_enemySafeZoneIntruder", false])
    && {_projectile isEqualTo ""}
    && {_collisionSourceProtected};
if (_intruderCollision) exitWith {_damage};

private _sourceBlocked = (!isNull _source && {
    _source getVariable ["BN_KOTH_safeZoneProtected", false]
    || {_source getVariable ["BN_KOTH_enemySafeZoneIntruder", false]}
    || {_source getVariable ["BN_KOTH_safeZoneVehicleProtected", false]}
    || {_source getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]}
}) || {
    !isNull _sourceVehicle && {
        _sourceVehicle getVariable ["BN_KOTH_safeZoneVehicleProtected", false]
        || {_sourceVehicle getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]}
    }
} || {
    !isNull _instigator && {
        _instigator getVariable ["BN_KOTH_safeZoneProtected", false]
        || {_instigator getVariable ["BN_KOTH_enemySafeZoneIntruder", false]}
    }
} || {
    !isNull _instigatorVehicle && {
        _instigatorVehicle getVariable ["BN_KOTH_safeZoneVehicleProtected", false]
        || {_instigatorVehicle getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]}
    }
};

if (_sourceBlocked) exitWith {_currentDamage};

_damage

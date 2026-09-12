/*
    File: fn_handleFired.sqf
    Author: Mongo
    Edited: tylervip
    Description: Removes projectiles fired by protected players or safe-zone-restricted enemies and vehicles.
    Execution: Local to firing entity
    Parameters:
        Fired/FiredMan event payload <ARRAY>
    Returns:
        True when the shot was blocked <BOOL>
    Public: Yes
*/

params [
    ["_shooter", objNull, [objNull]],
    ["_weapon", "", [""]],
    ["_muzzle", "", [""]],
    ["_mode", "", [""]],
    ["_ammo", "", [""]],
    ["_magazine", "", [""]],
    ["_projectile", objNull, [objNull]],
    ["_gunner", objNull, [objNull]]
];

if (isNull _shooter) exitWith {false};

private _person = if (!isNull _gunner && {_gunner isKindOf "Man"}) then {_gunner} else {_shooter};
private _platform = vehicle _person;
private _personMembership = [_person, true] call bn_koth_fnc_respawn_getSafeZoneMembership;
private _personSide = _person getVariable ["BN_KOTH_teamSide", sideUnknown];
private _personProtectedByZone = if (_personSide isEqualTo west) then {_personMembership select 0} else {_personMembership select 1};
private _personIntruderByZone = if (_personSide isEqualTo west) then {_personMembership select 1} else {_personMembership select 0};
private _protectedPerson = (_person getVariable ["BN_KOTH_safeZoneProtected", false]) || {_personProtectedByZone};
private _intruder = (_person getVariable ["BN_KOTH_enemySafeZoneIntruder", false]) || {_personIntruderByZone};
private _protectedVehicle = _shooter getVariable ["BN_KOTH_safeZoneVehicleProtected", false]
    || {_platform getVariable ["BN_KOTH_safeZoneVehicleProtected", false]};
private _restrictedVehicle = _shooter getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]
    || {_platform getVariable ["BN_KOTH_enemySafeZoneVehicleRestricted", false]};

if (!_protectedPerson && {!_intruder} && {!_protectedVehicle} && {!_restrictedVehicle}) exitWith {false};

if (!isNull _projectile) then {
    deleteVehicle _projectile;
};

if (hasInterface && {_person isEqualTo player}) then {
    private _now = diag_tickTime;
    private _nextMessageAt = uiNamespace getVariable ["BN_KOTH_safeZoneNextBlockedMessageAt", -1];

    if (_now >= _nextMessageAt) then {
        private _cooldown = missionNamespace getVariable ["BN_KOTH_safeZoneMessageCooldownSeconds", 1];
        uiNamespace setVariable ["BN_KOTH_safeZoneNextBlockedMessageAt", _now + _cooldown];

        private _message = if (_intruder || {_restrictedVehicle}) then {
            "Enemy safe zone: weapons and vehicles are disabled."
        } else {
            "Safe zone protection active: weapons are disabled."
        };
        [_message] call bn_koth_fnc_ui_notify;
    };
};

true

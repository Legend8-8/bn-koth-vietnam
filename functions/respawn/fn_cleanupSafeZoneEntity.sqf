/*
    File: fn_cleanupSafeZoneEntity.sqf
    Author: Mongo
    Description: Deletes strict safe-zone ground-loot and corpse candidates on server authority.
    Execution: Server
    Parameters:
        0: Entity to validate and clean up <OBJECT>
    Returns:
        True when the entity was deleted or marked for earliest-valid corpse deletion <BOOL>
    Public: Yes
*/

params [["_entity", objNull, [objNull]]];

if (!isServer || {isNull _entity}) exitWith {false};

private _entityType = typeOf _entity;
private _isGroundLoot = (_entity isKindOf "GroundWeaponHolder")
    || {_entity isKindOf "WeaponHolderSimulated"}
    || {_entity isKindOf "WeaponHolder"}
    || {_entityType isEqualTo "Weapon_Empty"};
private _isDeadBody = (_entity isKindOf "Man") && {!alive _entity};
if (!_isGroundLoot && {!_isDeadBody}) exitWith {false};

private _pendingSafeZoneCorpse = _isDeadBody
    && {_entity getVariable ["BN_KOTH_safeZoneCorpsePendingCleanup", false]};
private _roundState = [] call bn_koth_fnc_round_getState;
private _systemActive = _roundState in ["PREPARING", "ACTIVE"];
private _membership = [_entity, _systemActive] call bn_koth_fnc_respawn_getSafeZoneMembership;
private _insideSafeZone = (_membership select 0) || {_membership select 1};

if (!_insideSafeZone && {!_pendingSafeZoneCorpse}) exitWith {false};

if (_isDeadBody && {isPlayer _entity}) exitWith {
    _entity setVariable ["BN_KOTH_safeZoneCorpsePendingCleanup", true, true];
    true
};

deleteVehicle _entity;
true

/*
    File: fn_sweepSafeZoneGroundItems.sqf
    Author: Mongo
    Description: Performs a one-shot cleanup of existing loot holders and corpses in active safe zones.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of entities deleted or marked for cleanup <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _candidates = [];
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "GroundWeaponHolder");
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "WeaponHolderSimulated");
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "WeaponHolder");
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "Weapon_Empty");
{
    _candidates pushBackUnique _x;
} forEach allDeadMen;

private _cleanedCount = 0;
{
    if ([_x] call bn_koth_fnc_respawn_cleanupSafeZoneEntity) then {
        _cleanedCount = _cleanedCount + 1;
    };
} forEach _candidates;

if (_cleanedCount > 0) then {
    [format ["Safe-zone activation cleanup handled %1 ground-loot/corpse entity(s).", _cleanedCount], "INFO"] call bn_koth_fnc_common_log;
};

_cleanedCount

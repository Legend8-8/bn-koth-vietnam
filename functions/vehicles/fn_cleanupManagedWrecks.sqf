/*
    File: fn_cleanupManagedWrecks.sqf
    Author: tylervip
    Description: Deletes destroyed managed free-vehicle wrecks left in the world.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of deleted wrecks <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _deletedCount = 0;

{
    private _vehicle = _x;
    if (isNull _vehicle) then {
        continue;
    };

    if !(_vehicle getVariable ["BN_KOTH_isManagedFreeVehicle", false]) then {
        continue;
    };

    if (alive _vehicle) then {
        continue;
    };

    deleteVehicle _vehicle;
    _deletedCount = _deletedCount + 1;
} forEach vehicles;

if (_deletedCount > 0) then {
    [format ["Managed free-vehicle wreck cleanup complete. Deleted=%1", _deletedCount], "INFO"] call bn_koth_fnc_common_log;
};

_deletedCount

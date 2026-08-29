/*
    File: fn_cleanupBattlefieldPickups.sqf
    Author: Legend
    Description: Deletes tracked server-owned battlefield weapon holders.
    Execution: Server
    Parameters: None
    Returns: Number of live holders deleted <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _pickups = missionNamespace getVariable ["BN_KOTH_battlefieldPickupObjects", []];
if !(_pickups isEqualType []) then {_pickups = []};

private _deletedCount = 0;
{
    if (!isNull _x) then {
        deleteVehicle _x;
        _deletedCount = _deletedCount + 1;
    };
} forEach _pickups;

missionNamespace setVariable ["BN_KOTH_battlefieldPickupObjects", []];

if (_deletedCount > 0) then {
    [format ["Battlefield pickup cleanup removed %1 holder(s).", _deletedCount]] call bn_koth_fnc_common_log;
};

_deletedCount

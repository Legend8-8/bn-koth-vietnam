/*
    File: fn_cleanupManagedVehicles.sqf
    Author: tylervip
    Description: Deletes all managed free vehicles and clears managed slot runtime state.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of deleted vehicles <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _slots = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
private _slotIds = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlotIds", []];
private _deletedCount = 0;

if (_slots isEqualType createHashMap) then {
    {
        private _slotData = _slots getOrDefault [_x, createHashMap];
        if !(_slotData isEqualType createHashMap) then {
            continue;
        };

        private _vehicle = _slotData getOrDefault ["vehicle", objNull];
        if (!isNull _vehicle) then {
            deleteVehicle _vehicle;
            _deletedCount = _deletedCount + 1;
        };
    } forEach _slotIds;
};

missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
missionNamespace setVariable ["BN_KOTH_vehicleManagedSlotIds", []];

[format ["Managed free vehicle cleanup complete. Deleted=%1", _deletedCount], "INFO"] call bn_koth_fnc_common_log;
_deletedCount

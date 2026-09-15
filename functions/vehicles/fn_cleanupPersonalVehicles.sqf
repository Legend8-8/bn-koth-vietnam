/*
    File: fn_cleanupPersonalVehicles.sqf
    Author: Legend
    Description: Ends and deletes every active personal paid vehicle at a
        forced lifecycle boundary through the centralized life-end policy.
    Execution: Server
    Parameters: 0: lifecycle reason <STRING>
    Returns: Number of deleted vehicles <NUMBER>
    Public: No
*/
params [["_reason", "AO_RESET", [""]]];
if (!isServer) exitWith {0};
private _active = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
private _cleaned = 0;
{
    private _uid = _x;
    private _vehicle = (_active getOrDefault [_uid, createHashMap]) getOrDefault ["vehicle", objNull];
    private _ended = [_uid, _vehicle, _reason] call bn_koth_fnc_vehicles_endRentalLife;
    if (_ended) then {_cleaned = _cleaned + 1};
    if (!isNull _vehicle) then {
        deleteVehicle _vehicle;
    };
} forEach +(keys _active);
[format ["Personal paid-vehicle cleanup reason=%1 cleaned=%2", _reason, _cleaned], "INFO"] call bn_koth_fnc_common_log;
_cleaned

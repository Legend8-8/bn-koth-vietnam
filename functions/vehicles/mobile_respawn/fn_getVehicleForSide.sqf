/*
    File: fn_getVehicleForSide.sqf
    Author: tylervip
    Description: Returns currently tracked command vehicle for a side.
    Execution: Any
    Parameters:
        0: Side to resolve <SIDE>
    Returns:
        Vehicle object or objNull <OBJECT>
    Public: Yes
*/

params ["_side"];

private _sideToken = switch (_side) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};

if (_sideToken isEqualTo "") exitWith {objNull};

private _vehiclesBySide = missionNamespace getVariable ["BN_KOTH_commandVehicles", createHashMap];
_vehiclesBySide getOrDefault [_sideToken, objNull]

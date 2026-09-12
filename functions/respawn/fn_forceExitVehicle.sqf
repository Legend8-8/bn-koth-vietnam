/*
    File: fn_forceExitVehicle.sqf
    Author: Mongo
    Description: Ejects the local player representation from a vehicle on server authority.
    Execution: Client
    Parameters:
        0: Player unit to eject <OBJECT>
    Returns:
        True when the command was accepted <BOOL>
    Public: Yes
*/

params [["_unit", objNull, [objNull]]];

if (!hasInterface) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {false};
if (isNull _unit || {!local _unit} || {!(_unit isEqualTo player)}) exitWith {false};

if ((vehicle _unit) != _unit) then {
    moveOut _unit;
};

true

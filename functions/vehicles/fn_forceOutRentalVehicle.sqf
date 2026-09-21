/*
    File: fn_forceOutRentalVehicle.sqf
    Author: Legend
    Description: Applies a narrow server-authorized local exit from a personal
        vehicle, optionally placing the local player at a validated return point.
    Execution: Owning client
    Parameters: 0: Vehicle <OBJECT>, 1: Optional return ATL position <ARRAY>
    Returns: None
    Public: Yes
*/
params [["_vehicle",objNull,[objNull]], ["_returnPosition",[],[[]]]];
if (!hasInterface || {remoteExecutedOwner != 2}) exitWith {};
if (!isNull _vehicle && {(vehicle player) isEqualTo _vehicle}) then {moveOut player};
if ((count _returnPosition) >= 2) then {player setPosATL _returnPosition};

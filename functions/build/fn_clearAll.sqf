/*
    File: fn_clearAll.sqf
    Author: tylervip
    Description: Deletes all tracked player-built objects and clears the build tracking state.
    Execution: Server
    Parameters:
        None
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

private _tracked = missionNamespace getVariable ["BN_KOTH_buildObjects", []];
if !(_tracked isEqualType []) exitWith {};

{
    if !(isNull _x) then {
        deleteVehicle _x;
    };
} forEach _tracked;

missionNamespace setVariable ["BN_KOTH_buildObjects", []];

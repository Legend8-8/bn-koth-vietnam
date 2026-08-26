/*
    File: fn_cancelPlacement.sqf
    Author: tylervip
    Description: Cancels the local build placement preview and resets state.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _ghost = missionNamespace getVariable ["BN_KOTH_buildGhost", objNull];
if !(isNull _ghost) then {
    deleteVehicle _ghost;
};

missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementClass", ""];
missionNamespace setVariable ["BN_KOTH_buildPlacementKey", ""];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];

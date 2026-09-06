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

// Remove KeyDown EH
private _display = findDisplay 46;
private _eh = missionNamespace getVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];
if (!isNull _display && {_eh >= 0}) then {
    _display displayRemoveEventHandler ["KeyDown", _eh];
};
missionNamespace setVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];

// Delete ghost
private _ghost = missionNamespace getVariable ["BN_KOTH_buildGhost", objNull];
if !(isNull _ghost) then {
    deleteVehicle _ghost;
};

// Reset state
missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementClass", ""];
missionNamespace setVariable ["BN_KOTH_buildPlacementKey", ""];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeight", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightOffset", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementTargetPos", [0,0,0]];
missionNamespace setVariable ["BN_KOTH_buildPlacementCanPlace", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementConfirmRequested", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementCancelRequested", false];
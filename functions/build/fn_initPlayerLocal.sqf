/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Initializes client-local build state and runtime variables.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!hasInterface) exitWith {};

missionNamespace setVariable ["BN_KOTH_buildEnabled", true];
missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementTargetPos", [0,0,0]];
missionNamespace setVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];
missionNamespace setVariable ["BN_KOTH_buildInitialized", true];

["Build system initialized.", "INFO"] call bn_koth_fnc_common_log;

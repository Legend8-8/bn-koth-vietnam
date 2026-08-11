/*
    File: fn_init.sqf
    Author: tylervip
    Description: Starts server-side command vehicle tracking used by command mapboard teleport.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_commandTeleportInitialized", false]) exitWith {
    ["Command mapboard teleport already initialized.", "INFO"] call bn_koth_fnc_common_log;
};

missionNamespace setVariable ["BN_KOTH_commandTeleportInitialized", true];
missionNamespace setVariable ["BN_KOTH_commandTeleportMonitorRunning", true];
missionNamespace setVariable ["BN_KOTH_commandVehicles", createHashMap, true];
missionNamespace setVariable ["BN_KOTH_commandBoardDefs", [], true];

[] spawn bn_koth_fnc_vehicles_mobileRespawn_monitor;

["Command mapboard teleport initialized.", "INFO"] call bn_koth_fnc_common_log;

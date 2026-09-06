/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes server-session logical player-group state.
    Execution: Server
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

missionNamespace setVariable ["BN_KOTH_groups", createHashMap];
missionNamespace setVariable ["BN_KOTH_nextGroupId", 1];
missionNamespace setVariable ["BN_KOTH_groupsRevision", 0];
missionNamespace setVariable ["BN_KOTH_groupInvites", createHashMap];

["Player-group authority initialized.", "INFO"] call bn_koth_fnc_common_log;

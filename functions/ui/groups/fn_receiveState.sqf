/*
    File: fn_receiveState.sqf
    Author: Legend
    Description: Receives targeted group presentation from the server.
    Execution: Client
    Parameters:
        0: Group presentation <HASHMAP>
    Returns: None
    Public: Yes
*/

params [["_state", createHashMap, [createHashMap]]];
if (!hasInterface || {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
missionNamespace setVariable ["BN_KOTH_groupStateLocal", _state];
[] call bn_koth_fnc_groupMenu_updateLifecycle;
[] call bn_koth_fnc_groupMenu_refresh;

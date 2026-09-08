/*
    File: fn_receiveCasualtyHelpState.sqf
    Author: Legend
    Description: Receives the server-filtered same-team casualty help projection.
    Execution: Client, server-to-client RemoteExec only
    Parameters:
        0: Same-team casualty entries <ARRAY>
        1: Whether this player's current casualty request is active <BOOL>
    Returns:
        True when accepted <BOOL>
    Public: Yes
*/

params [
    ["_entries", [], [[]]],
    ["_ownRequestActive", false, [false]]
];

if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};

missionNamespace setVariable ["BN_KOTH_casualtyHelpStateLocal", _entries];
uiNamespace setVariable ["BN_KOTH_casualtyHelpOwnRequestActive", _ownRequestActive];
uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];

[] call bn_koth_fnc_playerMapMarkers_refresh;
[] call bn_koth_fnc_player3DIcons_refresh;
true

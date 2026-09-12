/*
    File: fn_reset.sqf
    Author: Legend
    Description: Clears round-only statistics and Live Leaders at the start of a new ACTIVE round.
        This is intentionally not called during ENDING/RESETTING/WAITING so the completed
        round's leaders remain visible through the post-round lobby and map vote.
    Execution: Server
    Parameters:
        None
    Returns:
        True when reset completed <BOOL>
    Public: No
*/

if (!isServer) exitWith {false};

{
    if (!isNull _x) then {
        _x setVariable ["BN_KOTH_assistContributors", nil, false];
        _x setVariable ["BN_KOTH_assistLastObservedDamage", nil, false];
    };
} forEach (missionNamespace getVariable ["BN_KOTH_combatAssistVictims", []]);
missionNamespace setVariable ["BN_KOTH_combatAssistVictims", []];
missionNamespace setVariable ["BN_KOTH_assistProcessedKills", createHashMap];
missionNamespace setVariable ["BN_KOTH_teamkillPenaltyProcessedKills", createHashMap];

missionNamespace setVariable ["BN_KOTH_roundStats", createHashMap];
missionNamespace setVariable ["BN_KOTH_roundStatsFinalized", false];
missionNamespace setVariable ["BN_KOTH_roundStatsFinalizing", false];
missionNamespace setVariable ["BN_KOTH_roundStartedAt", serverTime];
["BN_KOTH_roundResult", createHashMap] call bn_koth_fnc_common_publicState;

private _emptyLeader = {
    createHashMapFromArray [
        ["uid", ""],
        ["name", ""],
        ["value", 0]
    ]
};

private _leaders = createHashMapFromArray [
    ["mostDeadly", [] call _emptyLeader],
    ["objective", [] call _emptyLeader],
    ["bestStreak", [] call _emptyLeader]
];

["BN_KOTH_liveLeaders", _leaders] call bn_koth_fnc_common_publicState;

["Round stats reset for new ACTIVE round.", "INFO"] call bn_koth_fnc_common_log;
true

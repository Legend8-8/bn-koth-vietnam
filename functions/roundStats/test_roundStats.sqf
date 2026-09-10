/*
    File: test_roundStats.sqf
    Author: Legend
    Description: Focused server tests for round result accounting and replay-safe penalties.
    Execution: Server test console
    Returns: Failure messages; an empty array means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Round-stat tests must run on the server."]};
private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _keys = [
    "BN_KOTH_roundState", "BN_KOTH_playerRecords", "BN_KOTH_playerProgression",
    "BN_KOTH_activeParticipants", "BN_KOTH_roundStats", "BN_KOTH_liveLeaders",
    "BN_KOTH_roundResult", "BN_KOTH_teamScores", "BN_KOTH_roundStatsFinalized",
    "BN_KOTH_roundStatsFinalizing", "BN_KOTH_roundStartedAt", "BN_KOTH_xpTeamkillPenalty",
    "BN_KOTH_cashTeamkillPenalty", "BN_KOTH_teamkillPenaltyProcessedKills",
    "BN_KOTH_persistenceDirtyPlayers", "BN_KOTH_persistenceScheduledSaves",
    "BN_KOTH_streakMilestones"
];
private _backup = createHashMap;
{
    _backup set [_x, if (isNil {missionNamespace getVariable _x}) then {nil} else {missionNamespace getVariable _x}];
} forEach _keys;

missionNamespace setVariable ["BN_KOTH_roundState", "ACTIVE"];
missionNamespace setVariable ["BN_KOTH_playerRecords", createHashMapFromArray [
    ["WEST_UID", createHashMapFromArray [["ownerId", 77], ["name", "West"], ["assignedSide", west], ["deployed", true]]],
    ["ASSIST_UID", createHashMapFromArray [["ownerId", 79], ["name", "Assist"], ["assignedSide", west], ["deployed", true]]],
    ["EAST_UID", createHashMapFromArray [["ownerId", 78], ["name", "East"], ["assignedSide", east], ["deployed", true]]]
]];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMapFromArray [
    ["WEST_UID", createHashMapFromArray [["uid", "WEST_UID"], ["xp", 100], ["level", 1], ["cash", 100]]],
    ["ASSIST_UID", createHashMapFromArray [["uid", "ASSIST_UID"], ["xp", 100], ["level", 1], ["cash", 100]]],
    ["EAST_UID", createHashMapFromArray [["uid", "EAST_UID"], ["xp", 100], ["level", 1], ["cash", 100]]]
]];
missionNamespace setVariable ["BN_KOTH_activeParticipants", ["WEST_UID", "ASSIST_UID", "EAST_UID"]];
missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
missionNamespace setVariable ["BN_KOTH_streakMilestones", [2]];
[] call bn_koth_fnc_roundStats_reset;
["WEST_UID"] call bn_koth_fnc_roundStats_registerParticipant;
["ASSIST_UID"] call bn_koth_fnc_roundStats_registerParticipant;
["EAST_UID"] call bn_koth_fnc_roundStats_registerParticipant;

private _kill = createHashMapFromArray [
    ["roundActive", true], ["validPvp", true], ["suicide", false], ["teamkill", false],
    ["killerUid", "WEST_UID"], ["killerName", "West"], ["victimUid", "EAST_UID"],
    ["victimName", "East"], ["assistUids", ["ASSIST_UID"]]
];
[_kill] call bn_koth_fnc_roundStats_recordKill;
[_kill] call bn_koth_fnc_roundStats_recordKill;
private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
[((_stats get "WEST_UID") getOrDefault ["kills", 0]) isEqualTo 2, "Valid kills were not recorded."] call _check;
[((_stats get "WEST_UID") getOrDefault ["notifiedStreakMilestones", []]) isEqualTo [2], "Configured streak milestone was not recorded exactly once."] call _check;
[((_stats get "ASSIST_UID") getOrDefault ["assists", 0]) isEqualTo 2, "Assists were not recorded from canonical kill records."] call _check;

missionNamespace setVariable ["BN_KOTH_xpTeamkillPenalty", 10];
missionNamespace setVariable ["BN_KOTH_cashTeamkillPenalty", 20];
missionNamespace setVariable ["BN_KOTH_teamkillPenaltyProcessedKills", createHashMap];
private _teamkill = createHashMapFromArray [
    ["roundActive", true], ["teamkill", true], ["suicide", false],
    ["killerUid", "WEST_UID"], ["eventKey", "TEAMKILL_TEST"]
];
[_teamkill] call bn_koth_fnc_progression_xp_applyTeamkillPenalty;
private _replayAccepted = [_teamkill] call bn_koth_fnc_progression_xp_applyTeamkillPenalty;
private _westProgression = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) get "WEST_UID";
[(_westProgression getOrDefault ["xp", -1]) isEqualTo 90 && {(_westProgression getOrDefault ["cash", -1]) isEqualTo 80}, "Teamkill penalties were not clamped/applied exactly once."] call _check;
[!_replayAccepted, "Replayed teamkill event was accepted."] call _check;

missionNamespace setVariable ["BN_KOTH_teamScores", createHashMapFromArray [[west, 100], [east, 75]]];
private _recordsBeforeFinal = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
(_recordsBeforeFinal get "EAST_UID") set ["ownerId", -1];
missionNamespace setVariable ["BN_KOTH_xpRoundParticipationBonus", 0];
missionNamespace setVariable ["BN_KOTH_xpRoundWinnerBonus", 0];
missionNamespace setVariable ["BN_KOTH_cashRoundParticipationBonus", 0];
missionNamespace setVariable ["BN_KOTH_cashRoundWinnerBonus", 0];
private _finalized = [west] call bn_koth_fnc_roundStats_finalize;
private _result = missionNamespace getVariable ["BN_KOTH_roundResult", createHashMap];
[_finalized && {(_result getOrDefault ["winner", sideUnknown]) isEqualTo west} && {(count (_result getOrDefault ["players", []])) isEqualTo 3}, "Round result did not finalize the authoritative participant snapshot."] call _check;
private _eastResultIndex = (_result getOrDefault ["players", []]) findIf {(_x getOrDefault ["uid", ""]) isEqualTo "EAST_UID"};
[_eastResultIndex >= 0 && {!(((_result get "players") select _eastResultIndex) getOrDefault ["connected", true])}, "Disconnected participant was not retained and marked LEFT in the result model."] call _check;
private _resultBeforeReplay = str _result;
private _finalizeReplay = [west] call bn_koth_fnc_roundStats_finalize;
[_finalizeReplay && {(str (missionNamespace getVariable ["BN_KOTH_roundResult", createHashMap])) isEqualTo _resultBeforeReplay}, "Round result finalization was not idempotent."] call _check;

{
    private _value = _backup get _x;
    missionNamespace setVariable [_x, _value];
} forEach _keys;
_failures

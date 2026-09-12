/*
    File: test_career.sqf
    Author: Legend
    Description: Focused pure/in-memory checks for career queue and leaderboard request contracts.
    Execution: Server debug console
    Returns: Failure messages <ARRAY>
*/
private _failures = [];
private _check = {params ["_name", "_condition"]; if (!_condition) then {_failures pushBack _name}};
private _backupPending = missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap];
private _backupMax = missionNamespace getVariable ["BN_KOTH_careerLeaderboardMaxResults", 25];
private _backupSeen = missionNamespace getVariable ["BN_KOTH_careerSeenKillEvents", []];
private _backupStats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
missionNamespace setVariable ["BN_KOTH_careerPending", createHashMap];
missionNamespace setVariable ["BN_KOTH_careerLeaderboardMaxResults", 25];
missionNamespace setVariable ["BN_KOTH_careerSeenKillEvents", []];

private _uid = "CAREER_TEST";
[_uid, createHashMapFromArray [["kills", 1], ["highestKillStreak", 2]], "kill"] call bn_koth_fnc_career_mutate;
[_uid, createHashMapFromArray [["kills", 1], ["highestKillStreak", 1]], "kill"] call bn_koth_fnc_career_mutate;
private _batches = (missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap]) get _uid;
private _deltas = (_batches select 0) get "deltas";
["Valid kills merge exactly once per mutation", (_deltas get "kills") isEqualTo 2] call _check;
["Highest streak uses maximum candidate", (_deltas get "highestKillStreak") isEqualTo 2] call _check;

missionNamespace setVariable ["BN_KOTH_roundStats", createHashMapFromArray [["KILLER", createHashMapFromArray [["bestStreak", 3]]]]];
private _kill = createHashMapFromArray [["eventKey", "TEST_EVENT"], ["roundActive", true], ["victimUid", "VICTIM"], ["killerUid", "KILLER"], ["validPvp", true], ["suicide", false], ["teamkill", false]];
private _firstKill = [_kill] call bn_koth_fnc_career_recordKill;
private _duplicateKill = [_kill] call bn_koth_fnc_career_recordKill;
["Canonical kill event accepted once", _firstKill && {!_duplicateKill}] call _check;
private _afterKill = missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap];
private _victimDelta = (((_afterKill get "VICTIM") select 0) get "deltas") get "deaths";
private _killerDelta = (((_afterKill get "KILLER") select 0) get "deltas");
["Death increments exactly once", _victimDelta isEqualTo 1] call _check;
["Valid PvP kill increments once", (_killerDelta get "kills") isEqualTo 1] call _check;
["Career streak receives round-owned maximum", (_killerDelta get "highestKillStreak") isEqualTo 3] call _check;
private _invalid = createHashMapFromArray [["eventKey", "INVALID_EVENT"], ["roundActive", true], ["victimUid", "VICTIM_TWO"], ["killerUid", "KILLER"], ["validPvp", false]];
[_invalid] call bn_koth_fnc_career_recordKill;
private _invalidKillerBatches = (missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap]) get "KILLER";
["Invalid kill adds no killer delta", (count _invalidKillerBatches) isEqualTo 1] call _check;

["Metric rejects unknown IDs", !(([0,0,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success", true])] call _check;
["Period rejects unknown IDs", !(([1,9,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success", true])] call _check;
["Mode rejects SQL/query input", !(([1,0,"leaderboardTopAllTime",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success", true])] call _check;
private _bounded = [9,3,"around",999] call bn_koth_fnc_career_validateLeaderboardRequest;
["Result limit is bounded", (_bounded getOrDefault ["limit", 0]) isEqualTo 25] call _check;
["All supported periods validate", ({([1,_x,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success", false]} count [0,1,2,3]) isEqualTo 4] call _check;
["All supported modes validate", ({([1,0,_x,10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success", false]} count ["TOP","RANK","AROUND","COUNT"]) isEqualTo 4] call _check;

missionNamespace setVariable ["BN_KOTH_careerPending", _backupPending];
missionNamespace setVariable ["BN_KOTH_careerLeaderboardMaxResults", _backupMax];
missionNamespace setVariable ["BN_KOTH_careerSeenKillEvents", _backupSeen];
missionNamespace setVariable ["BN_KOTH_roundStats", _backupStats];
diag_log format ["[BN_KOTH_TEST] Career backend: %1 failure(s): %2", count _failures, _failures];
_failures

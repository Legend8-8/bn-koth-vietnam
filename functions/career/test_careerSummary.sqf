/*
    File: test_careerSummary.sqf
    Author: Legend
    Description: Focused server checks for the one-call semantic career-summary projection.
    Execution: Server debug console
    Returns: Failure messages <ARRAY>
*/
if (!isServer) exitWith {["Career summary tests must run on the server."]};
private _failures = [];
private _check = {params ["_name","_condition"]; if (!_condition) then {_failures pushBack _name}};
private _adapterBackup = missionNamespace getVariable ["bn_koth_fnc_persistence_extdbCall", {}];
private _installResult = {
    params ["_result"];
    missionNamespace setVariable ["BN_KOTH_testCareerSummaryResult", _result];
    missionNamespace setVariable ["BN_KOTH_testCareerSummaryCalls", []];
    missionNamespace setVariable ["bn_koth_fnc_persistence_extdbCall", {
        params ["_statement","_parameters"];
        private _calls = missionNamespace getVariable ["BN_KOTH_testCareerSummaryCalls", []];
        _calls pushBack [_statement,+_parameters];
        missionNamespace setVariable ["BN_KOTH_testCareerSummaryCalls", _calls];
        missionNamespace getVariable ["BN_KOTH_testCareerSummaryResult", createHashMap]
    }];
};

[createHashMapFromArray [["success",true],["rows",[[1,2,3,4,5,6,7,8]]]]] call _installResult;
private _mapped = ["UID_TEST"] call bn_koth_fnc_career_querySummary;
private _calls = missionNamespace getVariable ["BN_KOTH_testCareerSummaryCalls", []];
private _stats = _mapped getOrDefault ["stats",createHashMap];
["Summary makes exactly one adapter call", (count _calls) isEqualTo 1] call _check;
["Summary uses exact semantic statement and UID parameter", (count _calls) isEqualTo 1 && {(_calls select 0) isEqualTo ["loadCareerSummary",["UID_TEST"]]}] call _check;
["Eight columns map in contract order", (_stats getOrDefault ["kills",-1]) isEqualTo 1 && {(_stats getOrDefault ["deaths",-1]) isEqualTo 2} && {(_stats getOrDefault ["wins",-1]) isEqualTo 3} && {(_stats getOrDefault ["roundsPlayed",-1]) isEqualTo 4} && {(_stats getOrDefault ["objectiveContribution",-1]) isEqualTo 5} && {(_stats getOrDefault ["highestKillStreak",-1]) isEqualTo 6} && {(_stats getOrDefault ["totalXpEarned",-1]) isEqualTo 7} && {(_stats getOrDefault ["timePlayedSeconds",-1]) isEqualTo 8}] call _check;

[createHashMapFromArray [["success",true],["rows",[[0,0,0,0,0,0,0,0]]]]] call _installResult;
private _zero = ["UID_ZERO"] call bn_koth_fnc_career_querySummary;
["All-zero row is valid career data", (_zero getOrDefault ["success",false]) && {((_zero get "stats") getOrDefault ["kills",-1]) isEqualTo 0} && {(count (_zero get "stats")) isEqualTo 8}] call _check;

[createHashMapFromArray [["success",true],["rows",[]]]] call _installResult;
private _new = ["UID_NEW"] call bn_koth_fnc_career_querySummary;
private _newStats = _new getOrDefault ["stats",createHashMap];
["No row is a valid new-player zero summary", (_new getOrDefault ["success",false]) && {(_new getOrDefault ["code",""]) isEqualTo "CAREER_NEW"} && {(count _newStats) isEqualTo 8} && {({(_newStats getOrDefault [_x,-1]) isEqualTo 0} count ["kills","deaths","wins","roundsPlayed","objectiveContribution","highestKillStreak","totalXpEarned","timePlayedSeconds"]) isEqualTo 8}] call _check;

[createHashMapFromArray [["success",false],["code","BACKEND_UNAVAILABLE"],["rows",[]]]] call _installResult;
private _failed = ["UID_FAIL"] call bn_koth_fnc_career_querySummary;
["DB failure stays unavailable without fabricated stats", !(_failed getOrDefault ["success",true]) && {(count (_failed getOrDefault ["stats",createHashMap])) isEqualTo 0}] call _check;

missionNamespace setVariable ["bn_koth_fnc_persistence_extdbCall", _adapterBackup];
missionNamespace setVariable ["BN_KOTH_testCareerSummaryResult", nil];
missionNamespace setVariable ["BN_KOTH_testCareerSummaryCalls", nil];
diag_log format ["[BN_KOTH_TEST] Career summary: %1 failure(s): %2",count _failures,_failures];
_failures

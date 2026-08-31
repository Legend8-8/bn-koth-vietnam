/*
    File: fn_validateLeaderboardRequest.sqf
    Author: Legend
    Description: Validates and normalizes a semantic bounded leaderboard request without exposing SQL identifiers.
    Execution: Server
    Public: No
*/
params [["_metric", 0, [0]], ["_period", 0, [0]], ["_mode", "", [""]], ["_limit", 10, [0]]];
private _max = missionNamespace getVariable ["BN_KOTH_careerLeaderboardMaxResults", 25];
if !(_metric in [1,2,3,4,5,6,7,8,9]) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_METRIC"]]};
if !(_period in [0,1,2,3]) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_PERIOD"]]};
private _normalizedMode = toUpper _mode;
if !(_normalizedMode in ["TOP", "RANK", "AROUND", "COUNT"]) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_MODE"]]};
createHashMapFromArray [["success", true], ["code", "VALID"], ["metric", _metric], ["period", _period], ["mode", _normalizedMode], ["limit", (floor _limit) max 1 min _max]]

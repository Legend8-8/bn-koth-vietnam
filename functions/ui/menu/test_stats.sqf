/*
    File: test_stats.sqf
    Author: Legend
    Description: Focused in-engine checks for Stats formatting, selection defaults, and semantic request validation.
    Execution: Client/server debug console
    Returns: Failure messages <ARRAY>
*/
private _failures = [];
private _check = {params ["_name", "_condition"]; if (!_condition) then {_failures pushBack _name}};
private _backupMax = missionNamespace getVariable ["BN_KOTH_careerLeaderboardMaxResults", 25];
missionNamespace setVariable ["BN_KOTH_careerLeaderboardMaxResults", 25];

["All metric IDs validate", ({([_x,0,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success",false]} count [1,2,3,4,5,6,7,8,9]) isEqualTo 9] call _check;
["Invalid metric is rejected", !(([10,0,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success",true])] call _check;
["All period IDs validate", ({([1,_x,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success",false]} count [0,1,2,3]) isEqualTo 4] call _check;
["Invalid period is rejected", !(([1,4,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success",true])] call _check;
["TOP mode maps directly", (([1,0,"TOP",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["mode",""]) isEqualTo "TOP"] call _check;
["MY POSITION server mode is AROUND", (([1,0,"AROUND",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["mode",""]) isEqualTo "AROUND"] call _check;
["SQL/query names are rejected", !(([1,0,"leaderboardTopAllTime",10] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["success",true])] call _check;
["Limit is bounded", (([1,0,"TOP",999] call bn_koth_fnc_career_validateLeaderboardRequest) getOrDefault ["limit",0]) isEqualTo 25] call _check;
["K/D zero deaths is safe", ([12,9,0] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "12.00"] call _check;
["K/D formats to two decimals", ([7,9,4] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "1.75"] call _check;
["Zero seconds formats as minutes", ([0,8] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "0m"] call _check;
["Under one hour formats as minutes", ([2820,8] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "47m"] call _check;
["Multi-hour duration formats consistently", ([11520,8] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "3h 12m"] call _check;
[">100 hour duration remains readable", ([461040,8] call bn_koth_fnc_menu_formatCareerValue) isEqualTo "128h 04m"] call _check;
private _zero = createHashMapFromArray [["kills",0],["deaths",0]];
["Legitimate zero is data, not unavailable", (_zero getOrDefault ["kills",-1]) isEqualTo 0 && {(count _zero) > 0}] call _check;
["Unavailable is structurally distinct", (count createHashMap) isEqualTo 0] call _check;

private _requestSource = loadFile "functions\career\fn_requestStats.sqf";
private _clientRequestSource = loadFile "functions\ui\menu\fn_menu_requestStats.sqf";
private _receiverSource = loadFile "functions\ui\menu\fn_menu_receiveStats.sqf";
private _refreshSource = loadFile "functions\ui\menu\fn_menu_refresh.sqf";
private _statsRefreshSource = loadFile "functions\ui\menu\fn_menu_refreshStats.sqf";
["Stats read never forces a career flush", (_requestSource find "career_flushPlayer") < 0] call _check;
["Stats read has no summary leaderboard fan-out", (_requestSource find "career_querySummary") < 0] call _check;
private _leaderCall = _requestSource find "call bn_koth_fnc_career_queryLeaderboard";
private _afterLeaderCall = if (_leaderCall < 0) then {""} else {_requestSource select [_leaderCall + 1]};
["Stats request contains exactly one leaderboard call", _leaderCall >= 0 && {(_afterLeaderCall find "call bn_koth_fnc_career_queryLeaderboard") < 0}] call _check;
["Request ID is echoed by the server", (_requestSource find "[""requestId"", _requestId]") >= 0] call _check;
["Receiver rejects non-server remote owners", (_receiverSource find "remoteExecutedOwner isNotEqualTo 2") >= 0] call _check;
["Receiver requires latest request ID", (_receiverSource find "BN_KOTH_menuStatsLatestRequestId") >= 0] call _check;
["Dead pending-key state was removed", (_clientRequestSource find "BN_KOTH_menuStatsPendingKey") < 0] call _check;
["Deferred request is lifecycle guarded", (_clientRequestSource find "BN_KOTH_menuStatsLifecycle") >= 0 && {(_refreshSource find "BN_KOTH_menuStatsLifecycle") >= 0}] call _check;
["Stats runtime view lists use named IDCs", (_refreshSource find "8690,8691") < 0 && {(_statsRefreshSource find "8700,8701") < 0}] call _check;
["Unavailable career tiles use dash values", (_statsRefreshSource find "private _value = ""—""") >= 0] call _check;
["Metric handlers remain installed without career data", (_statsRefreshSource find "ctrlRemoveAllEventHandlers ""MouseButtonClick""") >= 0 && {(_statsRefreshSource find "BN_KOTH_menuStatsMetric") >= 0}] call _check;
["Career unavailable notice remains separate", (_statsRefreshSource find "CAREER DATA UNAVAILABLE") >= 0 && {(_statsRefreshSource find "ctrlShow (!_careerAvailable)") >= 0}] call _check;

if (hasInterface) then {
    private _savedMetric = uiNamespace getVariable ["BN_KOTH_menuStatsMetric", 1];
    private _savedPeriod = uiNamespace getVariable ["BN_KOTH_menuStatsPeriod", 0];
    private _savedMode = uiNamespace getVariable ["BN_KOTH_menuStatsMode", "TOP"];
    private _savedLatest = uiNamespace getVariable ["BN_KOTH_menuStatsLatestRequestId", -1];
    private _savedLoading = uiNamespace getVariable ["BN_KOTH_menuStatsLoading", false];
    private _savedResponse = uiNamespace getVariable ["BN_KOTH_menuStatsResponse", createHashMap];
    uiNamespace setVariable ["BN_KOTH_menuStatsMetric", 1];
    uiNamespace setVariable ["BN_KOTH_menuStatsPeriod", 0];
    uiNamespace setVariable ["BN_KOTH_menuStatsMode", "TOP"];
    uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", 2];
    uiNamespace setVariable ["BN_KOTH_menuStatsLoading", true];
    uiNamespace setVariable ["BN_KOTH_menuStatsResponse", createHashMapFromArray [["marker","CURRENT"]]];
    [createHashMapFromArray [["requestId",1],["metric",1],["period",0],["mode","TOP"],["success",true],["rows",[]]]] call bn_koth_fnc_menu_receiveStats;
    ["Stale response cannot clear current loading", uiNamespace getVariable ["BN_KOTH_menuStatsLoading", false]] call _check;
    ["Stale response cannot replace latest response", ((uiNamespace getVariable ["BN_KOTH_menuStatsResponse",createHashMap]) getOrDefault ["marker",""]) isEqualTo "CURRENT"] call _check;
    uiNamespace setVariable ["BN_KOTH_menuStatsMetric", _savedMetric];
    uiNamespace setVariable ["BN_KOTH_menuStatsPeriod", _savedPeriod];
    uiNamespace setVariable ["BN_KOTH_menuStatsMode", _savedMode];
    uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", _savedLatest];
    uiNamespace setVariable ["BN_KOTH_menuStatsLoading", _savedLoading];
    uiNamespace setVariable ["BN_KOTH_menuStatsResponse", _savedResponse];
};

missionNamespace setVariable ["BN_KOTH_careerLeaderboardMaxResults", _backupMax];
diag_log format ["[BN_KOTH_TEST] Stats UI contract: %1 failure(s): %2", count _failures, _failures];
_failures

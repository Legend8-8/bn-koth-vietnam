/*
    File: fn_queryLeaderboard.sqf
    Author: Legend
    Description: Executes one validated server-side semantic leaderboard query.
    Execution: Server
    Parameters: metric ID, period ID (0 all-time), mode, self UID, bounded limit
    Returns: Structured query result <HASHMAP>
    Public: Yes
*/
params [["_metric", 0, [0]], ["_period", 0, [0]], ["_mode", "", [""]], ["_selfUid", "", [""]], ["_limit", 10, [0]]];
if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
private _valid = [_metric, _period, _mode, _limit] call bn_koth_fnc_career_validateLeaderboardRequest;
if !(_valid getOrDefault ["success", false]) exitWith {_valid};
private _normalizedMode = _valid get "mode";
if (_normalizedMode in ["RANK", "AROUND"] && {_selfUid isEqualTo ""}) exitWith {createHashMapFromArray [["success", false], ["code", "SELF_UID_REQUIRED"]]};
private _suffix = switch (_normalizedMode) do {case "TOP": {"Top"}; case "RANK": {"Rank"}; case "AROUND": {"Around"}; default {"Count"};};
private _statement = if (_period == 0) then {format ["leaderboard%1AllTime", _suffix]} else {format ["leaderboard%1Window", _suffix]};
private _parameters = [];
if (_period > 0) then {_parameters pushBack _period};
_parameters pushBack _metric;
if (_normalizedMode in ["RANK", "AROUND"]) then {_parameters pushBack _selfUid};
if (_normalizedMode in ["TOP", "AROUND"]) then {_parameters pushBack (_valid get "limit")};
private _result = [_statement, _parameters] call bn_koth_fnc_persistence_extdbCall;
if !(_result getOrDefault ["success", false]) exitWith {createHashMapFromArray [["success", false], ["code", _result getOrDefault ["code", "LEADERBOARD_UNAVAILABLE"]], ["metric", _metric], ["period", _period], ["mode", _normalizedMode]]};
createHashMapFromArray [["success", true], ["code", "LEADERBOARD_OK"], ["metric", _metric], ["period", _period], ["mode", _normalizedMode], ["rows", _result getOrDefault ["rows", []]]]

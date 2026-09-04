/*
    File: fn_requestStats.sqf
    Author: Legend
    Description: Handles a narrow throttled client request for bounded leaderboard presentation data.
    Execution: Client request / Server authority
    Parameters: metric ID, period ID, UI mode, bounded limit, opaque request ID
    Returns: None
    Public: Yes (RemoteExec endpoint)
*/
params [["_metric", 1, [0]], ["_period", 0, [0]], ["_uiMode", "TOP", [""]], ["_limit", 10, [0]], ["_requestId", -1, [0]]];

if (hasInterface && {!isServer}) exitWith {[_metric, _period, _uiMode, _limit, _requestId] remoteExecCall ["bn_koth_fnc_career_requestStats", 2]};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {[_metric, _period, _uiMode, _limit, _requestId] remoteExecCall ["bn_koth_fnc_career_requestStats", 2]};
if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {};
private _target = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _target) exitWith {};
private _uid = getPlayerUID _target;
if (_uid isEqualTo "") exitWith {};
if !(finite _requestId && {_requestId isEqualTo floor _requestId} && {_requestId >= 0} && {_requestId <= 1000000}) exitWith {};

private _mode = toUpper _uiMode;
if !(_mode in ["TOP", "MY_POSITION"]) exitWith {
    [createHashMapFromArray [["success", false], ["code", "INVALID_REQUEST"], ["requestId", _requestId], ["metric", _metric], ["period", _period], ["mode", _mode], ["rows", []]]] remoteExecCall ["bn_koth_fnc_menu_receiveStats", _ownerId];
};
private _queryMode = if (_mode isEqualTo "MY_POSITION") then {"AROUND"} else {"TOP"};
private _valid = [_metric, _period, _queryMode, _limit] call bn_koth_fnc_career_validateLeaderboardRequest;
private _reply = {params ["_payload"]; [_payload] remoteExecCall ["bn_koth_fnc_menu_receiveStats", _ownerId]};
if !(_valid getOrDefault ["success", false]) exitWith {
    [createHashMapFromArray [["success", false], ["code", "INVALID_REQUEST"], ["requestId", _requestId], ["metric", _metric], ["period", _period], ["mode", _mode], ["rows", []]]] call _reply;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {};
if (isNil {_records get _uid}) exitWith {};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {};
private _now = serverTime;
if ((_now - (_record getOrDefault ["lastCareerStatsRequestAt", -999])) < 0.75) exitWith {
    [createHashMapFromArray [["success", false], ["code", "THROTTLED"], ["requestId", _requestId], ["metric", _metric], ["period", _period], ["mode", _mode], ["rows", []]]] call _reply;
};
_record set ["lastCareerStatsRequestAt", _now];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

// Summary failure is independent of the leaderboard: either half may remain
// available without fabricating or suppressing the other half's data.
private _summary = [_uid] call bn_koth_fnc_career_querySummary;

// AROUND's contract treats limit as a radius. Keep the returned neighbourhood
// within the same ten-row UI bound while retaining the local row.
private _queryLimit = if (_mode isEqualTo "MY_POSITION") then {floor (((_valid get "limit") - 1) / 2) max 1} else {_valid get "limit"};
private _leader = [_valid get "metric", _valid get "period", _queryMode, _uid, _queryLimit] call bn_koth_fnc_career_queryLeaderboard;
private _safeRows = [];
if (_leader getOrDefault ["success", false]) then {
    {
        if (_x isEqualType [] && {(count _x) >= 4} && {(count _safeRows) < (_valid get "limit")}) then {
            private _rank = _x select 0;
            private _rawName = _x select 2;
            private _value = _x select 3;
            private _rowUid = _x select 1;
            if (_rank isEqualType 0 && {_rawName isEqualType ""} && {_value isEqualType 0} && {finite _value}) then {
                private _name = ((_rawName splitString "<>") joinString "");
                if ((count _name) > 32) then {_name = _name select [0, 32]};
                _safeRows pushBack [_rank max 0, _name, _value max 0, _rowUid isEqualTo _uid];
            };
        };
    } forEach (_leader getOrDefault ["rows", []]);
};

private _localRank = -1;
private _rankedCount = -1;
if (_mode isEqualTo "MY_POSITION") then {
    private _localIndex = _safeRows findIf {_x select 3};
    if (_localIndex >= 0) then {_localRank = (_safeRows select _localIndex) select 0};
};

[createHashMapFromArray [
    ["success", _leader getOrDefault ["success", false]],
    ["code", if (_leader getOrDefault ["success", false]) then {"OK"} else {"UNAVAILABLE"}],
    ["requestId", _requestId],
    ["metric", _valid get "metric"], ["period", _valid get "period"], ["mode", _mode],
    ["rows", _safeRows], ["localRank", _localRank], ["rankedCount", _rankedCount],
    ["careerAvailable", _summary getOrDefault ["success", false]],
    ["career", _summary getOrDefault ["stats", createHashMap]]
]] call _reply;

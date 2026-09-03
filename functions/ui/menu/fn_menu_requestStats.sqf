/*
    File: fn_menu_requestStats.sqf
    Author: Legend
    Description: Requests one selected Stats leaderboard, using a short client cache and loading state.
    Execution: Client
    Public: No
*/
if (!hasInterface) exitWith {};
private _metric = uiNamespace getVariable ["BN_KOTH_menuStatsMetric", 1];
private _period = uiNamespace getVariable ["BN_KOTH_menuStatsPeriod", 0];
private _mode = uiNamespace getVariable ["BN_KOTH_menuStatsMode", "TOP"];
private _key = format ["%1:%2:%3", _metric, _period, _mode];
private _cache = uiNamespace getVariable ["BN_KOTH_menuStatsCache", createHashMap];
private _entry = _cache getOrDefault [_key, []];
if (_entry isEqualType [] && {(count _entry) isEqualTo 2} && {(diag_tickTime - (_entry select 0)) < 15}) exitWith {
    uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", -1];
    uiNamespace setVariable ["BN_KOTH_menuStatsLoading", false];
    uiNamespace setVariable ["BN_KOTH_menuStatsResponse", _entry select 1];
    [uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull]] call bn_koth_fnc_menu_refreshStats;
};
private _lastSent = uiNamespace getVariable ["BN_KOTH_menuStatsLastRequest", -100];
if ((diag_tickTime - _lastSent) < 0.8) exitWith {
    if !(uiNamespace getVariable ["BN_KOTH_menuStatsDeferred", false]) then {
        uiNamespace setVariable ["BN_KOTH_menuStatsDeferred", true];
        private _lifecycle = uiNamespace getVariable ["BN_KOTH_menuStatsLifecycle", 0];
        private _worker = [_lifecycle] spawn {
            params ["_expectedLifecycle"];
            sleep 0.85;
            if ((uiNamespace getVariable ["BN_KOTH_menuStatsLifecycle", -1]) isEqualTo _expectedLifecycle) then {
                uiNamespace setVariable ["BN_KOTH_menuStatsDeferred", false];
                uiNamespace setVariable ["BN_KOTH_menuStatsDeferredScript", scriptNull];
                if ((uiNamespace getVariable ["BN_KOTH_menuActivePage", ""]) isEqualTo "STATS") then {[] call bn_koth_fnc_menu_requestStats};
            };
        };
        uiNamespace setVariable ["BN_KOTH_menuStatsDeferredScript", _worker];
    };
};
private _requestId = ((uiNamespace getVariable ["BN_KOTH_menuStatsRequestSequence", -1]) + 1) mod 1000001;
uiNamespace setVariable ["BN_KOTH_menuStatsRequestSequence", _requestId];
uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", _requestId];
uiNamespace setVariable ["BN_KOTH_menuStatsLoading", true];
uiNamespace setVariable ["BN_KOTH_menuStatsResponse", createHashMap];
uiNamespace setVariable ["BN_KOTH_menuStatsLastRequest", diag_tickTime];
[uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull]] call bn_koth_fnc_menu_refreshStats;
[_metric, _period, _mode, 10, _requestId] call bn_koth_fnc_career_requestStats;

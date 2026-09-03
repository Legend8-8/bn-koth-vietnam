/*
    File: fn_menu_receiveStats.sqf
    Author: Legend
    Description: Receives a server-authored bounded Stats response for the local menu.
    Execution: Client
    Public: Yes (RemoteExec endpoint)
*/
params [["_payload", createHashMap, [createHashMap]]];
if (!hasInterface || {(count _payload) == 0}) exitWith {};
// Dedicated responses arrive with owner 2. Direct local calls are permitted on
// a hosted server; any remote client owner is rejected on every client type.
if (remoteExecutedOwner > 0 && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
private _metric = _payload getOrDefault ["metric", -1];
private _period = _payload getOrDefault ["period", -1];
private _mode = _payload getOrDefault ["mode", ""];
private _requestId = _payload getOrDefault ["requestId", -1];
if !(_metric in [1,2,3,4,5,6,7,8,9] && {_period in [0,1,2,3]} && {_mode in ["TOP","MY_POSITION"]}) exitWith {};
if !(_requestId isEqualTo (uiNamespace getVariable ["BN_KOTH_menuStatsLatestRequestId", -2])) exitWith {};
if !(_metric isEqualTo (uiNamespace getVariable ["BN_KOTH_menuStatsMetric", 1]) && {_period isEqualTo (uiNamespace getVariable ["BN_KOTH_menuStatsPeriod", 0])} && {_mode isEqualTo (uiNamespace getVariable ["BN_KOTH_menuStatsMode", "TOP"])}) exitWith {};
uiNamespace setVariable ["BN_KOTH_menuStatsLoading", false];
uiNamespace setVariable ["BN_KOTH_menuStatsResponse", _payload];
if (_payload getOrDefault ["success", false]) then {
    private _cache = uiNamespace getVariable ["BN_KOTH_menuStatsCache", createHashMap];
    _cache set [format ["%1:%2:%3", _metric, _period, _mode], [diag_tickTime, _payload]];
    uiNamespace setVariable ["BN_KOTH_menuStatsCache", _cache];
};
if ((uiNamespace getVariable ["BN_KOTH_menuActivePage", ""]) isEqualTo "STATS") then {
    [uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull]] call bn_koth_fnc_menu_refreshStats;
};

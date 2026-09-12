/*
    File: fn_menu_close.sqf
    Author: Legend
    Description: Closes the deployed menu on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"

if (!hasInterface) exitWith {};

disableSerialization;

private _statsDeferredScript = uiNamespace getVariable ["BN_KOTH_menuStatsDeferredScript", scriptNull];
if !(scriptDone _statsDeferredScript) then {terminate _statsDeferredScript};

uiNamespace setVariable ["BN_KOTH_menuStatsMetric", 1];
uiNamespace setVariable ["BN_KOTH_menuStatsPeriod", 0];
uiNamespace setVariable ["BN_KOTH_menuStatsMode", "TOP"];
uiNamespace setVariable ["BN_KOTH_menuStatsResponse", createHashMap];
uiNamespace setVariable ["BN_KOTH_menuStatsLoading", false];
uiNamespace setVariable ["BN_KOTH_menuStatsCache", createHashMap];
uiNamespace setVariable ["BN_KOTH_menuStatsDeferred", false];
uiNamespace setVariable ["BN_KOTH_menuStatsDeferredScript", scriptNull];
uiNamespace setVariable ["BN_KOTH_menuStatsLastRequest", -100];
uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", -1];
uiNamespace setVariable ["BN_KOTH_menuStatsLifecycle", (uiNamespace getVariable ["BN_KOTH_menuStatsLifecycle", 0]) + 1];

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};

if (!isNull _display) then {
    _display closeDisplay 2;
} else {
    [] call bn_koth_fnc_menu_stopPlayerPreview;
};

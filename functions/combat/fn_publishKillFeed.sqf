/*
    File: fn_publishKillFeed.sqf
    Description: Consumes a canonical kill record from combat_handleKill and
        decides what the kill feed shows, and to whom, based on
        CfgBnKothCombat. Does not decide whether/what the kill was -
        combat_handleKill already established that. Clients receive
        display-only data and never re-derive anything.
    Execution: Server
    Parameters:
        0: Canonical kill record from bn_koth_fnc_combat_handleKill <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params ["_kill"];

if (!isServer) exitWith {};
if (_kill isEqualTo createHashMap) exitWith {};

private _combatCfg = missionConfigFile >> "CfgBnKothCombat";
private _mode = if (isText (_combatCfg >> "mode")) then {getText (_combatCfg >> "mode")} else {"killfeed"};
private _method = _kill get "method";

private _categoryEnabled = switch (_method) do {
    case "direct":    {!isNumber (_combatCfg >> "showDirectKills")    || {getNumber (_combatCfg >> "showDirectKills") == 1}};
    case "vehicle":   {!isNumber (_combatCfg >> "showVehicleKills")   || {getNumber (_combatCfg >> "showVehicleKills") == 1}};
    case "cas":       {!isNumber (_combatCfg >> "showCasKills")       || {getNumber (_combatCfg >> "showCasKills") == 1}};
    case "artillery": {!isNumber (_combatCfg >> "showArtilleryKills") || {getNumber (_combatCfg >> "showArtilleryKills") == 1}};
    default           {true}; // "other" - suicide / environment, always shown
};

if (!_categoryEnabled) exitWith {
    [format ["combat_publishKillFeed suppressed: method=%1 disabled by CfgBnKothCombat", _method], "INFO"] call bn_koth_fnc_common_log;
};

if (_mode isEqualTo "deathfeed") exitWith {
    // Hardcore: only the victim's own team is told, and only that a
    // teammate is down - no killer identity, weapon, or range is ever sent.
    private _victimSide = _kill get "victimSide";
    private _targets = (allPlayers select {side _x isEqualTo _victimSide}) apply {owner _x};

    if (count _targets > 0) then {
        [
            "down",
            "",
            sideUnknown,
            "",
            (_kill get "victimName"),
            _victimSide,
            ""
        ] remoteExecCall ["bn_koth_fnc_ui_addKillFeedEntry", _targets];
    };
};

// killfeed mode: full detail, broadcast to everyone
private _type = if (_kill get "suicide") then {
    "suicide"
} else {
    if ((_kill get "killerUid") isEqualTo "") then {"environment"} else {"kill"}
};

[
    _type,
    (_kill get "killerName"),
    (_kill get "killerSide"),
    (_kill get "weapon"),
    (_kill get "victimName"),
    (_kill get "victimSide"),
    (_kill get "distanceText")
] remoteExecCall ["bn_koth_fnc_ui_addKillFeedEntry", 0];

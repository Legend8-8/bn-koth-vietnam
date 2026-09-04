/*
    File: fn_publishKillFeed.sqf
    Author: SpadeMe
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

private _sideToken = {
    switch (_this) do {
        case west:       {"WEST"};
        case east:       {"EAST"};
        case resistance: {"GUER"};
        case civilian:   {"CIV"};
        default          {"UNKNOWN"};
    };
};

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
    // Hardcore: only players authoritatively assigned to the victim's team
    // are told. Do not derive KOTH team membership from the represented
    // unit's engine side because lobby representations may be CIV.
    private _victimSide = _kill get "victimSide";
    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    private _targets = [];

    if (_records isEqualType createHashMap) then {
        {
            private _record = _records get _x;

            if (_record isEqualType createHashMap) then {
                private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];

                if (_assignedSide isEqualTo _victimSide) then {
                    private _ownerId = _record getOrDefault ["ownerId", -1];

                    if (_ownerId > 0) then {
                        _targets pushBackUnique _ownerId;
                    };
                };
            };
        } forEach (keys _records);
    };

    if (count _targets > 0) then {
        [
            "down",
            "",
            "UNKNOWN",
            "",
            (_kill get "victimName"),
            (_victimSide call _sideToken),
            "",
            (_kill getOrDefault ["weaponPicture", ""])
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
    ((_kill get "killerSide") call _sideToken),
    (_kill get "weapon"),
    (_kill get "victimName"),
    ((_kill get "victimSide") call _sideToken),
    (_kill get "distanceText"),
    (_kill getOrDefault ["weaponPicture", ""])
] remoteExecCall ["bn_koth_fnc_ui_addKillFeedEntry", 0];

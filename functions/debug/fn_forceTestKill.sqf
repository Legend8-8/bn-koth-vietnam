/*
    ============================================================
    DEBUG-ONLY - REMOVE BEFORE RELEASE
    ============================================================
    File: fn_forceTestKill.sqf
    Description: Fires a synthetic kill straight into
        combat_publishKillFeed, bypassing EntityKilled and
        combat_handleKill entirely. Lets you test the kill feed /
        death feed UI and the CfgBnKothCombat gate solo, without a
        second player or a real death.

        This does NOT touch BN_KOTH_playerRecords, does not affect
        scoring/respawn/zone state, and is not called from anywhere
        else in the mission - it only runs when you call it yourself
        from the debug console.

        TO REMOVE:
          1. Delete this file (functions/debug/fn_forceTestKill.sqf)
          2. Delete the "debug" class block it added to
             config/CfgFunctions.hpp
          3. grep the repo for "DEBUG-ONLY" to confirm nothing's left

    Execution: Server (run from the server's debug console, or a
        listen-server host's console)
    Parameters:
        0: STRING - scenario <OPTIONAL, default "kill">
           "kill"       - WEST kills EAST, normal detail
           "teamkill"   - WEST kills WEST
           "suicide"    - unit dies by own hand
           "environment"- no identifiable killer
    Returns:
        None
    Public: No - debug only, not part of CfgFunctions' normal surface
    ============================================================
*/

params [["_scenario", "kill", [""]]];

if (!isServer) exitWith {
    ["DEBUG forceTestKill: must be run on the server", "WARN"] call bn_koth_fnc_common_log;
};

private _kill = createHashMap;
_kill set ["victimUid", "DEBUG_VICTIM"];
_kill set ["victimName", "TestVictim"];
_kill set ["victimSide", east];
_kill set ["killerUid", "DEBUG_KILLER"];
_kill set ["killerName", "TestKiller"];
_kill set ["killerSide", west];
_kill set ["suicide", false];
_kill set ["teamkill", false];
_kill set ["validPvp", true];
_kill set ["method", "direct"];
_kill set ["weapon", "Test Rifle"];
_kill set ["distanceText", "~140m"];
_kill set ["roundActive", true];

switch (toLower _scenario) do {
    case "teamkill": {
        _kill set ["victimSide", west];
        _kill set ["teamkill", true];
        _kill set ["validPvp", false];
    };
    case "suicide": {
        _kill set ["suicide", true];
        _kill set ["killerName", "TestVictim"];
        _kill set ["killerSide", east];
        _kill set ["victimSide", east];
        _kill set ["distanceText", ""];
        _kill set ["validPvp", false];
    };
    case "environment": {
        _kill set ["killerUid", ""];
        _kill set ["killerName", ""];
        _kill set ["killerSide", sideUnknown];
        _kill set ["method", "other"];
        _kill set ["distanceText", ""];
        _kill set ["validPvp", false];
    };
};

[format ["DEBUG forceTestKill firing scenario=%1", _scenario], "INFO"] call bn_koth_fnc_common_log;

[_kill] call bn_koth_fnc_combat_publishKillFeed;

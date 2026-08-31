/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes bounded server career queues, playtime sampling, flushing and low-frequency pruning.
    Execution: Server
    Public: Yes
*/
if (!isServer) exitWith {};
private _cfg = missionConfigFile >> "CfgBnKothCareer";
private _sample = if (isNumber (_cfg >> "playtimeSampleSeconds")) then {getNumber (_cfg >> "playtimeSampleSeconds")} else {60};
private _flush = if (isNumber (_cfg >> "flushIntervalSeconds")) then {getNumber (_cfg >> "flushIntervalSeconds")} else {300};
private _prune = if (isNumber (_cfg >> "pruneIntervalSeconds")) then {getNumber (_cfg >> "pruneIntervalSeconds")} else {86400};
private _days = if (isNumber (_cfg >> "hourlyRetentionDays")) then {getNumber (_cfg >> "hourlyRetentionDays")} else {32};
private _max = if (isNumber (_cfg >> "leaderboardMaxResults")) then {getNumber (_cfg >> "leaderboardMaxResults")} else {25};
missionNamespace setVariable ["BN_KOTH_careerPending", createHashMap];
missionNamespace setVariable ["BN_KOTH_careerIdentityPending", createHashMap];
missionNamespace setVariable ["BN_KOTH_careerSessions", createHashMap];
missionNamespace setVariable ["BN_KOTH_careerSeenKillEvents", []];
missionNamespace setVariable ["BN_KOTH_careerLeaderboardMaxResults", floor (_max max 1)];
if !(missionNamespace getVariable ["BN_KOTH_careerLoopRunning", false]) then {
    missionNamespace setVariable ["BN_KOTH_careerLoopRunning", true];
    [_sample max 10, _flush max 30, _prune max 3600, floor (_days max 1)] spawn {
        params ["_sample", "_flush", "_prune", "_days"];
        private _lastFlush = serverTime;
        private _lastPrune = -_prune;
        while {missionNamespace getVariable ["BN_KOTH_careerLoopRunning", false]} do {
            sleep _sample;
            {[_x] call bn_koth_fnc_career_accumulatePlaytime} forEach +(keys (missionNamespace getVariable ["BN_KOTH_careerSessions", createHashMap]));
            if ((serverTime - _lastFlush) >= _flush) then { ["interval"] call bn_koth_fnc_career_flushAll; _lastFlush = serverTime; };
            if ((serverTime - _lastPrune) >= _prune && {missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]}) then {
                private _result = ["pruneCareerHourly", [_days]] call bn_koth_fnc_persistence_extdbCall;
                if !(_result getOrDefault ["success", false]) then {[format ["Career hourly prune failed code=%1", _result getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log};
                _lastPrune = serverTime;
            };
        };
    };
};
if !(missionNamespace getVariable ["BN_KOTH_careerShutdownHandlerInstalled", false]) then {
    addMissionEventHandler ["MPEnded", {
        {[_x] call bn_koth_fnc_career_accumulatePlaytime} forEach +(keys (missionNamespace getVariable ["BN_KOTH_careerSessions", createHashMap]));
        ["mission_end"] call bn_koth_fnc_career_flushAll;
    }];
    missionNamespace setVariable ["BN_KOTH_careerShutdownHandlerInstalled", true];
};

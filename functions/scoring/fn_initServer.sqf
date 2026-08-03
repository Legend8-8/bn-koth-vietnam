/*
    File: fn_initServer.sqf
    Description: Starts periodic score-award loop.
    Execution: Server
*/

if (!isServer) exitWith {};

[] spawn {
    // Start directly in ACTIVE for the first prototype.
    ["ACTIVE"] call bn_koth_fnc_round_setState;

    while {true} do {
        private _interval = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", 5];
        sleep _interval;
        [] call bn_koth_fnc_scoring_awardControlTick;
    };
};

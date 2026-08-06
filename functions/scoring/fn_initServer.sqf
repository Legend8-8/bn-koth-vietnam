/*
    File: fn_initServer.sqf
    Author: tylervip
    Description: Starts periodic score-award loop.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

[] spawn {
    while {true} do {
        private _interval = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", 5];
        sleep _interval;
        [] call bn_koth_fnc_scoring_awardControlTick;
    };
};

/*
    File: fn_initServer.sqf
    Description: Starts periodic zone control evaluation.
    Execution: Server
*/

if (!isServer) exitWith {};

[] spawn {
    while {true} do {
        [] call bn_koth_fnc_zone_evaluateControl;
        sleep 1;
    };
};

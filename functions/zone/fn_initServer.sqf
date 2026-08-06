/*
    File: fn_initServer.sqf
    Author: tylervip
    Description: Starts periodic zone control evaluation.
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
        [] call bn_koth_fnc_zone_evaluateControl;
        sleep 1;
    };
};

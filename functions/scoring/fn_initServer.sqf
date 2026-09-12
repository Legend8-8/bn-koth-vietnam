/*
    File: fn_initServer.sqf
    Author: tylervip
    Description: Initializes authoritative score-progress state.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

[] call bn_koth_fnc_scoring_resetProgress;

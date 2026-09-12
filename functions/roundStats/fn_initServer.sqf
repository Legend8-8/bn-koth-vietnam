/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes server-owned round statistics and the public Live Leaders projection.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

[] call bn_koth_fnc_roundStats_reset;

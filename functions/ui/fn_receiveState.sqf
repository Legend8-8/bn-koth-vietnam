/*
    File: fn_receiveState.sqf
    Author: tylervip
    Description: Receives and applies server state snapshot on client.
    Execution: Client
    Parameters:
        0: State payload <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params ["_payload"];

if (!hasInterface) exitWith {};

missionNamespace setVariable ["BN_KOTH_clientSnapshot", _payload];

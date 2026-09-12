/*
    File: fn_getPlayerByOwner.sqf
    Author: Legend
    Description: Resolves a connected player object from network owner ID.
    Execution: Server
    Parameters:
        0: Owner ID <NUMBER>
    Returns:
        Matching player or objNull <OBJECT>
    Public: Yes
*/

params ["_ownerId"];

if (!isServer) exitWith {objNull};
if (_ownerId <= 0) exitWith {objNull};

private _resolved = objNull;
{
    if (owner _x isEqualTo _ownerId) exitWith {
        _resolved = _x;
    };
} forEach allPlayers;

_resolved

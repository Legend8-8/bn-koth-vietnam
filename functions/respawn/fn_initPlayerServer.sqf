/*
    File: fn_initPlayerServer.sqf
    Author: tylervip
    Edited: Legend
    Description: Prepares server-side player state for respawn system.
    Execution: Server
    Parameters:
        0: Player object <OBJECT>
    Returns:
        None
    Public: Yes
*/

params ["_player"];

if (!isServer) exitWith {};
if (isNull _player) exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [getPlayerUID _player, createHashMap];
private _assignedSide = if (_record isEqualType createHashMap) then {
    _record getOrDefault ["assignedSide", sideUnknown]
} else {
    sideUnknown
};

_player setVariable ["BN_KOTH_teamSide", _assignedSide, true];

// Placeholder: add spawn protection and validated spawn selection logic.

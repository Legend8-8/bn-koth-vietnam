/*
    File: fn_endWithWinner.sqf
    Author: Attribution pending maintainer decision (new file has no committed human authorship yet)
    Description: Declares a winner and transitions the round into ENDING.
    Execution: Server
    Parameters:
        0: Winning side <SIDE>
    Returns:
        True when winner was accepted, otherwise false <BOOL>
    Public: Yes
*/

params ["_winningSide"];

if (!isServer) exitWith {false};

private _state = [] call bn_koth_fnc_round_getState;
if !(_state isEqualTo "ACTIVE") exitWith {
    [format ["Ignored winner declaration in state %1", _state], "WARN"] call bn_koth_fnc_log;
    false
};

if !([_winningSide] call bn_koth_fnc_teams_validateSide) exitWith {
    [format ["Rejected invalid winning side: %1", _winningSide], "ERROR"] call bn_koth_fnc_log;
    false
};

["BN_KOTH_winningSide", _winningSide] call bn_koth_fnc_publicState;
["ENDING"] call bn_koth_fnc_round_setState;

true

/*
    File: fn_switchTeams.sqf
    Author: tylervip
    Description: Handles ESC-menu "Switch Teams" button clicks; requests a return to the
                 neutral lobby (server validates round-state/score eligibility).
    Execution: Client
    Parameters:
        0: Pause display (optional) <DISPLAY>
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

["LOBBY"] call bn_koth_fnc_teams_requestSelection;

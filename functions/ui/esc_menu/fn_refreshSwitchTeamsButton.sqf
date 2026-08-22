/*
    File: fn_refreshSwitchTeamsButton.sqf
    Author: tylervip
    Description: Enables/disables the ESC-menu "Switch Teams" button based on locally cached
                 team-selected/deployed state and the published score-switch threshold. The
                 server remains authoritative and re-validates on click.
    Execution: Client
    Parameters:
        0: Pause display <DISPLAY>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\esc_menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _button = _display displayCtrl BN_KOTH_IDC_ESC_SWITCH_TEAMS_BUTTON;
if (isNull _button) exitWith {};

private _myUid = getPlayerUID player;
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _myState = if (_playerStates isEqualType createHashMap) then {_playerStates getOrDefault [_myUid, "LOBBY"]} else {"LOBBY"};

private _eligibleState = _myState in ["TEAM_SELECTED", "ACTIVE"];
private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", "WAITING"];
private _belowThreshold = if (_roundState isEqualTo "ACTIVE") then {[] call bn_koth_fnc_teams_isScoreBelowSwitchThreshold} else {true};

_button ctrlEnable (_eligibleState && _belowThreshold);
_button ctrlSetText (if (_belowThreshold) then {"SWITCH TEAMS"} else {"SWITCH TEAMS (LOCKED)"});

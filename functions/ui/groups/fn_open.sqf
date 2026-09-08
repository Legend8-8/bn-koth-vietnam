/*
    File: fn_open.sqf
    Author: Legend
    Description: Opens the custom Group Menu for a legitimately deployed player.
    Execution: Client
    Parameters: None
    Returns: True when opened or refreshed <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\groups\idcs.hpp"

if (!hasInterface) exitWith {false};

private _existing = uiNamespace getVariable ["BN_KOTH_groupMenuDisplay", displayNull];
if (isNull _existing) then {_existing = findDisplay BN_KOTH_IDD_GROUP_MENU};
if (!isNull _existing) exitWith {
    ["SNAPSHOT", ""] call bn_koth_fnc_groups_request;
    true
};

private _uid = getPlayerUID player;
private _states = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _side = if (_assignments isEqualType createHashMap) then {_assignments getOrDefault [_uid, sideUnknown]} else {sideUnknown};
private _allowed = missionNamespace getVariable ["BN_KOTH_stateReady", false]
    && {!(_uid isEqualTo "")}
    && {_states isEqualType createHashMap}
    && {(_states getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE"}
    && {_uid in _active}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE"}
    && {[_side] call bn_koth_fnc_teams_validateSide}
    && {alive player}
    && {!([player] call bn_koth_fnc_respawn_isIncapacitated)}
    && {!dialog}
    && {!(uiNamespace getVariable ["BN_KOTH_transitionVisible", false])}
    && {!(uiNamespace getVariable ["BN_KOTH_resultsVisible", false])};
if (!_allowed) exitWith {false};

missionNamespace setVariable ["BN_KOTH_groupStateLocal", createHashMap];
uiNamespace setVariable ["BN_KOTH_groupMenuMode", "MAIN"];
private _opened = createDialog "BN_KOTH_RscGroupMenu";
if (_opened) then {["SNAPSHOT", ""] call bn_koth_fnc_groups_request};
_opened

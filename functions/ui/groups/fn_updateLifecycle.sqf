/*
    File: fn_updateLifecycle.sqf
    Author: Legend
    Description: Closes Group Menu whenever deployed gameplay access becomes invalid.
    Execution: Client
    Parameters: None
    Returns: Whether Group Menu access is currently allowed <BOOL>
    Public: No
*/

if (!hasInterface) exitWith {false};
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
    && {!(uiNamespace getVariable ["BN_KOTH_transitionVisible", false])}
    && {!(uiNamespace getVariable ["BN_KOTH_resultsVisible", false])};
if (!_allowed) then {[] call bn_koth_fnc_groupMenu_close};
_allowed

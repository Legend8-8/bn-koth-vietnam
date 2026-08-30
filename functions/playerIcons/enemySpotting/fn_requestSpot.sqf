/*
    File: fn_requestSpot.sqf
    Author: tylervip
    Description: Requests a server validation of a spotted enemy target from the bound key action.
    Execution: Client
    Parameters: None
    Returns: True when a request was submitted <BOOL>
    Public: Yes
*/

if (!hasInterface || {isNull player} || {!alive player}) exitWith {false};

private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_playerAssignments isEqualType createHashMap) then {
    _playerAssignments = createHashMap;
};

private _myUid = getPlayerUID player;
private _myAssignedSide = _playerAssignments getOrDefault [_myUid, side group player];
if !([_myAssignedSide] call bn_koth_fnc_teams_validateSide) then {
    _myAssignedSide = side group player;
};
if !([_myAssignedSide] call bn_koth_fnc_teams_validateSide) exitWith {false};

private _candidate = cursorTarget;
if (isNull _candidate || {!(_candidate isKindOf "Man")} || {!alive _candidate} || {side group _candidate isEqualTo _myAssignedSide}) then {
    _candidate = objNull;
};

if (isNull _candidate) exitWith {false};

if (isNull _candidate) exitWith {false};

[_candidate] remoteExecCall ["bn_koth_fnc_enemySpotting_serverValidateAndMark", 2];
true

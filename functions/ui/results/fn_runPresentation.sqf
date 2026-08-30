/*
    File: fn_runPresentation.sqf
    Author: Legend
    Description: Renders one token-owned client-local after-action report sequence.
    Execution: Client scheduled
    Parameters:
        0: Results lifecycle token <NUMBER>
        1: Immutable completed-round presentation snapshot <HASHMAP>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\results\idcs.hpp"

params ["_token", "_snapshot"];

if (!hasInterface) exitWith {};
if !(_snapshot isEqualType createHashMap) exitWith {};

private _isCurrent = {
    (uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", -1]) isEqualTo _token
};

private _display = displayNull;
private _displayDeadline = diag_tickTime + 2;
waitUntil {
    _display = uiNamespace getVariable ["BN_KOTH_resultsDisplay", displayNull];
    !isNull _display || {diag_tickTime >= _displayDeadline} || {!(call _isCurrent)}
};
if (isNull _display || {!(call _isCurrent)}) exitWith {};

private _winner = _snapshot getOrDefault ["winner", sideUnknown];
private _leftSide = _snapshot getOrDefault ["leftSide", west];
private _rightSide = _snapshot getOrDefault ["rightSide", east];
private _leftScore = _snapshot getOrDefault ["leftScore", 0];
private _rightScore = _snapshot getOrDefault ["rightScore", 0];
private _leaders = _snapshot getOrDefault ["leaders", createHashMap];

(_display displayCtrl BN_KOTH_IDC_RESULTS_OUTCOME) ctrlSetText (
    if (_winner in [_leftSide, _rightSide]) then {format ["%1 VICTORY", toUpper str _winner]} else {"ROUND COMPLETE"}
);
(_display displayCtrl BN_KOTH_IDC_RESULTS_SCORE) ctrlSetText format [
    "%1  %2    -    %3  %4",
    toUpper str _leftSide,
    _leftScore,
    _rightScore,
    toUpper str _rightSide
];

private _renderLeader = {
    params ["_key", "_nameIdc", "_valueIdc", "_singular", "_plural"];
    private _entry = _leaders getOrDefault [_key, createHashMap];
    if !(_entry isEqualType createHashMap) then {_entry = createHashMap};
    private _name = _entry getOrDefault ["name", ""];
    private _value = _entry getOrDefault ["value", 0];
    private _nameControl = _display displayCtrl _nameIdc;

    if (_name isEqualTo "" || {_value <= 0}) then {
        _nameControl ctrlSetText "NO LEADER";
        (_display displayCtrl _valueIdc) ctrlSetText format ["0 %1", _plural];
    } else {
        _nameControl ctrlSetText ([_nameControl, _name, 0.006] call bn_koth_fnc_ui_fitLobbyName);
        (_display displayCtrl _valueIdc) ctrlSetText format [
            "%1 %2",
            _value,
            if (_value isEqualTo 1) then {_singular} else {_plural}
        ];
    };
};

["mostDeadly", BN_KOTH_IDC_RESULTS_LEADER_1_NAME, BN_KOTH_IDC_RESULTS_LEADER_1_VALUE, "KILL", "KILLS"] call _renderLeader;
["objective", BN_KOTH_IDC_RESULTS_LEADER_2_NAME, BN_KOTH_IDC_RESULTS_LEADER_2_VALUE, "PT", "PTS"] call _renderLeader;
["bestStreak", BN_KOTH_IDC_RESULTS_LEADER_3_NAME, BN_KOTH_IDC_RESULTS_LEADER_3_VALUE, "KILL", "KILLS"] call _renderLeader;

private _groups = [
    [BN_KOTH_IDC_RESULTS_FRAME, BN_KOTH_IDC_RESULTS_ACCENT, BN_KOTH_IDC_RESULTS_TITLE],
    [BN_KOTH_IDC_RESULTS_OUTCOME],
    [BN_KOTH_IDC_RESULTS_SCORE_LABEL, BN_KOTH_IDC_RESULTS_SCORE],
    [BN_KOTH_IDC_RESULTS_LEADER_1_CARD, BN_KOTH_IDC_RESULTS_LEADER_1_LABEL, BN_KOTH_IDC_RESULTS_LEADER_1_NAME, BN_KOTH_IDC_RESULTS_LEADER_1_VALUE],
    [BN_KOTH_IDC_RESULTS_LEADER_2_CARD, BN_KOTH_IDC_RESULTS_LEADER_2_LABEL, BN_KOTH_IDC_RESULTS_LEADER_2_NAME, BN_KOTH_IDC_RESULTS_LEADER_2_VALUE],
    [BN_KOTH_IDC_RESULTS_LEADER_3_CARD, BN_KOTH_IDC_RESULTS_LEADER_3_LABEL, BN_KOTH_IDC_RESULTS_LEADER_3_NAME, BN_KOTH_IDC_RESULTS_LEADER_3_VALUE],
    [BN_KOTH_IDC_RESULTS_STATUS, BN_KOTH_IDC_RESULTS_FOOTER]
];

{
    {(_display displayCtrl _x) ctrlSetFade 1; (_display displayCtrl _x) ctrlCommit 0} forEach _x;
} forEach _groups;

uiSleep 0.35;
{
    if !(call _isCurrent) exitWith {};
    {(_display displayCtrl _x) ctrlSetFade 0; (_display displayCtrl _x) ctrlCommit 0.45} forEach _x;
    uiSleep 0.65;
} forEach _groups;

if !(call _isCurrent) exitWith {};
uiSleep 3.2;
if !(call _isCurrent) exitWith {};

uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", true];
uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
[] call bn_koth_fnc_ui_results_update;

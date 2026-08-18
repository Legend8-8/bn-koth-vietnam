/*
    File: fn_refreshLobbyCenter.sqf
    Author: Legend
    Description: Applies spectator/lobby center panel settings and player-facing copy.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
        1: Center-panel view model <HASHMAP>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\lobby\idcs.hpp"

params ["_display", "_viewModel"];

if (isNull _display) exitWith {};
if !(_viewModel isEqualType createHashMap) exitWith {};

private _scoreLimit = _viewModel getOrDefault ["scoreLimit", 100];
private _westScore = _viewModel getOrDefault ["westScore", 0];
private _eastScore = _viewModel getOrDefault ["eastScore", 0];

if (_scoreLimit < 1) then {
    _scoreLimit = 1;
};

if (_westScore < 0) then {
    _westScore = 0;
};

if (_eastScore < 0) then {
    _eastScore = 0;
};

(_display displayCtrl BN_KOTH_IDC_CENTER_INFO) ctrlSetStructuredText parseText format [
    "<t align='center' size='0.9' color='#D3C8B4'>ROUND SETTINGS</t><br/><br/><t align='left' color='#8F8778'>Score Limit</t><t align='right' color='#F0ECE2'>%1</t><br/><t align='left' color='#8F8778'>Round Time Limit</t><t align='right' color='#F0ECE2'>%2</t><br/><t align='left' color='#8F8778'>Vehicles</t><t align='right' color='#F0ECE2'>%3</t><br/><t align='left' color='#8F8778'>Friendly Fire</t><t align='right' color='#F0ECE2'>%4</t><br/><t align='left' color='#8F8778'>3rd Person</t><t align='right' color='#F0ECE2'>%5</t>",
    _scoreLimit,
    _viewModel getOrDefault ["roundTimeLimitText", "NONE"],
    _viewModel getOrDefault ["vehiclesText", "SERVER RULES"],
    _viewModel getOrDefault ["friendlyFireText", "SERVER RULES"],
    _viewModel getOrDefault ["thirdPersonText", "SERVER RULES"]
];

(_display displayCtrl BN_KOTH_IDC_CENTER_WEST_SCORE) ctrlSetText str _westScore;
(_display displayCtrl BN_KOTH_IDC_CENTER_EAST_SCORE) ctrlSetText str _eastScore;
(_display displayCtrl BN_KOTH_IDC_CENTER_SCORE_LIMIT) ctrlSetText format ["FIRST TO %1", _scoreLimit];

private _applyBarWidth = {
    params ["_barBgCtrl", "_barCtrl", "_score", "_limit"];

    private _bgPos = ctrlPosition _barBgCtrl;
    private _barPos = ctrlPosition _barCtrl;
    private _ratio = (((_score max 0) min _limit) / _limit);

    _barPos set [2, (_bgPos select 2) * _ratio];
    _barCtrl ctrlSetPosition _barPos;
    _barCtrl ctrlCommit 0;
};

[
    _display displayCtrl BN_KOTH_IDC_CENTER_WEST_BAR_BG,
    _display displayCtrl BN_KOTH_IDC_CENTER_WEST_BAR,
    _westScore,
    _scoreLimit
] call _applyBarWidth;

[
    _display displayCtrl BN_KOTH_IDC_CENTER_EAST_BAR_BG,
    _display displayCtrl BN_KOTH_IDC_CENTER_EAST_BAR,
    _eastScore,
    _scoreLimit
] call _applyBarWidth;

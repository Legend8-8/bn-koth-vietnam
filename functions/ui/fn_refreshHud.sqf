/*
    File: fn_refreshHud.sqf
    Author: Legend
    Description: Renders the local HUD shell from replicated score, zone, and progress state.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\hud\idcs.hpp"

if (!hasInterface) exitWith {};

private _display = uiNamespace getVariable ["BN_KOTH_hudDisplay", displayNull];
if (isNull _display) exitWith {};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreLimit")} else {100}];
if (_scoreLimit < 1) then {
    _scoreLimit = 1;
};

private _teamScores = missionNamespace getVariable ["BN_KOTH_teamScores", createHashMapFromArray [[west, 0], [east, 0]]];
private _westScore = 0;
private _eastScore = 0;
if (_teamScores isEqualType createHashMap) then {
    _westScore = _teamScores getOrDefault [west, 0];
    _eastScore = _teamScores getOrDefault [east, 0];
};

private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
private _zoneController = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
private _progress = missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap];
private _progressSide = sideUnknown;
private _progressBase = 0;
private _progressStartedAt = -1;
private _progressActive = false;
private _progressDuration = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {5}];

if (_progress isEqualType createHashMap) then {
    _progressSide = _progress getOrDefault ["side", sideUnknown];
    _progressBase = _progress getOrDefault ["base", 0];
    _progressStartedAt = _progress getOrDefault ["startedAt", -1];
    _progressActive = _progress getOrDefault ["active", false];
    _progressDuration = _progress getOrDefault ["duration", _progressDuration];
};

if (_progressDuration < 1) then {
    _progressDuration = 1;
};

private _progressRatio = _progressBase;
if (_progressActive && {_progressStartedAt >= 0}) then {
    _progressRatio = _progressBase + ((serverTime - _progressStartedAt) / _progressDuration);
};
_progressRatio = (_progressRatio max 0) min 1;

private _statusText = "NEUTRAL";
private _statusColor = [0.88, 0.86, 0.80, 0.95];
private _barColor = [0.45, 0.77, 1, 0.95];

switch (_zoneState) do {
    case "CONTESTED": {
        _statusText = "CONTESTED";
        _statusColor = [0.96, 0.78, 0.26, 1];
        _barColor = [0.96, 0.78, 0.26, 0.95];
    };

    case "CONTROLLED": {
        switch (_zoneController) do {
            case west: {
                _statusText = "WEST CONTROL";
                _statusColor = [0.45, 0.77, 1, 1];
                _barColor = [0.45, 0.77, 1, 0.95];
            };

            case east: {
                _statusText = "EAST CONTROL";
                _statusColor = [1, 0.48, 0.48, 1];
                _barColor = [1, 0.48, 0.48, 0.95];
            };

            default {
                _statusText = "CONTROLLED";
                _statusColor = [0.88, 0.86, 0.80, 0.95];
            };
        };
    };
};

(_display displayCtrl BN_KOTH_IDC_HUD_WEST_SCORE) ctrlSetText format ["WEST %1", _westScore];
(_display displayCtrl BN_KOTH_IDC_HUD_EAST_SCORE) ctrlSetText format ["%1 EAST", _eastScore];
(_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetText _statusText;
(_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetTextColor _statusColor;

private _barBgCtrl = _display displayCtrl BN_KOTH_IDC_HUD_PROGRESS_BG;
private _barFillCtrl = _display displayCtrl BN_KOTH_IDC_HUD_PROGRESS_FILL;
private _bgPos = ctrlPosition _barBgCtrl;
private _fillPos = ctrlPosition _barFillCtrl;
private _filledWidth = (_bgPos select 2) * _progressRatio;

if (_progressRatio <= 0) then {
    _barFillCtrl ctrlShow false;
} else {
    _barFillCtrl ctrlShow true;
    _fillPos set [2, _filledWidth];

    if (_progressSide isEqualTo east) then {
        _fillPos set [0, (_bgPos select 0) + (_bgPos select 2) - _filledWidth];
    } else {
        _fillPos set [0, _bgPos select 0];
    };

    _barFillCtrl ctrlSetPosition _fillPos;
    _barFillCtrl ctrlSetBackgroundColor _barColor;
    _barFillCtrl ctrlCommit 0;
};

(_display displayCtrl BN_KOTH_IDC_HUD_PROGRESS_BG) ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.92];

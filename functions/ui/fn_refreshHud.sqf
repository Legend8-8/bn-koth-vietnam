/*
    File: fn_refreshHud.sqf
    Author: Legend
    Edited: Mongo
    Description: Renders scores, AO control detail, Priority status, and safe-zone status.
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

private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _priorityAvailable = !((markerShape _priorityMarker) isEqualTo "")
    && {(markerAlpha _priorityMarker) > 0};
private _playerInPriority = _priorityAvailable && {!isNull player} && {player inArea _priorityMarker};

private _priorityCfg = missionConfigFile >> "CfgBnKothZone";
private _priorityWeight = if (isClass _priorityCfg) then {
    (getNumber (_priorityCfg >> "priorityControlWeight")) max 1
} else {
    2
};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _teamScores = missionNamespace getVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[west, 0], [east, 0]]
];
private _westScore = if (_teamScores isEqualType createHashMap) then {_teamScores getOrDefault [west, 0]} else {0};
private _eastScore = if (_teamScores isEqualType createHashMap) then {_teamScores getOrDefault [east, 0]} else {0};

private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
private _zoneController = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
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
        if (_zoneController isEqualTo west) then {
            _statusText = "WEST CONTROL";
            _statusColor = [0.45, 0.77, 1, 1];
            _barColor = [0.45, 0.77, 1, 0.95];
        } else {
            if (_zoneController isEqualTo east) then {
                _statusText = "EAST CONTROL";
                _statusColor = [1, 0.48, 0.48, 1];
                _barColor = [1, 0.48, 0.48, 0.95];
            } else {
                _statusText = "CONTROLLED";
            };
        };
    };
};

private _population = missionNamespace getVariable ["BN_KOTH_zonePopulation", createHashMap];
private _raw = [0, 0];
private _weighted = [0, 0];
private _priority = [0, 0];
if (_population isEqualType createHashMap) then {
    _raw = _population getOrDefault ["raw", [0, 0]];
    _weighted = _population getOrDefault ["weighted", [0, 0]];
    _priority = _population getOrDefault ["priority", [0, 0]];
} else {
    // Compatibility with a snapshot produced by the previous array-only state.
    _raw = _population;
    _weighted = _population;
};

private _readPair = {
    params ["_values"];
    [
        if ((count _values) > 0) then {_values select 0} else {0},
        if ((count _values) > 1) then {_values select 1} else {0}
    ]
};
_raw = [_raw] call _readPair;
_weighted = [_weighted] call _readPair;
_priority = [_priority] call _readPair;

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {_playableSides = [west, east];};
private _sideA = _playableSides select 0;
private _sideB = _playableSides select 1;

private _toWestEast = {
    params ["_values"];
    private _westValue = 0;
    private _eastValue = 0;
    if (_sideA isEqualTo west) then {_westValue = _values select 0;};
    if (_sideB isEqualTo west) then {_westValue = _values select 1;};
    if (_sideA isEqualTo east) then {_eastValue = _values select 0;};
    if (_sideB isEqualTo east) then {_eastValue = _values select 1;};
    [_westValue, _eastValue]
};
private _rawWestEast = [_raw] call _toWestEast;
private _weightedWestEast = [_weighted] call _toWestEast;
private _priorityWestEast = [_priority] call _toWestEast;

private _roundLeadText = "ROUND: TIED";
if (_westScore > _eastScore) then {
    _roundLeadText = format ["ROUND LEAD: WEST +%1", _westScore - _eastScore];
} else {
    if (_eastScore > _westScore) then {
        _roundLeadText = format ["ROUND LEAD: EAST +%1", _eastScore - _westScore];
    };
};

private _priorityText = "";
private _priorityVisible = _priorityAvailable;
if (_priorityAvailable) then {
    _priorityText = if (_playerInPriority) then {
        format ["YOU: IN PRIORITY - %1x CONTROL", _priorityWeight]
    } else {
        "YOU: OUTSIDE PRIORITY"
    };
};

private _safeZoneText = "";
private _safeZoneColor = [0.48, 1, 0.58, 1];
private _safeZoneVisible = false;
if (!isNull player && {player getVariable ["BN_KOTH_enemySafeZoneIntruder", false]}) then {
    _safeZoneText = "ENEMY SAFE ZONE - WEAPONS AND VEHICLES DISABLED";
    _safeZoneColor = [1, 0.35, 0.30, 1];
    _safeZoneVisible = true;
} else {
    if (!isNull player && {player getVariable ["BN_KOTH_safeZoneProtected", false]}) then {
        _safeZoneText = "SAFE ZONE - PROTECTED - WEAPONS DISABLED";
        _safeZoneVisible = true;
    };
};

private _actualText = format ["ACTUAL PLAYERS  W %1 | E %2", _rawWestEast select 0, _rawWestEast select 1];
private _weightedText = format ["WEIGHTED CONTROL  W %1 | E %2", _weightedWestEast select 0, _weightedWestEast select 1];
private _prioritySummaryText = format ["PRIORITY OCCUPANCY  W %1 | E %2", _priorityWestEast select 0, _priorityWestEast select 1];
private _staticKey = [
    _westScore,
    _eastScore,
    _statusText,
    _statusColor,
    _roundLeadText,
    _actualText,
    _weightedText,
    _prioritySummaryText,
    _priorityText,
    _priorityVisible,
    _safeZoneText,
    _safeZoneColor,
    _safeZoneVisible
];

if !((uiNamespace getVariable ["BN_KOTH_hudStaticKey", []]) isEqualTo _staticKey) then {
    (_display displayCtrl BN_KOTH_IDC_HUD_WEST_SCORE) ctrlSetText format ["WEST %1", _westScore];
    (_display displayCtrl BN_KOTH_IDC_HUD_EAST_SCORE) ctrlSetText format ["%1 EAST", _eastScore];
    (_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetText _statusText;
    (_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetTextColor _statusColor;
    (_display displayCtrl BN_KOTH_IDC_HUD_ROUND_LEAD) ctrlSetText _roundLeadText;
    (_display displayCtrl BN_KOTH_IDC_HUD_ACTUAL) ctrlSetText _actualText;
    (_display displayCtrl BN_KOTH_IDC_HUD_WEIGHTED) ctrlSetText _weightedText;
    (_display displayCtrl BN_KOTH_IDC_HUD_PRIORITY_SUMMARY) ctrlSetText _prioritySummaryText;

    private _priorityCtrl = _display displayCtrl BN_KOTH_IDC_HUD_PRIORITY;
    _priorityCtrl ctrlSetText _priorityText;
    _priorityCtrl ctrlShow _priorityVisible;

    private _safeZoneCtrl = _display displayCtrl BN_KOTH_IDC_HUD_SAFE_ZONE;
    _safeZoneCtrl ctrlSetText _safeZoneText;
    _safeZoneCtrl ctrlSetTextColor _safeZoneColor;
    _safeZoneCtrl ctrlShow _safeZoneVisible;
    uiNamespace setVariable ["BN_KOTH_hudStaticKey", _staticKey];
};

private _progress = missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap];
private _progressSide = sideUnknown;
private _progressBase = 0;
private _progressStartedAt = -1;
private _progressActive = false;
private _progressDuration = missionNamespace getVariable [
    "BN_KOTH_scoreTickInterval",
    if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {5}
];
if (_progress isEqualType createHashMap) then {
    _progressSide = _progress getOrDefault ["side", sideUnknown];
    _progressBase = _progress getOrDefault ["base", 0];
    _progressStartedAt = _progress getOrDefault ["startedAt", -1];
    _progressActive = _progress getOrDefault ["active", false];
    _progressDuration = _progress getOrDefault ["duration", _progressDuration];
};
_progressDuration = _progressDuration max 1;

private _progressRatio = _progressBase;
if (_progressActive && {_progressStartedAt >= 0}) then {
    _progressRatio = _progressBase + ((serverTime - _progressStartedAt) / _progressDuration);
};
_progressRatio = (_progressRatio max 0) min 1;

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
    _fillPos set [0, if (_progressSide isEqualTo east) then {
        (_bgPos select 0) + (_bgPos select 2) - _filledWidth
    } else {
        _bgPos select 0
    }];
    _barFillCtrl ctrlSetPosition _fillPos;
    _barFillCtrl ctrlSetBackgroundColor _barColor;
    _barFillCtrl ctrlCommit 0;
};

_barBgCtrl ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.92];

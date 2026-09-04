/*
    File: fn_refreshHud.sqf
    Author: Legend
    Edited: Mongo
    Description: Renders scores, AO status, score progress, and safe-zone notices.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\hud\idcs.hpp"

if (!hasInterface) exitWith {};

private _display = uiNamespace getVariable ["BN_KOTH_hudDisplay", displayNull];
if (isNull _display) exitWith {};

[] call bn_koth_fnc_ui_updatePriorityTask;

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

private _roundLeadText = "ROUND: TIED";
if (_westScore > _eastScore) then {
    _roundLeadText = format ["ROUND LEAD: WEST +%1", _westScore - _eastScore];
} else {
    if (_eastScore > _westScore) then {
        _roundLeadText = format ["ROUND LEAD: EAST +%1", _eastScore - _westScore];
    };
};

private _enemySafeZoneVisible = !isNull player
    && {player getVariable ["BN_KOTH_enemySafeZoneIntruder", false]};
private _enemySafeZoneText = if (_enemySafeZoneVisible) then {
    "ENEMY SAFE ZONE LEAVE NOW"
} else {
    ""
};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
private _progressionAvailable = _progression isEqualType createHashMap
    && {"level" in _progression}
    && {"xp" in _progression};
private _playerProgressText = "LEVEL --   XP SYNCING";
private _rankIcon = "";
private _rankColor = [1, 1, 1, 0];
private _rankVisible = false;
if (_progressionAvailable) then {
    private _levelProgress = [
        _progression getOrDefault ["xp", 0],
        _progression getOrDefault ["level", 1]
    ] call bn_koth_fnc_progression_xp_getLevelProgress;
    private _level = _levelProgress getOrDefault ["level", 1];
    private _xp = _levelProgress getOrDefault ["xp", 0];
    private _maxLevel = _levelProgress getOrDefault ["maxLevel", 270];
    if (_level >= _maxLevel) then {
        _playerProgressText = format ["LEVEL %1   MAX LEVEL  %2 XP", _level, round _xp];
    } else {
        _playerProgressText = format [
            "LEVEL %1   %2 / %3 XP",
            _level,
            round (_levelProgress getOrDefault ["xpIntoLevel", 0]),
            round (_levelProgress getOrDefault ["xpRequired", 0])
        ];
    };
    private _rank = [_level] call bn_koth_fnc_progression_resolveRankPresentation;
    _rankIcon = _rank getOrDefault ["icon", ""];
    _rankColor = _rank getOrDefault ["color", [1, 1, 1, 0]];
    _rankVisible = _rank getOrDefault ["hasIcon", false];
};

private _roundActive = (missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE";
private _activeAoMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _aoVisible = _roundActive
    && {!(_activeAoMarker isEqualTo "")}
    && {!((markerShape _activeAoMarker) isEqualTo "")};
private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _priorityVisible = _aoVisible && {!((markerShape _priorityMarker) isEqualTo "")};
private _priorityCounts = [0, 0];
private _aoCounts = [0, 0];
private _zonePopulation = missionNamespace getVariable ["BN_KOTH_zonePopulation", createHashMap];
if (_zonePopulation isEqualType createHashMap) then {
    private _publishedAoCounts = _zonePopulation getOrDefault ["raw", [0, 0]];
    if (_publishedAoCounts isEqualType [] && {(count _publishedAoCounts) >= 2}) then {
        _aoCounts = [(_publishedAoCounts select 0) max 0, (_publishedAoCounts select 1) max 0];
    };
    private _publishedCounts = _zonePopulation getOrDefault ["priority", [0, 0]];
    if (_publishedCounts isEqualType [] && {(count _publishedCounts) >= 2}) then {
        _priorityCounts = [(_publishedCounts select 0) max 0, (_publishedCounts select 1) max 0];
    };
};

private _safeZoneProtected = !isNull player
    && {player getVariable ["BN_KOTH_safeZoneProtected", false]};
private _previousSafeZoneProtected = uiNamespace getVariable [
    "BN_KOTH_hudSafeZonePreviousProtected",
    _safeZoneProtected
];
private _safeZoneExitUntil = uiNamespace getVariable [
    "BN_KOTH_hudSafeZoneExitUntil",
    -1
];
private _safeZonePresentationActive = !isNull player
    && {alive player}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) in ["PREPARING", "ACTIVE"]};
private _now = diag_tickTime;

if (_safeZoneProtected isNotEqualTo _previousSafeZoneProtected) then {
    if (_previousSafeZoneProtected
        && {!_safeZoneProtected}
        && {_safeZonePresentationActive}
        && {!_enemySafeZoneVisible}) then {
        private _respawnConfig = missionConfigFile >> "CfgBnKothRespawn";
        private _exitMessageSeconds = if (isClass _respawnConfig
            && {isNumber (_respawnConfig >> "friendlySafeZoneExitMessageSeconds")}) then {
            getNumber (_respawnConfig >> "friendlySafeZoneExitMessageSeconds")
        } else {
            5
        };

        _safeZoneExitUntil = _now + (_exitMessageSeconds max 0);
        uiNamespace setVariable ["BN_KOTH_hudSafeZoneExitUntil", _safeZoneExitUntil];
    };

    uiNamespace setVariable ["BN_KOTH_hudSafeZonePreviousProtected", _safeZoneProtected];
};

if (!_safeZonePresentationActive || {_safeZoneProtected} || {_enemySafeZoneVisible}) then {
    if (_safeZoneExitUntil >= 0) then {
        _safeZoneExitUntil = -1;
        uiNamespace setVariable ["BN_KOTH_hudSafeZoneExitUntil", _safeZoneExitUntil];
    };
};

private _safeZoneVisible = _safeZonePresentationActive
    && {!_safeZoneProtected}
    && {!_enemySafeZoneVisible}
    && {_now < _safeZoneExitUntil};
private _safeZoneText = if (_safeZoneVisible) then {
    "LEAVING SAFE ZONE"
} else {
    ""
};

private _staticKey = [
    _westScore,
    _eastScore,
    _statusText,
    _statusColor,
    _roundLeadText,
    _safeZoneText,
    _safeZoneVisible,
    _enemySafeZoneText,
    _enemySafeZoneVisible,
    _playerProgressText,
    _rankIcon,
    _rankColor,
    _rankVisible,
    _aoCounts,
    _priorityCounts,
    _aoVisible,
    _priorityVisible
];

if !((uiNamespace getVariable ["BN_KOTH_hudStaticKey", []]) isEqualTo _staticKey) then {
    (_display displayCtrl BN_KOTH_IDC_HUD_WEST_SCORE) ctrlSetText format ["WEST %1", _westScore];
    (_display displayCtrl BN_KOTH_IDC_HUD_EAST_SCORE) ctrlSetText format ["%1 EAST", _eastScore];
    (_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetText _statusText;
    (_display displayCtrl BN_KOTH_IDC_HUD_STATUS) ctrlSetTextColor _statusColor;
    (_display displayCtrl BN_KOTH_IDC_HUD_ROUND_LEAD) ctrlSetText _roundLeadText;

    private _safeZoneCtrl = _display displayCtrl BN_KOTH_IDC_HUD_SAFE_ZONE;
    _safeZoneCtrl ctrlSetText _safeZoneText;
    _safeZoneCtrl ctrlShow _safeZoneVisible;

    private _enemySafeZoneCtrl = _display displayCtrl BN_KOTH_IDC_HUD_ENEMY_SAFE_ZONE;
    _enemySafeZoneCtrl ctrlSetText _enemySafeZoneText;
    _enemySafeZoneCtrl ctrlShow _enemySafeZoneVisible;

    private _rankCtrl = _display displayCtrl BN_KOTH_IDC_HUD_RANK_ICON;
    _rankCtrl ctrlSetText _rankIcon;
    _rankCtrl ctrlSetTextColor _rankColor;
    _rankCtrl ctrlShow _rankVisible;
    (_display displayCtrl BN_KOTH_IDC_HUD_PLAYER_PROGRESS) ctrlSetText _playerProgressText;

    private _aoCtrl = _display displayCtrl BN_KOTH_IDC_HUD_AO_POPULATION;
    _aoCtrl ctrlSetStructuredText parseText format [
        "<t align='center' color='#E0DBCC'>AO  </t><t color='#73C4FF'>WEST %1</t><t color='#E0DBCC'> - </t><t color='#FF7A7A'>%2 EAST</t>",
        round (_aoCounts select 0),
        round (_aoCounts select 1)
    ];
    _aoCtrl ctrlShow _aoVisible;

    private _priorityCtrl = _display displayCtrl BN_KOTH_IDC_HUD_PRIORITY_POPULATION;
    _priorityCtrl ctrlSetStructuredText parseText format [
        "<t align='center' color='#F5C742'>PRIORITY BONUS  </t><t color='#73C4FF'>+%1</t><t color='#F5C742'> - </t><t color='#FF7A7A'>+%2</t>",
        round (_priorityCounts select 0),
        round (_priorityCounts select 1)
    ];
    _priorityCtrl ctrlShow _priorityVisible;
    uiNamespace setVariable ["BN_KOTH_hudStaticKey", _staticKey];
};

private _progress = missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap];
private _progressSide = sideUnknown;
private _progressBase = 0;
private _progressStartedAt = -1;
private _progressActive = false;
private _progressDuration = missionNamespace getVariable [
    "BN_KOTH_scoreTickInterval",
    if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {15}
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

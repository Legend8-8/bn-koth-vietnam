/*
    File: fn_awardControlTick.sqf
    Author: tylervip
    Edited: Legend
    Description: Advances the authoritative score-progress state and awards score when a cycle completes.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _scoreTick = missionNamespace getVariable ["BN_KOTH_scoreTick", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTick")} else {1}];
private _scoreTickInterval = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {5}];
private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreLimit")} else {100}];

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _resetProgress = {
    private _progress = createHashMapFromArray [
        ["side", sideUnknown],
        ["base", 0],
        ["startedAt", -1],
        ["active", false],
        ["duration", _scoreTickInterval]
    ];

    ["BN_KOTH_scoreProgress", _progress] call bn_koth_fnc_common_publicState;
};

if !(_roundState isEqualTo "ACTIVE") exitWith {
    [] call _resetProgress;
};

private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (_marker isEqualTo "") exitWith {
    [] call _resetProgress;
};

private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
private _controller = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
private _progress = missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap];

if !(_progress isEqualType createHashMap) exitWith {
    [] call _resetProgress;
};

private _progressSide = _progress getOrDefault ["side", sideUnknown];
private _progressBase = _progress getOrDefault ["base", 0];
private _progressStartedAt = _progress getOrDefault ["startedAt", -1];
private _progressActive = _progress getOrDefault ["active", false];
private _progressDuration = _progress getOrDefault ["duration", _scoreTickInterval];

private _currentProgressRatio = {
    params ["_base", "_startedAt", "_isActive", "_duration"];

    if (!_isActive || {_startedAt < 0}) exitWith {
        (_base max 0) min 1
    };

    ((
        _base + ((serverTime - _startedAt) / _duration)
    ) max 0) min 1
};

if (_progressDuration < 1) then {
    _progressDuration = 1;
};

if (_zoneState isEqualTo "NEUTRAL") exitWith {
    [] call _resetProgress;
};

if (_zoneState isEqualTo "CONTESTED") exitWith {
    if (_progressSide in _playableSides) then {
        if (_progressActive) then {
            private _frozenRatio = [_progressBase, _progressStartedAt, _progressActive, _progressDuration] call _currentProgressRatio;
            _progress set ["base", _frozenRatio];
            _progress set ["startedAt", -1];
            _progress set ["active", false];
            _progress set ["duration", _progressDuration];
            ["BN_KOTH_scoreProgress", _progress] call bn_koth_fnc_common_publicState;
        };
    } else {
        [] call _resetProgress;
    };
};

if !(_controller in _playableSides) exitWith {
    [] call _resetProgress;
};

if !(_progressSide isEqualTo _controller) exitWith {
    private _nextProgress = createHashMapFromArray [
        ["side", _controller],
        ["base", 0],
        ["startedAt", serverTime],
        ["active", true],
        ["duration", _progressDuration]
    ];

    ["BN_KOTH_scoreProgress", _nextProgress] call bn_koth_fnc_common_publicState;
};

if !_progressActive exitWith {
    _progress set ["active", true];
    _progress set ["startedAt", serverTime];
    _progress set ["duration", _progressDuration];
    ["BN_KOTH_scoreProgress", _progress] call bn_koth_fnc_common_publicState;
};

private _elapsed = serverTime - _progressStartedAt;
private _progressRatio = _progressBase + (_elapsed / _progressDuration);
if (_progressRatio < 1) exitWith {};

private _validatedController = [true] call bn_koth_fnc_zone_evaluateControl;
private _validatedZoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
if (!(_validatedZoneState isEqualTo "CONTROLLED")) exitWith {
    [] call _resetProgress;
};

if (!(_validatedController isEqualTo _controller)) exitWith {
    if (_validatedController in _playableSides) then {
        private _nextProgress = createHashMapFromArray [
            ["side", _validatedController],
            ["base", 0],
            ["startedAt", serverTime],
            ["active", true],
            ["duration", _progressDuration]
        ];

        ["BN_KOTH_scoreProgress", _nextProgress] call bn_koth_fnc_common_publicState;
    } else {
        [] call _resetProgress;
    };
};

private _scores = missionNamespace getVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]
];

private _current = _scores getOrDefault [_controller, 0];
private _newScore = _current + _scoreTick;

_scores set [_controller, _newScore];
missionNamespace setVariable ["BN_KOTH_teamScores", _scores, true];

[_controller, _scoreTick] call bn_koth_fnc_roundStats_recordObjectiveTick;
[_controller] call bn_koth_fnc_progression_xp_awardControlTick;

[format ["Score tick: %1 -> %2", _controller, _newScore]] call bn_koth_fnc_common_log;

if (_newScore >= _scoreLimit) then {
    [_controller] call bn_koth_fnc_round_endWithWinner;
} else {
    private _nextProgress = createHashMapFromArray [
        ["side", _controller],
        ["base", 0],
        ["startedAt", serverTime],
        ["active", true],
        ["duration", _progressDuration]
    ];

    ["BN_KOTH_scoreProgress", _nextProgress] call bn_koth_fnc_common_publicState;
};

/*
    File: fn_getXpThresholdForLevel.sqf
    Author: Legend
    Description: Returns cumulative XP required to reach a configured level.
        The curve is derived from mission config so balancing does not require
        changing runtime code. Persistent storage only needs cumulative XP;
        level can always be derived from the current configured curve.
    Execution: Any
    Parameters:
        0: Target level <NUMBER>
    Returns:
        Cumulative XP threshold <NUMBER>
    Public: No
*/

params [["_level", 1, [0]]];
if !(_level isEqualType 0 && {finite _level}) then {_level = 1};

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _baseXp = if (isNumber (_progressionCfg >> "xpLevelBase")) then {
    getNumber (_progressionCfg >> "xpLevelBase")
} else {
    500
};
private _linearStep = if (isNumber (_progressionCfg >> "xpLevelLinearStep")) then {
    getNumber (_progressionCfg >> "xpLevelLinearStep")
} else {
    75
};
private _quadraticStep = if (isNumber (_progressionCfg >> "xpLevelQuadraticStep")) then {
    getNumber (_progressionCfg >> "xpLevelQuadraticStep")
} else {
    0.12
};
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};

// Config-sourced curve constants must fail soft to their defaults rather than propagate a non-finite value.
if !(finite _baseXp) then {_baseXp = 500};
if !(finite _linearStep) then {_linearStep = 75};
if !(finite _quadraticStep) then {_quadraticStep = 0.12};
if !(finite _maxLevel) then {_maxLevel = 270};

_baseXp = _baseXp max 1;
_linearStep = _linearStep max 0;
_quadraticStep = _quadraticStep max 0;
_maxLevel = floor (_maxLevel max 1);

private _safeLevel = (floor (_level max 1)) min _maxLevel;
private _completedLevels = (_safeLevel - 1) max 0;
if (_completedLevels <= 0) exitWith {0};

private _n = _completedLevels;
private _linearSum = (_n * (_n - 1)) / 2;
private _squareSum = ((_n - 1) * _n * ((2 * _n) - 1)) / 6;

private _threshold = round (
    (_n * _baseXp)
    + (_linearStep * _linearSum)
    + (_quadraticStep * _squareSum)
);

if (finite _threshold) then {_threshold} else {0}

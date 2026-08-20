/*
    File: fn_getLevelProgress.sqf
    Author: Legend
    Description: Builds display-only progress within the current level from
        authoritative XP/level presentation state and configured XP curve.
    Execution: Any
    Parameters:
        0: Cumulative XP <NUMBER>
        1: Authoritative current level <NUMBER>
    Returns:
        Presentation values <HASHMAP>
    Public: No
*/

params [
    ["_xp", 0, [0]],
    ["_level", 1, [0]]
];

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";

private _baseXp = if (isNumber (_progressionCfg >> "xpLevelBase")) then {
    getNumber (_progressionCfg >> "xpLevelBase")
} else {
    100
};

private _levelStep = if (isNumber (_progressionCfg >> "xpLevelStep")) then {
    getNumber (_progressionCfg >> "xpLevelStep")
} else {
    50
};

private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};

_baseXp = _baseXp max 1;
_levelStep = _levelStep max 0;
_maxLevel = _maxLevel max 1;

private _safeXp = _xp max 0;
private _safeLevel = (_level max 1) min _maxLevel;

private _xpIntoLevel = 0;
private _xpRequired = 0;
private _ratio = 1;

if (_safeLevel < _maxLevel) then {
    private _completedLevels = (_safeLevel - 1) max 0;
    private _spentBeforeLevel = (_completedLevels * _baseXp)
        + ((_levelStep * _completedLevels * ((_completedLevels - 1) max 0)) / 2);

    _xpIntoLevel = (_safeXp - _spentBeforeLevel) max 0;
    _xpRequired = _baseXp + ((_safeLevel - 1) * _levelStep);
    _xpIntoLevel = _xpIntoLevel min _xpRequired;
    _ratio = (_xpIntoLevel / _xpRequired) max 0 min 1;
};

createHashMapFromArray [
    ["level", _safeLevel],
    ["maxLevel", _maxLevel],
    ["xp", _safeXp],
    ["xpIntoLevel", _xpIntoLevel],
    ["xpRequired", _xpRequired],
    ["ratio", _ratio]
]

/*
    File: fn_getLevelProgress.sqf
    Author: Legend
    Description: Builds display-only progress within the current level from
        authoritative XP/level presentation state and the shared configured curve.
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

// max()/min() do not reliably sanitize NaN in this engine, so non-finite inputs must be
// rejected explicitly with finite() before any arithmetic, not merely clamped.
if !(_xp isEqualType 0 && {finite _xp}) then {_xp = 0};
if !(_level isEqualType 0 && {finite _level}) then {_level = 1};

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};
if !(finite _maxLevel) then {_maxLevel = 270};
_maxLevel = floor (_maxLevel max 1);

private _safeXp = _xp max 0;
private _safeLevel = (floor (_level max 1)) min _maxLevel;
private _xpIntoLevel = 0;
private _xpRequired = 0;
private _ratio = 1;

if (_safeLevel < _maxLevel) then {
    private _currentThreshold = [_safeLevel] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;
    private _nextThreshold = [_safeLevel + 1] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;
    if !(finite _currentThreshold) then {_currentThreshold = 0};
    if !(finite _nextThreshold) then {_nextThreshold = _currentThreshold + 1};

    _xpRequired = (_nextThreshold - _currentThreshold) max 1;
    _xpIntoLevel = ((_safeXp - _currentThreshold) max 0) min _xpRequired;
    _ratio = (_xpIntoLevel / _xpRequired) max 0 min 1;
    if !(finite _ratio) then {_ratio = 0};
};

createHashMapFromArray [
    ["level", _safeLevel],
    ["maxLevel", _maxLevel],
    ["xp", _safeXp],
    ["xpIntoLevel", _xpIntoLevel],
    ["xpRequired", _xpRequired],
    ["ratio", _ratio]
]

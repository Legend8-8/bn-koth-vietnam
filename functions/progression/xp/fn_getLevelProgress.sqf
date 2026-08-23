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

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};
_maxLevel = floor (_maxLevel max 1);

private _safeXp = _xp max 0;
private _safeLevel = (floor (_level max 1)) min _maxLevel;
private _xpIntoLevel = 0;
private _xpRequired = 0;
private _ratio = 1;

if (_safeLevel < _maxLevel) then {
    private _currentThreshold = [_safeLevel] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;
    private _nextThreshold = [_safeLevel + 1] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;

    _xpRequired = (_nextThreshold - _currentThreshold) max 1;
    _xpIntoLevel = ((_safeXp - _currentThreshold) max 0) min _xpRequired;
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

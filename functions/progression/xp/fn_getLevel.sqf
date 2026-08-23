/*
    File: fn_getLevel.sqf
    Author: Tylervip
    Edited: Legend
    Description: Calculates a level from cumulative XP using the configured curve.
    Execution: Any
    Parameters:
        0: Cumulative XP <NUMBER>
    Returns:
        Calculated level <NUMBER>
    Public: No
*/

params [["_xp", 0, [0]]];

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};
_maxLevel = floor (_maxLevel max 1);

private _safeXp = _xp max 0;
private _level = 1;

while {_level < _maxLevel} do {
    private _nextLevelThreshold = [_level + 1] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;
    if (_safeXp < _nextLevelThreshold) exitWith {};
    _level = _level + 1;
};

_level

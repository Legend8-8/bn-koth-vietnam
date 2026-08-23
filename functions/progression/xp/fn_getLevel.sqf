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

// Find the highest level whose cumulative XP threshold has been reached.
// Binary search keeps lookup cost bounded even if maxLevel grows later.
private _low = 1;
private _high = _maxLevel;

while {_low < _high} do {
    private _mid = floor ((_low + _high + 1) / 2);
    private _threshold = [_mid] call bn_koth_fnc_progression_xp_getXpThresholdForLevel;

    if (_safeXp >= _threshold) then {
        _low = _mid;
    } else {
        _high = _mid - 1;
    };
};

_low

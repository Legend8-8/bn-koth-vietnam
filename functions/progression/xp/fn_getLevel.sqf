/*
    File: fn_getLevel.sqf
    Author: Tylervip
    Description: Calculates a level from cumulative XP using the configured curve.
    Execution: Any
    Parameters:
        0: Cumulative XP <NUMBER>
    Returns:
        Calculated level <NUMBER>
    Public: No
*/

params [["_xp", 0, [0]]];

private _baseXp = missionNamespace getVariable ["BN_KOTH_xpLevelBase", 100];
private _levelStep = missionNamespace getVariable ["BN_KOTH_xpLevelStep", 50];
private _maxLevel = missionNamespace getVariable ["BN_KOTH_xpMaxLevel", 270];

private _level = 1;
private _safeXp = _xp max 0;
while {_level < _maxLevel} do {
    private _requiredXp = _baseXp + ((_level - 1) * _levelStep);
    if (_safeXp < _requiredXp) exitWith {};
    _safeXp = _safeXp - _requiredXp;
    _level = _level + 1;
};

_level min _maxLevel

/*
    File: fn_menu_formatCareerValue.sqf
    Author: Legend
    Description: Formats validated career and leaderboard values for player-facing display.
    Execution: Any
    Parameters: value <NUMBER>, metric ID <NUMBER>, optional deaths <NUMBER>
    Returns: Formatted value <STRING>
    Public: No
*/
params [["_value", 0, [0]], ["_metric", 1, [0]], ["_deaths", -1, [0]]];
if !(finite _value) exitWith {"—"};
if (_metric isEqualTo 9) exitWith {
    private _ratio = if (_deaths >= 0) then {_value / (_deaths max 1)} else {_value};
    if !(finite _ratio) exitWith {"0.00"};
    _ratio toFixed 2
};
if (_metric isEqualTo 8) exitWith {
    private _seconds = floor (_value max 0);
    private _hours = floor (_seconds / 3600);
    private _minutes = floor ((_seconds mod 3600) / 60);
    if (_hours > 0) then {format ["%1h %2m", _hours, if (_minutes < 10) then {format ["0%1", _minutes]} else {str _minutes}]} else {format ["%1m", _minutes]}
};
[round (_value max 0)] call BIS_fnc_numberText

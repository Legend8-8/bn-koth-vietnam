/*
    File: fn_formatCash.sqf
    Author: Legend
    Description: Formats a non-negative cash value for compact UI display.
    Execution: Any
    Parameters:
        0: Cash value <NUMBER>
    Returns:
        Dollar-prefixed whole cash value with thousands separators <STRING>
    Public: No
*/

params [["_cash", 0, [0]]];

private _digits = str (round (_cash max 0));
private _digitCount = count _digits;
private _formatted = "";

for "_index" from 0 to (_digitCount - 1) do {
    if (_index > 0 && {((_digitCount - _index) mod 3) isEqualTo 0}) then {
        _formatted = _formatted + ",";
    };
    _formatted = _formatted + (_digits select [_index, 1]);
};

format ["$%1", _formatted]

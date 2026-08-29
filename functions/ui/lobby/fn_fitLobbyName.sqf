/*
    File: fn_fitLobbyName.sqf
    Author: Legend
    Description: Width-fits one player-name presentation to an existing lobby control.
    Execution: Client
    Parameters:
        0: Measuring lobby control <CONTROL>
        1: Full player name <STRING>
        2: Width reserved for control chrome or adjacent row text <NUMBER> (optional)
    Returns:
        Unchanged or ellipsis-truncated presentation name <STRING>
    Public: No
*/

params [
    ["_control", controlNull, [controlNull]],
    ["_name", "", [""]],
    ["_reservedWidth", 0.016, [0]]
];

if (isNull _control || {_name isEqualTo ""}) exitWith {_name};

private _font = ctrlFont _control;
private _fontHeight = ctrlFontHeight _control;
private _availableWidth = (((ctrlPosition _control) select 2) - (_reservedWidth max 0)) max 0;
private _ellipsis = "...";

if ((_name getTextWidth [_font, _fontHeight]) <= _availableWidth) exitWith {_name};
if ((_ellipsis getTextWidth [_font, _fontHeight]) > _availableWidth) exitWith {""};

private _low = 0;
private _high = count _name;
while {_low < _high} do {
    private _middle = ceil ((_low + _high) / 2);
    private _candidate = (_name select [0, _middle]) + _ellipsis;
    if ((_candidate getTextWidth [_font, _fontHeight]) <= _availableWidth) then {
        _low = _middle;
    } else {
        _high = _middle - 1;
    };
};

(_name select [0, _low]) + _ellipsis

/*
    File: fn_runTypewriter.sqf
    Author: Legend
    Description: Renders one token-owned client-local deployment order with human typing cadence.
    Execution: Client scheduled
    Parameters:
        0: Transition lifecycle token <NUMBER>
        1: Theatre display name <STRING>
        2: AO display name <STRING>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\transition\idcs.hpp"

params ["_token", "_theatreName", "_locationName"];

if (!hasInterface) exitWith {};

private _newline = toString [10];
private _rendered = "";

private _isCurrent = {
    (uiNamespace getVariable ["BN_KOTH_transitionLifecycleToken", -1]) isEqualTo _token
};

private _setText = {
    params [["_showCursor", true, [true]]];
    if !(call _isCurrent) exitWith {false};

    private _display = uiNamespace getVariable ["BN_KOTH_transitionDisplay", displayNull];
    if (isNull _display) exitWith {false};

    private _control = _display displayCtrl BN_KOTH_IDC_TRANSITION_TEXT;
    if (isNull _control) exitWith {false};

    _control ctrlSetText (_rendered + (if (_showCursor) then {"_"} else {""}));
    true
};

private _typeText = {
    params ["_text"];

    {
        if !(call _isCurrent) exitWith {};

        private _character = toString [_x];
        _rendered = _rendered + _character;
        if !([true] call _setText) exitWith {};

        private _delay = 0.055 + random 0.035;
        if (_character isEqualTo " ") then {_delay = 0.025 + random 0.020};
        if (_character in [".", ":"]) then {_delay = 0.18 + random 0.10};
        if (_character isEqualTo _newline) then {_delay = 0.30 + random 0.12};
        if ((random 1) < 0.055 && {!(_character isEqualTo _newline)}) then {
            _delay = _delay + 0.10 + random 0.16;
        };

        uiSleep _delay;
    } forEach (toArray _text);
};

private _blinkCursor = {
    params ["_duration"];

    private _endAt = diag_tickTime + _duration;
    private _cursorVisible = true;
    while {diag_tickTime < _endAt && {call _isCurrent}} do {
        [_cursorVisible] call _setText;
        _cursorVisible = !_cursorVisible;
        uiSleep (0.24 + random 0.08);
    };

    if (call _isCurrent) then {
        [true] call _setText;
    };
};

private _commonPrefixLength = {
    params ["_left", "_right"];

    private _leftChars = toArray _left;
    private _rightChars = toArray _right;
    private _limit = (count _leftChars) min (count _rightChars);
    private _length = 0;

    for "_index" from 0 to (_limit - 1) do {
        if !((_leftChars select _index) isEqualTo (_rightChars select _index)) exitWith {};
        _length = _length + 1;
    };

    _length
};

private _typoOptions = [
    ["PREPARIGN AO", "PREPARING AO"],
    ["DEPLOYING FROCES", "DEPLOYING FORCES"],
    ["ESTABLISHING SPWAN", "ESTABLISHING SPAWN"]
];
private _chosenTypo = selectRandom _typoOptions;

["DEPLOYMENT ORDER"] call _typeText;
[1.25 + random 0.45] call _blinkCursor;
[_newline + _newline] call _typeText;

[format ["THEATRE: %1", toUpper _theatreName]] call _typeText;
[_newline] call _typeText;
[format ["AO: %1", toUpper _locationName]] call _typeText;
[1.25 + random 0.50] call _blinkCursor;
[_newline + _newline] call _typeText;

private _operationalLines = ["PREPARING AO", "DEPLOYING FORCES", "ESTABLISHING SPAWN"];
{
    if !(call _isCurrent) exitWith {};

    private _correctText = _x;
    private _typoText = _chosenTypo select 0;
    private _typoCorrectText = _chosenTypo select 1;

    if (_correctText isEqualTo _typoCorrectText) then {
        private _lineStart = count _rendered;
        [_typoText] call _typeText;
        [0.95 + random 0.40] call _blinkCursor;

        private _commonLength = [_typoText, _typoCorrectText] call _commonPrefixLength;
        private _targetLength = _lineStart + _commonLength;
        while {(count _rendered) > _targetLength && {call _isCurrent}} do {
            _rendered = _rendered select [0, (count _rendered) - 1];
            [true] call _setText;
            uiSleep (0.035 + random 0.025);
        };

        [_typoCorrectText select [_commonLength]] call _typeText;
    } else {
        [_correctText] call _typeText;
    };

    ["..."] call _typeText;
    [_newline] call _typeText;
} forEach _operationalLines;

[0.75 + random 0.35] call _blinkCursor;
["READY"] call _typeText;
[1.20 + random 0.45] call _blinkCursor;

if !(call _isCurrent) exitWith {};

uiNamespace setVariable ["BN_KOTH_transitionPresentationFinished", true];

if (uiNamespace getVariable ["BN_KOTH_transitionServerReady", false]) then {
    uiNamespace setVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
    [false] call bn_koth_fnc_ui_transition_hide;
} else {
    [_newline + _newline + "AWAITING DEPLOYMENT CLEARANCE"] call _typeText;
    [true] call _setText;
    uiNamespace setVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
};

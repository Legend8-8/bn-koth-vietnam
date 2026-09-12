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

private _typeSlowText = {
    params ["_text"];

    {
        if !(call _isCurrent) exitWith {};

        private _character = toString [_x];
        _rendered = _rendered + _character;
        if !([true] call _setText) exitWith {};

        private _delay = 0.15 + random 0.15;
        if (_character isEqualTo " ") then {_delay = 0.20 + random 0.12};
        if (_character in [":", ";", "-", ")"]) then {_delay = 0.32 + random 0.16};
        if ((random 1) < 0.10) then {_delay = _delay + 0.18 + random 0.18};
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

private _backspaceTo = {
    params ["_targetLength", ["_minimumDelay", 0.035, [0]]];

    while {(count _rendered) > _targetLength && {call _isCurrent}} do {
        _rendered = _rendered select [0, (count _rendered) - 1];
        [true] call _setText;
        uiSleep (_minimumDelay + random 0.025);
    };
};

private _transitionCfg = missionConfigFile >> "CfgBnKothDeploymentTransition";
private _meltdownChance = if (isNumber (_transitionCfg >> "meltdownChance")) then {
    getNumber (_transitionCfg >> "meltdownChance")
} else {
    0
};
_meltdownChance = (_meltdownChance max 0) min 1;
private _meltdownActive = (random 1) < _meltdownChance;

private _typoOptions = [
    ["PREPARIGN AO", "PREPARING AO"],
    ["DEPLOYING FROCES", "DEPLOYING FORCES"],
    ["ESTABLISHING SPWAN", "ESTABLISHING SPAWN"]
];
private _chosenTypo = selectRandom _typoOptions;

["DEPLOYMENT ORDER"] call _typeText;
[1.25 + random 0.45] call _blinkCursor;
[_newline + _newline] call _typeText;

private _theatreValue = toUpper _theatreName;
private _theatreLine = format ["THEATRE: %1", _theatreValue];

if (_meltdownActive) then {
    private _theatreStart = count _rendered;
    private _theatreCharacters = toArray _theatreValue;
    private _swapIndices = [];
    for "_index" from 0 to ((count _theatreCharacters) - 2) do {
        private _left = _theatreCharacters select _index;
        private _right = _theatreCharacters select (_index + 1);
        if (_left != 32 && {_right != 32} && {_left != _right}) then {
            _swapIndices pushBack _index;
        };
    };

    private _makeSwapTypo = {
        params ["_index"];
        private _characters = +_theatreCharacters;
        if (_index >= 0 && {_index < ((count _characters) - 1)}) then {
            private _left = _characters select _index;
            _characters set [_index, _characters select (_index + 1)];
            _characters set [_index + 1, _left];
        };
        format ["THEATRE: %1", toString _characters]
    };

    private _firstSwap = if ((count _swapIndices) > 0) then {selectRandom _swapIndices} else {-1};
    private _remainingSwapIndices = _swapIndices - [_firstSwap];
    private _thirdSwap = if ((count _remainingSwapIndices) > 0) then {selectRandom _remainingSwapIndices} else {_firstSwap};
    private _duplicateCharacter = if ((count _theatreCharacters) > 0) then {
        toString [_theatreCharacters select ((count _theatreCharacters) - 1)]
    } else {
        "X"
    };

    private _typoAttempts = [
        if (_firstSwap >= 0) then {[_firstSwap] call _makeSwapTypo} else {_theatreLine + "X"},
        _theatreLine + _duplicateCharacter,
        if (_thirdSwap >= 0 && {_thirdSwap != _firstSwap}) then {[_thirdSwap] call _makeSwapTypo} else {_theatreLine select [0, ((count _theatreLine) - 1) max 0]}
    ];

    private _currentAttempt = "";
    {
        if !(call _isCurrent) exitWith {};

        private _nextAttempt = _x;
        if (_currentAttempt isEqualTo "") then {
            [_nextAttempt] call _typeText;
        } else {
            private _currentPrefix = [_currentAttempt, _theatreLine] call _commonPrefixLength;
            private _nextPrefix = [_nextAttempt, _theatreLine] call _commonPrefixLength;
            private _retainedPrefix = _currentPrefix min _nextPrefix;
            [_theatreStart + _retainedPrefix] call _backspaceTo;
            [_nextAttempt select [_retainedPrefix]] call _typeText;
        };

        _currentAttempt = _nextAttempt;
        [if (_forEachIndex < 2) then {0.75 + random 0.35} else {1.35 + random 0.45}] call _blinkCursor;
    } forEach _typoAttempts;

    if (call _isCurrent) then {
        private _keyboardPools = [
            "QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM", "FJDKSL", "PLMOKN",
            "QAZWSX", "JKLDSA", "MNBVCX", "POIUYT", "LKJHGF"
        ];
        private _anzacSlam = floor random 11;
        private _quickFollowUpAfter = floor random 10;

        for "_slam" from 0 to 10 do {
            if !(call _isCurrent) exitWith {};

            private _targetLength = 15 + floor random 36;
            private _chunk = "";
            while {(count _chunk) < _targetLength} do {
                private _pool = selectRandom _keyboardPools;
                private _poolStart = floor random ((count _pool) max 1);
                _chunk = _chunk + (_pool select [_poolStart]) + (selectRandom _keyboardPools);
            };
            _chunk = _chunk select [0, _targetLength];

            // Reserve the one authored Easter-egg occurrence rather than
            // allowing an accidental match in the generated keyboard mash.
            while {(_chunk find "ANZAC") >= 0} do {
                private _matchIndex = _chunk find "ANZAC";
                _chunk = (_chunk select [0, _matchIndex]) + "ASDFG" + (_chunk select [_matchIndex + 5]);
            };
            if (_slam isEqualTo _anzacSlam) then {
                private _insertAt = 3 + floor random (((count _chunk) - 8) max 1);
                _chunk = (_chunk select [0, _insertAt]) + "ANZAC" + (_chunk select [_insertAt + 5]);
            };

            _rendered = _rendered + _newline + _chunk;
            [true] call _setText;
            uiSleep (if (_slam isEqualTo _quickFollowUpAfter) then {
                0.18 + random 0.08
            } else {
                0.40 + random 0.20
            });
        };
    };

    if (call _isCurrent) then {
        [1.25 + random 0.55] call _blinkCursor;
    };

    if (call _isCurrent) then {
        private _display = uiNamespace getVariable ["BN_KOTH_transitionDisplay", displayNull];
        private _textControl = if (isNull _display) then {controlNull} else {_display displayCtrl BN_KOTH_IDC_TRANSITION_TEXT};
        if (!isNull _textControl) then {
            _textControl ctrlSetTextColor [0.03, 0.03, 0.025, 1];
            _textControl ctrlSetBackgroundColor [0.88, 0.86, 0.76, 0.96];
            uiSleep 0.75;
        };

        if (call _isCurrent) then {
            _rendered = _rendered select [0, _theatreStart];
            if (!isNull _textControl) then {
                _textControl ctrlSetBackgroundColor [0, 0, 0, 0];
                _textControl ctrlSetTextColor [0.88, 0.86, 0.76, 1];
            };
            [true] call _setText;
            [0.65 + random 0.25] call _blinkCursor;
            [_theatreLine + " ;-)"] call _typeSlowText;
            [0.85 + random 0.30] call _blinkCursor;
        };
    };
} else {
    [_theatreLine] call _typeText;
};

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

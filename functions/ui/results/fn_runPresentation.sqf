/*
    File: fn_runPresentation.sqf
    Author: Legend
    Description: Renders one token-owned client-local after-action report sequence.
    Execution: Client scheduled
    Parameters:
        0: Results lifecycle token <NUMBER>
        1: Immutable completed-round presentation snapshot <HASHMAP>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\results\idcs.hpp"

params ["_token", "_snapshot"];

if (!hasInterface) exitWith {};
if !(_snapshot isEqualType createHashMap) exitWith {};

private _isCurrent = {
    (uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", -1]) isEqualTo _token
};

private _display = displayNull;
private _displayDeadline = diag_tickTime + 2;
waitUntil {
    _display = uiNamespace getVariable ["BN_KOTH_resultsDisplay", displayNull];
    !isNull _display || {diag_tickTime >= _displayDeadline} || {!(call _isCurrent)}
};
if (isNull _display || {!(call _isCurrent)}) exitWith {};

private _winner = _snapshot getOrDefault ["winner", sideUnknown];
private _leftSide = _snapshot getOrDefault ["leftSide", west];
private _rightSide = _snapshot getOrDefault ["rightSide", east];
private _leftScore = _snapshot getOrDefault ["leftScore", 0];
private _rightScore = _snapshot getOrDefault ["rightScore", 0];
private _leaders = _snapshot getOrDefault ["leaders", createHashMap];
private _personal = _snapshot getOrDefault ["personal", createHashMap];
if !(_personal isEqualType createHashMap) then {_personal = createHashMap};
private _players = _snapshot getOrDefault ["players", []];
if !(_players isEqualType []) then {_players = []};

(_display displayCtrl BN_KOTH_IDC_RESULTS_OUTCOME) ctrlSetText (
    if (_winner in [_leftSide, _rightSide]) then {format ["%1 VICTORY", toUpper str _winner]} else {"ROUND COMPLETE"}
);
(_display displayCtrl BN_KOTH_IDC_RESULTS_SCORE) ctrlSetText format [
    "%1  %2    -    %3  %4",
    toUpper str _leftSide,
    _leftScore,
    _rightScore,
    toUpper str _rightSide
];

if ((count _personal) <= 0) then {
    (_display displayCtrl BN_KOTH_IDC_RESULTS_PERSONAL) ctrlSetText "YOU  —  NO ROUND STATISTICS";
    (_display displayCtrl BN_KOTH_IDC_RESULTS_REWARDS) ctrlSetText "ROUND REWARDS  —  NOT AVAILABLE";
} else {
    private _kills = _personal getOrDefault ["kills", 0];
    private _deaths = _personal getOrDefault ["deaths", 0];
    private _assists = _personal getOrDefault ["assists", 0];
    private _objective = _personal getOrDefault ["objectivePoints", 0];
    private _bestStreak = _personal getOrDefault ["bestStreak", 0];
    private _kd = if (_deaths > 0) then {(_kills / _deaths) toFixed 2} else {str _kills};
    (_display displayCtrl BN_KOTH_IDC_RESULTS_PERSONAL) ctrlSetText format [
        "YOU  %1 KILLS  /  %2 DEATHS  /  %3 ASSISTS  /  %4 OBJ  /  %5 K/D  /  BEST %6",
        _kills, _deaths, _assists, _objective, _kd, _bestStreak
    ];
    private _xpEarned = _personal getOrDefault ["xpEarned", 0];
    private _cashEarned = _personal getOrDefault ["cashEarned", 0];
    private _startLevel = _personal getOrDefault ["startLevel", 1];
    private _endLevel = _personal getOrDefault ["endLevel", _startLevel];
    (_display displayCtrl BN_KOTH_IDC_RESULTS_REWARDS) ctrlSetText format [
        "ROUND  %1%2 XP  /  $%3%4  /  LEVEL %5%6",
        if (_xpEarned >= 0) then {"+"} else {""}, _xpEarned,
        if (_cashEarned >= 0) then {"+"} else {""}, _cashEarned,
        _startLevel, if (_endLevel isEqualTo _startLevel) then {""} else {format [" > %1", _endLevel]}
    ];
};
private _duration = round (_snapshot getOrDefault ["durationSeconds", 0]);
private _minutes = floor (_duration / 60);
private _seconds = _duration mod 60;
(_display displayCtrl BN_KOTH_IDC_RESULTS_DURATION) ctrlSetText format [
    "DURATION  %1:%2",
    if (_minutes < 10) then {format ["0%1", _minutes]} else {str _minutes},
    if (_seconds < 10) then {format ["0%1", _seconds]} else {str _seconds}
];

private _renderLeader = {
    params ["_key", "_nameIdc", "_valueIdc", "_singular", "_plural"];
    private _entry = _leaders getOrDefault [_key, createHashMap];
    if !(_entry isEqualType createHashMap) then {_entry = createHashMap};
    private _name = _entry getOrDefault ["name", ""];
    private _value = _entry getOrDefault ["value", 0];
    private _nameControl = _display displayCtrl _nameIdc;

    if (_name isEqualTo "" || {_value <= 0}) then {
        _nameControl ctrlSetText "NO LEADER";
        (_display displayCtrl _valueIdc) ctrlSetText format ["0 %1", _plural];
    } else {
        _nameControl ctrlSetText ([_nameControl, _name, 0.006] call bn_koth_fnc_ui_fitLobbyName);
        (_display displayCtrl _valueIdc) ctrlSetText format [
            "%1 %2",
            _value,
            if (_value isEqualTo 1) then {_singular} else {_plural}
        ];
    };
};

["mostDeadly", BN_KOTH_IDC_RESULTS_LEADER_1_NAME, BN_KOTH_IDC_RESULTS_LEADER_1_VALUE, "KILL", "KILLS"] call _renderLeader;
["objective", BN_KOTH_IDC_RESULTS_LEADER_2_NAME, BN_KOTH_IDC_RESULTS_LEADER_2_VALUE, "PT", "PTS"] call _renderLeader;
["bestStreak", BN_KOTH_IDC_RESULTS_LEADER_3_NAME, BN_KOTH_IDC_RESULTS_LEADER_3_VALUE, "KILL", "KILLS"] call _renderLeader;

// The server owns every value in these rows. Sorting is presentation-only and
// deliberately transparent: team, objective contribution, kills, then name.
_players = _players select {_x isEqualType createHashMap};
private _sortedPlayers = [];
private _appendRankedGroup = {
    params ["_sidePlayers"];

    private _objectiveValues = [];
    {_objectiveValues pushBackUnique (_x getOrDefault ["objectivePoints", 0])} forEach _sidePlayers;
    _objectiveValues sort false;

    {
        private _objectiveValue = _x;
        private _objectivePlayers = _sidePlayers select {
            (_x getOrDefault ["objectivePoints", 0]) isEqualTo _objectiveValue
        };
        private _killValues = [];
        {_killValues pushBackUnique (_x getOrDefault ["kills", 0])} forEach _objectivePlayers;
        _killValues sort false;

        {
            private _killValue = _x;
            private _killPlayers = _objectivePlayers select {
                (_x getOrDefault ["kills", 0]) isEqualTo _killValue
            };
            _killPlayers = [_killPlayers, [], {
                format ["%1|%2", toLower (_x getOrDefault ["name", ""]), _x getOrDefault ["uid", ""]]
            }, "ASCEND"] call BIS_fnc_sortBy;
            _sortedPlayers append _killPlayers;
        } forEach _killValues;
    } forEach _objectiveValues;
};

[_players select {(_x getOrDefault ["side", sideUnknown]) isEqualTo west}] call _appendRankedGroup;
[_players select {(_x getOrDefault ["side", sideUnknown]) isEqualTo east}] call _appendRankedGroup;
[_players select {!((_x getOrDefault ["side", sideUnknown]) in [west, east])}] call _appendRankedGroup;
_players = _sortedPlayers;

private _scoreboard = _display displayCtrl BN_KOTH_IDC_RESULTS_SCOREBOARD;
lnbClear _scoreboard;
private _headerRow = _scoreboard lnbAddRow ["PLAYER", "TEAM", "K", "D", "A", "K/D", "OBJ", "BEST", "XP", "CASH"];
for "_column" from 0 to 9 do {
    _scoreboard lnbSetColor [[_headerRow, _column], [0.72, 0.55, 0.20, 1]];
};
private _localUid = if (!isNull player) then {getPlayerUID player} else {""};
{
    private _name = _x getOrDefault ["name", _x getOrDefault ["uid", "UNKNOWN"]];
    if ((count _name) > 24) then {_name = (_name select [0, 23]) + "…"};
    if ((_x getOrDefault ["uid", ""]) isEqualTo _localUid) then {_name = _name + " [YOU]"};
    if !(_x getOrDefault ["connected", true]) then {_name = _name + " [LEFT]"};
    private _side = _x getOrDefault ["side", sideUnknown];
    private _team = if (_side isEqualTo west) then {"WEST"} else {if (_side isEqualTo east) then {"EAST"} else {"—"}};
    private _kills = _x getOrDefault ["kills", 0];
    private _deaths = _x getOrDefault ["deaths", 0];
    private _kd = if (_deaths > 0) then {(_kills / _deaths) toFixed 2} else {str _kills};
    private _row = _scoreboard lnbAddRow [
        _name, _team, str _kills, str (_x getOrDefault ["deaths", 0]),
        str (_x getOrDefault ["assists", 0]), _kd,
        str (_x getOrDefault ["objectivePoints", 0]), str (_x getOrDefault ["bestStreak", 0]),
        str (_x getOrDefault ["xpEarned", 0]), str (_x getOrDefault ["cashEarned", 0])
    ];
    private _rowColor = if (_side isEqualTo west) then {[0.55, 0.72, 0.95, 1]} else {if (_side isEqualTo east) then {[0.95, 0.55, 0.50, 1]} else {[0.78, 0.76, 0.70, 1]}};
    for "_column" from 0 to 9 do {_scoreboard lnbSetColor [[_row, _column], _rowColor]};
} forEach _players;
if ((count _players) isEqualTo 0) then {
    _scoreboard lnbAddRow ["NO ROUND PARTICIPANTS", "", "", "", "", "", "", "", "", ""];
};

private _groups = [
    [BN_KOTH_IDC_RESULTS_FRAME, BN_KOTH_IDC_RESULTS_ACCENT, BN_KOTH_IDC_RESULTS_TITLE],
    [BN_KOTH_IDC_RESULTS_OUTCOME],
    [BN_KOTH_IDC_RESULTS_SCORE_LABEL, BN_KOTH_IDC_RESULTS_SCORE],
    [BN_KOTH_IDC_RESULTS_PERSONAL, BN_KOTH_IDC_RESULTS_REWARDS, BN_KOTH_IDC_RESULTS_DURATION],
    [BN_KOTH_IDC_RESULTS_LEADER_1_CARD, BN_KOTH_IDC_RESULTS_LEADER_1_LABEL, BN_KOTH_IDC_RESULTS_LEADER_1_NAME, BN_KOTH_IDC_RESULTS_LEADER_1_VALUE],
    [BN_KOTH_IDC_RESULTS_LEADER_2_CARD, BN_KOTH_IDC_RESULTS_LEADER_2_LABEL, BN_KOTH_IDC_RESULTS_LEADER_2_NAME, BN_KOTH_IDC_RESULTS_LEADER_2_VALUE],
    [BN_KOTH_IDC_RESULTS_LEADER_3_CARD, BN_KOTH_IDC_RESULTS_LEADER_3_LABEL, BN_KOTH_IDC_RESULTS_LEADER_3_NAME, BN_KOTH_IDC_RESULTS_LEADER_3_VALUE],
    [BN_KOTH_IDC_RESULTS_SCOREBOARD_LABEL, BN_KOTH_IDC_RESULTS_SCOREBOARD],
    [BN_KOTH_IDC_RESULTS_STATUS, BN_KOTH_IDC_RESULTS_FOOTER]
];

{
    {(_display displayCtrl _x) ctrlSetFade 1; (_display displayCtrl _x) ctrlCommit 0} forEach _x;
} forEach _groups;

uiSleep 0.35;
{
    if !(call _isCurrent) exitWith {};
    {(_display displayCtrl _x) ctrlSetFade 0; (_display displayCtrl _x) ctrlCommit 0.45} forEach _x;
    uiSleep 0.65;
} forEach _groups;

if !(call _isCurrent) exitWith {};
uiSleep 3.2;
if !(call _isCurrent) exitWith {};

uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", true];
uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
[] call bn_koth_fnc_ui_results_update;

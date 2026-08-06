/*
    File: fn_awardControlTick.sqf
    Author: tylervip
    Edited: Legend
    Description: Awards score tick to controlling side.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "ACTIVE") exitWith {};

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _controller = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
if !(_controller in _playableSides) exitWith {};

private _scores = missionNamespace getVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]
];
private _tick = missionNamespace getVariable ["BN_KOTH_scoreTick", 1];
private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", 100];

private _current = _scores getOrDefault [_controller, 0];
private _newScore = _current + _tick;

_scores set [_controller, _newScore];
missionNamespace setVariable ["BN_KOTH_teamScores", _scores, true];

[format ["Score tick: %1 -> %2", _controller, _newScore]] call bn_koth_fnc_common_log;

if (_newScore >= _scoreLimit) then {
    [_controller] call bn_koth_fnc_round_endWithWinner;
};

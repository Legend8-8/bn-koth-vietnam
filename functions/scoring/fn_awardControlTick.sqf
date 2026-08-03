/*
    File: fn_awardControlTick.sqf
    Description: Awards score tick to controlling side.
    Execution: Server
*/

if (!isServer) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "ACTIVE") exitWith {};

private _controller = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
if !(_controller in [west, east]) exitWith {};

private _scores = missionNamespace getVariable ["BN_KOTH_teamScores", createHashMapFromArray [[west, 0], [east, 0]]];
private _tick = missionNamespace getVariable ["BN_KOTH_scoreTick", 1];
private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", 100];

private _current = _scores getOrDefault [_controller, 0];
private _newScore = _current + _tick;

_scores set [_controller, _newScore];
missionNamespace setVariable ["BN_KOTH_teamScores", _scores, true];

[format ["Score tick: %1 -> %2", _controller, _newScore]] call bn_koth_fnc_log;

if (_newScore >= _scoreLimit) then {
    missionNamespace setVariable ["BN_KOTH_winningSide", _controller, true];
    ["ENDING"] call bn_koth_fnc_round_setState;
    // Placeholder: trigger end-of-round UI and reset flow.
};

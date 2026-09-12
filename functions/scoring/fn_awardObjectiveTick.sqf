/*
    File: fn_awardObjectiveTick.sqf
    Author: tylervip
    Edited: Legend
    Description: Advances the occupied-AO objective cycle, dispatches rewards, and awards controlled team score.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _roundState = [] call bn_koth_fnc_round_getState;
private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
if (!(_roundState isEqualTo "ACTIVE") || {_marker isEqualTo ""} || {!(_zoneState in ["CONTROLLED", "CONTESTED"])}) exitWith {
    [] call bn_koth_fnc_scoring_resetProgress;
};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _duration = (missionNamespace getVariable ["BN_KOTH_scoreTickInterval", getNumber (_scoringCfg >> "scoreTickInterval")]) max 1;
private _progress = missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap];
if !(_progress isEqualType createHashMap) exitWith {
    [] call bn_koth_fnc_scoring_resetProgress;
};

private _startedAt = _progress getOrDefault ["startedAt", -1];
private _active = _progress getOrDefault ["active", false];
private _seedCycle = {
    params ["_start"];
    ["BN_KOTH_scoreProgress", createHashMapFromArray [
        ["side", sideUnknown],
        ["base", 0],
        ["startedAt", _start],
        ["active", true],
        ["duration", _duration]
    ]] call bn_koth_fnc_common_publicState;
};

if (!_active || {_startedAt < 0}) exitWith {
    [serverTime] call _seedCycle;
};

_duration = (_progress getOrDefault ["duration", _duration]) max 1;
if ((serverTime - _startedAt) < _duration) exitWith {};

// Refresh zone-owned eligibility at completion, without recursively advancing scoring.
private _controller = [true] call bn_koth_fnc_zone_evaluateControl;
_zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
if !(_zoneState in ["CONTROLLED", "CONTESTED"]) exitWith {
    [] call bn_koth_fnc_scoring_resetProgress;
};

[] call bn_koth_fnc_progression_xp_awardObjectiveTick;

if (_zoneState isEqualTo "CONTROLLED" && {[_controller] call bn_koth_fnc_teams_validateSide}) then {
    private _scoreTick = missionNamespace getVariable ["BN_KOTH_scoreTick", getNumber (_scoringCfg >> "scoreTick")];
    private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", getNumber (_scoringCfg >> "scoreLimit")];
    private _scores = missionNamespace getVariable ["BN_KOTH_teamScores", createHashMap];
    private _newScore = (_scores getOrDefault [_controller, 0]) + _scoreTick;
    _scores set [_controller, _newScore];
    missionNamespace setVariable ["BN_KOTH_teamScores", _scores, true];

    [_controller, _scoreTick] call bn_koth_fnc_roundStats_recordObjectiveTick;
    [format ["Score tick: %1 -> %2", _controller, _newScore]] call bn_koth_fnc_common_log;
    if (_newScore >= _scoreLimit) then {
        [_controller] call bn_koth_fnc_round_endWithWinner;
    };
};

// ENDING owns reset. Never seed another cycle after the winning tick.
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {};

// Preserve the authoritative phase despite cadence/network delay. After a stall,
// award only the current completion, never replay rewards for missed snapshots.
private _completedIntervals = floor ((serverTime - _startedAt) / _duration);
[_startedAt + (_completedIntervals * _duration)] call _seedCycle;

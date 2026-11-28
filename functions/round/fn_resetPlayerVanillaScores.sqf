/*
    File: fn_resetPlayerVanillaScores.sqf
    Author: Legend
    Description: Clears one deployed player's vanilla P-screen counters once per ACTIVE round.
    Execution: Server
    Parameters:
        0: Current player unit <OBJECT>
    Returns:
        True when this player was processed for the round, otherwise false <BOOL>
    Public: No
*/

params [["_player", objNull, [objNull]]];

if (!isServer || {isNull _player} || {!isPlayer _player}) exitWith {false};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {false};

private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {false};
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};
if !((_record getOrDefault ["currentUnit", objNull]) isEqualTo _player
    && {_record getOrDefault ["deployed", false]}
    && {(_record getOrDefault ["ownerId", -1]) isEqualTo owner _player}) exitWith {false};

private _roundStartedAt = missionNamespace getVariable ["BN_KOTH_roundStartedAt", -1];
if (_roundStartedAt < 0 || {(_record getOrDefault ["vanillaScoresResetRound", -1]) isEqualTo _roundStartedAt}) exitWith {false};

private _scores = getPlayerScores _player;
if ((count _scores) < 5) exitWith {
    [format ["[ROUND] Vanilla score reset deferred: unavailable scores uid=%1 round=%2", _uid, _roundStartedAt], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _totalScore = score _player;
if ((_scores select [0, 5]) isNotEqualTo [0, 0, 0, 0, 0]) then {
    _player addPlayerScores [
        -(_scores select 0),
        -(_scores select 1),
        -(_scores select 2),
        -(_scores select 3),
        -(_scores select 4)
    ];
};
if (_totalScore != 0) then {
    [_player, -_totalScore] call BIS_fnc_addScore;
};

_record set ["vanillaScoresResetRound", _roundStartedAt];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[format ["[ROUND] Reset vanilla scores uid=%1 round=%2", _uid, _roundStartedAt], "INFO"] call bn_koth_fnc_common_log;
true

/*
    File: fn_finalize.sqf
    Author: Legend
    Description: Awards configured end-of-round bonuses exactly once and publishes
        the immutable authoritative after-action result model.
    Execution: Server
    Parameters: 0: Winning side <SIDE>
    Returns: Whether finalization completed or had already completed <BOOL>
    Public: No
*/

params [["_winningSide", sideUnknown, [sideUnknown]]];
if (!isServer) exitWith {false};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {false};
if !([_winningSide] call bn_koth_fnc_teams_validateSide) exitWith {false};
if (missionNamespace getVariable ["BN_KOTH_roundStatsFinalized", false]) exitWith {true};
if (missionNamespace getVariable ["BN_KOTH_roundStatsFinalizing", false]) exitWith {false};
missionNamespace setVariable ["BN_KOTH_roundStatsFinalizing", true];

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
if !(_stats isEqualType createHashMap) then {_stats = createHashMap};
private _eligible = [];
{
    private _uid = _x;
    private _record = _records getOrDefault [_uid, createHashMap];
    private _entry = _stats getOrDefault [_uid, createHashMap];
    private _side = _record getOrDefault ["assignedSide", sideUnknown];
    if (_entry isEqualType createHashMap
        && {_entry getOrDefault ["registered", false]}
        && {_record isEqualType createHashMap}
        && {(_record getOrDefault ["ownerId", -1]) > 0}
        && {[_side] call bn_koth_fnc_teams_validateSide}
        && {_side isEqualTo (_entry getOrDefault ["side", sideUnknown])}) then {
        _eligible pushBackUnique _uid;
    };
} forEach (keys _stats);

private _xpParticipation = missionNamespace getVariable ["BN_KOTH_xpRoundParticipationBonus", 0];
private _xpWinner = missionNamespace getVariable ["BN_KOTH_xpRoundWinnerBonus", 0];
private _cashParticipation = missionNamespace getVariable ["BN_KOTH_cashRoundParticipationBonus", 0];
private _cashWinner = missionNamespace getVariable ["BN_KOTH_cashRoundWinnerBonus", 0];

{
    private _uid = _x;
    private _record = _records get _uid;
    private _side = _record getOrDefault ["assignedSide", sideUnknown];
    if (_xpParticipation > 0) then {[_uid, _xpParticipation, "round_participation"] call bn_koth_fnc_progression_xp_addXp};
    if (_cashParticipation > 0) then {[_uid, _cashParticipation, "round_participation"] call bn_koth_fnc_progression_cash_addCash};
    if (_side isEqualTo _winningSide) then {
        if (_xpWinner > 0) then {[_uid, _xpWinner, "round_winner"] call bn_koth_fnc_progression_xp_addXp};
        if (_cashWinner > 0) then {[_uid, _cashWinner, "round_winner"] call bn_koth_fnc_progression_cash_addCash};
    };
} forEach _eligible;

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _rows = [];
{
    private _uid = _x;
    private _entry = _stats get _uid;
    if (_entry isEqualType createHashMap && {_entry getOrDefault ["registered", false]}) then {
        private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
        if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
        private _record = _records getOrDefault [_uid, createHashMap];
        private _connected = _record isEqualType createHashMap && {(_record getOrDefault ["ownerId", -1]) > 0};
        _rows pushBack createHashMapFromArray [
            ["uid", _uid], ["name", _entry getOrDefault ["name", _uid]],
            ["side", _entry getOrDefault ["side", sideUnknown]],
            ["connected", _connected],
            ["kills", _entry getOrDefault ["kills", 0]],
            ["deaths", _entry getOrDefault ["deaths", 0]],
            ["assists", _entry getOrDefault ["assists", 0]],
            ["teamkills", _entry getOrDefault ["teamkills", 0]],
            ["objectivePoints", _entry getOrDefault ["objectivePoints", 0]],
            ["bestStreak", _entry getOrDefault ["bestStreak", 0]],
            ["xpEarned", _entry getOrDefault ["xpEarned", 0]],
            ["cashEarned", _entry getOrDefault ["cashEarned", 0]],
            ["startLevel", _entry getOrDefault ["startLevel", 1]],
            ["endLevel", _progression getOrDefault ["level", _entry getOrDefault ["startLevel", 1]]]
        ];
    };
} forEach (keys _stats);

private _result = createHashMapFromArray [
    ["winner", _winningSide],
    ["teamScores", missionNamespace getVariable ["BN_KOTH_teamScores", createHashMap]],
    ["leaders", missionNamespace getVariable ["BN_KOTH_liveLeaders", createHashMap]],
    ["durationSeconds", (serverTime - (missionNamespace getVariable ["BN_KOTH_roundStartedAt", serverTime])) max 0],
    ["players", _rows]
];
["BN_KOTH_roundResult", _result] call bn_koth_fnc_common_publicState;
missionNamespace setVariable ["BN_KOTH_roundStatsFinalized", true];
missionNamespace setVariable ["BN_KOTH_roundStatsFinalizing", false];
[format ["Round result finalized: winner=%1 eligible=%2 rows=%3", _winningSide, count _eligible, count _rows], "INFO"] call bn_koth_fnc_common_log;
true

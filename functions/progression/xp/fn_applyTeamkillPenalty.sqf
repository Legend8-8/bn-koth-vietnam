/*
    File: fn_applyTeamkillPenalty.sqf
    Author: Legend
    Description: Applies configured XP/cash consequences to one authoritative teamkill.
    Execution: Server
    Parameters: 0: Canonical kill record <HASHMAP>
    Returns: Whether a configured consequence was applied <BOOL>
    Public: No
*/

params [["_killRecord", createHashMap, [createHashMap]]];
if (!isServer || {(count _killRecord) == 0}) exitWith {false};
if !(_killRecord getOrDefault ["roundActive", false]) exitWith {false};
if !(_killRecord getOrDefault ["teamkill", false]) exitWith {false};
if (_killRecord getOrDefault ["suicide", false]) exitWith {false};
private _uid = _killRecord getOrDefault ["killerUid", ""];
if (_uid isEqualTo "") exitWith {false};
private _eventKey = _killRecord getOrDefault ["eventKey", ""];
if (_eventKey isEqualTo "") exitWith {false};
private _processed = missionNamespace getVariable ["BN_KOTH_teamkillPenaltyProcessedKills", createHashMap];
if !(_processed isEqualType createHashMap) then {_processed = createHashMap};
if !(isNil {_processed get _eventKey}) exitWith {false};
_processed set [_eventKey, diag_tickTime];
missionNamespace setVariable ["BN_KOTH_teamkillPenaltyProcessedKills", _processed];

private _xp = [_uid, missionNamespace getVariable ["BN_KOTH_xpTeamkillPenalty", 0], "teamkill"] call bn_koth_fnc_progression_xp_applyPenalty;
private _cash = [_uid, missionNamespace getVariable ["BN_KOTH_cashTeamkillPenalty", 0], "teamkill"] call bn_koth_fnc_progression_cash_applyPenalty;
if (_xp <= 0 && {_cash <= 0}) then {
    [_uid, "teamkill", 0, "teamkill"] call bn_koth_fnc_progression_publishUpdate;
};
(_xp > 0) || {_cash > 0}

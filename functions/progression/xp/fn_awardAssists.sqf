/*
    File: fn_awardAssists.sqf
    Author: Legend
    Description: Awards configured XP and cash to server-validated assistants.
    Execution: Server
    Parameters: 0: Canonical kill record <HASHMAP>
    Returns: Number of assistants processed <NUMBER>
    Public: No
*/

params [["_killRecord", createHashMap, [createHashMap]]];
if (!isServer || {(count _killRecord) == 0}) exitWith {0};
if !(_killRecord getOrDefault ["roundActive", false]) exitWith {0};
if !(_killRecord getOrDefault ["validPvp", false]) exitWith {0};

private _eventKey = _killRecord getOrDefault ["eventKey", ""];
if (_eventKey isEqualTo "") exitWith {0};
private _processed = missionNamespace getVariable ["BN_KOTH_assistProcessedKills", createHashMap];
if !(_processed isEqualType createHashMap) then {_processed = createHashMap};
if !(isNil {_processed get _eventKey}) exitWith {0};
_processed set [_eventKey, diag_tickTime];
missionNamespace setVariable ["BN_KOTH_assistProcessedKills", _processed];

private _xp = missionNamespace getVariable ["BN_KOTH_xpPerAssist", 0];
private _cash = missionNamespace getVariable ["BN_KOTH_cashPerAssist", 0];
private _count = 0;
{
    if !(_x isEqualTo "") then {
        if (_xp > 0) then {[_x, _xp, "assist"] call bn_koth_fnc_progression_xp_addXp};
        if (_cash > 0) then {[_x, _cash, "assist"] call bn_koth_fnc_progression_cash_addCash};
        _count = _count + 1;
    };
} forEach (_killRecord getOrDefault ["assistUids", []]);
_count

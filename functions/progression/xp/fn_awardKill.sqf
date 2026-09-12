/*
    File: fn_awardKill.sqf
    Author: Tylervip
    Edited: Legend
    Description: Awards configured XP and cash from an already validated
        canonical combat kill record.
        Combat owns kill identity, side, suicide/teamkill/PvP, and round-state
        interpretation. Progression only decides whether that validated kill is
        eligible for progression rewards.
    Execution: Server
    Parameters:
        0: Canonical combat kill record <HASHMAP>
    Returns:
        Updated progression state, or an empty hash map when rejected <HASHMAP>
    Public: No
*/

params [["_killRecord", createHashMap, [createHashMap]]];

if (!isServer) exitWith {createHashMap};
if ((count _killRecord) == 0) exitWith {createHashMap};

if !(_killRecord getOrDefault ["roundActive", false]) exitWith {createHashMap};
if !(_killRecord getOrDefault ["validPvp", false]) exitWith {createHashMap};
if (_killRecord getOrDefault ["suicide", false]) exitWith {createHashMap};
if (_killRecord getOrDefault ["teamkill", false]) exitWith {createHashMap};

private _killerUid = _killRecord getOrDefault ["killerUid", ""];
if (_killerUid isEqualTo "") exitWith {createHashMap};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {createHashMap};

private _killerRecord = _records getOrDefault [_killerUid, createHashMap];
if !(_killerRecord isEqualType createHashMap) exitWith {createHashMap};

private _killerEligible =
    (_killerRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"
    && {_killerRecord getOrDefault ["deployed", false]};

if (!_killerEligible) exitWith {createHashMap};

private _xpAmount = missionNamespace getVariable ["BN_KOTH_xpPerKill", 100];
private _cashAmount = missionNamespace getVariable ["BN_KOTH_cashPerKill", 0];
if (_xpAmount <= 0 && {_cashAmount <= 0}) exitWith {createHashMap};

private _xpResult = if (_xpAmount > 0) then {
    [_killerUid, _xpAmount, "kill"] call bn_koth_fnc_progression_xp_addXp
} else {
    createHashMap
};

if (_cashAmount > 0) then {
    [_killerUid, _cashAmount, "kill"] call bn_koth_fnc_progression_cash_addCash;
};

_xpResult

/*
    File: fn_finalizeAssists.sqf
    Author: Legend
    Description: Consumes bounded server-local damage contributions for one death
        and returns canonical eligible assistant UIDs.
    Execution: Server
    Parameters: 0: Victim object <OBJECT>, 1: Canonical kill record <HASHMAP>
    Returns: Eligible assistant UIDs <ARRAY>
    Public: No
*/

params ["_victim", ["_killRecord", createHashMap, [createHashMap]]];
if (!isServer || {isNull _victim}) exitWith {[]};

private _contributors = _victim getVariable ["BN_KOTH_assistContributors", createHashMap];
_victim setVariable ["BN_KOTH_assistContributors", nil, false];
_victim setVariable ["BN_KOTH_assistLastObservedDamage", nil, false];
private _tracked = missionNamespace getVariable ["BN_KOTH_combatAssistVictims", []];
missionNamespace setVariable ["BN_KOTH_combatAssistVictims", _tracked - [_victim]];

if !(missionNamespace getVariable ["BN_KOTH_assistsEnabled", false]) exitWith {[]};
if !(_killRecord getOrDefault ["roundActive", false]) exitWith {[]};
if !(_killRecord getOrDefault ["validPvp", false]) exitWith {[]};
if !(_contributors isEqualType createHashMap) exitWith {[]};

private _killerUid = _killRecord getOrDefault ["killerUid", ""];
private _victimSide = _killRecord getOrDefault ["victimSide", sideUnknown];
private _window = missionNamespace getVariable ["BN_KOTH_assistWindowSeconds", 15];
private _minimumDamage = missionNamespace getVariable ["BN_KOTH_assistMinimumDamage", 0.20];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _assistUids = [];

{
    private _uid = _x;
    (_contributors get _uid) params [["_damage", 0, [0]], ["_lastAt", -1, [0]]];
    private _record = _records getOrDefault [_uid, createHashMap];
    private _side = _record getOrDefault ["assignedSide", sideUnknown];
    if (!(_uid isEqualTo _killerUid)
        && {_damage >= _minimumDamage}
        && {_lastAt >= 0 && {(diag_tickTime - _lastAt) <= _window}}
        && {_record isEqualType createHashMap}
        && {_record getOrDefault ["deployed", false]}
        && {[_side] call bn_koth_fnc_teams_validateSide}
        && {!(_side isEqualTo _victimSide)}) then {
        _assistUids pushBack _uid;
    };
} forEach (keys _contributors);

_assistUids

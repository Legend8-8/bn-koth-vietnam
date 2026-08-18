/*
    File: fn_awardKill.sqf
    Author: Tylervip
    Description: Awards XP for a validated opposing player kill.
    Execution: Server
    Parameters:
        0: Killed entity <OBJECT>
        1: Killer entity <OBJECT>
        2: Instigator entity <OBJECT>
    Returns:
        Updated progression state, or an empty hash map when rejected <HASHMAP>
    Public: No
*/

params ["_killed", ["_killer", objNull, [objNull]], ["_instigator", objNull, [objNull]]];

if (!isServer) exitWith {createHashMap};
if (([] call bn_koth_fnc_round_getState) isNotEqualTo "ACTIVE") exitWith {createHashMap};
if (isNull _killed || {!isPlayer _killed}) exitWith {createHashMap};

private _attacker = if (!isNull _instigator && {isPlayer _instigator}) then {
    _instigator
} else {
    if (!isNull _killer && {isPlayer _killer}) then {_killer} else {objNull}
};
if (isNull _attacker || {_attacker isEqualTo _killed}) exitWith {createHashMap};

private _attackerSide = side group _attacker;
private _victimSide = side group _killed;
if !([_attackerSide] call bn_koth_fnc_teams_validateSide) exitWith {createHashMap};
if !([_victimSide] call bn_koth_fnc_teams_validateSide) exitWith {createHashMap};
if (_attackerSide isEqualTo _victimSide) exitWith {createHashMap};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _attackerUid = getPlayerUID _attacker;
private _victimUid = getPlayerUID _killed;
private _attackerRecord = _records getOrDefault [_attackerUid, createHashMap];
private _victimRecord = _records getOrDefault [_victimUid, createHashMap];
if !(_attackerRecord isEqualType createHashMap) exitWith {createHashMap};
if !(_victimRecord isEqualType createHashMap) exitWith {createHashMap};

private _attackerEligible = (_attackerRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"
    && {_attackerRecord getOrDefault ["deployed", false]}
    && {(_attackerRecord getOrDefault ["currentUnit", objNull]) isEqualTo _attacker};
private _victimEligible = (_victimRecord getOrDefault ["state", "LOBBY"]) in ["ACTIVE", "RESPAWNING"];
if (!_attackerEligible || {!_victimEligible}) exitWith {createHashMap};

private _xpAmount = missionNamespace getVariable ["BN_KOTH_xpPerKill", 100];
[_attackerUid, _xpAmount, "kill"] call bn_koth_fnc_progression_xp_addXp

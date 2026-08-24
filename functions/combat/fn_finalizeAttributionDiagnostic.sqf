/*
    File: fn_finalizeAttributionDiagnostic.sqf
    Author: Legend
    Description: Emits a fail-closed server RPT result for a recent uniquely
        correlated projectile hit. It does not alter kill or progression state.
    Execution: Server
    Parameters:
        0: Victim <OBJECT>
        1: Engine killer <OBJECT>
        2: Engine instigator <OBJECT>
    Returns: Diagnostic result <HASHMAP>
    Public: No
*/

params ["_victim", ["_killer", objNull], ["_instigator", objNull]];

private _result = createHashMapFromArray [
    ["result", "UNKNOWN"], ["reason", "DIAGNOSTICS_DISABLED"],
    ["victim", str _victim], ["killer", str _killer], ["instigator", str _instigator],
    ["ammo", ""], ["projectile", ""], ["candidateWeapons", []], ["canonicalCandidates", []]
];

if (!isServer || {isNull _victim}) exitWith {_result};
if !(missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnosticsInitialized", false]) exitWith {_result};

private _combatCfg = missionConfigFile >> "CfgBnKothCombat";
private _lethalWindow = if (isNumber (_combatCfg >> "attributionLethalWindowSeconds")) then {
    (getNumber (_combatCfg >> "attributionLethalWindowSeconds")) max 0.1
} else {2};
private _now = diag_tickTime;
private _effectiveKiller = if (!isNull _instigator) then {_instigator} else {_killer};
private _events = _victim getVariable ["BN_KOTH_combatAttributionHits", []];
_victim setVariable ["BN_KOTH_combatAttributionHits", nil, false];

if (isNull _effectiveKiller) exitWith {
    _result set ["reason", "KILLER_OR_INSTIGATOR_MISSING"];
    diag_log format ["[BN_KOTH][ATTRIBUTION] KILL %1", _result];
    _result
};

private _correlation = [_events, _effectiveKiller, _now, _lethalWindow] call bn_koth_fnc_combat_evaluateKillAttributionEvidence;
{
    _result set [_x, _correlation get _x];
} forEach (keys _correlation);

diag_log format ["[BN_KOTH][ATTRIBUTION] KILL %1", _result];
_result

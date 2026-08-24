/*
    File: fn_recordAttributionHit.sqf
    Author: Legend
    Description: Records one exact projectile-object hit observation on the
        server-local victim object for later diagnostic kill correlation.
    Execution: Server
    Parameters:
        0: Projectile <OBJECT>
        1: Hit entity <OBJECT>
        2: Event-reported instigator <OBJECT>
        3: DIRECT or EXPLOSION <STRING>
    Returns: Nothing
    Public: No
*/

params ["_projectile", "_victim", ["_eventInstigator", objNull], ["_hitKind", "UNKNOWN"]];
if (!isServer || {isNull _projectile} || {isNull _victim}) exitWith {};

private _facts = _projectile getVariable ["BN_KOTH_combatAttributionFacts", createHashMap];
if !(_facts isEqualType createHashMap && {count _facts > 0}) exitWith {};

private _instigator = _facts getOrDefault ["instigator", _eventInstigator];
if (isNull _instigator && {!isNull _eventInstigator}) then {
    _instigator = _eventInstigator;
};
private _hit = createHashMapFromArray [
    ["observedAt", diag_tickTime], ["observedFrame", diag_frameNo],
    ["victimAliveAtObservation", alive _victim],
    ["victimDamageAtObservation", damage _victim],
    ["hitKind", toUpper _hitKind],
    ["projectileId", _facts getOrDefault ["projectileId", str _projectile]],
    ["ammo", _facts getOrDefault ["ammo", ""]],
    ["source", _facts getOrDefault ["source", objNull]],
    ["instigator", _instigator],
    ["correlation", _facts getOrDefault ["evaluation", createHashMap]]
];

private _hits = _victim getVariable ["BN_KOTH_combatAttributionHits", []];
private _projectileId = _hit get "projectileId";
private _existingIndex = _hits findIf {(_x getOrDefault ["projectileId", ""]) isEqualTo _projectileId};
if (_existingIndex < 0) then {
    _hits pushBack _hit;
} else {
    _hits set [_existingIndex, _hit];
};
private _maxHits = missionNamespace getVariable ["BN_KOTH_combatAttributionMaxHits", 16];
if ((count _hits) > _maxHits) then {
    _hits deleteRange [0, (count _hits) - _maxHits];
};
_victim setVariable ["BN_KOTH_combatAttributionHits", _hits, false];

diag_log format ["[BN_KOTH][ATTRIBUTION] HIT %1", createHashMapFromArray [
    ["victim", str _victim], ["instigator", str _instigator],
    ["ammo", _hit get "ammo"], ["projectile", _projectileId],
    ["hitKind", _hit get "hitKind"], ["observedAt", _hit get "observedAt"],
    ["victimAlive", _hit get "victimAliveAtObservation"],
    ["victimDamage", _hit get "victimDamageAtObservation"],
    ["correlation", _hit get "correlation"]
]];

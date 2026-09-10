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

// The same server-observed projectile event supplies bounded assist evidence.
// A contributor is recorded only when canonical current representations and
// opposing assigned sides can both be proven by the server.
if (missionNamespace getVariable ["BN_KOTH_assistsEnabled", false]) then {
    private _currentDamage = (damage _victim) max 0 min 1;
    private _lastDamage = _victim getVariable ["BN_KOTH_assistLastObservedDamage", 0];
    if !(_lastDamage isEqualType 0 && {finite _lastDamage}) then {_lastDamage = 0};
    private _damageDelta = (_currentDamage - _lastDamage) max 0;
    // Consume every observed damage change, including friendly/self damage, so
    // an ineligible hit cannot be credited to a later eligible attacker.
    _victim setVariable ["BN_KOTH_assistLastObservedDamage", _currentDamage, false];

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    if (_records isEqualType createHashMap && {!isNull _instigator}) then {
        private _attackerUid = [_instigator, _records] call bn_koth_fnc_common_resolvePlayerUid;
        private _victimUid = [_victim, _records] call bn_koth_fnc_common_resolvePlayerUid;
        if !(_attackerUid isEqualTo "" || {_victimUid isEqualTo ""} || {_attackerUid isEqualTo _victimUid}) then {
            private _attackerRecord = _records getOrDefault [_attackerUid, createHashMap];
            private _victimRecord = _records getOrDefault [_victimUid, createHashMap];
            private _attackerSide = _attackerRecord getOrDefault ["assignedSide", sideUnknown];
            private _victimSide = _victimRecord getOrDefault ["assignedSide", sideUnknown];
            if (_attackerRecord isEqualType createHashMap
                && {_victimRecord isEqualType createHashMap}
                && {_attackerRecord getOrDefault ["deployed", false]}
                && {_victimRecord getOrDefault ["deployed", false]}
                && {[_attackerSide] call bn_koth_fnc_teams_validateSide}
                && {[_victimSide] call bn_koth_fnc_teams_validateSide}
                && {!(_attackerSide isEqualTo _victimSide)}) then {
                if (_damageDelta > 0) then {
                    private _contributors = _victim getVariable ["BN_KOTH_assistContributors", createHashMap];
                    if !(_contributors isEqualType createHashMap) then {_contributors = createHashMap};
                    private _entry = _contributors getOrDefault [_attackerUid, [0, -1]];
                    _entry params [["_totalDamage", 0, [0]], ["_lastAt", -1, [0]]];
                    _contributors set [_attackerUid, [(_totalDamage + _damageDelta) min 1, diag_tickTime]];

                    private _maxContributors = missionNamespace getVariable ["BN_KOTH_assistMaxContributors", 8];
                    if ((count _contributors) > _maxContributors) then {
                        private _oldestUid = "";
                        private _oldestAt = 1e12;
                        {
                            private _candidateAt = (_contributors get _x) param [1, -1];
                            if (_candidateAt < _oldestAt) then {_oldestAt = _candidateAt; _oldestUid = _x};
                        } forEach (keys _contributors);
                        if !(_oldestUid isEqualTo "") then {_contributors deleteAt _oldestUid};
                    };
                    _victim setVariable ["BN_KOTH_assistContributors", _contributors, false];
                    private _trackedVictims = missionNamespace getVariable ["BN_KOTH_combatAssistVictims", []];
                    _trackedVictims pushBackUnique _victim;
                    missionNamespace setVariable ["BN_KOTH_combatAssistVictims", _trackedVictims select {!isNull _x}];
                };
            };
        };
    };
};

if (missionNamespace getVariable ["BN_KOTH_combatAttributionDiagnosticsEnabled", false]) then {
    diag_log format ["[BN_KOTH][ATTRIBUTION] HIT %1", createHashMapFromArray [
        ["victim", str _victim], ["instigator", str _instigator],
        ["ammo", _hit get "ammo"], ["projectile", _projectileId],
        ["hitKind", _hit get "hitKind"], ["observedAt", _hit get "observedAt"],
        ["victimAlive", _hit get "victimAliveAtObservation"],
        ["victimDamage", _hit get "victimDamageAtObservation"],
        ["correlation", _hit get "correlation"]
    ]];
};

/*
    File: fn_evaluateKillAttributionEvidence.sqf
    Author: Legend
    Description: Pure, fail-closed aggregation of recent projectile hit
        evidence for an EntityKilled effective killer. EntityKilled supplies
        lethality; this function only resolves recent matching attribution.
    Execution: Any
    Parameters:
        0: Bounded projectile hit records <ARRAY>
        1: Effective killer/instigator identity <ANY>
        2: Current diagnostic time <NUMBER>
        3: Correlation window seconds <NUMBER>
    Returns: Aggregated attribution result <HASHMAP>
    Public: No
*/

params [
    ["_events", [], [[]]],
    "_effectiveKiller",
    ["_now", 0, [0]],
    ["_window", 2, [0]]
];

private _result = createHashMapFromArray [
    ["result", "UNKNOWN"],
    ["reason", "NO_VALID_RECENT_PROJECTILE_ATTRIBUTION"],
    ["ammo", ""],
    ["projectile", ""],
    ["ammoClasses", []],
    ["projectiles", []],
    ["candidateWeapons", []],
    ["canonicalCandidates", []],
    ["evidenceCount", 0]
];

private _qualifying = [];
{
    private _observedAt = _x getOrDefault ["observedAt", -1e6];
    private _age = _now - _observedAt;
    private _eventInstigator = _x getOrDefault ["instigator", objNull];
    private _eventSource = _x getOrDefault ["source", objNull];
    private _correlation = _x getOrDefault ["correlation", createHashMap];
    private _canonical = _correlation getOrDefault ["canonicalCandidates", []];
    private _identityMatches = _effectiveKiller isEqualTo _eventSource
        || {_effectiveKiller isEqualTo _eventInstigator};
    private _validAttribution = (_correlation getOrDefault ["result", ""]) isEqualTo "ATTRIBUTED"
        && {(count _canonical) isEqualTo 1};

    if (_age >= 0 && {_age <= _window} && {_identityMatches} && {_validAttribution}) then {
        _qualifying pushBack _x;
    };
} forEach _events;

private _canonicalCandidates = [];
private _candidateWeapons = [];
private _ammoClasses = [];
private _projectiles = [];
{
    private _correlation = _x get "correlation";
    {_canonicalCandidates pushBackUnique _x} forEach (_correlation get "canonicalCandidates");
    {_candidateWeapons pushBackUnique _x} forEach (_correlation getOrDefault ["candidateWeapons", []]);
    _ammoClasses pushBackUnique (_x getOrDefault ["ammo", ""]);
    _projectiles pushBackUnique (_x getOrDefault ["projectileId", ""]);
} forEach _qualifying;

_canonicalCandidates = _canonicalCandidates select {!(_x isEqualTo "")};
_candidateWeapons = _candidateWeapons select {!(_x isEqualTo "")};
_ammoClasses = _ammoClasses select {!(_x isEqualTo "")};
_projectiles = _projectiles select {!(_x isEqualTo "")};
_canonicalCandidates sort true;
_candidateWeapons sort true;
_ammoClasses sort true;
_projectiles sort true;

_result set ["canonicalCandidates", _canonicalCandidates];
_result set ["candidateWeapons", _candidateWeapons];
_result set ["ammoClasses", _ammoClasses];
_result set ["projectiles", _projectiles];
_result set ["evidenceCount", count _qualifying];
if ((count _ammoClasses) isEqualTo 1) then {_result set ["ammo", _ammoClasses select 0]};
if ((count _projectiles) isEqualTo 1) then {_result set ["projectile", _projectiles select 0]};

if ((count _canonicalCandidates) isEqualTo 1) exitWith {
    _result set ["result", "ATTRIBUTED"];
    _result set ["reason", "UNIQUE_CANONICAL_WEAPON_ACROSS_RECENT_HITS"];
    _result
};

if ((count _canonicalCandidates) > 1) then {
    _result set ["result", "AMBIGUOUS"];
    _result set ["reason", "MULTIPLE_CANONICAL_WEAPONS_ACROSS_RECENT_HITS"];
};

_result

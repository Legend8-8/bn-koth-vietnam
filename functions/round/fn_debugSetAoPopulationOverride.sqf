/*
    File: fn_debugSetAoPopulationOverride.sqf
    Author: Legend
    Description: Temporarily substitutes a test population only for server AO
        candidate eligibility and immediately reconciles published candidates.
    Execution: Server debug console only
    Parameters:
        0: Enable override <BOOL>
        1: Whole test population from 0 through 256; required when enabling <NUMBER>
    Returns: Debug operation state <HASHMAP>
    Public: No
*/

// TEMPORARY BETA VEHICLE-TEST AO POPULATION OVERRIDE
private _result = createHashMapFromArray [
    ["success", false],
    ["code", "INVALID_ARGUMENTS"],
    ["enabled", false],
    ["population", -1],
    ["realPopulation", -1],
    ["eligibilityPopulation", -1],
    ["candidates", []]
];
if (!isServer) exitWith {_result set ["code", "NOT_SERVER"]; _result};

private _fail = {
    params ["_code", "_message"];
    _result set ["code", _code];
    [format ["TEMPORARY AO population override rejected: %1", _message], "WARN"] call bn_koth_fnc_common_log;
    _result
};
if !(_this isEqualType []) exitWith {["INVALID_ARGUMENTS", "Expected [enabled, population]."] call _fail};
if ((count _this) < 1) exitWith {["INVALID_ARGUMENTS", "Enable flag is required."] call _fail};
private _enabled = _this select 0;
if !(_enabled isEqualType true) exitWith {["INVALID_ENABLE", "Enable flag must be boolean."] call _fail};
if (_enabled && {(count _this) < 2}) exitWith {["MISSING_POPULATION", "A test population is required when enabling."] call _fail};

private _population = if (_enabled) then {_this select 1} else {-1};
if (_enabled && {!(_population isEqualType 0)}) exitWith {["INVALID_POPULATION", "Test population must be numeric."] call _fail};
if (_enabled && {!(finite _population) || {_population < 0} || {_population > 256} || {!((floor _population) isEqualTo _population)}}) exitWith {
    ["INVALID_POPULATION", "Test population must be a whole number from 0 through 256."] call _fail
};

if (_enabled) then {
    missionNamespace setVariable ["BN_KOTH_debugAoPopulationOverride", _population];
} else {
    missionNamespace setVariable ["BN_KOTH_debugAoPopulationOverride", nil];
};

private _realPopulation = count ([] call bn_koth_fnc_teams_getConnectedHumanUids);
private _reconciliation = [_realPopulation, true] call bn_koth_fnc_round_reconcileVoteCandidates;
private _effectivePopulation = _reconciliation getOrDefault ["population", _realPopulation];
private _candidates = _reconciliation getOrDefault ["candidates", []];
_result set ["success", true];
_result set ["code", if (_enabled) then {"AO_POPULATION_OVERRIDE_ENABLED"} else {"AO_POPULATION_OVERRIDE_DISABLED"}];
_result set ["enabled", _enabled];
_result set ["population", if (_enabled) then {_population} else {-1}];
_result set ["realPopulation", _realPopulation];
_result set ["eligibilityPopulation", _effectivePopulation];
_result set ["candidates", _candidates];

[format [
    "TEMPORARY BETA vehicle-test AO population override %1; eligibilityPopulation=%2 realConnectedHumans=%3 candidates=%4.",
    if (_enabled) then {"ENABLED"} else {"DISABLED"},
    _effectivePopulation,
    _realPopulation,
    _candidates
], "WARN"] call bn_koth_fnc_common_log;
_result

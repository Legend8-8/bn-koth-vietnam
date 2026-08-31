/*
    File: test_populationEligibility.sqf
    Author: Legend
    Description: Focused pure checks for inclusive AO population eligibility.
    Execution: Debug console after mission initialization
    Returns: Failure messages <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_name", "_condition"];
    if (!_condition) then {_failures pushBack _name};
};

private _small = createHashMapFromArray [["id", "small"], ["minPlayers", 0], ["maxPlayers", 20]];
private _large = createHashMapFromArray [["id", "large"], ["minPlayers", 15], ["maxPlayers", -1]];
private _defaulted = createHashMapFromArray [["id", "defaulted"]];
private _invalid = createHashMapFromArray [["id", "invalid"], ["minPlayers", 20], ["maxPlayers", 10]];

["Small AO includes zero", [_small, 0] call bn_koth_fnc_round_isLocationPopulationEligible] call _check;
["Small AO includes maximum", [_small, 20] call bn_koth_fnc_round_isLocationPopulationEligible] call _check;
["Small AO rejects above maximum", !([_small, 21] call bn_koth_fnc_round_isLocationPopulationEligible)] call _check;
["Large AO rejects below minimum", !([_large, 14] call bn_koth_fnc_round_isLocationPopulationEligible)] call _check;
["Large AO includes minimum", [_large, 15] call bn_koth_fnc_round_isLocationPopulationEligible] call _check;
["Unlimited maximum accepts high population", [_large, 100] call bn_koth_fnc_round_isLocationPopulationEligible] call _check;
["Missing metadata preserves unrestricted default", [_defaulted, 100] call bn_koth_fnc_round_isLocationPopulationEligible] call _check;
["Malformed range fails closed", !([_invalid, 15] call bn_koth_fnc_round_isLocationPopulationEligible)] call _check;

diag_log format ["[BN_KOTH_TEST] AO population eligibility: %1 failure(s): %2", count _failures, _failures];
_failures

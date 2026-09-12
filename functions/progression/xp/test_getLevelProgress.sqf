/*
    File: test_getLevelProgress.sqf
    Author: Legend
    Description: Focused checks that bn_koth_fnc_progression_xp_getLevelProgress
        never propagates NaN/non-finite values into its presentation hashmap,
        regardless of malformed inputs. This file is not registered as a
        runtime function.
    Execution: Any context after function initialization
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _allFinite = {
    params ["_progress"];
    (["level", "maxLevel", "xp", "xpIntoLevel", "xpRequired", "ratio"]) findIf {
        private _value = _progress getOrDefault [_x, 0];
        !(_value isEqualType 0) || {!(finite _value)}
    } isEqualTo -1
};

private _nan = 0 / 0;

// NaN XP must fail soft to 0, never propagate.
private _result = [_nan, 5] call bn_koth_fnc_progression_xp_getLevelProgress;
["NaN XP yields only finite fields", [_result] call _allFinite] call _check;
["NaN XP falls back to xp 0", (_result getOrDefault ["xp", -1]) isEqualTo 0] call _check;

// NaN level must fail soft to level 1, never propagate.
_result = [1000, _nan] call bn_koth_fnc_progression_xp_getLevelProgress;
["NaN level yields only finite fields", [_result] call _allFinite] call _check;
["NaN level falls back to level 1", (_result getOrDefault ["level", -1]) isEqualTo 1] call _check;

// Negative inputs must clamp, not error or go negative.
_result = [-500, -10] call bn_koth_fnc_progression_xp_getLevelProgress;
["Negative XP/level yields only finite fields", [_result] call _allFinite] call _check;
["Negative XP clamps to 0", (_result getOrDefault ["xp", -1]) isEqualTo 0] call _check;
["Negative level clamps to 1", (_result getOrDefault ["level", -1]) isEqualTo 1] call _check;

// Normal values must resolve to plain finite numbers.
_result = [750, 2] call bn_koth_fnc_progression_xp_getLevelProgress;
["Normal XP/level yields only finite fields", [_result] call _allFinite] call _check;
["Normal level is preserved", (_result getOrDefault ["level", -1]) isEqualTo 2] call _check;

// Max level must resolve without a divide-by-zero attempt at the top of the curve.
private _maxLevelConfigured = getNumber (missionConfigFile >> "CfgBnKothScoring" >> "progression" >> "maxLevel");
_result = [999999999, _maxLevelConfigured] call bn_koth_fnc_progression_xp_getLevelProgress;
["Max level yields only finite fields", [_result] call _allFinite] call _check;
["Max level clamps to configured ceiling", (_result getOrDefault ["level", -1]) isEqualTo _maxLevelConfigured] call _check;

if ((count _failures) isEqualTo 0) then {
    ["test_getLevelProgress: ALL CHECKS PASSED"] call bn_koth_fnc_common_log;
} else {
    [format ["test_getLevelProgress: %1 CHECK(S) FAILED: %2", count _failures, _failures], "ERROR"] call bn_koth_fnc_common_log;
};

_failures

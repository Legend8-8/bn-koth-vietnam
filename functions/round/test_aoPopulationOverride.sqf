/*
    File: test_aoPopulationOverride.sqf
    Author: Legend
    Description: Focused server checks for the temporary AO eligibility-only
        population override and its non-persistent boundary.
    Execution: Server debug console after mission initialization
    Returns: Failure messages <ARRAY>
*/

private _failures = [];
private _check = {params ["_name", "_condition"]; if (!_condition) then {_failures pushBack _name}};
["Override test runs on server", isServer] call _check;
if (!isServer) exitWith {_failures};

private _overrideName = "BN_KOTH_debugAoPopulationOverride";
private _priorOverride = missionNamespace getVariable [_overrideName, -1];
private _realBefore = count ([] call bn_koth_fnc_teams_getConnectedHumanUids);

private _disabled = [false] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Disabled state clears override", isNil {missionNamespace getVariable _overrideName}] call _check;
["Disabled state uses real population", (_disabled getOrDefault ["eligibilityPopulation", -1]) isEqualTo _realBefore] call _check;

private _enabled = [true, 32] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Enabled state accepts 32", (_enabled getOrDefault ["success", false]) && {(missionNamespace getVariable [_overrideName, -1]) isEqualTo 32}] call _check;
["Enabled state changes only AO eligibility input", (_enabled getOrDefault ["eligibilityPopulation", -1]) isEqualTo 32] call _check;
["Real connected-human count remains unchanged", (count ([] call bn_koth_fnc_teams_getConnectedHumanUids)) isEqualTo _realBefore] call _check;

private _invalid = [true, -1] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Negative override is rejected", !(_invalid getOrDefault ["success", true]) && {(missionNamespace getVariable [_overrideName, -1]) isEqualTo 32}] call _check;
private _unreasonable = [true, 257] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Unreasonable override is rejected", !(_unreasonable getOrDefault ["success", true]) && {(missionNamespace getVariable [_overrideName, -1]) isEqualTo 32}] call _check;
private _malformed = [true, "32"] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Malformed override is rejected", !(_malformed getOrDefault ["success", true]) && {(missionNamespace getVariable [_overrideName, -1]) isEqualTo 32}] call _check;

private _restored = [false] call bn_koth_fnc_round_debugSetAoPopulationOverride;
["Disabling restores normal eligibility", (_restored getOrDefault ["eligibilityPopulation", -1]) isEqualTo _realBefore] call _check;
["Disabling leaves no override state", isNil {missionNamespace getVariable _overrideName}] call _check;

private _initSource = preprocessFileLineNumbers "functions\round\fn_initServer.sqf";
private _saveSource = preprocessFileLineNumbers "functions\persistence\fn_backendSavePlayer.sqf";
private _codecSource = preprocessFileLineNumbers "functions\persistence\fn_serializeVehicleProgression.sqf";
["Mission initialization explicitly clears temporary state", (_initSource find 'missionNamespace setVariable ["BN_KOTH_debugAoPopulationOverride", nil]') >= 0] call _check;
["Override is absent from persistence paths", (_saveSource find _overrideName) < 0 && {(_codecSource find _overrideName) < 0}] call _check;

if (_priorOverride isEqualType 0 && {_priorOverride >= 0} && {_priorOverride <= 256} && {(floor _priorOverride) isEqualTo _priorOverride}) then {
    [true, _priorOverride] call bn_koth_fnc_round_debugSetAoPopulationOverride;
};

diag_log format ["[BN_KOTH_TEST] Temporary AO population override: %1 failure(s): %2", count _failures, _failures];
_failures

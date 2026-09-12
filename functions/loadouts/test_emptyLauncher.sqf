/*
    File: test_emptyLauncher.sqf
    Author: Legend
    Description: Focused regression checks against the actual private weapon
        extractor, without registering a runtime test endpoint.
    Execution: Hosted or dedicated server after mission initialization
    Parameters: None
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Run on the server."]};

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label;};
};

// Compile the production helpers in isolation so no player state is required
// and unrelated saved-kit gates cannot mask the extraction result.
private _source = loadFile "functions\loadouts\fn_validateMutation.sqf";
private _start = _source find "private _resolveBaseWeapon = {";
private _end = _source find "private _resolveAllowedCargoMagazines = {";
if ((_start < 0) || {_end <= _start}) exitWith {["Production extractor boundaries not found."]};
private _helpers = call compile ((_source select [_start, _end - _start]) + "[_resolveBaseWeapon, _extractWeaponComposition]");
private _resolveBaseWeapon = _helpers select 0;
private _extract = _helpers select 1;
private _compatibilityCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility";
private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";

{
    private _result = [_x, "LAUNCHER", "Launcher"] call _extract;
    [format ["Empty launcher %1 accepted as empty", _x],
        (_result getOrDefault ["success", false]) &&
        {(_result getOrDefault ["composition", createHashMap]) getOrDefault ["isEmpty", false]}
    ] call _check;
} forEach [[], ["", "", "", "", [], [], ""]];

{
    private _result = [_x, "LAUNCHER", "Launcher"] call _extract;
    [format ["Malformed launcher %1 rejected", _x],
        !(_result getOrDefault ["success", true]) &&
        {(_result getOrDefault ["code", ""]) isEqualTo "ERR_LOADOUT_SLOT_SHAPE"}
    ] call _check;
} forEach ["", [""], ["vn_rpg7", "", "", "", []]];

private _result = [["vn_rpg7", "", "", "", ["vn_rpg7_mag", 1], [], ""], "LAUNCHER", "Launcher"] call _extract;
private _composition = _result getOrDefault ["composition", createHashMap];
["Populated launcher extracted normally",
    (_result getOrDefault ["success", false]) &&
    {!(_composition getOrDefault ["isEmpty", true])} &&
    {(_composition getOrDefault ["weaponClass", ""]) isEqualTo "vn_rpg7"} &&
    {(_composition getOrDefault ["magazines", []]) isEqualTo ["vn_rpg7_mag"]}
] call _check;
private _validated = [_composition, _compatibilityCfg, "LAUNCHER", "Launcher"] call bn_koth_fnc_loadouts_validateWeaponComposition;
["Populated launcher passes normal compatibility validation", _validated getOrDefault ["success", false]] call _check;

diag_log format ["[BN_KOTH_TEST] Empty launcher: %1 failure(s): %2", count _failures, _failures];
_failures

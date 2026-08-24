/*
    File: test_progressionMetadata.sqf
    Author: Legend
    Description: Focused in-engine checks for human-authored weapon and
        attachment progression metadata. This file is not registered as a
        runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

{
    private _metadata = [_x] call bn_koth_fnc_loadouts_getWeaponMetadata;
    [format ["Starter %1 is configured at level 1", _x],
        (_metadata getOrDefault ["configured", false]) &&
        {(_metadata getOrDefault ["minLevel", 0]) isEqualTo 1}] call _check;
} forEach ["vn_m1903", "vn_m1911", "vn_k98k", "vn_pm"];

private _l1a1Metadata = ["vn_l1a1_01"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["L1A1 remains level 20", (_l1a1Metadata getOrDefault ["minLevel", 0]) isEqualTo 20] call _check;
["L1A1 explicitly permits cross-side licensing",
    _l1a1Metadata getOrDefault ["crossSideAllowed", false]] call _check;

private _l1a1VariantMetadata = ["vn_l1a1_02"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["L1A1 structural variant inherits canonical level",
    (_l1a1VariantMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_l1a1_01" &&
    {(_l1a1VariantMetadata getOrDefault ["minLevel", 0]) isEqualTo 20} &&
    {_l1a1VariantMetadata getOrDefault ["crossSideAllowed", false]} &&
    {(_l1a1VariantMetadata getOrDefault ["licenseKills", 0]) isEqualTo 50}] call _check;

private _level19 = createHashMapFromArray [["level", 19], ["perks", []], ["weaponKills", createHashMap]];
private _entitlement = ["test_uid", "WEST", _level19, _l1a1Metadata, "vn_l1a1_01"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["L1A1 is level-locked at level 19", (_entitlement getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL"] call _check;

private _unresolvedMetadata = ["vn_fkb1_pm"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["PM flashlight remains unconfigured", !(_unresolvedMetadata getOrDefault ["configured", true])] call _check;

private _svdOpticMetadata = ["Attachments", "vn_o_4x_svd"] call bn_koth_fnc_loadouts_getItemMetadata;
["SVD optic uses adjusted level 135",
    (_svdOpticMetadata getOrDefault ["configured", false]) &&
    {(_svdOpticMetadata getOrDefault ["minLevel", 0]) isEqualTo 135}] call _check;

private _m16SuppressorMetadata = ["Attachments", "vn_s_m16"] call bn_koth_fnc_loadouts_getItemMetadata;
["M16 suppressor remains independently level-gated",
    (_m16SuppressorMetadata getOrDefault ["configured", false]) &&
    {(_m16SuppressorMetadata getOrDefault ["minLevel", 0]) isEqualTo 70}] call _check;

diag_log format ["[BN_KOTH_TEST] Progression metadata: %1 failure(s): %2", count _failures, _failures];
_failures

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
    [format ["Starter %1 remains acquisition-uncontrolled", _x],
        (_metadata getOrDefault ["purchasePrice", 0]) < 0 &&
        {(_metadata getOrDefault ["rentalPrice", 0]) < 0}] call _check;
} forEach ["vn_m3a1", "vn_m1911", "vn_pps43", "vn_pm"];

private _m1903Metadata = ["vn_m1903"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["Former WEST starter M1903 moved to level 10",
    (_m1903Metadata getOrDefault ["minLevel", 0]) isEqualTo 10] call _check;

private _k98kMetadata = ["vn_k98k"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["Former EAST starter K98K moved to level 10",
    (_k98kMetadata getOrDefault ["minLevel", 0]) isEqualTo 10] call _check;

private _westStarterCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Loadouts" >> "starter_west";
private _eastStarterCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Loadouts" >> "starter_east";
private _westAssignedItems = getArray (_westStarterCfg >> "assignedItems");
private _eastAssignedItems = getArray (_eastStarterCfg >> "assignedItems");
["WEST starter uses M3A1 and GPS slot 1",
    (getText (_westStarterCfg >> "primaryWeapon")) isEqualTo "vn_m3a1" &&
    {(_westAssignedItems param [1, ""]) isEqualTo "ItemGPS"}] call _check;
["EAST starter uses PPS-43 and GPS slot 1",
    (getText (_eastStarterCfg >> "primaryWeapon")) isEqualTo "vn_pps43" &&
    {(_eastAssignedItems param [1, ""]) isEqualTo "ItemGPS"}] call _check;
["Starter primary magazine counts remain four",
    (getNumber (_westStarterCfg >> "primaryMagazineCount")) isEqualTo 4 &&
    {(getNumber (_eastStarterCfg >> "primaryMagazineCount")) isEqualTo 4}] call _check;

private _sourceWeaponsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility" >> "SourceWeapons";
private _sourceItemsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility" >> "SourceItems";
private _gpsValidation = [1, "ItemGPS", _sourceItemsCfg] call bn_koth_fnc_loadouts_validateAssignedItemSlot;
["ItemGPS validates in assigned GPS slot 1",
    _gpsValidation getOrDefault ["success", false]] call _check;
["WEST starter magazine remains factual high-confidence M3A1 magazine",
    (getText (_sourceWeaponsCfg >> "vn_m3a1" >> "baseMagazine")) isEqualTo "vn_m3a1_mag" &&
    {(getText (_sourceWeaponsCfg >> "vn_m3a1" >> "baseMagazineConfidence")) isEqualTo "high"}] call _check;
["EAST starter magazine remains factual high-confidence PPS magazine",
    (getText (_sourceWeaponsCfg >> "vn_pps43" >> "baseMagazine")) isEqualTo "vn_pps_mag" &&
    {(getText (_sourceWeaponsCfg >> "vn_pps43" >> "baseMagazineConfidence")) isEqualTo "high"}] call _check;

private _l1a1Metadata = ["vn_l1a1_01"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["L1A1 remains level 20", (_l1a1Metadata getOrDefault ["minLevel", 0]) isEqualTo 20] call _check;
["L1A1 has provisional purchase and rental prices",
    (_l1a1Metadata getOrDefault ["purchasePrice", -1]) isEqualTo 1500 &&
    {(_l1a1Metadata getOrDefault ["rentalPrice", -1]) isEqualTo 300}] call _check;
["L1A1 explicitly permits cross-side mastery",
    _l1a1Metadata getOrDefault ["crossSideAllowed", false]] call _check;

private _l1a1VariantMetadata = ["vn_l1a1_02"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["L1A1 structural variant inherits canonical level",
    (_l1a1VariantMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_l1a1_01" &&
    {(_l1a1VariantMetadata getOrDefault ["minLevel", 0]) isEqualTo 20} &&
    {_l1a1VariantMetadata getOrDefault ["crossSideAllowed", false]} &&
    {(_l1a1VariantMetadata getOrDefault ["masteryKillsRequired", 0]) isEqualTo 50} &&
    {(_l1a1VariantMetadata getOrDefault ["purchasePrice", -1]) isEqualTo 1500} &&
    {(_l1a1VariantMetadata getOrDefault ["rentalPrice", -1]) isEqualTo 300}] call _check;

private _level19 = createHashMapFromArray [["level", 19], ["perks", []], ["weaponKills", createHashMap]];
private _entitlement = ["test_uid", "WEST", _level19, _l1a1Metadata, "vn_l1a1_01"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["L1A1 is level-locked at level 19", (_entitlement getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL"] call _check;

private _unresolvedMetadata = ["vn_fkb1_pm"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["PM flashlight remains unconfigured", !(_unresolvedMetadata getOrDefault ["configured", true])] call _check;
["PM flashlight remains acquisition-uncontrolled",
    (_unresolvedMetadata getOrDefault ["purchasePrice", 0]) < 0 &&
    {(_unresolvedMetadata getOrDefault ["rentalPrice", 0]) < 0}] call _check;

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

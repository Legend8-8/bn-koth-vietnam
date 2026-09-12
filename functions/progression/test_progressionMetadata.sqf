/*
    File: test_progressionMetadata.sqf
    Author: Legend
    Description: Focused in-engine checks for human-authored weapon, attachment,
        and consumable progression metadata. This file is not registered as a
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
["WEST M1903 is starter-accessible at level 1",
    (_m1903Metadata getOrDefault ["minLevel", 0]) isEqualTo 1] call _check;

private _k98kMetadata = ["vn_k98k"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["EAST K98K is starter-accessible at level 1",
    (_k98kMetadata getOrDefault ["minLevel", 0]) isEqualTo 1] call _check;

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
private _westCargo = getArray (_westStarterCfg >> "cargo");
private _eastCargo = getArray (_eastStarterCfg >> "cargo");
["WEST starter carries three M61 frags and two M18 white smokes",
    ["vn_m61_grenade_mag", 3, "vest"] in _westCargo &&
    {["vn_m18_white_mag", 2, "vest"] in _westCargo}] call _check;
["EAST starter carries three RGD-5 frags and two RDG-2 smokes",
    ["vn_rgd5_grenade_mag", 3, "vest"] in _eastCargo &&
    {["vn_rdg2_mag", 2, "vest"] in _eastCargo}] call _check;

{
    _x params ["_group", "_className", "_sideToken"];
    private _metadata = [_group, _className] call bn_koth_fnc_loadouts_getItemMetadata;
    private _sidePolicy = [_sideToken, _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
    [format ["Starter consumable %1 is explicit Level 1 %2 policy", _className, _sideToken],
        (_metadata getOrDefault ["configured", false]) &&
        {(_metadata getOrDefault ["minLevel", 0]) isEqualTo 1} &&
        {_sidePolicy getOrDefault ["allowed", false]}] call _check;
} forEach [
    ["Consumables", "vn_m61_grenade_mag", "WEST"],
    ["Consumables", "vn_m18_white_mag", "WEST"],
    ["Consumables", "vn_rgd5_grenade_mag", "EAST"],
    ["Consumables", "vn_rdg2_mag", "EAST"]
];

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
["L1A1 resolves to WEST", (_l1a1Metadata getOrDefault ["allowedSides", []]) isEqualTo ["WEST"]] call _check;
["L1A1 unlock level is 5", (_l1a1Metadata getOrDefault ["minLevel", 0]) isEqualTo 5] call _check;
["L1A1 purchase price is 500", (_l1a1Metadata getOrDefault ["purchasePrice", -1]) isEqualTo 500] call _check;
["L1A1 rental price is 100", (_l1a1Metadata getOrDefault ["rentalPrice", -1]) isEqualTo 100] call _check;
["L1A1 mastery requirement is 30",
    (_l1a1Metadata getOrDefault ["masteryKillsRequired", 0]) isEqualTo 30] call _check;
["L1A1 explicitly permits cross-side mastery",
    _l1a1Metadata getOrDefault ["crossSideAllowed", false]] call _check;

{
    private _variantMetadata = [_x] call bn_koth_fnc_loadouts_getWeaponMetadata;
    [format ["L1A1 structural variant %1 inherits canonical policy", _x],
        (_variantMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_l1a1_01" &&
        {(_variantMetadata getOrDefault ["allowedSides", []]) isEqualTo ["WEST"]} &&
        {(_variantMetadata getOrDefault ["minLevel", 0]) isEqualTo 5} &&
        {(_variantMetadata getOrDefault ["masteryKillsRequired", 0]) isEqualTo 30} &&
        {(_variantMetadata getOrDefault ["purchasePrice", -1]) isEqualTo 500} &&
        {(_variantMetadata getOrDefault ["rentalPrice", -1]) isEqualTo 100}] call _check;
} forEach [
    "vn_l1a1_01_bayo",
    "vn_l1a1_01_camo",
    "vn_l1a1_01_gl",
    "vn_l1a1_01_mrk",
    "vn_l1a1_02",
    "vn_l1a1_02_bayo",
    "vn_l1a1_02_camo",
    "vn_l1a1_02_gl",
    "vn_l1a1_02_mrk",
    "vn_l1a1_03",
    "vn_l1a1_03_camo",
    "vn_l1a1_xm148",
    "vn_l1a1_xm148_camo"
];

private _level5Unowned = createHashMapFromArray [
    ["level", 5],
    ["ownedWeapons", []],
    ["rentedWeapons", []],
    ["perks", []],
    ["weaponKills", createHashMap]
];
private _entitlement = ["test_uid", "WEST", _level5Unowned, _l1a1Metadata, "vn_l1a1_01"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["Level 5 does not grant L1A1 ownership",
    !(_entitlement getOrDefault ["entitled", true]) &&
    {!(_entitlement getOrDefault ["owned", true])} &&
    {(_entitlement getOrDefault ["code", ""]) isEqualTo "REQUIRES_ACQUISITION"}] call _check;

private _pmFlashlightMetadata = ["vn_fkb1_pm"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["PM flashlight shares canonical PM progression", (_pmFlashlightMetadata getOrDefault ["configured", false]) && {(_pmFlashlightMetadata getOrDefault ["technicalClass", ""]) isEqualTo "vn_fkb1_pm"} && {(_pmFlashlightMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_pm"}] call _check;
["PM flashlight inherits PM mastery policy", (_pmFlashlightMetadata getOrDefault ["masteryKillsRequired", 0]) isEqualTo 30] call _check;
["PM flashlight technical root unlocks after base PM", (_pmFlashlightMetadata getOrDefault ["minLevel", 0]) isEqualTo 5] call _check;
["PM flashlight remains acquisition-uncontrolled",
    (_pmFlashlightMetadata getOrDefault ["purchasePrice", 0]) < 0 &&
    {(_pmFlashlightMetadata getOrDefault ["rentalPrice", 0]) < 0}] call _check;
private _pmFlashlightSuppressedMetadata = ["vn_fkb1_pm_sd"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["Suppressed PM flashlight variant retains technical family and PM progression",
    (_pmFlashlightSuppressedMetadata getOrDefault ["technicalClass", ""]) isEqualTo "vn_fkb1_pm" &&
    {(_pmFlashlightSuppressedMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_pm"} &&
    {(_pmFlashlightSuppressedMetadata getOrDefault ["minLevel", 0]) isEqualTo 5}] call _check;

private _managedGrenadeMetadata = ["Consumables", "vn_f1_grenade_mag"] call bn_koth_fnc_loadouts_getItemMetadata;
private _managedGrenadeLocked = [
    createHashMapFromArray [["level", 2]],
    _managedGrenadeMetadata, "vn_f1_grenade_mag", "WEST", false
] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
["Managed grenade remains locked below its minimum level",
    (_managedGrenadeLocked getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL" &&
    {!(_managedGrenadeLocked getOrDefault ["entitled", true])}] call _check;
private _managedGrenadeEntitled = [
    createHashMapFromArray [["level", 3]],
    _managedGrenadeMetadata, "vn_f1_grenade_mag", "WEST", false
] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
["Managed grenade becomes entitled when its level and policy gates pass",
    (_managedGrenadeEntitled getOrDefault ["entitled", false]) &&
    {(_managedGrenadeEntitled getOrDefault ["code", ""]) isEqualTo "ENTITLED"}] call _check;

{
    private _wpMetadata = ["Consumables", _x] call bn_koth_fnc_loadouts_getItemMetadata;
    private _wpEntitlement = [createHashMapFromArray [["level", 999]], _wpMetadata, _x, "WEST", false] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
    [format ["WP class %1 remains explicitly unavailable", _x],
        (_wpMetadata getOrDefault ["configured", false]) &&
        {!(_wpMetadata getOrDefault ["available", true])} &&
        {!(_wpEntitlement getOrDefault ["entitled", true])} &&
        {(_wpEntitlement getOrDefault ["code", ""]) isEqualTo "NOT_AVAILABLE"}] call _check;
} forEach [
    "vn_m34_grenade_mag",
    "vn_20mm_dgn_wp_mag",
    "vn_22mm_m19_wp_mag",
    "vn_m20a1b1_wp_mag",
    "vn_mine_m18_wp_fuze10_mag",
    "vn_mine_m18_wp_mag",
    "vn_mine_m18_wp_range_mag"
];

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

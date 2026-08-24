/*
    File: test_weaponAcquisition.sqf
    Author: Legend
    Description: Focused in-engine tests for pure weapon purchase/rental
        transactions and server-session acquisition initialization. This file
        is not registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

if (!isServer) exitWith {["Weapon acquisition tests require server execution"]};

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _uid = "BN_KOTH_TEST_ACQUISITION_UID";
private _baseProgression = createHashMapFromArray [
    ["level", 10], ["cash", 1000], ["ownedWeapons", []],
    ["rentedWeapons", []], ["perks", ["test_perk"]], ["weaponKills", createHashMap]
];
private _metadata = createHashMapFromArray [
    ["success", true], ["configured", true], ["canonicalClass", "vn_test_weapon"],
    ["allowedSides", ["WEST"]], ["minLevel", 5], ["licenseKills", 0],
    ["crossSideAllowed", false],
    ["requiredPerks", ["test_perk"]], ["purchasePrice", 400], ["rentalPrice", 100]
];

private _baseEntitlement = [_uid, "WEST", _baseProgression, _metadata, "vn_test_weapon_variant"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _purchase = ["PURCHASE", _uid, "vn_test_weapon_variant", _baseProgression, _metadata, _baseEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Funded eligible purchase succeeds", (_purchase getOrDefault ["code", ""]) isEqualTo "WEAPON_PURCHASED"] call _check;
["Purchase charges exactly once", (_purchase getOrDefault ["cash", -1]) isEqualTo 600] call _check;
["Purchase grants canonical ownership", "vn_test_weapon" in (_purchase getOrDefault ["nextOwnedWeapons", []])] call _check;

private _ownedProgression = createHashMapFromArray [
    ["level", 10], ["cash", 600],
    ["ownedWeapons", _purchase getOrDefault ["nextOwnedWeapons", []]],
    ["rentedWeapons", _purchase getOrDefault ["nextRentedWeapons", []]],
    ["perks", ["test_perk"]], ["weaponKills", createHashMap]
];
private _ownedEntitlement = [_uid, "WEST", _ownedProgression, _metadata, "vn_test_weapon_variant"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _repeatPurchase = ["PURCHASE", _uid, "vn_test_weapon_variant", _ownedProgression, _metadata, _ownedEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Repeated purchase is idempotent", (_repeatPurchase getOrDefault ["code", ""]) isEqualTo "ALREADY_OWNED"] call _check;
["Repeated purchase does not charge", (_repeatPurchase getOrDefault ["cash", -1]) isEqualTo 600 && {(_repeatPurchase getOrDefault ["charged", -1]) isEqualTo 0}] call _check;
["Structural variant entitlement inherits canonical ownership", (_ownedEntitlement getOrDefault ["accessType", ""]) isEqualTo "OWNED"] call _check;

private _wrongSide = [_uid, "EAST", _baseProgression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _wrongSidePurchase = ["PURCHASE", _uid, "vn_test_weapon", _baseProgression, _metadata, _wrongSide] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Cross-side-disabled purchase fails before spend", (_wrongSidePurchase getOrDefault ["code", ""]) isEqualTo "CROSS_SIDE_NOT_ALLOWED" && {(_baseProgression get "cash") isEqualTo 1000}] call _check;

private _crossMetadata = createHashMapFromArray ((keys _metadata) apply {[_x, _metadata get _x]});
_crossMetadata set ["crossSideAllowed", true];
_crossMetadata set ["licenseKills", 5];
private _crossProgression = createHashMapFromArray ((keys _baseProgression) apply {[_x, _baseProgression get _x]});
_crossProgression set ["weaponKills", createHashMapFromArray [["vn_test_weapon", 4]]];
private _crossEntitlement = [_uid, "EAST", _crossProgression, _crossMetadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _crossPurchase = ["PURCHASE", _uid, "vn_test_weapon", _crossProgression, _crossMetadata, _crossEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Incomplete cross-side licence fails before spend", (_crossPurchase getOrDefault ["code", ""]) isEqualTo "LOCKED_LICENSE" && {(_crossProgression get "cash") isEqualTo 1000}] call _check;
(_crossProgression get "weaponKills") set ["vn_test_weapon", 5];
_crossEntitlement = [_uid, "EAST", _crossProgression, _crossMetadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
_crossPurchase = ["PURCHASE", _uid, "vn_test_weapon", _crossProgression, _crossMetadata, _crossEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Completed cross-side licence permits funded purchase", (_crossPurchase getOrDefault ["code", ""]) isEqualTo "WEAPON_PURCHASED"] call _check;

private _lowProgression = createHashMapFromArray [
    ["level", 1], ["cash", 1000], ["ownedWeapons", []], ["rentedWeapons", []],
    ["perks", ["test_perk"]], ["weaponKills", createHashMap]
];
private _lowEntitlement = [_uid, "WEST", _lowProgression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _lowPurchase = ["PURCHASE", _uid, "vn_test_weapon", _lowProgression, _metadata, _lowEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Below-level purchase fails before spend", (_lowPurchase getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL" && {(_lowProgression get "cash") isEqualTo 1000}] call _check;

private _poorProgression = createHashMapFromArray [
    ["level", 10], ["cash", 50], ["ownedWeapons", []], ["rentedWeapons", []],
    ["perks", ["test_perk"]], ["weaponKills", createHashMap]
];
private _poorEntitlement = [_uid, "WEST", _poorProgression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _poorPurchase = ["PURCHASE", _uid, "vn_test_weapon", _poorProgression, _metadata, _poorEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Insufficient cash does not mutate", (_poorPurchase getOrDefault ["code", ""]) isEqualTo "INSUFFICIENT_CASH" && {(_poorProgression get "cash") isEqualTo 50} && {(count (_poorProgression get "ownedWeapons")) isEqualTo 0}] call _check;

private _noPurchaseMetadata = createHashMapFromArray ((keys _metadata) apply {[_x, _metadata get _x]});
_noPurchaseMetadata set ["purchasePrice", -1];
private _noPurchaseEntitlement = [_uid, "WEST", _baseProgression, _noPurchaseMetadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _noPurchase = ["PURCHASE", _uid, "vn_test_weapon", _baseProgression, _noPurchaseMetadata, _noPurchaseEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Unconfigured purchase price rejects", (_noPurchase getOrDefault ["code", ""]) isEqualTo "PURCHASE_NOT_CONFIGURED"] call _check;

private _rent = ["RENT", _uid, "vn_test_weapon", _baseProgression, _metadata, _baseEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Funded eligible rental succeeds", (_rent getOrDefault ["code", ""]) isEqualTo "WEAPON_RENTED"] call _check;
["Rental charges exactly once", (_rent getOrDefault ["cash", -1]) isEqualTo 900] call _check;
["Rental grants canonical temporary entitlement", "vn_test_weapon" in (_rent getOrDefault ["nextRentedWeapons", []])] call _check;

private _rentedProgression = createHashMapFromArray [
    ["level", 10], ["cash", 900], ["ownedWeapons", []],
    ["rentedWeapons", _rent getOrDefault ["nextRentedWeapons", []]],
    ["perks", ["test_perk"]], ["weaponKills", createHashMap]
];
private _rentedEntitlement = [_uid, "WEST", _rentedProgression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _repeatRent = ["RENT", _uid, "vn_test_weapon", _rentedProgression, _metadata, _rentedEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Repeated rental is idempotent", (_repeatRent getOrDefault ["code", ""]) isEqualTo "ALREADY_RENTED" && {(_repeatRent getOrDefault ["cash", -1]) isEqualTo 900}] call _check;

private _rentOwned = ["RENT", _uid, "vn_test_weapon", _ownedProgression, _metadata, _ownedEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Owned weapon rental does not charge", (_rentOwned getOrDefault ["code", ""]) isEqualTo "ALREADY_OWNED" && {(_rentOwned getOrDefault ["charged", -1]) isEqualTo 0}] call _check;

private _noRentMetadata = createHashMapFromArray ((keys _metadata) apply {[_x, _metadata get _x]});
_noRentMetadata set ["rentalPrice", -1];
private _noRentEntitlement = [_uid, "WEST", _baseProgression, _noRentMetadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
private _noRent = ["RENT", _uid, "vn_test_weapon", _baseProgression, _noRentMetadata, _noRentEntitlement] call bn_koth_fnc_progression_acquisition_evaluateRules;
["Unconfigured rental price rejects", (_noRent getOrDefault ["code", ""]) isEqualTo "RENTAL_NOT_CONFIGURED"] call _check;

private _progressionBackup = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMapFromArray [[
    _uid, createHashMapFromArray [["cash", 1000], ["ownedWeapons", []], ["rentedWeapons", ["vn_test_weapon"]]]
]]];
[_uid] call bn_koth_fnc_progression_acquisition_initPlayer;
[_uid] call bn_koth_fnc_progression_acquisition_initPlayer;
private _sessionState = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) get _uid;
["Repeated player initialization preserves session rental", "vn_test_weapon" in (_sessionState getOrDefault ["rentedWeapons", []])] call _check;
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionBackup];

diag_log format ["[BN_KOTH_TEST] Weapon acquisition: %1 failure(s): %2", count _failures, _failures];
_failures

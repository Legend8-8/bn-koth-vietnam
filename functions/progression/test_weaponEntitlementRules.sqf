/*
    File: test_weaponEntitlementRules.sqf
    Author: Legend
    Description: Focused in-engine checks for acquisition configuration and
        weapon entitlement gate precedence. Run after mission functions are
        initialized. This file is not registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _progression = createHashMapFromArray [
    ["level", 10],
    ["ownedWeapons", []],
    ["rentedWeapons", []],
    ["perks", []],
    ["weaponKills", createHashMap]
];
private _metadata = createHashMapFromArray [
    ["success", true],
    ["configured", true],
    ["canonicalClass", "vn_test_weapon"],
    ["allowedSides", ["WEST"]],
    ["minLevel", 1],
    ["licenseKills", 0],
    ["requiredPerks", []],
    ["purchasePrice", -1],
    ["rentalPrice", -1]
];

private _result = ["test_uid", "WEST", _progression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["No acquisition prices permits entitlement", _result getOrDefault ["entitled", false]] call _check;
["No acquisition prices is uncontrolled", (_result getOrDefault ["accessType", ""]) isEqualTo "UNCONTROLLED"] call _check;

_metadata set ["purchasePrice", 100];
_result = ["test_uid", "WEST", _progression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["Configured price requires acquisition", (_result getOrDefault ["code", ""]) isEqualTo "REQUIRES_ACQUISITION"] call _check;
["Configured price without ownership is denied", !(_result getOrDefault ["entitled", true])] call _check;

_metadata set ["purchasePrice", -1];
_metadata set ["minLevel", 20];
_result = ["test_uid", "WEST", _progression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["Level lock precedes absent acquisition", (_result getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL"] call _check;

_metadata set ["minLevel", 1];
_result = ["test_uid", "EAST", _progression, _metadata, "vn_test_weapon"] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules;
["Wrong side remains rejected", (_result getOrDefault ["code", ""]) isEqualTo "LOCKED_SIDE"] call _check;

diag_log format ["[BN_KOTH_TEST] Weapon entitlement rules: %1 failure(s): %2", count _failures, _failures];
_failures

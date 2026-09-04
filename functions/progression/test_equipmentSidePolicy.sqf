/*
    File: test_equipmentSidePolicy.sqf
    Author: Legend
    Description: Focused in-engine checks for KOTH equipment side policy.
        Run after mission functions/config are initialized. This file is not
        registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _metadata = createHashMapFromArray [
    ["success", true],
    ["configured", true],
    ["appearanceSide", ""],
    ["allowedSides", ["WEST"]]
];
private _result = ["WEST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
["WEST-only allows WEST", _result getOrDefault ["allowed", false]] call _check;
_result = ["EAST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
["WEST-only rejects EAST", !(_result getOrDefault ["allowed", true])] call _check;

_metadata set ["allowedSides", ["EAST"]];
_result = ["EAST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
["EAST-only allows EAST", _result getOrDefault ["allowed", false]] call _check;
_result = ["WEST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
["EAST-only rejects WEST", !(_result getOrDefault ["allowed", true])] call _check;

_metadata set ["allowedSides", ["WEST", "EAST"]];
["Both-sides allows WEST", (["WEST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules) getOrDefault ["allowed", false]] call _check;
["Both-sides allows EAST", (["EAST", _metadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules) getOrDefault ["allowed", false]] call _check;

_metadata set ["appearanceSide", "WEST"];
_result = ["EAST", _metadata, true] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
["Enemy appearance rejected", !(_result getOrDefault ["allowed", true])] call _check;

private _missingMetadata = createHashMapFromArray [
    ["success", true],
    ["configured", false],
    ["allowedSides", []],
    ["appearanceSide", ""]
];
["Missing combat metadata remains uncontrolled", (["WEST", _missingMetadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules) getOrDefault ["allowed", false]] call _check;
["Missing appearance metadata fails closed", !((["WEST", _missingMetadata, true] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules) getOrDefault ["allowed", true])] call _check;

private _variantMetadata = ["vn_l1a1_02"] call bn_koth_fnc_loadouts_getWeaponMetadata;
["Structural variant resolves canonical policy", (_variantMetadata getOrDefault ["canonicalClass", ""]) isEqualTo "vn_l1a1_01"] call _check;
["Structural variant inherits canonical allowedSides", (_variantMetadata getOrDefault ["allowedSides", []]) isEqualTo ["WEST"]] call _check;

// Appearance entitlement model: level >= minLevel AND (appearanceSide == side OR appearanceSide == BOTH).
// No ownership, rental, or Mastery input exists in this metadata/progression shape.
private _uniformWest = createHashMapFromArray [
    ["success", true], ["configured", true],
    ["allowedSides", ["WEST"]], ["appearanceSide", "WEST"], ["minLevel", 5]
];
private _uniformEast = createHashMapFromArray [
    ["success", true], ["configured", true],
    ["allowedSides", ["EAST"]], ["appearanceSide", "EAST"], ["minLevel", 5]
];
private _vestWest = createHashMapFromArray [
    ["success", true], ["configured", true],
    ["allowedSides", ["WEST"]], ["appearanceSide", "WEST"], ["minLevel", 1]
];
private _backpackEast = createHashMapFromArray [
    ["success", true], ["configured", true],
    ["allowedSides", ["EAST"]], ["appearanceSide", "EAST"], ["minLevel", 1]
];
private _headgearBoth = createHashMapFromArray [
    ["success", true], ["configured", true],
    ["allowedSides", ["WEST", "EAST"]], ["appearanceSide", "BOTH"], ["minLevel", 5]
];
private _leveledPlayer = createHashMapFromArray [["level", 10]];
private _underleveledPlayer = createHashMapFromArray [["level", 1]];

// 1-4: uniform strictly follows its own side, never the opposite.
["WEST uniform on WEST at level is entitled", ([_leveledPlayer, _uniformWest, "vn_test_uniform_west", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["WEST uniform on EAST is denied", !((([_leveledPlayer, _uniformWest, "vn_test_uniform_west", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true]))] call _check;
["EAST uniform on EAST at level is entitled", ([_leveledPlayer, _uniformEast, "vn_test_uniform_east", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["EAST uniform on WEST is denied", !((([_leveledPlayer, _uniformEast, "vn_test_uniform_east", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true]))] call _check;

// 5-6: vest/backpack use the identical rule; opposite side is always denied.
["WEST vest on EAST is denied", !((([_leveledPlayer, _vestWest, "vn_test_vest_west", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true]))] call _check;
["EAST backpack on WEST is denied", !((([_leveledPlayer, _backpackEast, "vn_test_backpack_east", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true]))] call _check;

// 7-8: headgear appearanceSide=BOTH is usable by either side, subject to level.
["BOTH headgear on WEST at level is entitled", ([_leveledPlayer, _headgearBoth, "vn_test_headgear_both", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["BOTH headgear on EAST at level is entitled", ([_leveledPlayer, _headgearBoth, "vn_test_headgear_both", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;

// 9: level gates regardless of side/appearance correctness.
private _belowLevelResult = [_underleveledPlayer, _headgearBoth, "vn_test_headgear_both", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
["Below-level appearance item is denied regardless of side", !(_belowLevelResult getOrDefault ["entitled", true])] call _check;
["Below-level appearance item reports LOCKED_LEVEL", (_belowLevelResult getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL"] call _check;

// 10: sourceAffiliations[] must never be read by the side-policy interpreter, in either direction.
private _spoofedAffiliation = createHashMap;
{_spoofedAffiliation set [_x, _uniformWest get _x];} forEach (keys _uniformWest);
_spoofedAffiliation set ["sourceAffiliations", ["EAST"]];
["sourceAffiliations does not grant opposite-side entitlement", !((([_leveledPlayer, _spoofedAffiliation, "vn_test_uniform_west", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true]))] call _check;
["sourceAffiliations does not revoke native-side entitlement", ([_leveledPlayer, _spoofedAffiliation, "vn_test_uniform_west", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;

// 11: appearance entitlement result never carries a Mastery/ownership/rental signal.
private _appearanceResult = [_leveledPlayer, _headgearBoth, "vn_test_headgear_both", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
["Appearance entitlement never reports masteryKillsRequired", isNil {_appearanceResult get "masteryKillsRequired"}] call _check;
["Appearance entitlement never reports crossSideAllowed", isNil {_appearanceResult get "crossSideAllowed"}] call _check;
["Appearance entitlement never reports owned/rented", isNil {_appearanceResult get "owned"} && {isNil {_appearanceResult get "rented"}}] call _check;

// Real authored metadata regression cases for saved-kit visual identity. The
// server mutation path calls these same shared entitlement rules with
// requireAppearance=true before accepting an untrusted local kit.
private _realProgression = createHashMapFromArray [["level", 300]];
private _realWestUniform = ["Wearables", "vn_b_uniform_aus_01_01"] call bn_koth_fnc_loadouts_getItemMetadata;
private _realEastUniform = ["Wearables", "vn_o_uniform_nva_air_01"] call bn_koth_fnc_loadouts_getItemMetadata;
private _realBothHeadgear = ["Wearables", "vn_b_bandana_01"] call bn_koth_fnc_loadouts_getItemMetadata;

["Authored WEST uniform metadata is configured", _realWestUniform getOrDefault ["configured", false]] call _check;
["Authored WEST uniform rejects EAST appearance", !(([_realProgression, _realWestUniform, "vn_b_uniform_aus_01_01", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true])] call _check;
["Authored WEST uniform allows WEST appearance", ([_realProgression, _realWestUniform, "vn_b_uniform_aus_01_01", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["Authored EAST uniform rejects WEST appearance", !(([_realProgression, _realEastUniform, "vn_o_uniform_nva_air_01", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", true])] call _check;
["Authored EAST uniform allows EAST appearance", ([_realProgression, _realEastUniform, "vn_o_uniform_nva_air_01", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["Authored BOTH headgear allows WEST appearance", ([_realProgression, _realBothHeadgear, "vn_b_bandana_01", "WEST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;
["Authored BOTH headgear allows EAST appearance", ([_realProgression, _realBothHeadgear, "vn_b_bandana_01", "EAST", true] call bn_koth_fnc_progression_evaluateItemEntitlementRules) getOrDefault ["entitled", false]] call _check;

diag_log format ["[BN_KOTH_TEST] Equipment side policy: %1 failure(s): %2", count _failures, _failures];
_failures

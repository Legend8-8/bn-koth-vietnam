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

diag_log format ["[BN_KOTH_TEST] Equipment side policy: %1 failure(s): %2", count _failures, _failures];
_failures

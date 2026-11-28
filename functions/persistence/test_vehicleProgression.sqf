/*
    File: test_vehicleProgression.sqf
    Author: Legend
    Description: Pure persistence and entitlement checks for vehicle families,
        first-spawn use, mastery prerequisites, and legacy normalization.
    Execution: Server debug/test context
    Returns: Failed assertion labels <ARRAY>
*/
private _failures = [];
private _check = {params ["_label", "_condition"]; if (!_condition) then {_failures pushBack _label}};
private _mastery = createHashMapFromArray [["UH1", createHashMapFromArray [["insertions", 12], ["infantryKills", 8]]]];
private _state = createHashMapFromArray [["ownedVehicleFamilies", ["UH1"]], ["vehicleFirstSpawnsUsed", ["UH1"]], ["vehicleMastery", _mastery]];
private _serialized = [_state] call bn_koth_fnc_persistence_serializeVehicleProgression;
private _parsed = [_serialized getOrDefault ["value", ""]] call bn_koth_fnc_persistence_deserializeVehicleProgression;
["Vehicle progression serializes", _serialized getOrDefault ["success", false]] call _check;
["Ownership round-trips", (_parsed getOrDefault ["owned", []]) isEqualTo ["UH1"]] call _check;
["First-spawn use round-trips once", (_parsed getOrDefault ["used", []]) isEqualTo ["UH1"]] call _check;
["Mastery round-trips", (((_parsed getOrDefault ["mastery", createHashMap]) getOrDefault ["UH1", createHashMap]) getOrDefault ["insertions", -1]) isEqualTo 12] call _check;
private _malformed = ["not-data"] call bn_koth_fnc_persistence_deserializeVehicleProgression;
["Malformed non-decimal progression fails closed", !(_malformed getOrDefault ["success", true])] call _check;
private _malformedDecoded = ["091"] call bn_koth_fnc_persistence_deserializeVehicleProgression;
["Malformed decoded progression is caught and fails closed", !(_malformedDecoded getOrDefault ["success", true]) && {(_malformedDecoded getOrDefault ["code", ""]) isEqualTo "MALFORMED_VEHICLE_PROGRESSION"}] call _check;
private _legacy = ["VEHICLE_LEGACY", createHashMapFromArray [["schemaVersion", 3], ["uid", "VEHICLE_LEGACY"], ["xp", 10], ["cash", 20]]] call bn_koth_fnc_persistence_normalizePlayerState;
private _legacyState = _legacy getOrDefault ["state", createHashMap];
["Schema v3 gains empty vehicle ownership", (_legacyState getOrDefault ["ownedVehicleFamilies", ["bad"]]) isEqualTo []] call _check;
["Schema v3 gains empty vehicle mastery", (_legacyState getOrDefault ["vehicleMastery", objNull]) isEqualType createHashMap] call _check;

private _uh1Base = ["vn_b_air_uh1e_03_04"] call bn_koth_fnc_vehicles_getProgressionMetadata;
private _unowned = [createHashMapFromArray [["ownedVehicleFamilies", []], ["vehicleMastery", createHashMap]], _uh1Base] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Unowned base is purchase eligible", _unowned getOrDefault ["purchaseEligible", false]] call _check;
private _unownedBaseRental = [createHashMapFromArray [["ownedVehicleFamilies", []], ["vehicleMastery", createHashMap]], _uh1Base, false] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Unowned rentable base passes rental loadout rules", (_uh1Base getOrDefault ["rentable", false]) && {_unownedBaseRental getOrDefault ["unlocked", false]}] call _check;
private _ownedState = createHashMapFromArray [["ownedVehicleFamilies", ["UH1"]], ["vehicleMastery", createHashMap]];
private _ownedBase = [_ownedState, _uh1Base] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Owned base loadout is unlocked", _ownedBase getOrDefault ["unlocked", false]] call _check;
private _uh1Gunship = ["vn_b_air_uh1e_01_04"] call bn_koth_fnc_vehicles_getProgressionMetadata;
private _locked = [_ownedState, _uh1Gunship] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Missing mastery locks stronger loadout", !(_locked getOrDefault ["unlocked", true])] call _check;
private _rentalMastery = createHashMapFromArray [["UH1", createHashMapFromArray [["insertions", 5]]]];
private _unownedAdvancedState = createHashMapFromArray [["ownedVehicleFamilies", []], ["vehicleFirstSpawnsUsed", []], ["vehicleMastery", _rentalMastery]];
private _unownedAdvancedOwnedRules = [_unownedAdvancedState, _uh1Gunship, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
private _unownedAdvancedRentalRules = [_unownedAdvancedState, _uh1Gunship, false] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Unowned advanced loadout remains unavailable to owned SPAWN", !(_unownedAdvancedOwnedRules getOrDefault ["unlocked", true]) && {(_unownedAdvancedOwnedRules getOrDefault ["code", ""]) isEqualTo "FAMILY_NOT_OWNED"}] call _check;
["Unowned configured advanced rental unlocks from mastery", (_uh1Gunship getOrDefault ["rentable", false]) && {_unownedAdvancedRentalRules getOrDefault ["unlocked", false]}] call _check;
["Rental evaluation does not mutate ownership or first-spawn state", (_unownedAdvancedState getOrDefault ["ownedVehicleFamilies", ["bad"]]) isEqualTo [] && {(_unownedAdvancedState getOrDefault ["vehicleFirstSpawnsUsed", ["bad"]]) isEqualTo []}] call _check;
private _ownedAdvancedState = createHashMapFromArray [["ownedVehicleFamilies", ["UH1"]], ["vehicleFirstSpawnsUsed", ["UH1"]], ["vehicleMastery", _rentalMastery]];
private _ownedAdvancedUnlocked = [_ownedAdvancedState, _uh1Gunship, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
["Owned SPAWN unlocks only after prerequisite mastery", _ownedAdvancedUnlocked getOrDefault ["unlocked", false]] call _check;
private _uh1Bushranger = ["vn_b_air_uh1d_03_06"] call bn_koth_fnc_vehicles_getProgressionMetadata;
["Mastery-exclusive loadout remains explicitly non-rentable", !(_uh1Bushranger getOrDefault ["rentable", true])] call _check;
_failures

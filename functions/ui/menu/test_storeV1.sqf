/*
    File: test_storeV1.sqf
    Author: Legend
    Description: Focused in-engine checks for canonical Store catalogue and
        weapon-state presentation. This file is not runtime-registered.
    Execution: Client debug/test context
    Returns: Failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _storeCards = call bn_koth_fnc_menu_getItemCardControls;
private _storeCardIdcs = [];
{_storeCardIdcs append _x} forEach _storeCards;
["Store paging uses the shared four-card pool", (count _storeCards) isEqualTo 4] call _check;
["Shared Store card controls remain uniquely addressed", (count _storeCardIdcs) isEqualTo (count (_storeCardIdcs arrayIntersect _storeCardIdcs))] call _check;

private _entries = [] call bn_koth_fnc_menu_buildStoreWeaponEntries;
private _classes = _entries apply {_x getOrDefault ["weaponClass", ""]};
private _uniqueClasses = _classes arrayIntersect _classes;
["Store catalogue contains only unique canonical roots", (count _classes) isEqualTo (count _uniqueClasses)] call _check;
private _allCanonical = (_entries findIf {
    private _entryClass = _x getOrDefault ["weaponClass", ""];
    private _entryMetadata = _x getOrDefault ["metadata", createHashMap];
    !((_entryMetadata getOrDefault ["canonicalClass", ""]) isEqualTo _entryClass)
}) < 0;
["Store catalogue contains no structural variants", _allCanonical] call _check;

private _sideSurfaces = _entries apply {(_x getOrDefault ["metadata", createHashMap]) getOrDefault ["allowedSides", []]};
["Global Store includes a WEST weapon", (_sideSurfaces findIf {"WEST" in _x && {!("EAST" in _x)}}) >= 0] call _check;
["Global Store includes an EAST weapon", (_sideSurfaces findIf {"EAST" in _x && {!("WEST" in _x)}}) >= 0] call _check;
["Global Store includes a BOTH weapon", (_sideSurfaces findIf {"WEST" in _x && {"EAST" in _x}}) >= 0] call _check;

private _sortedClasses = +_classes;
private _sortKeys = _entries apply {format ["%1|%2", toLower (_x getOrDefault ["displayName", ""]), _x getOrDefault ["weaponClass", ""]]};
private _sortedKeys = +_sortKeys;
_sortedKeys sort true;
["Store catalogue ordering is deterministic", _sortKeys isEqualTo _sortedKeys] call _check;

private _weaponCategories = _entries apply {_x getOrDefault ["storeCategory", ""]};
["Every Store weapon has an infantry category", (_weaponCategories findIf {!(_x in ["PRIMARY", "SIDEARMS", "LAUNCHERS"])}) < 0] call _check;
["Handguns classify as Sidearms", (_entries findIf {(_x getOrDefault ["weaponType", ""]) isEqualTo "handgun" && {!((_x getOrDefault ["storeCategory", ""]) isEqualTo "SIDEARMS")}}) < 0] call _check;
["Launchers classify as Launchers", (_entries findIf {(_x getOrDefault ["weaponType", ""]) isEqualTo "launcher" && {!((_x getOrDefault ["storeCategory", ""]) isEqualTo "LAUNCHERS")}}) < 0] call _check;
["Primary products hand off to Primary Arsenal", (_entries findIf {(_x getOrDefault ["storeCategory", ""]) isEqualTo "PRIMARY" && {!((_x getOrDefault ["arsenalSlot", ""]) isEqualTo "primary")}}) < 0] call _check;
["Sidearms hand off to Handgun Arsenal", (_entries findIf {(_x getOrDefault ["storeCategory", ""]) isEqualTo "SIDEARMS" && {!((_x getOrDefault ["arsenalSlot", ""]) isEqualTo "handgun")}}) < 0] call _check;
["Launchers hand off to Launcher Arsenal", (_entries findIf {(_x getOrDefault ["storeCategory", ""]) isEqualTo "LAUNCHERS" && {!((_x getOrDefault ["arsenalSlot", ""]) isEqualTo "launcher")}}) < 0] call _check;

private _vehicleEntries = [] call bn_koth_fnc_menu_buildStoreVehicleEntries;
private _vehicleClasses = _vehicleEntries apply {_x getOrDefault ["vehicleClass", ""]};
private _vehicleUnique = _vehicleClasses arrayIntersect _vehicleClasses;
["Vehicle Store contains exactly the 84 curated products", (count _vehicleEntries) isEqualTo 84] call _check;
["Vehicle Store contains unique canonical products", (count _vehicleClasses) isEqualTo (count _vehicleUnique)] call _check;
["SEA stays hidden while the curated set is empty", (_vehicleEntries findIf {(_x getOrDefault ["storeCategory", ""]) isEqualTo "SEA"}) < 0] call _check;
private _editorPreviewCount = {(_x getOrDefault ["previewSource", "NONE"]) isEqualTo "EDITOR_PREVIEW"} count _vehicleEntries;
private _pictureFallbackCount = {(_x getOrDefault ["previewSource", "NONE"]) isEqualTo "PICTURE"} count _vehicleEntries;
private _missingPreviewCount = {(_x getOrDefault ["previewSource", "NONE"]) isEqualTo "NONE"} count _vehicleEntries;
["Every curated vehicle has one explicit preview source", (_editorPreviewCount + _pictureFallbackCount + _missingPreviewCount) isEqualTo (count _vehicleEntries)] call _check;
diag_log format ["[BN_KOTH][STORE_TEST] VEHICLE_PREVIEWS editorPreview=%1 pictureFallback=%2 neither=%3", _editorPreviewCount, _pictureFallbackCount, _missingPreviewCount];
private _vehicleSortKeys = _vehicleEntries apply {format ["%1|%2", toLower (_x getOrDefault ["displayName", ""]), _x getOrDefault ["vehicleClass", ""]]};
private _sortedVehicleKeys = +_vehicleSortKeys;
_sortedVehicleKeys sort true;
["Vehicle Store ordering is deterministic", _vehicleSortKeys isEqualTo _sortedVehicleKeys] call _check;
private _configuredVehicleClasses = ("true" configClasses (missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles")) apply {toLower (configName _x)};
["Vehicle Store uses only configured curated products", (_vehicleClasses findIf {!(_x in _configuredVehicleClasses)}) < 0] call _check;

private _vehicleProjectionEntry = createHashMapFromArray [
    ["metadata", createHashMapFromArray [["minLevel", 25], ["purchasePrice", 18000], ["rentalPrice", 3600]]],
    ["eligibility", createHashMapFromArray [["code", "LOCKED_LEVEL"], ["eligible", false]]]
];
private _vehicleProjection = [_vehicleProjectionEntry] call bn_koth_fnc_menu_projectStoreVehicleState;
["Vehicle level lock projects without enabling actions", (_vehicleProjection getOrDefault ["stateLabel", ""]) isEqualTo "LOCKED - LEVEL 25" && {!(_vehicleProjection getOrDefault ["actionsAvailable", true])}] call _check;

private _metadata = createHashMapFromArray [
    ["minLevel", 10], ["allowedSides", ["WEST"]], ["masteryKillsRequired", 50],
    ["crossSideAllowed", true], ["purchasePrice", 400], ["rentalPrice", 100]
];
private _makeEntry = {
    params ["_code", ["_extra", createHashMap, [createHashMap]]];
    private _entitlement = createHashMapFromArray [["code", _code], ["accessType", "NONE"]];
    {_entitlement set [_x, _extra get _x]} forEach (keys _extra);
    createHashMapFromArray [["metadata", _metadata], ["entitlement", _entitlement]]
};

private _levelState = [["LOCKED_LEVEL"] call _makeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Level lock is prominent and cannot transact", (_levelState get "stateLabel") isEqualTo "LOCKED · LEVEL 10" && {_levelState get "blocking"} && {!(_levelState get "canBuy")}] call _check;

private _masteryEntry = ["LOCKED_MASTERY", createHashMapFromArray [["masteryKills", 0], ["crossSide", true]]] call _makeEntry;
_masteryEntry set ["masteryKills", 18];
private _masteryState = [_masteryEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Mastery progress is a prominent blocking state", (_masteryState get "stateLabel") isEqualTo "MASTERY 18 / 50 KILLS" && {_masteryState get "blocking"}] call _check;

private _levelMasteryEntry = ["LOCKED_LEVEL", createHashMapFromArray [["crossSide", true]]] call _makeEntry;
_levelMasteryEntry set ["masteryKills", 17];
private _levelMasteryState = [_levelMasteryEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Mastery progress remains visible independently of level", (_levelMasteryState get "stateLabel") isEqualTo "LEVEL 10 · MASTERY 17 / 50 KILLS"] call _check;

private _completeLevelEntry = ["LOCKED_LEVEL", createHashMapFromArray [["crossSide", true]]] call _makeEntry;
_completeLevelEntry set ["masteryKills", 50];
private _completeLevelState = [_completeLevelEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Completed Mastery remains visible beside a level gate", (_completeLevelState get "stateLabel") isEqualTo "MASTERY COMPLETE · LEVEL 10"] call _check;

private _restrictedMetadata = createHashMapFromArray [
    ["minLevel", 10], ["allowedSides", ["WEST"]], ["masteryKillsRequired", 50],
    ["crossSideAllowed", false], ["purchasePrice", 400], ["rentalPrice", 100]
];
private _restrictedEntry = createHashMapFromArray [
    ["metadata", _restrictedMetadata],
    ["entitlement", createHashMapFromArray [["code", "CROSS_SIDE_NOT_ALLOWED"], ["accessType", "NONE"], ["crossSide", true]]]
];
private _sideState = [_restrictedEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Prohibited cross-side weapon is faction restricted", (_sideState get "stateLabel") isEqualTo "FACTION RESTRICTED" && {_sideState get "blocking"} && {!(_sideState get "canBuy")}] call _check;

private _completeEntry = ["ENTITLED", createHashMapFromArray [["crossSide", true], ["accessType", "UNCONTROLLED"]]] call _makeEntry;
_completeEntry set ["masteryKills", 50];
private _completeState = [_completeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Completed cross-side mastery is explicit", (_completeState get "stateLabel") isEqualTo "MASTERY COMPLETE"] call _check;

private _ownedState = [["ENTITLED", createHashMapFromArray [["accessType", "OWNED"]]] call _makeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Owned state suppresses acquisition", (_ownedState get "owned") && {!(_ownedState get "canBuy")} && {!(_ownedState get "canRent")}] call _check;

private _rentedState = [["ENTITLED", createHashMapFromArray [["accessType", "RENTED"]]] call _makeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Rented state permits configured permanent upgrade", (_rentedState get "rented") && {_rentedState get "canBuy"} && {!(_rentedState get "canRent")}] call _check;

private _insufficientCashState = [["REQUIRES_ACQUISITION"] call _makeEntry, 50] call bn_koth_fnc_menu_projectStoreWeaponState;
["Cached cash projects affordability without becoming authority", (_insufficientCashState get "canBuy") && {!(_insufficientCashState get "canAffordPurchase")}] call _check;

private _unpricedMetadata = createHashMapFromArray ((keys _metadata) apply {[_x, _metadata get _x]});
_unpricedMetadata set ["purchasePrice", -1];
_unpricedMetadata set ["rentalPrice", -1];
private _unpricedEntry = createHashMapFromArray [
    ["metadata", _unpricedMetadata],
    ["entitlement", createHashMapFromArray [["code", "ENTITLED"], ["accessType", "UNCONTROLLED"]]]
];
private _unpricedState = [_unpricedEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Unpriced acquisition fails safe in presentation", (_unpricedState get "stateLabel") isEqualTo "ACQUISITION NOT CONFIGURED" && {!(_unpricedState get "canBuy")} && {!(_unpricedState get "canRent")}] call _check;

diag_log format ["[BN_KOTH_TEST] Store V1: %1 failure(s): %2", count _failures, _failures];
_failures

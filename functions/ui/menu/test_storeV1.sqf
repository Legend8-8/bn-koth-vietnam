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

private _metadata = createHashMapFromArray [
    ["minLevel", 10], ["allowedSides", ["WEST"]], ["masteryKillsRequired", 50],
    ["purchasePrice", 400], ["rentalPrice", 100]
];
private _makeEntry = {
    params ["_code", ["_extra", createHashMap, [createHashMap]]];
    private _entitlement = createHashMapFromArray [["code", _code], ["accessType", "NONE"]];
    {_entitlement set [_x, _extra get _x]} forEach (keys _extra);
    createHashMapFromArray [["metadata", _metadata], ["entitlement", _entitlement]]
};

private _levelState = [["LOCKED_LEVEL"] call _makeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Level lock is presented and cannot transact", (_levelState get "stateLabel") isEqualTo "LOCKED - LEVEL 10" && {!(_levelState get "canBuy")}] call _check;

private _masteryEntry = ["LOCKED_MASTERY", createHashMapFromArray [["masteryKills", 0]]] call _makeEntry;
_masteryEntry set ["masteryKills", 18];
private _masteryState = [_masteryEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Mastery progress is presented", (_masteryState get "stateLabel") isEqualTo "MASTERY 18 / 50"] call _check;

private _sideState = [["CROSS_SIDE_NOT_ALLOWED"] call _makeEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Unavailable cross-side weapon cannot transact", (_sideState get "stateLabel") isEqualTo "UNAVAILABLE FOR YOUR FACTION" && {!(_sideState get "canBuy")}] call _check;

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

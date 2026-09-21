/*
    File: test_storeV1.sqf
    Author: Legend
    Description: Focused in-engine checks for canonical Store and Arsenal
        weapon catalogues and weapon-state presentation. This file is not
        runtime-registered.
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

private _compatibilityCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility";
{
    _x params ["_slotToken", "_expectedClearCount"];
    private _browserEntries = [_compatibilityCfg, _slotToken] call bn_koth_fnc_menu_buildBrowserWeaponEntries;
    private _clearEntries = _browserEntries select {_x getOrDefault ["clearSlot", false]};

    [format ["%1 Arsenal catalogue has expected clear entry count", _slotToken], (count _clearEntries) isEqualTo _expectedClearCount] call _check;
    if (_expectedClearCount > 0) then {
        [format ["%1 Arsenal clear entry remains first", _slotToken],
            (count _browserEntries) > 0 &&
            {(_browserEntries select 0) getOrDefault ["clearSlot", false]} &&
            {((_browserEntries select 0) getOrDefault ["weaponClass", "__missing__"]) isEqualTo ""} &&
            {((_browserEntries select 0) getOrDefault ["displayName", ""]) isEqualTo "NONE"}
        ] call _check;
    };
} forEach [
    ["PRIMARY", 0],
    ["HANDGUN", 1],
    ["LAUNCHER", 1]
];

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

private _sortKeys = _entries apply {
    private _levelText = str (((_x getOrDefault ["metadata", createHashMap]) getOrDefault ["minLevel", 1]) max 1);
    format ["%1|%2|%3", ("000000" + _levelText) select [(count _levelText), 6], toLower (_x getOrDefault ["displayName", ""]), _x getOrDefault ["weaponClass", ""]]
};
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
private _vehicleSortKeys = _vehicleEntries apply {
    private _levelText = str (_x getOrDefault ["familyBaseMinLevel", 999]);
    format [
        "%1|%2|%3|%4|%5|%6",
        _x getOrDefault ["storeCategory", ""],
        ("000000" + _levelText) select [(count _levelText), 6],
        toLower (_x getOrDefault ["familyDisplayName", ""]),
        1000 + (_x getOrDefault ["familyProgressionOrder", 999]),
        toLower (_x getOrDefault ["displayName", ""]),
        _x getOrDefault ["vehicleClass", ""]
    ]
};
private _sortedVehicleKeys = +_vehicleSortKeys;
_sortedVehicleKeys sort true;
["Vehicle Store family/progression ordering is deterministic", _vehicleSortKeys isEqualTo _sortedVehicleKeys] call _check;
private _configuredVehicleClasses = ("true" configClasses (missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles")) apply {toLower (configName _x)};
["Vehicle Store uses only configured curated products", (_vehicleClasses findIf {!(_x in _configuredVehicleClasses)}) < 0] call _check;

private _vehicleByLoadout = createHashMap;
private _vehicleFamilies = createHashMap;
{
    private _entry = _x;
    private _metadata = _entry getOrDefault ["metadata", createHashMap];
    private _loadoutId = _metadata getOrDefault ["loadoutId", ""];
    private _familyId = _metadata getOrDefault ["familyId", ""];
    _vehicleByLoadout set [_loadoutId, _entry];
    private _familyRows = _vehicleFamilies getOrDefault [_familyId, []];
    _familyRows pushBack [_forEachIndex, _entry];
    _vehicleFamilies set [_familyId, _familyRows];
    [format ["%1 has a human family name", _entry getOrDefault ["vehicleClass", ""]],
        !((_entry getOrDefault ["familyDisplayName", ""]) in ["", _familyId, _loadoutId])] call _check;
    if (_metadata getOrDefault ["baseLoadout", false]) then {
        [format ["%1 base has no displayed prerequisite", _entry getOrDefault ["vehicleClass", ""]],
            (_entry getOrDefault ["requiredLoadoutDisplayName", "__missing__"]) isEqualTo ""] call _check;
    };
} forEach _vehicleEntries;
{
    private _entry = _x;
    private _metadata = _entry getOrDefault ["metadata", createHashMap];
    private _requiredLoadout = _metadata getOrDefault ["requiredLoadout", ""];
    if !(_requiredLoadout isEqualTo "") then {
        private _requiredEntry = _vehicleByLoadout getOrDefault [_requiredLoadout, createHashMap];
        [format ["%1 resolves prerequisite display name", _entry getOrDefault ["vehicleClass", ""]],
            !(_requiredEntry isEqualTo createHashMap) &&
            {(_entry getOrDefault ["requiredLoadoutDisplayName", ""]) isEqualTo (_requiredEntry getOrDefault ["displayName", "__missing__"])} &&
            {!((_entry getOrDefault ["requiredLoadoutDisplayName", ""]) isEqualTo _requiredLoadout)}] call _check;
    };
} forEach _vehicleEntries;
{
    private _rows = _vehicleFamilies get _x;
    private _indices = _rows apply {_x select 0};
    private _firstEntry = (_rows select 0) select 1;
    [format ["%1 family is contiguous", _x], ((_indices select ((count _indices) - 1)) - (_indices select 0) + 1) isEqualTo count _indices] call _check;
    [format ["%1 family begins with base loadout", _x], ((_firstEntry getOrDefault ["metadata", createHashMap]) getOrDefault ["baseLoadout", false])] call _check;
    [format ["%1 family uses its base minimum level for ordering", _x],
        (_firstEntry getOrDefault ["familyBaseMinLevel", -1]) isEqualTo (((_firstEntry getOrDefault ["metadata", createHashMap]) getOrDefault ["minLevel", 1]) max 1) &&
        {(_rows findIf {((_x select 1) getOrDefault ["familyBaseMinLevel", -1]) isNotEqualTo (_firstEntry getOrDefault ["familyBaseMinLevel", -1])}) < 0}] call _check;
    {
        private _entry = _x select 1;
        [format ["%1 family progression order is sequential", _entry getOrDefault ["vehicleClass", ""]],
            (_entry getOrDefault ["familyProgressionOrder", -1]) isEqualTo _forEachIndex] call _check;
    } forEach _rows;
} forEach (keys _vehicleFamilies);
private _rotaryFamilyOrder = [];
{
    private _familyId = (_x getOrDefault ["metadata", createHashMap]) getOrDefault ["familyId", ""];
    _rotaryFamilyOrder pushBackUnique _familyId;
} forEach (_vehicleEntries select {(_x getOrDefault ["storeCategory", ""]) isEqualTo "ROTARY"});
["Rotary families follow base-level progression order", _rotaryFamilyOrder isEqualTo ["OH6", "MI2", "UH34", "UH1", "CH47", "AH1G"]] call _check;

private _refreshStoreSource = preprocessFileLineNumbers "functions\ui\menu\fn_menu_refreshStore.sqf";
["Base vehicle detail uses purchase ownership wording", (_refreshStoreSource find '"BASE LOADOUT"') >= 0 && {(_refreshStoreSource find '"PURCHASE TO OWN FAMILY"') >= 0}] call _check;
["Advanced vehicle detail labels human prerequisite", (_refreshStoreSource find '"REQUIRED LOADOUT: %1"') >= 0] call _check;
["Vehicle detail separates mastery progress", (_refreshStoreSource find '"MASTERY PROGRESS: %1"') >= 0] call _check;
["Vehicle detail separates ownership and transaction concepts",
    (_refreshStoreSource find '"OWNERSHIP: %1"') >= 0 &&
    {(_refreshStoreSource find '"PURCHASE"') >= 0} &&
    {(_refreshStoreSource find '"REPLACEMENT"') >= 0} &&
    {(_refreshStoreSource find '"RENTAL"') >= 0} &&
    {(_refreshStoreSource find '"MASTERY EXCLUSIVE"') >= 0}] call _check;
["Vehicle detail does not expose legacy prerequisite wording", (_refreshStoreSource find '"PREREQUISITE: %1"') < 0 && {(_refreshStoreSource find '"BASE FAMILY"') < 0}] call _check;
["Vehicle detail does not read internal logical IDs",
    (_refreshStoreSource find 'getOrDefault ["familyId"') < 0 &&
    {(_refreshStoreSource find 'getOrDefault ["loadoutId"') < 0} &&
    {(_refreshStoreSource find 'getOrDefault ["requiredLoadout"') < 0}] call _check;
["Vehicle cards use a dimmed LOCKED overlay", (_refreshStoreSource find '_overlay ctrlShow _showVehicleLock') >= 0 && {(_refreshStoreSource find '_lock ctrlSetText (if (_showVehicleLock) then {"LOCKED"}') >= 0}] call _check;
["Vehicle detail presents aggregate unmet requirements", (_refreshStoreSource find '"UNMET REQUIREMENTS"') >= 0 && {(_refreshStoreSource find 'getOrDefault ["lockReasons"') >= 0}] call _check;
["Vehicle PURCHASE and RENT buttons invoke the authoritative request path",
    (_refreshStoreSource find "['PURCHASE',%1,''] call bn_koth_fnc_vehicles_requestRental") >= 0 &&
    {(_refreshStoreSource find "['RENT',%1,''] call bn_koth_fnc_vehicles_requestRental") >= 0}] call _check;
private _vehicleReceiverSource = preprocessFileLineNumbers "functions\vehicles\fn_receiveRentalResult.sqf";
["Vehicle result invalidates cached presentation and exposes inline feedback",
    (_vehicleReceiverSource find 'uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""]') >= 0 &&
    {(_vehicleReceiverSource find 'uiNamespace setVariable ["BN_KOTH_menuVehicleTransactionResult", _result]') >= 0}] call _check;

private _vehicleProjectionEntry = createHashMapFromArray [
    ["displayName", "M151A1 Jeep"],
    ["familyDisplayName", "M151A1 Jeep"],
    ["requiredLoadoutDisplayName", ""],
    ["playerSide", "WEST"], ["playerLevel", 10], ["playerPerks", []],
    ["metadata", createHashMapFromArray [["minLevel", 25], ["allowedSides", ["WEST"]], ["requiredPerks", []], ["purchasePrice", 15000], ["rentalPrice", 2400], ["replacementPrice", 1200], ["baseLoadout", true], ["rentable", true]]],
    ["eligibility", createHashMapFromArray [["code", "LOCKED_LEVEL"], ["eligible", false]]],
    ["loadoutEligibility", createHashMapFromArray [["owned", false], ["unlocked", false], ["purchaseEligible", true]]],
    ["rentalEligibility", createHashMapFromArray [["unlocked", true]]]
];
private _savedProgressionLocal = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
private _savedVehiclePersonalLocal = missionNamespace getVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMap];
missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", createHashMapFromArray [["cash", 10000]]];
missionNamespace setVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMap];
private _vehicleProjection = [_vehicleProjectionEntry] call bn_koth_fnc_menu_projectStoreVehicleState;
["Vehicle level lock projects all current blocking state without enabling actions",
    (_vehicleProjection getOrDefault ["stateLabel", ""]) isEqualTo "LOCKED" &&
    {"LEVEL 25" in (_vehicleProjection getOrDefault ["lockReasons", []])} &&
    {_vehicleProjection getOrDefault ["blocking", false]} &&
    {!(_vehicleProjection getOrDefault ["canPurchase", true])} &&
    {!(_vehicleProjection getOrDefault ["canRent", true])}] call _check;

private _aggregateEntry = createHashMapFromArray [
    ["vehicleClass", "test_aggregate"], ["displayName", "Test Gunship"],
    ["familyDisplayName", "OH-6A Cayuse"], ["requiredLoadoutDisplayName", "OH-6A Cayuse Gunship"],
    ["playerSide", "EAST"], ["playerLevel", 12], ["playerPerks", []],
    ["metadata", createHashMapFromArray [
        ["minLevel", 48], ["allowedSides", ["WEST"]], ["requiredPerks", ["medic"]],
        ["purchasePrice", 30000], ["rentalPrice", 6000], ["replacementPrice", 3000], ["baseLoadout", false], ["rentable", true]
    ]],
    ["eligibility", createHashMapFromArray [["code", "LOCKED_SIDE"]]],
    ["loadoutEligibility", createHashMapFromArray [["owned", false], ["unlocked", false], ["purchaseEligible", false], ["missingMastery", createHashMap]]],
    ["rentalEligibility", createHashMapFromArray [["unlocked", false], ["missingMastery", createHashMapFromArray [["insertions", [0, 5]]]]]]
];
missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", createHashMapFromArray [["cash", 0]]];
missionNamespace setVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMapFromArray [["activeClass", "another_vehicle"], ["cooldownRemaining", 42]]];
private _aggregateState = [_aggregateEntry] call bn_koth_fnc_menu_projectStoreVehicleState;
private _aggregateReasons = _aggregateState getOrDefault ["lockReasons", []];
["Vehicle lock presentation aggregates side, level, ownership, loadout, mastery, perk, active life, cooldown and cash",
    "WEST FACTION ONLY" in _aggregateReasons &&
    {"LEVEL 48" in _aggregateReasons} &&
    {"PURCHASE OH-6A CAYUSE" in _aggregateReasons} &&
    {"REQUIRED LOADOUT OH-6A CAYUSE GUNSHIP" in _aggregateReasons} &&
    {"INSERTIONS 0/5" in _aggregateReasons} &&
    {"PERK MEDIC" in _aggregateReasons} &&
    {"PERSONAL VEHICLE ACTIVE" in _aggregateReasons} &&
    {"COOLDOWN 42S" in _aggregateReasons} &&
    {"INSUFFICIENT CASH" in _aggregateReasons}] call _check;
["Aggregate vehicle lock text exposes no logical family/loadout IDs",
    ((_aggregateState getOrDefault ["lockSummary", ""]) find "TEST_") < 0 &&
    {((_aggregateState getOrDefault ["lockSummary", ""]) find "OH6_") < 0}] call _check;

private _exclusiveEntry = createHashMapFromArray ((keys _aggregateEntry) apply {[_x, _aggregateEntry get _x]});
private _exclusiveMetadata = createHashMapFromArray ((keys (_aggregateEntry get "metadata")) apply {[_x, (_aggregateEntry get "metadata") get _x]});
_exclusiveMetadata set ["rentable", false];
_exclusiveEntry set ["metadata", _exclusiveMetadata];
private _exclusiveState = [_exclusiveEntry] call bn_koth_fnc_menu_projectStoreVehicleState;
["Unowned non-rentable advanced vehicle is clearly mastery exclusive", "MASTERY EXCLUSIVE" in (_exclusiveState getOrDefault ["lockReasons", []])] call _check;

private _advancedRentalEntry = createHashMapFromArray [
    ["vehicleClass", "test_advanced_rental"],
    ["playerSide", "WEST"], ["playerLevel", 99], ["playerPerks", []], ["familyDisplayName", "Test Family"], ["requiredLoadoutDisplayName", "Test Base"],
    ["metadata", createHashMapFromArray [["minLevel", 1], ["allowedSides", ["WEST"]], ["requiredPerks", []], ["purchasePrice", 35000], ["rentalPrice", 5600], ["replacementPrice", 2800], ["baseLoadout", false], ["rentable", true]]],
    ["eligibility", createHashMapFromArray [["code", "ELIGIBLE"], ["eligible", true]]],
    ["loadoutEligibility", createHashMapFromArray [["owned", false], ["unlocked", false], ["purchaseEligible", false]]],
    ["rentalEligibility", createHashMapFromArray [["unlocked", true], ["missingMastery", createHashMap]]]
];
missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", createHashMapFromArray [["cash", 10000]]];
missionNamespace setVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMap];
private _advancedRentalState = [_advancedRentalEntry] call bn_koth_fnc_menu_projectStoreVehicleState;
["Unowned mastery-qualified advanced vehicle projects RENT", (_advancedRentalState getOrDefault ["canRent", false]) && {!(_advancedRentalState getOrDefault ["canPurchase", true])} && {(_advancedRentalState getOrDefault ["stateLabel", ""]) isEqualTo "AVAILABLE TO RENT"}] call _check;
missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", _savedProgressionLocal];
missionNamespace setVariable ["BN_KOTH_vehiclePersonalStateLocal", _savedVehiclePersonalLocal];

private _vehicleProjectionSource = preprocessFileLineNumbers "functions\ui\menu\fn_menu_projectStoreVehicleState.sqf";
private _storeRefreshSource = preprocessFileLineNumbers "functions\ui\menu\fn_menu_refreshStore.sqf";
["Vehicle cooldown presentation derives live remaining time from the authoritative expiry", (_vehicleProjectionSource find 'cooldownUntil') >= 0 && {(_vehicleProjectionSource find 'serverTime') >= 0}] call _check;
["Open vehicle Store cooldown refresh is bounded and lifecycle-aware", (_storeRefreshSource find 'BN_KOTH_menuVehicleCooldownRefreshScript') >= 0 && {(_storeRefreshSource find 'uiSleep 1') >= 0} && {(_storeRefreshSource find 'BN_KOTH_menuActivePage') >= 0} && {(_storeRefreshSource find '_expiresAt <= serverTime') >= 0}] call _check;

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

private _detailEntry = {
    params ["_metadata", "_code", ["_extra", createHashMap, [createHashMap]], ["_kills", 0, [0]]];
    private _entitlement = createHashMapFromArray [["code", _code], ["accessType", "NONE"]];
    {_entitlement set [_x, _extra get _x]} forEach (keys _extra);
    createHashMapFromArray [["metadata", _metadata], ["entitlement", _entitlement], ["masteryKills", _kills]]
};

private _availableDetail = [[_metadata, "REQUIRES_ACQUISITION"] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Available weapon detail is concise", (_availableDetail get "detailStatus") isEqualTo "AVAILABLE TO ACQUIRE" && {(_availableDetail get "detailLines") isEqualTo []}] call _check;

private _levelMetadata = createHashMapFromArray [["minLevel", 35], ["allowedSides", ["WEST"]], ["masteryKillsRequired", 0], ["crossSideAllowed", false], ["purchasePrice", 400], ["rentalPrice", 100]];
private _levelDetail = [[_levelMetadata, "LOCKED_LEVEL", createHashMapFromArray [["playerLevel", 20]]] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Level-locked detail gives requirement and current level", (_levelDetail get "detailStatus") isEqualTo "LEVEL 35 REQUIRED" && {(_levelDetail get "detailLines") isEqualTo ["You are Level 20"]}] call _check;

private _eastMasteryMetadata = createHashMapFromArray [["minLevel", 1], ["allowedSides", ["EAST"]], ["masteryKillsRequired", 60], ["crossSideAllowed", true], ["purchasePrice", 400], ["rentalPrice", 100]];
private _eastMasteryDetail = [[_eastMasteryMetadata, "LOCKED_MASTERY", createHashMapFromArray [["crossSide", true]], 0] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Other-team detail names EAST and mastery progress", (_eastMasteryDetail get "detailStatus") isEqualTo "LOCKED — USE ON EAST FIRST" && {(_eastMasteryDetail get "detailLines") isEqualTo ["Get 60 kills with this weapon on EAST", "0 / 60 kills"]}] call _check;

private _westMasteryMetadata = createHashMapFromArray [["minLevel", 1], ["allowedSides", ["WEST"]], ["masteryKillsRequired", 30], ["crossSideAllowed", true], ["purchasePrice", 400], ["rentalPrice", 100]];
private _westMasteryDetail = [[_westMasteryMetadata, "LOCKED_MASTERY", createHashMapFromArray [["crossSide", true]], 12] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Partial other-team detail names WEST and current progress", (_westMasteryDetail get "detailStatus") isEqualTo "LOCKED — USE ON WEST FIRST" && {(_westMasteryDetail get "detailLines") isEqualTo ["Get 30 kills with this weapon on WEST", "12 / 30 kills"]}] call _check;

private _multipleMetadata = createHashMapFromArray [["minLevel", 20], ["allowedSides", ["EAST"]], ["masteryKillsRequired", 60], ["crossSideAllowed", true], ["purchasePrice", 400], ["rentalPrice", 100]];
private _multipleDetail = [[_multipleMetadata, "LOCKED_LEVEL", createHashMapFromArray [["crossSide", true], ["playerLevel", 14]], 0] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Multiple-lock detail presents level before EAST kills", (_multipleDetail get "detailStatus") isEqualTo "LOCKED" && {(_multipleDetail get "detailLines") isEqualTo ["Reach Level 20", "Then get 60 kills with this weapon on EAST", "0 / 60 kills"]}] call _check;

private _ownedDetail = [[_metadata, "ENTITLED", createHashMapFromArray [["accessType", "OWNED"]]] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Owned weapon detail is concise", (_ownedDetail get "detailStatus") isEqualTo "OWNED" && {(_ownedDetail get "detailLines") isEqualTo []}] call _check;

private _rentedDetail = [[_metadata, "ENTITLED", createHashMapFromArray [["accessType", "RENTED"]]] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Rented weapon detail states its session lifetime", (_rentedDetail get "detailStatus") isEqualTo "RENTED FOR THIS SERVER SESSION" && {(_rentedDetail get "detailLines") isEqualTo []}] call _check;

private _restrictedDetail = [[_restrictedMetadata, "CROSS_SIDE_NOT_ALLOWED", createHashMapFromArray [["crossSide", true]]] call _detailEntry, 1000] call bn_koth_fnc_menu_projectStoreWeaponState;
["Permanent side restriction names the available team", (_restrictedDetail get "detailStatus") isEqualTo "AVAILABLE ON WEST ONLY" && {(_restrictedDetail get "detailLines") isEqualTo []}] call _check;

diag_log format ["[BN_KOTH_TEST] Store V1: %1 failure(s): %2", count _failures, _failures];
_failures

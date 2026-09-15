/*
    File: fn_getProgressionMetadata.sqf
    Author: Legend
    Description: Resolves explicit vehicle variant relationships and returns
        normalized human-authored KOTH family/loadout progression metadata. This
        function reads configuration only and grants no entitlement.
    Execution: Any
    Parameters:
        0: Vehicle classname <STRING>
    Returns:
        Vehicle metadata result <HASHMAP>
    Public: No
*/

params [["_vehicleClass", "", [""]]];

private _requestedClass = toLower _vehicleClass;
private _finishFailure = {
    params ["_code", ["_canonicalClass", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["requestedClass", _requestedClass],
        ["canonicalClass", _canonicalClass],
        ["configured", false]
    ]
};

if (_requestedClass isEqualTo "") exitWith {
    ["ERR_VEHICLE_CLASS_EMPTY"] call _finishFailure
};

if !(isClass (configFile >> "CfgVehicles" >> _requestedClass)) exitWith {
    ["ERR_UNKNOWN_VEHICLE"] call _finishFailure
};

private _vehiclesCfg = missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles";
if !(isClass _vehiclesCfg) exitWith {
    ["ERR_VEHICLE_METADATA_MISSING"] call _finishFailure
};

private _requestedCfg = _vehiclesCfg >> _requestedClass;
if !(isClass _requestedCfg) exitWith {
    ["ERR_VEHICLE_UNCONFIGURED"] call _finishFailure
};

private _canonicalClass = _requestedClass;
private _visited = [];
private _resolutionCode = "OK";

while {_resolutionCode isEqualTo "OK"} do {
    if (_canonicalClass in _visited) exitWith {
        _resolutionCode = "ERR_VEHICLE_VARIANT_CYCLE";
    };
    _visited pushBack _canonicalClass;

    private _currentCfg = _vehiclesCfg >> _canonicalClass;
    if !(isClass _currentCfg) exitWith {
        _resolutionCode = "ERR_VEHICLE_VARIANT_TARGET";
    };

    private _variantOf = toLower (getText (_currentCfg >> "variantOf"));
    if (_variantOf isEqualTo "") exitWith {};
    if !(isClass (_vehiclesCfg >> _variantOf)) exitWith {
        _canonicalClass = _variantOf;
        _resolutionCode = "ERR_VEHICLE_VARIANT_TARGET";
    };

    _canonicalClass = _variantOf;
};

if !(_resolutionCode isEqualTo "OK") exitWith {
    [_resolutionCode, _canonicalClass] call _finishFailure
};

private _metadataCfg = _vehiclesCfg >> _canonicalClass;
private _validCategories = ["GROUND", "SEA", "ROTARY", "FIXED_WING"];
private _validCapabilities = ["TRANSPORT", "LOGISTICS", "COMMAND", "COMBAT", "CAS"];
if (
    !(isArray (_metadataCfg >> "allowedSides")) ||
    {!(isText (_metadataCfg >> "familyId"))} ||
    {!(isText (_metadataCfg >> "loadoutId"))} ||
    {!(isNumber (_metadataCfg >> "baseLoadout"))} ||
    {!(isText (_metadataCfg >> "requiredLoadout"))} ||
    {!(isArray (_metadataCfg >> "requiredMastery"))} ||
    {!(isNumber (_metadataCfg >> "minLevel"))} ||
    {!(isNumber (_metadataCfg >> "purchasePrice"))} ||
    {!(isNumber (_metadataCfg >> "replacementPrice"))} ||
    {!(isNumber (_metadataCfg >> "rentalPrice"))} ||
    {!(isNumber (_metadataCfg >> "rentable"))} ||
    {!(isNumber (_metadataCfg >> "replacementCooldownSeconds"))} ||
    {!(isText (_metadataCfg >> "storeCategory"))} ||
    {!(isArray (_metadataCfg >> "capabilities"))} ||
    {!(isNumber (_metadataCfg >> "crossSideEligible"))} ||
    {!(isText (_metadataCfg >> "visualProfile"))}
) exitWith {
    ["ERR_VEHICLE_POLICY", _canonicalClass] call _finishFailure
};

private _allowedSides = [];
if (isArray (_metadataCfg >> "allowedSides")) then {
    _allowedSides = (getArray (_metadataCfg >> "allowedSides")) apply {toUpper _x};
};

private _minLevel = getNumber (_metadataCfg >> "minLevel");
private _purchasePrice = getNumber (_metadataCfg >> "purchasePrice");
private _replacementPrice = getNumber (_metadataCfg >> "replacementPrice");
private _rentalPrice = getNumber (_metadataCfg >> "rentalPrice");
private _storeCategory = toUpper (getText (_metadataCfg >> "storeCategory"));
private _familyId = toUpper (getText (_metadataCfg >> "familyId"));
private _loadoutId = toUpper (getText (_metadataCfg >> "loadoutId"));
private _requiredLoadout = toUpper (getText (_metadataCfg >> "requiredLoadout"));
private _capabilities = (getArray (_metadataCfg >> "capabilities")) apply {toUpper _x};
private _requiredMasteryRaw = getArray (_metadataCfg >> "requiredMastery");
private _requiredMastery = createHashMap;
private _validMasteryCounters = ["infantryKills", "vehicleKills", "assists", "insertions", "passengersDelivered", "transportDistance", "operatorSeconds", "objectiveSupport", "masteryScore", "masteryTier"];
private _masteryValid = ((count _requiredMasteryRaw) mod 2) isEqualTo 0;
for "_index" from 0 to ((count _requiredMasteryRaw) - 1) step 2 do {
    private _counter = _requiredMasteryRaw select _index;
    private _amount = _requiredMasteryRaw select (_index + 1);
    if !(_counter in _validMasteryCounters && {_amount isEqualType 0} && {finite _amount} && {_amount > 0} && {isNil {_requiredMastery get _counter}}) then {
        _masteryValid = false;
    } else {
        _requiredMastery set [_counter, floor _amount];
    };
};
if (
    (count _allowedSides) isEqualTo 0 ||
    {_allowedSides findIf {!(_x in ["WEST", "EAST"])} >= 0} ||
    {!(finite _minLevel) || {_minLevel < 0}} ||
    {!(finite _purchasePrice) || {_purchasePrice < 0}} ||
    {!(finite _replacementPrice) || {_replacementPrice < 0}} ||
    {!(finite _rentalPrice) || {_rentalPrice < 0}} ||
    {!(_storeCategory in _validCategories)} ||
    {_familyId isEqualTo ""} ||
    {_loadoutId isEqualTo ""} ||
    {!_masteryValid} ||
    {(count _capabilities) isEqualTo 0} ||
    {_capabilities findIf {!(_x in _validCapabilities)} >= 0} ||
    {(count _capabilities) isNotEqualTo (count (_capabilities arrayIntersect _capabilities))}
) exitWith {
    ["ERR_VEHICLE_POLICY", _canonicalClass] call _finishFailure
};

private _requiredPerks = [];
if (isArray (_metadataCfg >> "requiredPerks")) then {
    _requiredPerks = getArray (_metadataCfg >> "requiredPerks");
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["requestedClass", _requestedClass],
    ["canonicalClass", _canonicalClass],
    ["familyId", _familyId],
    ["loadoutId", _loadoutId],
    ["baseLoadout", (getNumber (_metadataCfg >> "baseLoadout")) > 0],
    ["requiredLoadout", _requiredLoadout],
    ["requiredMastery", _requiredMastery],
    ["configured", true],
    ["allowedSides", _allowedSides],
    ["minLevel", _minLevel],
    ["purchasePrice", _purchasePrice],
    ["replacementPrice", _replacementPrice],
    ["rentalPrice", _rentalPrice],
    ["rentable", (getNumber (_metadataCfg >> "rentable")) > 0],
    ["replacementCooldownSeconds", (getNumber (_metadataCfg >> "replacementCooldownSeconds")) max 0],
    ["storeCategory", _storeCategory],
    ["capabilities", _capabilities],
    ["appearanceSide", toUpper (getText (_metadataCfg >> "appearanceSide"))],
    ["crossSideEligible", (getNumber (_metadataCfg >> "crossSideEligible")) > 0],
    ["capturedRequirement", toUpper (getText (_metadataCfg >> "capturedRequirement"))],
    ["visualProfile", getText (_metadataCfg >> "visualProfile")],
    ["requiredPerks", _requiredPerks],
    ["resolutionPath", +_visited]
]

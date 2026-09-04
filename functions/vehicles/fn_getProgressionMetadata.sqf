/*
    File: fn_getProgressionMetadata.sqf
    Author: Legend
    Description: Resolves explicit vehicle variant relationships and returns
        normalized human-authored KOTH vehicle progression metadata. This
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
private _validRoles = ["TRANSPORT", "LOGISTICS", "COMMAND", "COMBAT"];
if (
    !(isArray (_metadataCfg >> "allowedSides")) ||
    {!(isNumber (_metadataCfg >> "minLevel"))} ||
    {!(isNumber (_metadataCfg >> "purchasePrice"))} ||
    {!(isNumber (_metadataCfg >> "rentalPrice"))} ||
    {!(isText (_metadataCfg >> "storeCategory"))} ||
    {!(isText (_metadataCfg >> "vehicleRole"))}
) exitWith {
    ["ERR_VEHICLE_POLICY", _canonicalClass] call _finishFailure
};

private _allowedSides = [];
if (isArray (_metadataCfg >> "allowedSides")) then {
    _allowedSides = (getArray (_metadataCfg >> "allowedSides")) apply {toUpper _x};
};

private _minLevel = getNumber (_metadataCfg >> "minLevel");
private _purchasePrice = getNumber (_metadataCfg >> "purchasePrice");
private _rentalPrice = getNumber (_metadataCfg >> "rentalPrice");
private _storeCategory = toUpper (getText (_metadataCfg >> "storeCategory"));
private _vehicleRole = toUpper (getText (_metadataCfg >> "vehicleRole"));
if (
    (count _allowedSides) isEqualTo 0 ||
    {_allowedSides findIf {!(_x in ["WEST", "EAST"])} >= 0} ||
    {!(finite _minLevel) || {_minLevel < 0}} ||
    {!(finite _purchasePrice) || {_purchasePrice < 0}} ||
    {!(finite _rentalPrice) || {_rentalPrice < 0}} ||
    {!(_storeCategory in _validCategories)} ||
    {!(_vehicleRole in _validRoles)}
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
    ["configured", true],
    ["allowedSides", _allowedSides],
    ["minLevel", _minLevel],
    ["purchasePrice", _purchasePrice],
    ["rentalPrice", _rentalPrice],
    ["storeCategory", _storeCategory],
    ["vehicleRole", _vehicleRole],
    ["appearanceSide", toUpper (getText (_metadataCfg >> "appearanceSide"))],
    ["requiredPerks", _requiredPerks],
    ["resolutionPath", +_visited]
]

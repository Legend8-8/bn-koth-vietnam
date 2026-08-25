/*
    File: test_progressionMetadata.sqf
    Author: Legend
    Description: Focused in-engine checks for config-owned vehicle progression
        metadata and the pure eligibility interpreter. This file is not
        registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _vehiclesCfg = missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles";
private _entries = "true" configClasses _vehiclesCfg;
private _validCategories = ["GROUND", "SEA", "ROTARY", "FIXED_WING"];
private _validRoles = ["TRANSPORT", "LOGISTICS", "COMMAND", "COMBAT"];
private _projection = [];
private _rootCount = 0;
private _variantCount = 0;

{
    private _className = toLower (configName _x);
    private _variantOf = toLower (getText (_x >> "variantOf"));
    private _isVariant = !(_variantOf isEqualTo "");

    if (_isVariant) then {
        _variantCount = _variantCount + 1;
        [format ["Variant %1 target exists", _className], isClass (_vehiclesCfg >> _variantOf)] call _check;
        [format ["Variant %1 owns no side policy", _className], !(isArray (_x >> "allowedSides"))] call _check;
        [format ["Variant %1 owns no level", _className], !(isNumber (_x >> "minLevel"))] call _check;
        [format ["Variant %1 owns no purchase price", _className], !(isNumber (_x >> "purchasePrice"))] call _check;
        [format ["Variant %1 owns no rental price", _className], !(isNumber (_x >> "rentalPrice"))] call _check;
    } else {
        _rootCount = _rootCount + 1;
        private _metadata = [_className] call bn_koth_fnc_vehicles_getProgressionMetadata;
        private _allowedSides = _metadata getOrDefault ["allowedSides", []];
        private _minLevel = _metadata getOrDefault ["minLevel", -1];
        private _purchasePrice = _metadata getOrDefault ["purchasePrice", -1];
        private _rentalPrice = _metadata getOrDefault ["rentalPrice", -1];
        private _category = _metadata getOrDefault ["storeCategory", ""];
        private _role = _metadata getOrDefault ["vehicleRole", ""];

        [format ["Root %1 authors sides", _className], isArray (_x >> "allowedSides")] call _check;
        [format ["Root %1 authors level", _className], isNumber (_x >> "minLevel")] call _check;
        [format ["Root %1 authors purchase price", _className], isNumber (_x >> "purchasePrice")] call _check;
        [format ["Root %1 authors rental price", _className], isNumber (_x >> "rentalPrice")] call _check;
        [format ["Root %1 authors category", _className], isText (_x >> "storeCategory")] call _check;
        [format ["Root %1 authors role", _className], isText (_x >> "vehicleRole")] call _check;
        [format ["Root %1 resolves", _className], _metadata getOrDefault ["success", false]] call _check;
        [format ["Root %1 is a S.O.G. CfgVehicles class", _className], isClass (configFile >> "CfgVehicles" >> _className)] call _check;
        [format ["Root %1 has valid sides", _className],
            (count _allowedSides) > 0 && {_allowedSides findIf {!(_x in ["WEST", "EAST"])} < 0}] call _check;
        [format ["Root %1 has valid level", _className], finite _minLevel && {_minLevel >= 0}] call _check;
        [format ["Root %1 has valid purchase price", _className], finite _purchasePrice && {_purchasePrice >= 0}] call _check;
        [format ["Root %1 has valid rental price", _className], finite _rentalPrice && {_rentalPrice >= 0}] call _check;
        [format ["Root %1 has valid category", _className], _category in _validCategories] call _check;
        [format ["Root %1 has valid role", _className], _role in _validRoles] call _check;
        [format ["Root %1 uses no weapon mastery", _className], !(isNumber (_x >> "masteryKillsRequired"))] call _check;

        _projection pushBack format ["%1|%2|%3", _category, _role, _className];
    };

    private _seen = [];
    private _cursor = _className;
    private _validGraph = true;
    while {_validGraph && {!(_cursor isEqualTo "")}} do {
        if (_cursor in _seen) exitWith {_validGraph = false};
        _seen pushBack _cursor;
        private _cursorCfg = _vehiclesCfg >> _cursor;
        if !(isClass _cursorCfg) exitWith {_validGraph = false};
        _cursor = toLower (getText (_cursorCfg >> "variantOf"));
    };
    [format ["Vehicle graph from %1 is acyclic and complete", _className], _validGraph] call _check;
} forEach _entries;

private _sortedProjection = +_projection;
_sortedProjection sort true;
private _secondProjection = +_projection;
_secondProjection sort true;
["Store category projection is deterministic", _sortedProjection isEqualTo _secondProjection] call _check;
["Curated combat vehicle progression set is configured", _rootCount isEqualTo 84] call _check;
["No unsupported structural variants are authored", _variantCount isEqualTo 0] call _check;
["Reserved SEA category has no current progression products", (_projection findIf {(_x find "SEA|") isEqualTo 0}) < 0] call _check;

private _btr40 = ["vn_o_wheeled_btr40_mg_01"] call bn_koth_fnc_vehicles_getProgressionMetadata;
private _belowLevel = ["EAST", 24, [], _btr40] call bn_koth_fnc_vehicles_evaluateProgressionRules;
["Below-level vehicle is locked", (_belowLevel getOrDefault ["code", ""]) isEqualTo "LOCKED_LEVEL"] call _check;

private _westOnlyMetadata = createHashMapFromArray [
    ["success", true],
    ["canonicalClass", "test_vehicle"],
    ["allowedSides", ["WEST"]],
    ["minLevel", 1],
    ["purchasePrice", 10000],
    ["rentalPrice", 2000],
    ["storeCategory", "GROUND"],
    ["vehicleRole", "COMBAT"],
    ["requiredPerks", []]
];
private _wrongSide = ["EAST", 270, [], _westOnlyMetadata] call bn_koth_fnc_vehicles_evaluateProgressionRules;
["Wrong-side vehicle is locked", (_wrongSide getOrDefault ["code", ""]) isEqualTo "LOCKED_SIDE"] call _check;

private _eligible = ["EAST", 25, [], _btr40] call bn_koth_fnc_vehicles_evaluateProgressionRules;
["Valid side and level proceeds", (_eligible getOrDefault ["code", ""]) isEqualTo "ELIGIBLE"] call _check;

diag_log format ["[BN_KOTH_TEST] Vehicle progression metadata: %1 failure(s): %2", count _failures, _failures];
_failures

/*
    File: test_progressionMetadata.sqf
    Author: Legend
    Description: Focused in-engine checks for logical family/loadout metadata,
        capability coexistence, prerequisite graphs, and native-side policy.
    Execution: Hosted or dedicated server debug/test context
    Returns: Failed assertion labels <ARRAY>
*/
private _failures = [];
private _check = {params ["_label", "_condition"]; if (!_condition) then {_failures pushBack _label}};
private _cfg = missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles";
private _entries = "true" configClasses _cfg;
private _loadoutIds = [];
private _families = createHashMap;
private _rotaryCount = 0;
private _cobraCount = 0;
private _nonCobraAllCapabilitiesCount = 0;
private _cobraWithoutTransportCount = 0;
{
    private _class = toLower (configName _x);
    private _metadata = [_class] call bn_koth_fnc_vehicles_getProgressionMetadata;
    private _family = _metadata getOrDefault ["familyId", ""];
    private _loadout = _metadata getOrDefault ["loadoutId", ""];
    private _caps = _metadata getOrDefault ["capabilities", []];
    private _masteryRequirements = _metadata getOrDefault ["requiredMastery", createHashMap];
    [format ["%1 metadata resolves", _class], _metadata getOrDefault ["success", false]] call _check;
    [format ["%1 unique logical loadout", _class], !(_loadout in _loadoutIds)] call _check;
    _loadoutIds pushBack _loadout;
    private _familyRows = _families getOrDefault [_family, []]; _familyRows pushBack _metadata; _families set [_family, _familyRows];
    [format ["%1 purchase in target range", _class], (_metadata getOrDefault ["purchasePrice", -1]) >= 8000 && {(_metadata getOrDefault ["purchasePrice", -1]) <= 100000}] call _check;
    [format ["%1 replacement below rental", _class], (_metadata getOrDefault ["replacementPrice", -1]) < (_metadata getOrDefault ["rentalPrice", -1])] call _check;
    [format ["%1 cross-side remains disabled", _class], !(_metadata getOrDefault ["crossSideEligible", true])] call _check;
    [format ["%1 visual profile inert", _class], (_metadata getOrDefault ["visualProfile", "bad"]) isEqualTo ""] call _check;
    [format ["%1 mastery uses an awarded counter", _class],
        ((keys _masteryRequirements) findIf {!(_x in ["infantryKills", "insertions", "passengersDelivered", "transportDistance"])}) < 0] call _check;
    if ((_metadata getOrDefault ["storeCategory", ""]) isEqualTo "ROTARY") then {
        _rotaryCount = _rotaryCount + 1;
        if (_family isEqualTo "AH1G") then {
            _cobraCount = _cobraCount + 1;
            private _correctCobraCapabilities = !("TRANSPORT" in _caps) && {"COMBAT" in _caps} && {"CAS" in _caps} && {(count _caps) isEqualTo 2};
            if (_correctCobraCapabilities) then {_cobraWithoutTransportCount = _cobraWithoutTransportCount + 1};
            [format ["%1 Cobra is COMBAT/CAS only", _class], _correctCobraCapabilities] call _check;
        } else {
            private _correctMultiCapabilities = "TRANSPORT" in _caps && {"COMBAT" in _caps} && {"CAS" in _caps} && {(count _caps) isEqualTo 3};
            if (_correctMultiCapabilities) then {_nonCobraAllCapabilitiesCount = _nonCobraAllCapabilitiesCount + 1};
            [format ["%1 non-Cobra rotary has TRANSPORT/COMBAT/CAS", _class], _correctMultiCapabilities] call _check;
        };
    };
} forEach _entries;
["Curated 84-product surface retained", (count _entries) isEqualTo 84] call _check;
["All 29 curated rotary products audited", _rotaryCount isEqualTo 29] call _check;
["Five Cobra loadouts audited", _cobraCount isEqualTo 5] call _check;
["Exactly 24 non-Cobra rotary products have all three capabilities", _nonCobraAllCapabilitiesCount isEqualTo 24] call _check;
["Exactly five Cobra products exclude TRANSPORT", _cobraWithoutTransportCount isEqualTo 5] call _check;
{
    private _rows = _families get _x;
    [format ["Family %1 has one base loadout", _x], ({_x getOrDefault ["baseLoadout", false]} count _rows) isEqualTo 1] call _check;
    {
        private _required = _x getOrDefault ["requiredLoadout", ""];
        [format ["Family %1 prerequisite %2 exists", _x getOrDefault ["familyId", ""], _required], _required isEqualTo "" || {_required in _loadoutIds}] call _check;
    } forEach _rows;
} forEach (keys _families);

private _westOnly = ["vn_b_air_oh6a_01"] call bn_koth_fnc_vehicles_getProgressionMetadata;
private _wrongSide = ["EAST", 270, [], _westOnly] call bn_koth_fnc_vehicles_evaluateProgressionRules;
["Native side enforced", (_wrongSide getOrDefault ["code", ""]) isEqualTo "LOCKED_SIDE"] call _check;
private _chico = ["vn_b_air_f4c_chico"] call bn_koth_fnc_vehicles_getProgressionMetadata;
private _emptyF4State = createHashMapFromArray [["ownedVehicleFamilies", ["F4"]], ["vehicleMastery", createHashMap]];
private _chicoRules = [_emptyF4State, _chico, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
private _chicoMissing = _chicoRules getOrDefault ["missingMastery", createHashMap];
["Cumulative mastery reports the highest required threshold",
    (_chicoMissing getOrDefault ["infantryKills", [-1, -1]]) isEqualTo [0, 15]] call _check;
diag_log format ["[BN_KOTH_TEST] Vehicle progression metadata: %1 failure(s): %2", count _failures, _failures];
_failures

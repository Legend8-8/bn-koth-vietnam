/*
    File: fn_evaluateLoadoutRules.sqf
    Author: Legend
    Description: Pure interpreter for durable family ownership and derived
        loadout mastery prerequisites. The caller selects whether ownership is
        required so SPAWN and RENT can share one prerequisite interpreter.
    Execution: Any
    Parameters:
        0: Player progression state <HASHMAP>
        1: Vehicle metadata <HASHMAP>
        2: Require durable family ownership <BOOL>
    Returns: Loadout entitlement result <HASHMAP>
    Public: No
*/

params [
    ["_progression", createHashMap, [createHashMap]],
    ["_metadata", createHashMap, [createHashMap]],
    ["_requireOwnership", true, [true]]
];

private _familyId = _metadata getOrDefault ["familyId", ""];
private _loadoutId = _metadata getOrDefault ["loadoutId", ""];
private _ownedFamilies = _progression getOrDefault ["ownedVehicleFamilies", []];
private _owned = _familyId in _ownedFamilies;
private _finish = {
    params ["_unlocked", "_code", "_message", ["_missing", createHashMap, [createHashMap]]];
    createHashMapFromArray [
        ["success", true], ["owned", _owned], ["unlocked", _unlocked],
        ["purchaseEligible", !_owned && {_metadata getOrDefault ["baseLoadout", false]}],
        ["code", _code], ["message", _message], ["familyId", _familyId],
        ["loadoutId", _loadoutId], ["missingMastery", _missing],
        ["requiredLoadout", _metadata getOrDefault ["requiredLoadout", ""]]
    ]
};

if !(_metadata getOrDefault ["success", false]) exitWith {
    createHashMapFromArray [["success", false], ["code", "INVALID_METADATA"], ["owned", false], ["unlocked", false]]
};
if (_requireOwnership && {!_owned}) exitWith {
    if (_metadata getOrDefault ["baseLoadout", false]) then {
        [false, "FAMILY_NOT_OWNED", "Purchase this vehicle family to receive its first base-loadout spawn."] call _finish
    } else {
        [false, "FAMILY_NOT_OWNED", "Purchase the base vehicle family before earning this loadout."] call _finish
    }
};

private _familyMastery = (_progression getOrDefault ["vehicleMastery", createHashMap]) getOrDefault [_familyId, createHashMap];
if !(_familyMastery isEqualType createHashMap) then {_familyMastery = createHashMap};
private _missing = createHashMap;
private _vehiclesCfg = missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles";
private _cursor = _metadata;
private _visited = [];
private _validGraph = true;

while {_validGraph} do {
    private _cursorId = _cursor getOrDefault ["loadoutId", ""];
    if (_cursorId isEqualTo "" || {_cursorId in _visited}) exitWith {_validGraph = false};
    _visited pushBack _cursorId;
    private _requirements = _cursor getOrDefault ["requiredMastery", createHashMap];
    {
        private _required = _requirements get _x;
        private _current = _familyMastery getOrDefault [_x, 0];
        if (_current < _required) then {
            private _existing = _missing getOrDefault [_x, [_current, 0]];
            if (_required > (_existing select 1)) then {
                _missing set [_x, [_current, _required]];
            };
        };
    } forEach (keys _requirements);

    private _requiredLoadout = _cursor getOrDefault ["requiredLoadout", ""];
    if (_requiredLoadout isEqualTo "") exitWith {};
    private _requiredClass = "";
    {
        if ((toUpper (getText (_x >> "loadoutId"))) isEqualTo _requiredLoadout) exitWith {
            _requiredClass = toLower (configName _x);
        };
    } forEach ("true" configClasses _vehiclesCfg);
    if (_requiredClass isEqualTo "") exitWith {_validGraph = false};
    _cursor = [_requiredClass] call bn_koth_fnc_vehicles_getProgressionMetadata;
    if !((_cursor getOrDefault ["familyId", ""]) isEqualTo _familyId) exitWith {_validGraph = false};
};

if (!_validGraph) exitWith {[false, "INVALID_LOADOUT_GRAPH", "Vehicle loadout prerequisite graph is invalid."] call _finish};
if ((count _missing) > 0) exitWith {[false, "LOADOUT_LOCKED", "Vehicle loadout mastery requirements are incomplete.", _missing] call _finish};
[true, "LOADOUT_UNLOCKED", "Vehicle loadout prerequisites are complete."] call _finish

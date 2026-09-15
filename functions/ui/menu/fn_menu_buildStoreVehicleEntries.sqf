/*
    File: fn_menu_buildStoreVehicleEntries.sqf
    Author: Legend
    Description: Builds deterministic Store discovery entries from the curated
        human-authored vehicle progression surface only.
    Execution: Client
    Parameters: None
    Returns: Store vehicle entries <ARRAY<HashMap>>
    Public: No
*/

private _entries = [];
private _vehiclesCfg = missionConfigFile >> "CfgBnKothVehicles" >> "Metadata" >> "Vehicles";
if !(isClass _vehiclesCfg) exitWith {_entries};

private _uid = if (!isNull player) then {getPlayerUID player} else {""};
private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_assignments isEqualType createHashMap) then {_assignments = createHashMap};
private _assignedSide = _assignments getOrDefault [_uid, sideUnknown];
private _sideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _level = (_progression getOrDefault ["level", 1]) max 1;
private _perks = _progression getOrDefault ["activePerks", _progression getOrDefault ["perks", []]];
if !(_perks isEqualType []) then {_perks = []};
private _personalState = missionNamespace getVariable ["BN_KOTH_vehiclePersonalStateLocal", createHashMap];
private _vehicleProgression = createHashMapFromArray [
    ["ownedVehicleFamilies", +(_personalState getOrDefault ["ownedVehicleFamilies", []])],
    ["vehicleFirstSpawnsUsed", +(_personalState getOrDefault ["vehicleFirstSpawnsUsed", []])],
    ["vehicleMastery", _personalState getOrDefault ["vehicleMastery", createHashMap]]
];

private _entryByLoadout = createHashMap;
private _familyDisplayNames = createHashMap;
{
    private _vehicleClass = toLower (configName _x);
    private _metadata = [_vehicleClass] call bn_koth_fnc_vehicles_getProgressionMetadata;
    if !(_metadata getOrDefault ["success", false]) then {continue};
    if !((_metadata getOrDefault ["canonicalClass", ""]) isEqualTo _vehicleClass) then {continue};

    private _storeCategory = _metadata getOrDefault ["storeCategory", ""];
    if !(_storeCategory in ["GROUND", "ROTARY", "FIXED_WING"]) then {continue};

    private _vehicleCfg = configFile >> "CfgVehicles" >> _vehicleClass;
    if !(isClass _vehicleCfg) then {continue};
    private _displayName = getText (_vehicleCfg >> "displayName");
    if (_displayName isEqualTo "") then {_displayName = toUpper _vehicleClass};
    private _editorPreview = getText (_vehicleCfg >> "editorPreview");
    private _picture = getText (_vehicleCfg >> "picture");
    private _previewAsset = if !(_editorPreview isEqualTo "") then {_editorPreview} else {_picture};
    private _previewSource = if !(_editorPreview isEqualTo "") then {
        "EDITOR_PREVIEW"
    } else {
        if !(_picture isEqualTo "") then {"PICTURE"} else {"NONE"}
    };
    private _eligibility = if (_sideToken isEqualTo "") then {
        createHashMapFromArray [
            ["success", false], ["eligible", false], ["code", "LOCKED_STATE"],
            ["message", "Player side state is not ready."], ["canonicalClass", _vehicleClass]
        ]
    } else {
        [_sideToken, _level, _perks, _metadata] call bn_koth_fnc_vehicles_evaluateProgressionRules
    };
    private _loadoutEligibility = [_vehicleProgression, _metadata, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules;
    private _rentalEligibility = [_vehicleProgression, _metadata, false] call bn_koth_fnc_vehicles_evaluateLoadoutRules;

    private _entry = createHashMapFromArray [
        ["vehicleClass", _vehicleClass],
        ["displayName", _displayName],
        ["picture", _previewAsset],
        ["previewSource", _previewSource],
        ["metadata", _metadata],
        ["eligibility", _eligibility],
        ["loadoutEligibility", _loadoutEligibility],
        ["rentalEligibility", _rentalEligibility],
        ["playerSide", _sideToken],
        ["playerLevel", _level],
        ["playerPerks", +_perks],
        ["storeCategory", _storeCategory],
        ["capabilities", +(_metadata getOrDefault ["capabilities", []])]
    ];
    _entries pushBack _entry;
    private _loadoutId = toUpper (_metadata getOrDefault ["loadoutId", ""]);
    private _familyId = toUpper (_metadata getOrDefault ["familyId", ""]);
    if !(_loadoutId isEqualTo "") then {_entryByLoadout set [_loadoutId, _entry]};
    if (_metadata getOrDefault ["baseLoadout", false]) then {_familyDisplayNames set [_familyId, _displayName]};
} forEach ("true" configClasses _vehiclesCfg);

{
    private _entry = _x;
    private _metadata = _entry getOrDefault ["metadata", createHashMap];
    private _familyId = toUpper (_metadata getOrDefault ["familyId", ""]);
    private _requiredLoadout = toUpper (_metadata getOrDefault ["requiredLoadout", ""]);
    private _familyDisplayName = _familyDisplayNames getOrDefault [_familyId, _entry getOrDefault ["displayName", "VEHICLE FAMILY"]];
    private _requiredEntry = _entryByLoadout getOrDefault [_requiredLoadout, createHashMap];
    private _requiredDisplayName = if (_requiredLoadout isEqualTo "") then {""} else {_requiredEntry getOrDefault ["displayName", "UNRESOLVED CONFIGURED LOADOUT"]};
    private _depth = 0;
    private _cursor = _requiredLoadout;
    private _visited = [];
    while {!(_cursor isEqualTo "") && {!(_cursor in _visited)}} do {
        _visited pushBack _cursor;
        _depth = _depth + 1;
        private _cursorEntry = _entryByLoadout getOrDefault [_cursor, createHashMap];
        private _cursorMetadata = _cursorEntry getOrDefault ["metadata", createHashMap];
        _cursor = toUpper (_cursorMetadata getOrDefault ["requiredLoadout", ""]);
    };
    _entry set ["familyDisplayName", _familyDisplayName];
    _entry set ["requiredLoadoutDisplayName", _requiredDisplayName];
    _entry set ["familyProgressionOrder", _depth];
} forEach _entries;

private _familyBaseLevels = createHashMap;
{
    private _metadata = _x getOrDefault ["metadata", createHashMap];
    if (_metadata getOrDefault ["baseLoadout", false]) then {
        _familyBaseLevels set [toUpper (_metadata getOrDefault ["familyId", ""]), (_metadata getOrDefault ["minLevel", 1]) max 1];
    };
} forEach _entries;
{
    private _metadata = _x getOrDefault ["metadata", createHashMap];
    _x set ["familyBaseMinLevel", _familyBaseLevels getOrDefault [toUpper (_metadata getOrDefault ["familyId", ""]), 999]];
} forEach _entries;

_entries = [_entries, [], {
    private _entry = _x;
    private _levelText = str (_entry getOrDefault ["familyBaseMinLevel", 999]);
    format [
        "%1|%2|%3|%4|%5|%6",
        _entry getOrDefault ["storeCategory", ""],
        ("000000" + _levelText) select [(count _levelText), 6],
        toLower (_entry getOrDefault ["familyDisplayName", ""]),
        1000 + (_entry getOrDefault ["familyProgressionOrder", 999]),
        toLower (_entry getOrDefault ["displayName", ""]),
        _entry getOrDefault ["vehicleClass", ""]
    ]
}, "ASCEND"] call BIS_fnc_sortBy;
_entries

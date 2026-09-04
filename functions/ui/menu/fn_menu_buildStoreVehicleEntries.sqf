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
private _perks = _progression getOrDefault ["perks", []];
if !(_perks isEqualType []) then {_perks = []};

private _sortable = [];
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

    private _entry = createHashMapFromArray [
        ["vehicleClass", _vehicleClass],
        ["displayName", _displayName],
        ["picture", _previewAsset],
        ["previewSource", _previewSource],
        ["metadata", _metadata],
        ["eligibility", _eligibility],
        ["storeCategory", _storeCategory],
        ["vehicleRole", _metadata getOrDefault ["vehicleRole", ""]]
    ];
    _sortable pushBack [format ["%1|%2", toLower _displayName, _vehicleClass], _entry];
} forEach ("true" configClasses _vehiclesCfg);

_sortable sort true;
{_entries pushBack (_x select 1)} forEach _sortable;
_entries

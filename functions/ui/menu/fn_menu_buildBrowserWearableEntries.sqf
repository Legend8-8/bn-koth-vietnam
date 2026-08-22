/*
    File: fn_menu_buildBrowserWearableEntries.sqf
    Author: Legend
    Description: Builds cached factual S.O.G. wearable browser entries and
        attaches human-authored entitlement metadata without deciding access.
    Execution: Client
    Parameters:
        0: Item slot (UNIFORM|VEST|BACKPACK|HEADGEAR|FACEWEAR|BINOCULAR) <STRING>
    Returns: Browser entries <ARRAY<HASHMAP>>
    Public: No
*/

params [["_slot", "UNIFORM", [""]]];
private _slotUpper = toUpper _slot;
private _entries = [];
if !(_slotUpper in ["UNIFORM", "VEST", "BACKPACK", "HEADGEAR", "FACEWEAR", "BINOCULAR"]) exitWith {_entries};

if (_slotUpper isEqualTo "BACKPACK") exitWith {
    _entries pushBack [0, "", "", createHashMapFromArray [
        ["itemClass", ""], ["displayName", "NONE"], ["picture", ""],
        ["metadata", createHashMapFromArray [["minLevel", 1], ["requiredPerks", []]]]
    ]];

    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
        if !(_class isKindOf ["Bag_Base", configFile >> "CfgVehicles"]) then {continue;};

        private _metadata = ["Wearables", _class] call bn_koth_fnc_loadouts_getItemMetadata;
        private _displayName = getText (_cfg >> "displayName");
        if (_displayName isEqualTo "") then {_displayName = toUpper _class};
        private _minLevel = _metadata getOrDefault ["minLevel", 1];
        _entries pushBack [_minLevel, toLower _displayName, _class, createHashMapFromArray [
            ["itemClass", _class], ["displayName", _displayName],
            ["picture", getText (_cfg >> "picture")], ["metadata", _metadata]
        ]];
    } forEach ("true" configClasses (configFile >> "CfgVehicles"));

    _entries sort true;
    _entries apply {_x select 3}
};

if (_slotUpper in ["HEADGEAR", "FACEWEAR", "BINOCULAR"]) then {
    _entries pushBack [0, "", "", createHashMapFromArray [
        ["itemClass", ""], ["displayName", "NONE"], ["picture", ""],
        ["metadata", createHashMapFromArray [["minLevel", 1], ["requiredPerks", []]]]
    ]];
};

if (_slotUpper isEqualTo "FACEWEAR") exitWith {
    {
        private _class = toLower (configName _x);
        if ((_class find "vn_") != 0 || {(getNumber (_x >> "scope")) < 2}) then {continue;};
        private _metadata = ["Wearables", _class] call bn_koth_fnc_loadouts_getItemMetadata;
        private _name = getText (_x >> "displayName"); if (_name isEqualTo "") then {_name = toUpper _class};
        _entries pushBack [_metadata getOrDefault ["minLevel",1],toLower _name,_class,createHashMapFromArray [["itemClass",_class],["displayName",_name],["picture",getText (_x >> "picture")],["metadata",_metadata]]];
    } forEach ("true" configClasses (configFile >> "CfgGlasses"));
    _entries sort true; _entries apply {_x select 3}
};

if (_slotUpper isEqualTo "BINOCULAR") exitWith {
    private _settings = missionConfigFile >> "CfgBnKothArsenalSettings";
    private _catalogueClass = getText (_settings >> "catalogueClass"); if (_catalogueClass isEqualTo "") then {_catalogueClass = "CfgBnKothArsenal"};
    private _source = missionConfigFile >> _catalogueClass >> "Equipment" >> "Compatibility" >> "SourceItems";
    {
        if !((toLower (getText (_x >> "itemType"))) isEqualTo "binocular") then {continue;};
        private _class = toLower (configName _x);
        private _cfg = configFile >> "CfgWeapons" >> _class;
        private _metadata = ["Wearables", _class] call bn_koth_fnc_loadouts_getItemMetadata;
        private _name = getText (_x >> "displayName"); if (_name isEqualTo "") then {_name = toUpper _class};
        _entries pushBack [_metadata getOrDefault ["minLevel",1],toLower _name,_class,createHashMapFromArray [["itemClass",_class],["displayName",_name],["picture",getText (_cfg >> "picture")],["metadata",_metadata]]];
    } forEach ("true" configClasses _source);
    _entries sort true; _entries apply {_x select 3}
};

{
    private _cfg = _x;
    private _class = toLower (configName _cfg);
    if ((_class find "vn_") != 0) then {continue;};
    if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
    private _itemInfo = _cfg >> "ItemInfo";
    if !(isClass _itemInfo) then {continue;};
    private _requiredType = switch (_slotUpper) do {case "UNIFORM": {801}; case "VEST": {701}; default {605};};
    if !((getNumber (_itemInfo >> "type")) isEqualTo _requiredType) then {continue;};

    private _metadata = ["Wearables", _class] call bn_koth_fnc_loadouts_getItemMetadata;
    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {_displayName = toUpper _class};
    private _sortName = toLower _displayName;
    private _minLevel = _metadata getOrDefault ["minLevel", 1];
    _entries pushBack [_minLevel, _sortName, _class, createHashMapFromArray [
        ["itemClass", _class], ["displayName", _displayName],
        ["picture", getText (_cfg >> "picture")], ["metadata", _metadata]
    ]];
} forEach ("true" configClasses (configFile >> "CfgWeapons"));

_entries sort true;
_entries apply {_x select 3}

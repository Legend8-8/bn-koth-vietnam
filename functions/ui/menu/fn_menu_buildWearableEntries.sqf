/*
    File: fn_menu_buildWearableEntries.sqf
    Author: Legend
    Description: Builds selector entries for wearable and binocular pages.
    Execution: Client
    Parameters:
        0: Selector mode <STRING> (UNIFORM|VEST|BACKPACK|HEADGEAR|FACEWEAR|BINOCULAR)
        1: Intended loadout snapshot <ARRAY>
        2: Compatibility config root <CONFIG>
    Returns:
        Selector entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_selectorMode", "UNIFORM", [""]],
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

private _entries = [];

private _resolveItemName = {
    params ["_className"];
    if (_className isEqualTo "") exitWith {"NONE"};

    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };
    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {toUpper _className} else {_displayName}
};

private _currentWeaponClass = toLower (switch (_selectorMode) do {
    case "UNIFORM": {
        private _slot = _intendedLoadout select 3;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "VEST": {
        private _slot = _intendedLoadout select 4;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "BACKPACK": {
        private _slot = _intendedLoadout select 5;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "HEADGEAR": {toLower (_intendedLoadout select 6)};
    case "FACEWEAR": {toLower (_intendedLoadout select 7)};
    default {
        private _slot = _intendedLoadout select 8;
        if (_slot isEqualType "") then {toLower _slot} else {""}
    };
});

private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";

if (_selectorMode isEqualTo "UNIFORM") exitWith {
    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
        private _itemInfo = _cfg >> "ItemInfo";
        if !(isClass _itemInfo) then {continue;};
        if !((getNumber (_itemInfo >> "type")) isEqualTo 801) then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["weaponClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses (configFile >> "CfgWeapons"));

    _entries sort true;
    _entries
};

if (_selectorMode isEqualTo "VEST") exitWith {
    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
        private _itemInfo = _cfg >> "ItemInfo";
        if !(isClass _itemInfo) then {continue;};
        if !((getNumber (_itemInfo >> "type")) isEqualTo 701) then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["weaponClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses (configFile >> "CfgWeapons"));

    _entries sort true;
    _entries
};

if (_selectorMode isEqualTo "BACKPACK") exitWith {
    _entries pushBack (createHashMapFromArray [
        ["displayName", "NONE / NO BACKPACK"],
        ["weaponClass", ""],
        ["available", true],
        ["equipped", _currentWeaponClass isEqualTo ""]
    ]);

    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
        if !(_class isKindOf ["Bag_Base", configFile >> "CfgVehicles"]) then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["weaponClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses (configFile >> "CfgVehicles"));

    _entries
};

if (_selectorMode isEqualTo "HEADGEAR") exitWith {
    _entries pushBack (createHashMapFromArray [
        ["displayName", "NONE / NO HEADGEAR"],
        ["weaponClass", ""],
        ["available", true],
        ["equipped", _currentWeaponClass isEqualTo ""]
    ]);

    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
        private _itemInfo = _cfg >> "ItemInfo";
        if !(isClass _itemInfo) then {continue;};
        if !((getNumber (_itemInfo >> "type")) isEqualTo 605) then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["weaponClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses (configFile >> "CfgWeapons"));

    _entries
};

if (_selectorMode isEqualTo "FACEWEAR") exitWith {
    _entries pushBack (createHashMapFromArray [
        ["displayName", "NONE / NO FACEWEAR"],
        ["weaponClass", ""],
        ["available", true],
        ["equipped", _currentWeaponClass isEqualTo ""]
    ]);

    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        if ((_class find "vn_") != 0) then {continue;};
        if ((getNumber (_cfg >> "scope")) < 2) then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["weaponClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses (configFile >> "CfgGlasses"));

    _entries
};

_entries pushBack (createHashMapFromArray [
    ["displayName", "NONE / NO BINOCULAR"],
    ["binocularClass", ""],
    ["available", true],
    ["equipped", _currentWeaponClass isEqualTo ""]
]);

if (isClass _sourceItemsCfg) then {
    {
        private _cfg = _x;
        private _class = toLower (configName _cfg);
        private _itemType = toLower (getText (_cfg >> "itemType"));
        if !(_itemType isEqualTo "binocular") then {continue;};

        private _name = getText (_cfg >> "displayName");
        if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

        _entries pushBack (createHashMapFromArray [
            ["displayName", _name],
            ["binocularClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo _currentWeaponClass]
        ]);
    } forEach ("true" configClasses _sourceItemsCfg);
};

_entries

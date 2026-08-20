/*
    File: fn_menu_buildCargoEntries.sqf
    Author: Legend
    Description: Builds cargo quantity candidates. Current-weapon ammunition is
        shown first, then items already present in the selected container, then
        remaining supported cargo choices.
    Execution: Client
    Parameters:
        0: Intended loadout snapshot <ARRAY>
        1: Compatibility config root <CONFIG>
    Returns:
        Selector entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

private _entries = [];
if !(isClass _compatibilityCfg) exitWith {_entries};

private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";

private _resolveItemName = {
    params ["_className"];
    if (_className isEqualTo "") exitWith {"NONE"};
    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {_cfg = configFile >> "CfgVehicles" >> _className;};
    if !(isClass _cfg) then {_cfg = configFile >> "CfgGlasses" >> _className;};
    if !(isClass _cfg) then {_cfg = configFile >> "CfgMagazines" >> _className;};
    if !(isClass _cfg) exitWith {toUpper _className};
    private _name = getText (_cfg >> "displayName");
    if (_name isEqualTo "") then {toUpper _className} else {_name}
};

private _containerFilter = toLower (uiNamespace getVariable ["BN_KOTH_menuCargoContainerFilter", ""]);
private _containers = [];

{
    _x params ["_name", "_index"];
    if !(_containerFilter isEqualTo "") then {
        if !(_name isEqualTo _containerFilter) then {continue;};
    };
    if ((count _intendedLoadout) <= _index) then {continue;};
    private _slot = _intendedLoadout select _index;
    if ((_slot isEqualType []) && {(count _slot) >= 2}) then {
        private _containerClass = toLower (_slot select 0);
        if !(_containerClass isEqualTo "") then {_containers pushBack _x;};
    };
} forEach [["uniform", 3], ["vest", 4], ["backpack", 5]];

if ((count _containers) <= 0) exitWith {_entries};

private _initialContainer = uiNamespace getVariable ["BN_KOTH_menuCargoInitialContainer", ""];
private _initialInKit = uiNamespace getVariable ["BN_KOTH_menuCargoInitialInKit", createHashMap];

if (
    !(_initialInKit isEqualType createHashMap) ||
    {!(_initialContainer isEqualTo _containerFilter)}
) then {
    _initialInKit = createHashMap;

    {
        _x params ["_containerName", "_index"];
        private _slot = _intendedLoadout select _index;
        private _cargo = _slot select 1;
        if !(_cargo isEqualType []) then {_cargo = [];};

        {
            if ((_x isEqualType []) && {(count _x) >= 2}) then {
                private _className = toLower (_x select 0);
                private _count = _x select 1;
                if (
                    (_className isEqualType "") &&
                    {!(_className isEqualTo "")} &&
                    {_count isEqualType 0} &&
                    {_count > 0}
                ) then {
                    _initialInKit set [_className, true];
                };
            };
        } forEach _cargo;
    } forEach _containers;

    uiNamespace setVariable ["BN_KOTH_menuCargoInitialContainer", _containerFilter];
    uiNamespace setVariable ["BN_KOTH_menuCargoInitialInKit", _initialInKit];
};

private _currentWeaponAmmo = [];
if (isClass _weaponMagazinesCfg) then {
    {
        if ((count _intendedLoadout) <= _x) then {continue;};
        private _slot = _intendedLoadout select _x;
        if !((_slot isEqualType []) && {(count _slot) >= 1}) then {continue;};
        private _weaponClass = toLower (_slot select 0);
        if (_weaponClass isEqualTo "") then {continue;};
        private _magCfg = _weaponMagazinesCfg >> _weaponClass;
        if (isClass _magCfg) then {
            {_currentWeaponAmmo pushBackUnique (toLower _x);} forEach (getArray (_magCfg >> "values"));
        };
    } forEach [0, 1, 2];
};

private _candidates = +_currentWeaponAmmo;

// Anything already in the selected container stays visible and ranks near the top.
{
    _x params ["_containerName", "_index"];
    private _slot = _intendedLoadout select _index;
    private _cargo = _slot select 1;
    if !(_cargo isEqualType []) then {_cargo = [];};
    {
        if ((_x isEqualType []) && {(count _x) >= 2}) then {
            private _className = toLower (_x select 0);
            private _count = _x select 1;
            if ((_className isEqualType "") && {!(_className isEqualTo "")} && {_count isEqualType 0} && {_count > 0}) then {
                _candidates pushBackUnique _className;
            };
        };
    } forEach _cargo;
} forEach _containers;

if (isClass _sourceMagazinesCfg) then {
    {
        private _class = toLower (configName _x);
        private _category = toLower (getText (_x >> "category"));
        if (
            ((_category find "grenade") >= 0) ||
            ((_category find "smoke") >= 0) ||
            (_category isEqualTo "throwable_grenade") ||
            (_category isEqualTo "throwable_smoke") ||
            (_category isEqualTo "throwable_flare")
        ) then {_candidates pushBackUnique _class;};
    } forEach ("true" configClasses _sourceMagazinesCfg);
};

if (isClass _sourceItemsCfg) then {
    {
        private _class = toLower (configName _x);
        private _itemType = [_class] call BIS_fnc_itemType;
        if !((_itemType isEqualType []) && {(count _itemType) >= 2}) then {continue;};
        private _subType = toLower (_itemType select 1);
        if (
            (_subType isEqualTo "map") ||
            (_subType isEqualTo "gps") ||
            ((_subType find "uav") >= 0) ||
            (_subType isEqualTo "radio") ||
            (_subType isEqualTo "compass") ||
            (_subType isEqualTo "watch") ||
            ((_subType find "nvg") >= 0) ||
            ((_subType find "firstaid") >= 0) ||
            (_subType isEqualTo "medikit")
        ) then {_candidates pushBackUnique _class;};
    } forEach ("true" configClasses _sourceItemsCfg);
};

private _sortable = [];
{
    _x params ["_containerName", "_index"];
    private _slot = _intendedLoadout select _index;
    private _cargo = _slot select 1;
    if !(_cargo isEqualType []) then {_cargo = [];};

    private _counts = createHashMap;
    {
        if ((_x isEqualType []) && {(count _x) >= 2}) then {
            private _className = toLower (_x select 0);
            private _count = _x select 1;
            if ((_className isEqualType "") && {_count isEqualType 0}) then {_counts set [_className, _count max 0];};
        };
    } forEach _cargo;

    {
        private _className = _x;
        private _currentCount = _counts getOrDefault [_className, 0];
        private _displayName = [_className] call _resolveItemName;
        private _priority = 2;
        private _reason = "AVAILABLE";

        if (_className in _currentWeaponAmmo) then {
            _priority = 0;
            _reason = "CURRENT WEAPON AMMO";
        } else {
            if (_initialInKit getOrDefault [_className, false]) then {
                _priority = 1;
                _reason = "IN KIT";
            };
        };

        private _entry = createHashMapFromArray [
            ["displayName", format ["%1  x%2", _displayName, _currentCount]],
            ["container", _containerName],
            ["className", _className],
            ["currentCount", _currentCount],
            ["priority", _priority],
            ["priorityReason", _reason],
            ["available", true],
            ["equipped", _currentCount > 0]
        ];
        _sortable pushBack [format ["%1|%2", _priority, toLower _displayName], _entry];
    } forEach _candidates;
} forEach _containers;

_sortable sort true;
{_entries pushBack (_x select 1);} forEach _sortable;
_entries

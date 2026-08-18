/*
    File: fn_menu_buildCargoEntries.sqf
    Author: Legend
    Description: Builds cargo mutation candidates from canonical compatibility and source data.
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
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgMagazines" >> _className;
    };
    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {toUpper _className} else {_displayName}
};

private _containers = [];
{
    _x params ["_name", "_index"];
    private _slot = _intendedLoadout select _index;
    if ((_slot isEqualType []) && {(count _slot) >= 2}) then {
        private _containerClass = toLower (_slot select 0);
        if !(_containerClass isEqualTo "") then {
            _containers pushBack _x;
        };
    };
} forEach [["uniform", 3], ["vest", 4], ["backpack", 5]];

if ((count _containers) <= 0) exitWith {_entries};

{
    _x params ["_containerName", "_index"];
    private _slot = _intendedLoadout select _index;
    private _cargo = _slot select 1;
    if !(_cargo isEqualType []) then {
        _cargo = [];
    };

    {
        if ((_x isEqualType []) && {(count _x) >= 2}) then {
            private _entryClass = toLower (_x select 0);
            private _entryCount = _x select 1;
            if ((_entryClass isEqualType "") && {(_entryCount isEqualType 0)} && {_entryCount > 0}) then {
                _entries pushBack (createHashMapFromArray [
                    ["displayName", format ["REMOVE %1: %2 (x%3)", toUpper _containerName, [_entryClass] call _resolveItemName, _entryCount]],
                    ["container", _containerName],
                    ["className", _entryClass],
                    ["delta", -1],
                    ["available", true],
                    ["equipped", false]
                ]);
            };
        };
    } forEach _cargo;
} forEach _containers;

private _candidateClasses = [];

if (isClass _weaponMagazinesCfg) then {
    {
        private _slot = _intendedLoadout select _x;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {
            private _weaponClass = toLower (_slot select 0);
            private _magCfg = _weaponMagazinesCfg >> _weaponClass;
            if (isClass _magCfg) then {
                {
                    _candidateClasses pushBackUnique (toLower _x);
                } forEach (getArray (_magCfg >> "values"));
            };
        };
    } forEach [0, 1, 2];
};

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
        ) then {
            _candidateClasses pushBackUnique _class;
        };
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
            ((_subType find "nvg") >= 0)
        ) then {
            _candidateClasses pushBackUnique _class;
        };
    } forEach ("true" configClasses _sourceItemsCfg);
};

private _added = 0;
{
    private _className = _x;
    if (_added > 250) then {break;};

    {
        _x params ["_containerName", "_index"];

        _entries pushBack (createHashMapFromArray [
            ["displayName", format ["ADD %1: %2", toUpper _containerName, [_className] call _resolveItemName]],
            ["container", _containerName],
            ["className", _className],
            ["delta", 1],
            ["available", true],
            ["equipped", false]
        ]);
        _added = _added + 1;
    } forEach _containers;

} forEach _candidateClasses;

_entries

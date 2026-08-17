/*
    File: fn_menu_buildWeaponEntries.sqf
    Author: GitHub Copilot
    Description: Builds canonical weapon selector entries for primary, handgun, and launcher pages.
    Execution: Client
    Parameters:
        0: Selector mode <STRING> (PRIMARY|HANDGUN|LAUNCHER)
        1: Intended loadout snapshot <ARRAY>
        2: Compatibility config root <CONFIG>
    Returns:
        Selector entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_selectorMode", "PRIMARY", [""]],
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

private _entries = [];
if !(isClass _compatibilityCfg) exitWith {_entries};

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
if (!(isClass _sourceWeaponsCfg) || {!(isClass _weaponMagazinesCfg)}) exitWith {_entries};

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
    case "HANDGUN": {
        private _slot = _intendedLoadout select 2;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "LAUNCHER": {
        private _slot = _intendedLoadout select 1;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    default {
        private _slot = _intendedLoadout select 0;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
});

private _selectorWeaponTypes = switch (_selectorMode) do {
    case "HANDGUN": {["handgun"]};
    case "LAUNCHER": {["launcher"]};
    default {["rifle", "lmg", "smg", "shotgun", "marksman"]};
};
private _selectorEngineType = switch (_selectorMode) do {
    case "HANDGUN": {2};
    case "LAUNCHER": {4};
    default {1};
};

private _sortable = [];
{
    private _weaponCfg = _x;
    private _weaponClass = toLower (configName _weaponCfg);
    private _variantOf = toLower (getText (_weaponCfg >> "variantOf"));
    private _weaponType = toLower (getText (_weaponCfg >> "weaponType"));

    if !(_variantOf isEqualTo "") then {continue;};
    if !(_weaponType in _selectorWeaponTypes) then {continue;};

    private _engineCfg = configFile >> "CfgWeapons" >> _weaponClass;
    if !(isClass _engineCfg) then {continue;};
    if !((getNumber (_engineCfg >> "type")) isEqualTo _selectorEngineType) then {continue;};

    private _magCfg = _weaponMagazinesCfg >> _weaponClass;
    private _magazines = if (isClass _magCfg) then {(getArray (_magCfg >> "values")) apply {toLower _x}} else {[]};
    private _baseMagazine = toLower (getText (_weaponCfg >> "baseMagazine"));
    private _defaultMagazine = if (_baseMagazine in _magazines) then {_baseMagazine} else {if ((count _magazines) > 0) then {_magazines select 0} else {""}};

    private _available = !(_defaultMagazine isEqualTo "") && {isClass (configFile >> "CfgMagazines" >> _defaultMagazine)};
    private _displayName = getText (_weaponCfg >> "displayName");
    if (_displayName isEqualTo "") then {_displayName = [_weaponClass] call _resolveItemName;};

    private _defaultMagazineName = if (_available) then {[_defaultMagazine] call _resolveItemName} else {"NO COMPATIBLE DEFAULT MAGAZINE"};

    _sortable pushBack [toLower _displayName, createHashMapFromArray [
        ["displayName", _displayName],
        ["weaponClass", _weaponClass],
        ["defaultMagazine", _defaultMagazine],
        ["defaultMagazineName", _defaultMagazineName],
        ["available", _available],
        ["equipped", _weaponClass isEqualTo _currentWeaponClass]
    ]];
} forEach ("true" configClasses _sourceWeaponsCfg);

_sortable sort true;

if (_selectorMode isEqualTo "LAUNCHER") then {
    _entries pushBack (createHashMapFromArray [
        ["displayName", "NONE"],
        ["weaponClass", ""],
        ["defaultMagazine", ""],
        ["defaultMagazineName", "NO LAUNCHER"],
        ["available", true],
        ["equipped", _currentWeaponClass isEqualTo ""]
    ]);
};

{
    _entries pushBack (_x select 1);
} forEach _sortable;

_entries

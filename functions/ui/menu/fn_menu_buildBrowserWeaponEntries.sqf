/*
    File: fn_menu_buildBrowserWeaponEntries.sqf
    Author: Legend
    Description: Builds one static factual weapon-slot catalogue used by
        the item browser. Structural variants resolve to one canonical logical
        weapon; this function does not evaluate player entitlement.
    Execution: Client
    Parameters:
        0: Canonical compatibility config root <CONFIG>
        1: Weapon slot: PRIMARY or HANDGUN <STRING>
    Returns:
        Canonical browser weapon entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_compatibilityCfg", configNull, [configNull]],
    ["_weaponSlot", "PRIMARY", [""]]
];

private _entries = [];
if !(isClass _compatibilityCfg) exitWith {_entries};

_weaponSlot = toUpper _weaponSlot;
if !(_weaponSlot in ["PRIMARY", "HANDGUN"]) exitWith {_entries};

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
if !(isClass _sourceWeaponsCfg) exitWith {_entries};

private _seenCanonicalClasses = [];
private _sortable = [];
private _allowedWeaponTypes = if (_weaponSlot isEqualTo "HANDGUN") then {
    ["handgun"]
} else {
    ["rifle", "lmg", "smg", "shotgun", "marksman"]
};
private _cfgWeaponType = if (_weaponSlot isEqualTo "HANDGUN") then {2} else {1};

{
    private _weaponClass = toLower (configName _x);
    private _weaponType = toLower (getText (_x >> "weaponType"));
    if !(_weaponType in _allowedWeaponTypes) then {continue;};

    private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
    if !(_metadata getOrDefault ["success", false]) then {continue;};

    private _canonicalClass = _metadata getOrDefault ["canonicalClass", ""];
    if (_canonicalClass isEqualTo "" || {_canonicalClass in _seenCanonicalClasses}) then {continue;};

    private _weaponCfg = configFile >> "CfgWeapons" >> _canonicalClass;
    if !(isClass _weaponCfg) then {continue;};
    if !((getNumber (_weaponCfg >> "type")) isEqualTo _cfgWeaponType) then {continue;};

    private _displayName = getText (_weaponCfg >> "displayName");
    if (_displayName isEqualTo "") then {
        _displayName = toUpper _canonicalClass;
    };

    private _minLevel = (_metadata getOrDefault ["minLevel", 1]) max 1;
    private _levelText = str _minLevel;
    private _levelSortKey = ("000000" + _levelText) select [(count _levelText), 6];

    _seenCanonicalClasses pushBack _canonicalClass;
    private _entry = createHashMapFromArray [
        ["weaponClass", _canonicalClass],
        ["displayName", _displayName],
        ["picture", getText (_weaponCfg >> "picture")],
        ["metadata", _metadata]
    ];

    _sortable pushBack [
        format ["%1|%2|%3", _levelSortKey, toLower _displayName, _canonicalClass],
        _entry
    ];
} forEach ("true" configClasses _sourceWeaponsCfg);

_sortable sort true;
{_entries pushBack (_x select 1);} forEach _sortable;
_entries

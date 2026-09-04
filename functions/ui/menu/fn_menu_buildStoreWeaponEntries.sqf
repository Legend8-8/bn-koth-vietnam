/*
    File: fn_menu_buildStoreWeaponEntries.sqf
    Author: Legend
    Description: Builds the deterministic global Store weapon catalogue from
        canonical factual weapon roots and human-authored KOTH metadata.
    Execution: Client
    Parameters: None
    Returns: Store weapon entries <ARRAY<HashMap>>
    Public: No
*/

private _entries = [];
private _sourceWeaponsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility" >> "SourceWeapons";
if !(isClass _sourceWeaponsCfg) exitWith {_entries};

private _uid = if (!isNull player) then {getPlayerUID player} else {""};
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
_ownedWeapons = _ownedWeapons apply {toLower _x};
private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};
_rentedWeapons = _rentedWeapons apply {toLower _x};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};

private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_assignments isEqualType createHashMap) then {_assignments = createHashMap};
private _assignedSide = _assignments getOrDefault [_uid, sideUnknown];
private _sideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};

private _sortable = [];
{
    private _sourceCfg = _x;
    private _weaponClass = toLower (configName _sourceCfg);
    if !((toLower (getText (_sourceCfg >> "variantOf"))) isEqualTo "") then {continue};

    private _weaponType = toLower (getText (_sourceCfg >> "weaponType"));
    if !(_weaponType in ["handgun", "rifle", "lmg", "smg", "shotgun", "marksman", "launcher"]) then {continue};

    private _weaponCfg = configFile >> "CfgWeapons" >> _weaponClass;
    if !(isClass _weaponCfg) then {continue};
    if !((getNumber (_weaponCfg >> "type")) in [1, 2, 4]) then {continue};

    private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
    if !(_metadata getOrDefault ["success", false]) then {continue};
    if !((_metadata getOrDefault ["canonicalClass", ""]) isEqualTo _weaponClass) then {continue};

    private _displayName = getText (_weaponCfg >> "displayName");
    if (_displayName isEqualTo "") then {_displayName = getText (_sourceCfg >> "displayName")};
    if (_displayName isEqualTo "") then {_displayName = toUpper _weaponClass};

    private _storeCategory = switch (_weaponType) do {
        case "handgun": {"SIDEARMS"};
        case "launcher": {"LAUNCHERS"};
        default {"PRIMARY"};
    };
    private _arsenalSlot = switch (_weaponType) do {
        case "handgun": {"handgun"};
        case "launcher": {"launcher"};
        default {"primary"};
    };

    private _entitlement = if !(_sideToken isEqualTo "") then {
        [_uid, _sideToken, _progression, _metadata, _weaponClass] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules
    } else {
        createHashMapFromArray [
            ["success", false], ["entitled", false], ["code", "LOCKED_STATE"],
            ["message", "Player side state is not ready."], ["canonicalClass", _weaponClass]
        ]
    };

    private _entry = createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["displayName", _displayName],
        ["picture", getText (_weaponCfg >> "picture")],
        ["weaponType", _weaponType],
        ["storeCategory", _storeCategory],
        ["arsenalSlot", _arsenalSlot],
        ["metadata", _metadata],
        ["entitlement", _entitlement],
        ["owned", _weaponClass in _ownedWeapons],
        ["rented", _weaponClass in _rentedWeapons],
        ["masteryKills", (_weaponKills getOrDefault [_weaponClass, 0]) max 0]
    ];
    _sortable pushBack [format ["%1|%2", toLower _displayName, _weaponClass], _entry];
} forEach ("true" configClasses _sourceWeaponsCfg);

_sortable sort true;
{_entries pushBack (_x select 1)} forEach _sortable;
_entries

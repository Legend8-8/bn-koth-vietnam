/*
    File: fn_evaluateWeaponEntitlementRules.sqf
    Author: Legend
    Description: Pure weapon entitlement rule interpreter shared by authoritative
        server validation and client presentation. No mission state is read here.
    Execution: Any
    Parameters:
        0: Player UID <STRING>
        1: Side token <STRING>
        2: Progression state <HASHMAP>
        3: Weapon metadata <HASHMAP>
        4: Requested weapon classname <STRING>
    Returns:
        Entitlement result <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_sideToken", "", [""]],
    ["_progression", createHashMap, [createHashMap]],
    ["_metadata", createHashMap, [createHashMap]],
    ["_weaponClass", "", [""]]
];

private _requestedClass = toLower _weaponClass;
private _canonicalClass = _metadata getOrDefault ["canonicalClass", _requestedClass];
private _configured = _metadata getOrDefault ["configured", false];

private _finish = {
    params ["_success", "_entitled", "_code", "_message", ["_extra", createHashMap, [createHashMap]]];

    private _result = createHashMapFromArray [
        ["success", _success],
        ["entitled", _entitled],
        ["code", _code],
        ["message", _message],
        ["uid", _uid],
        ["requestedClass", _requestedClass],
        ["canonicalClass", _canonicalClass],
        ["sideToken", _sideToken],
        ["configured", _configured]
    ];

    {
        _result set [_x, _extra get _x];
    } forEach (keys _extra);

    _result
};

private _playerLevel = (_progression getOrDefault ["level", 1]) max 1;
private _minLevel = (_metadata getOrDefault ["minLevel", 1]) max 1;
private _allowedSides = _metadata getOrDefault ["allowedSides", []];
if !(_allowedSides isEqualType []) then {_allowedSides = []};
private _licenseKillsRequired = (_metadata getOrDefault ["licenseKills", 0]) max 0;
private _requiredPerks = _metadata getOrDefault ["requiredPerks", []];
if !(_requiredPerks isEqualType []) then {_requiredPerks = []};
private _purchasePrice = _metadata getOrDefault ["purchasePrice", -1];
private _rentalPrice = _metadata getOrDefault ["rentalPrice", -1];
private _acquisitionConfigured = (_purchasePrice >= 0) || {_rentalPrice >= 0};

private _sidePolicy = [
    _sideToken,
    _metadata,
    false
] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;

if !(_sidePolicy getOrDefault ["allowed", false]) exitWith {
    [false, false,
        _sidePolicy getOrDefault ["code", "LOCKED_SIDE"],
        _sidePolicy getOrDefault ["message", "Weapon is not available to this KOTH side."],
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["accessType", "NONE"]
        ]] call _finish
};

if (!_configured) exitWith {
    [true, true, "ENTITLED_UNCONTROLLED", "Weapon has no KOTH progression metadata.",
        createHashMapFromArray [["allowedSides", _allowedSides], ["accessType", "UNCONTROLLED"]]] call _finish
};

if (_playerLevel < _minLevel) exitWith {
    [false, false, "LOCKED_LEVEL", format ["Requires level %1.", _minLevel],
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["licenseKills", _licenseKillsRequired],
            ["accessType", "NONE"]
        ]] call _finish
};

private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};
private _playerPerks = _progression getOrDefault ["perks", []];
if !(_playerPerks isEqualType []) then {_playerPerks = []};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};

private _normalizedOwned = _ownedWeapons apply {toLower _x};
private _normalizedRented = _rentedWeapons apply {toLower _x};
private _normalizedPerks = _playerPerks apply {toLower _x};

private _isOwned = _canonicalClass in _normalizedOwned;
private _isRented = _canonicalClass in _normalizedRented;
private _kills = (_weaponKills getOrDefault [_canonicalClass, 0]) max 0;
private _licenseComplete = _kills >= _licenseKillsRequired;

private _missingPerks = [];
{
    private _perk = toLower _x;
    if !(_perk in _normalizedPerks) then {_missingPerks pushBack _x;};
} forEach _requiredPerks;

if ((count _missingPerks) > 0) exitWith {
    [false, false, "LOCKED_PERK", "Required perk entitlement is incomplete.",
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["weaponKills", _kills],
            ["licenseKills", _licenseKillsRequired],
            ["missingPerks", _missingPerks],
            ["accessType", "NONE"]
        ]] call _finish
};

if (!_acquisitionConfigured) exitWith {
    [true, true, "ENTITLED", "Weapon acquisition is not configured and does not gate entitlement.",
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["weaponKills", _kills],
            ["licenseKills", _licenseKillsRequired],
            ["licenseComplete", _licenseComplete],
            ["owned", _isOwned],
            ["rented", _isRented],
            ["canPurchase", false],
            ["canRent", false],
            ["accessType", "UNCONTROLLED"]
        ]] call _finish
};

if (_isOwned) exitWith {
    [true, true, "ENTITLED", "Permanent weapon entitlement is valid.",
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["weaponKills", _kills],
            ["licenseKills", _licenseKillsRequired],
            ["licenseComplete", _licenseComplete],
            ["owned", true],
            ["rented", _isRented],
            ["canPurchase", _purchasePrice >= 0],
            ["canRent", _rentalPrice >= 0],
            ["accessType", "OWNED"]
        ]] call _finish
};

if (_isRented) exitWith {
    [true, true, "ENTITLED", "Temporary weapon rental entitlement is valid.",
        createHashMapFromArray [
            ["allowedSides", _allowedSides],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["weaponKills", _kills],
            ["licenseKills", _licenseKillsRequired],
            ["licenseComplete", _licenseComplete],
            ["owned", false],
            ["rented", true],
            ["canPurchase", _purchasePrice >= 0],
            ["canRent", _rentalPrice >= 0],
            ["accessType", "RENTED"]
        ]] call _finish
};

[true, false, "REQUIRES_ACQUISITION",
    "Weapon is side- and level-eligible but requires ownership or rental.",
    createHashMapFromArray [
        ["allowedSides", _allowedSides],
        ["playerLevel", _playerLevel],
        ["minLevel", _minLevel],
        ["weaponKills", _kills],
        ["licenseKills", _licenseKillsRequired],
        ["licenseComplete", _licenseComplete],
        ["owned", false],
        ["rented", false],
        ["canPurchase", _purchasePrice >= 0],
        ["canRent", _rentalPrice >= 0],
        ["accessType", "NONE"]
    ]] call _finish

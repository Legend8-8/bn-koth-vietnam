/*
    File: fn_getWeaponMetadata.sqf
    Author: Legend
    Description: Resolves a requested weapon to its canonical base weapon and
        returns normalized human-authored KOTH progression metadata.
        This function reads configuration only. It does not decide player
        entitlement and does not read or mutate progression state.
    Execution: Any
    Parameters:
        0: Weapon classname <STRING>
    Returns:
        Weapon metadata <HASHMAP>
    Public: No
*/

params [["_weaponClass", "", [""]]];

private _requestedClass = toLower _weaponClass;
if (_requestedClass isEqualTo "") exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_WEAPON_CLASS_EMPTY"],
        ["requestedClass", ""],
        ["canonicalClass", ""],
        ["configured", false]
    ]
};

private _arsenalCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment";
private _compatibilityCfg = _arsenalCfg >> "Compatibility";
private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";

if !(isClass _sourceWeaponsCfg) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_COMPATIBILITY_MISSING"],
        ["requestedClass", _requestedClass],
        ["canonicalClass", ""],
        ["configured", false]
    ]
};

if !(isClass (_sourceWeaponsCfg >> _requestedClass)) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_UNKNOWN_WEAPON"],
        ["requestedClass", _requestedClass],
        ["canonicalClass", ""],
        ["configured", false]
    ]
};

private _canonicalClass = _requestedClass;
private _safety = 0;

while {_safety < 16} do {
    private _weaponCfg = _sourceWeaponsCfg >> _canonicalClass;
    if !(isClass _weaponCfg) exitWith {};

    private _variantOf = toLower (getText (_weaponCfg >> "variantOf"));
    if (_variantOf isEqualTo "") exitWith {};

    _canonicalClass = _variantOf;
    _safety = _safety + 1;
};

private _metadataCfg = _arsenalCfg >> "Metadata" >> "Weapons" >> _canonicalClass;
private _configured = isClass _metadataCfg;

private _allowedSides = [];
private _minLevel = 1;
private _licenseKills = 0;
private _purchasePrice = -1;
private _rentalPrice = -1;
private _requiredPerks = [];

if (_configured) then {
    if (isArray (_metadataCfg >> "allowedSides")) then {
        _allowedSides = (getArray (_metadataCfg >> "allowedSides")) apply {toUpper _x};
    };

    if (isNumber (_metadataCfg >> "minLevel")) then {
        _minLevel = (getNumber (_metadataCfg >> "minLevel")) max 1;
    };

    if (isNumber (_metadataCfg >> "licenseKills")) then {
        _licenseKills = (getNumber (_metadataCfg >> "licenseKills")) max 0;
    };

    if (isNumber (_metadataCfg >> "purchasePrice")) then {
        _purchasePrice = getNumber (_metadataCfg >> "purchasePrice");
    };

    if (isNumber (_metadataCfg >> "rentalPrice")) then {
        _rentalPrice = getNumber (_metadataCfg >> "rentalPrice");
    };

    if (isArray (_metadataCfg >> "requiredPerks")) then {
        _requiredPerks = getArray (_metadataCfg >> "requiredPerks");
    };
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["requestedClass", _requestedClass],
    ["canonicalClass", _canonicalClass],
    ["configured", _configured],
    ["allowedSides", _allowedSides],
    ["minLevel", _minLevel],
    ["licenseKills", _licenseKills],
    ["purchasePrice", _purchasePrice],
    ["rentalPrice", _rentalPrice],
    ["requiredPerks", _requiredPerks]
]

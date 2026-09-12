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

private _technicalClass = _canonicalClass;
private _metadataRoot = _arsenalCfg >> "Metadata" >> "Weapons";
private _metadataCfg = _metadataRoot >> _technicalClass;
private _configured = isClass _metadataCfg;
private _metadataError = "";
private _technicalMinLevel = if (_configured && {isNumber (_metadataCfg >> "minLevel")}) then {
    (getNumber (_metadataCfg >> "minLevel")) max 1
} else {-1};

// A technical root may deliberately share another canonical progression root
// without pretending an integral S.O.G. configuration is attachment-derived.
if (_configured) then {
    private _progressionRoot = toLower (getText (_metadataCfg >> "progressionRoot"));
    if !(_progressionRoot isEqualTo "") then {
        private _progressionCfg = _metadataRoot >> _progressionRoot;
        if (isClass _progressionCfg) then {
            _canonicalClass = _progressionRoot;
            _metadataCfg = _progressionCfg;
        } else {
            _configured = false;
            _metadataError = "ERR_WEAPON_PROGRESSION_ROOT";
        };
    };
};

if !(_metadataError isEqualTo "") exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", _metadataError],
        ["requestedClass", _requestedClass],
        ["technicalClass", _technicalClass],
        ["canonicalClass", _canonicalClass],
        ["configured", false]
    ]
};

private _allowedSides = [];
private _crossSideAllowed = false;
private _minLevel = 1;
private _masteryKillsRequired = 0;
private _purchasePrice = -1;
private _rentalPrice = -1;
private _requiredPerks = [];

if (_configured) then {
    if (isArray (_metadataCfg >> "allowedSides")) then {
        _allowedSides = (getArray (_metadataCfg >> "allowedSides")) apply {toUpper _x};
    };

    if (isNumber (_metadataCfg >> "crossSideAllowed")) then {
        _crossSideAllowed = (getNumber (_metadataCfg >> "crossSideAllowed")) > 0;
    };

    if (isNumber (_metadataCfg >> "minLevel")) then {
        _minLevel = (getNumber (_metadataCfg >> "minLevel")) max 1;
    };
    if (_technicalMinLevel >= 1) then {
        _minLevel = _technicalMinLevel;
    };

    if (isNumber (_metadataCfg >> "masteryKillsRequired")) then {
        _masteryKillsRequired = (getNumber (_metadataCfg >> "masteryKillsRequired")) max 0;
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
    ["technicalClass", _technicalClass],
    ["canonicalClass", _canonicalClass],
    ["configured", _configured],
    ["allowedSides", _allowedSides],
    ["crossSideAllowed", _crossSideAllowed],
    ["minLevel", _minLevel],
    ["masteryKillsRequired", _masteryKillsRequired],
    ["purchasePrice", _purchasePrice],
    ["rentalPrice", _rentalPrice],
    ["requiredPerks", _requiredPerks]
]

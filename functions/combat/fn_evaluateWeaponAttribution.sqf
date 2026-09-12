/*
    File: fn_evaluateWeaponAttribution.sqf
    Author: Legend
    Description: Pure, fail-closed attribution of one factual ammo classname
        to canonical infantry weapons present in a server-known weapon set.
        It reads generated compatibility and the existing variant graph only.
    Execution: Any
    Parameters:
        0: Ammo/projectile classname <STRING>
        1: Server-known carried weapon classnames at shot creation <ARRAY>
        2: Source kind: INFANTRY, VEHICLE, or UNKNOWN <STRING>
    Returns:
        Attribution evaluation <HASHMAP>
    Public: No
*/

params [
    ["_ammoClass", "", [""]],
    ["_inventoryWeapons", [], [[]]],
    ["_sourceKind", "UNKNOWN", [""]]
];

private _result = createHashMapFromArray [
    ["result", "UNKNOWN"],
    ["reason", "UNRESOLVED"],
    ["ammo", toLower _ammoClass],
    ["matchingMagazineCategories", []],
    ["candidateWeapons", []],
    ["canonicalCandidates", []]
];

if !((toUpper _sourceKind) isEqualTo "INFANTRY") exitWith {
    _result set ["reason", "NON_INFANTRY_SOURCE"];
    _result
};

private _ammo = toLower _ammoClass;
if (_ammo isEqualTo "") exitWith {
    _result set ["reason", "AMMO_CLASS_MISSING"];
    _result
};

private _compatibilityCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Compatibility";
private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";

if !(isClass _sourceWeaponsCfg && {isClass _sourceMagazinesCfg} && {isClass _weaponMagazinesCfg}) exitWith {
    _result set ["reason", "COMPATIBILITY_DATA_MISSING"];
    _result
};

private _candidateWeapons = [];
private _canonicalCandidates = [];
private _matchingCategories = [];
private _combatCfg = missionConfigFile >> "CfgBnKothCombat";
private _eligibleCategories = if (isArray (_combatCfg >> "attributionInfantryMagazineCategories")) then {
    (getArray (_combatCfg >> "attributionInfantryMagazineCategories")) apply {toLower _x}
} else {[]};

if (_eligibleCategories isEqualTo []) exitWith {
    _result set ["reason", "INFANTRY_MAGAZINE_CATEGORIES_MISSING"];
    _result
};

{
    private _weaponClass = toLower _x;
    if (_weaponClass isEqualTo "" || {!isClass (_sourceWeaponsCfg >> _weaponClass)}) then {
        continue;
    };

    private _weaponMagCfg = _weaponMagazinesCfg >> _weaponClass;
    if !(isClass _weaponMagCfg && {isArray (_weaponMagCfg >> "values")}) then {
        continue;
    };

    private _matchesAmmo = false;
    {
        private _magazineClass = toLower _x;
        private _magazineCfg = _sourceMagazinesCfg >> _magazineClass;
        if (isClass _magazineCfg && {toLower (getText (_magazineCfg >> "ammoClass")) isEqualTo _ammo}) then {
            private _category = toLower (getText (_magazineCfg >> "category"));
            _matchingCategories pushBackUnique _category;
            if (_category in _eligibleCategories) then {
                _matchesAmmo = true;
            };
        };
        if (_matchesAmmo) exitWith {};
    } forEach (getArray (_weaponMagCfg >> "values"));

    if (!_matchesAmmo) then {
        continue;
    };

    _candidateWeapons pushBackUnique _weaponClass;
    private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
    if (_metadata getOrDefault ["success", false]) then {
        private _canonicalClass = _metadata getOrDefault ["canonicalClass", ""];
        if !(_canonicalClass isEqualTo "") then {
            _canonicalCandidates pushBackUnique _canonicalClass;
        };
    };
} forEach _inventoryWeapons;

_candidateWeapons sort true;
_canonicalCandidates sort true;
_matchingCategories sort true;
_result set ["matchingMagazineCategories", _matchingCategories];
_result set ["candidateWeapons", _candidateWeapons];
_result set ["canonicalCandidates", _canonicalCandidates];

if (_canonicalCandidates isEqualTo []) exitWith {
    _result set ["reason", if (_matchingCategories isEqualTo []) then {"NO_COMPATIBLE_CARRIED_WEAPON"} else {"NON_INFANTRY_AMMO_CATEGORY"}];
    _result
};

if ((count _canonicalCandidates) > 1) exitWith {
    _result set ["result", "AMBIGUOUS"];
    _result set ["reason", "MULTIPLE_CANONICAL_WEAPONS"];
    _result
};

_result set ["result", "ATTRIBUTED"];
_result set ["reason", "UNIQUE_CANONICAL_WEAPON"];
_result

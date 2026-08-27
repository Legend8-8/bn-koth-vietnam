/*
    File: fn_buildWeaponSlot.sqf
    Author: Legend
    Description: Converts one already validated canonical weapon composition
        into the physical seven-element Arma Unit Loadout weapon tuple.
    Execution: Server
    Parameters:
        0: Human-readable slot name <STRING>
        1: Validated weapon payload <HASHMAP>
    Returns:
        Build result containing slot <HASHMAP>
    Public: No
*/

params [
    ["_slotName", "weapon", [""]],
    ["_weaponData", createHashMap, [createHashMap]]
];

private _fail = {
    params ["_code", "_message"];
    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["slot", []]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Weapon slot construction must run on server."] call _fail
};

private _weaponClass = _weaponData getOrDefault ["weaponClass", ""];
private _magazines = _weaponData getOrDefault ["magazines", []];
private _attachments = _weaponData getOrDefault ["attachments", objNull];

if !(_weaponClass isEqualType "") exitWith {
    ["ERR_VALIDATED_WEAPON_CLASS_TYPE", format ["Validated %1 weaponClass must be a string.", _slotName]] call _fail
};
if (_weaponClass isEqualTo "") exitWith {
    ["ERR_VALIDATED_WEAPON_CLASS_EMPTY", format ["Validated %1 weaponClass is empty.", _slotName]] call _fail
};
if !(_magazines isEqualType []) exitWith {
    ["ERR_VALIDATED_MAGAZINES_TYPE", format ["Validated %1 magazines must be an array.", _slotName]] call _fail
};
if !(_attachments isEqualType []) exitWith {
    ["ERR_VALIDATED_ATTACHMENTS_TYPE", format ["Validated %1 weapon attachments must be an array.", _slotName]] call _fail
};

private _weaponCfg = configFile >> "CfgWeapons" >> _weaponClass;
if !(isClass _weaponCfg) exitWith {
    ["ERR_WEAPON_CONFIG_MISSING", format ["Validated weapon '%1' is missing from CfgWeapons.", _weaponClass]] call _fail
};

private _weaponSlot = [_weaponClass, "", "", "", [], [], ""];
private _slotCompat = [
    [1, (compatibleItems [_weaponClass, "MuzzleSlot"]) apply {toLower _x}],
    [2, (compatibleItems [_weaponClass, "PointerSlot"]) apply {toLower _x}],
    [3, (compatibleItems [_weaponClass, "CowsSlot"]) apply {toLower _x}],
    [6, (compatibleItems [_weaponClass, "UnderBarrelSlot"]) apply {toLower _x}]
];
private _failure = createHashMap;

{
    if ((count _failure) isEqualTo 0) then {
        private _attachment = toLower _x;
        private _candidateIndexes = [];
        {
            _x params ["_index", "_compatible"];
            if (_attachment in _compatible) then {_candidateIndexes pushBack _index;};
        } forEach _slotCompat;

        if ((count _candidateIndexes) isEqualTo 0) then {
            _failure = ["ERR_ATTACHMENT_SLOT_UNMAPPED", format ["Validated attachment '%1' has no physical slot on weapon '%2'.", _attachment, _weaponClass]] call _fail;
        } else {
            if ((count _candidateIndexes) > 1) then {
                _failure = ["ERR_ATTACHMENT_SLOT_AMBIGUOUS", format ["Validated attachment '%1' maps to more than one physical slot on weapon '%2'.", _attachment, _weaponClass]] call _fail;
            } else {
                private _targetIndex = _candidateIndexes select 0;
                if !((_weaponSlot select _targetIndex) isEqualTo "") then {
                    _failure = ["ERR_ATTACHMENT_SLOT_COLLISION", format ["Weapon '%1' received multiple attachments for loadout slot index %2.", _weaponClass, _targetIndex]] call _fail;
                } else {
                    _weaponSlot set [_targetIndex, _attachment];
                };
            };
        };
    };
} forEach _attachments;

if ((count _failure) > 0) exitWith {_failure};

private _muzzles = getArray (_weaponCfg >> "muzzles");
if ((count _muzzles) <= 0) then {_muzzles = ["this"];};

{
    if ((count _failure) isEqualTo 0) then {
        private _magazine = toLower _x;
        private _matchingMuzzles = [];
        {
            private _muzzleName = _x;
            private _muzzleCfg = if ((toLower _muzzleName) isEqualTo "this") then {_weaponCfg} else {_weaponCfg >> _muzzleName};
            if ((isClass _muzzleCfg) && {_magazine in ((getArray (_muzzleCfg >> "magazines")) apply {toLower _x})}) then {
                _matchingMuzzles pushBack _muzzleName;
            };
        } forEach _muzzles;

        if ((count _matchingMuzzles) isEqualTo 0) then {
            _failure = ["ERR_MAGAZINE_MUZZLE_UNMAPPED", format ["Validated magazine '%1' does not map to a muzzle on weapon '%2'.", _magazine, _weaponClass]] call _fail;
        } else {
            if ((count _matchingMuzzles) > 1) then {
                _failure = ["ERR_MAGAZINE_MUZZLE_AMBIGUOUS", format ["Validated magazine '%1' maps to multiple muzzles on weapon '%2'.", _magazine, _weaponClass]] call _fail;
            } else {
                private _targetIndex = if ((toLower (_matchingMuzzles select 0)) isEqualTo "this") then {4} else {5};
                private _magazineCfg = configFile >> "CfgMagazines" >> _magazine;
                private _ammoCount = if (isClass _magazineCfg) then {getNumber (_magazineCfg >> "count")} else {-1};
                if !((_weaponSlot select _targetIndex) isEqualTo []) then {
                    _failure = ["ERR_MAGAZINE_MUZZLE_COLLISION", format ["Weapon '%1' received multiple loaded magazines for loadout muzzle index %2.", _weaponClass, _targetIndex]] call _fail;
                } else {
                    if (_ammoCount < 0) then {
                        _failure = ["ERR_MAGAZINE_CONFIG_MISSING", format ["Validated magazine '%1' is missing from CfgMagazines.", _magazine]] call _fail;
                    } else {
                        if (_ammoCount isEqualTo 0) then {
                            _failure = ["ERR_MAGAZINE_CAPACITY_INVALID", format ["Validated magazine '%1' has invalid capacity %2.", _magazine, _ammoCount]] call _fail;
                        } else {
                            _weaponSlot set [_targetIndex, [_magazine, _ammoCount]];
                        };
                    };
                };
            };
        };
    };
} forEach _magazines;

if ((count _failure) > 0) exitWith {_failure};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", format ["Validated %1 weapon slot built.", _slotName]],
    ["slot", _weaponSlot]
]

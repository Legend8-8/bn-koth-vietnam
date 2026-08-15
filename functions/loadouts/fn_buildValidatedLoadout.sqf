/*
    File: fn_buildValidatedLoadout.sqf
    Author: Legend
    Description: Builds a complete canonical Unit Loadout Array by applying validated weapon slots to the authoritative side starter loadout.
    Execution: Server
    Parameters:
        0: Authoritative player side <SIDE>
        1: validatedWeapons map produced by bn_koth_fnc_loadouts_validateLoadout <HASHMAP>
    Returns:
        Build result <HASHMAP>
    Public: No
*/

params [
    ["_side", sideUnknown, [sideUnknown]],
    ["_validatedWeapons", createHashMap, [createHashMap]]
];

private _fail = {
    params ["_code", "_message", ["_sideToken", "", [""]], ["_loadoutId", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["sideToken", _sideToken],
        ["loadoutId", _loadoutId],
        ["loadout", []]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Validated loadout building must run on server."] call _fail
};

if !([_side] call bn_koth_fnc_teams_validateSide) exitWith {
    ["ERR_INVALID_SIDE", "Validated loadout building requires a playable authoritative side."] call _fail
};

if !(_validatedWeapons isEqualType createHashMap) exitWith {
    ["ERR_VALIDATED_WEAPONS_TYPE", "validatedWeapons must be a hashmap."] call _fail
};

if ((count _validatedWeapons) <= 0) exitWith {
    ["ERR_VALIDATED_WEAPONS_EMPTY", "validatedWeapons is empty."] call _fail
};

private _starterResult = [_side] call bn_koth_fnc_loadouts_getStarterLoadout;
if !(_starterResult getOrDefault ["success", false]) exitWith {
    [
        _starterResult getOrDefault ["code", "ERR_STARTER_LOOKUP"],
        _starterResult getOrDefault ["message", "Starter loadout lookup failed."],
        _starterResult getOrDefault ["sideToken", ""],
        _starterResult getOrDefault ["loadoutId", ""]
    ] call _fail
};

private _sideToken = _starterResult getOrDefault ["sideToken", ""];
private _loadoutId = _starterResult getOrDefault ["loadoutId", ""];
private _starterLoadout = _starterResult getOrDefault ["loadout", []];

if !(_starterLoadout isEqualType []) exitWith {
    ["ERR_STARTER_LOADOUT_TYPE", "Starter loadout payload has invalid type.", _sideToken, _loadoutId] call _fail
};

if ((count _starterLoadout) < 10) exitWith {
    [
        "ERR_STARTER_LOADOUT_SHAPE",
        format ["Starter loadout '%1' does not contain the expected Unit Loadout Array structure.", _loadoutId],
        _sideToken,
        _loadoutId
    ] call _fail
};

// Only top-level weapon entries 0/1/2 are replaced.
// Uniform, vest, backpack, headgear, facewear, binoculars and assigned items remain untouched.
private _builtLoadout = +_starterLoadout;

private _buildWeaponSlot = {
    params ["_slotName", "_weaponData"];

    private _slotFail = {
        params ["_code", "_message"];

        createHashMapFromArray [
            ["success", false],
            ["code", _code],
            ["message", _message],
            ["slot", []]
        ]
    };

    if !(_weaponData isEqualType createHashMap) exitWith {
        ["ERR_VALIDATED_WEAPON_TYPE", format ["Validated %1 weapon payload must be a hashmap.", _slotName]] call _slotFail
    };

    private _weaponClass = _weaponData getOrDefault ["weaponClass", ""];
    private _magazines = _weaponData getOrDefault ["magazines", []];
    private _ordinaryAttachments = _weaponData getOrDefault ["ordinaryAttachments", objNull];

    if !(_weaponClass isEqualType "") exitWith {
        ["ERR_VALIDATED_WEAPON_CLASS_TYPE", format ["Validated %1 weaponClass must be a string.", _slotName]] call _slotFail
    };

    if (_weaponClass isEqualTo "") exitWith {
        ["ERR_VALIDATED_WEAPON_CLASS_EMPTY", format ["Validated %1 weaponClass is empty.", _slotName]] call _slotFail
    };

    if !(_magazines isEqualType []) exitWith {
        ["ERR_VALIDATED_MAGAZINES_TYPE", format ["Validated %1 magazines must be an array.", _slotName]] call _slotFail
    };

    // Structural attachments have already been represented by the resolved weapon classname.
    // Only ordinary physical attachments may be inserted into Unit Loadout Array attachment fields.
    if !(_ordinaryAttachments isEqualType []) exitWith {
        [
            "ERR_VALIDATED_ATTACHMENT_ROLES_MISSING",
            format ["Validated %1 weapon is missing ordinaryAttachments provenance.", _slotName]
        ] call _slotFail
    };

    private _weaponCfg = configFile >> "CfgWeapons" >> _weaponClass;
    if !(isClass _weaponCfg) exitWith {
        ["ERR_WEAPON_CONFIG_MISSING", format ["Validated weapon '%1' is missing from CfgWeapons.", _weaponClass]] call _slotFail
    };

    private _weaponSlot = [_weaponClass, "", "", "", [], [], ""];

    private _muzzleCompatible = (compatibleItems [_weaponClass, "MuzzleSlot"]) apply {toLower _x};
    private _pointerCompatible = (compatibleItems [_weaponClass, "PointerSlot"]) apply {toLower _x};
    private _opticCompatible = (compatibleItems [_weaponClass, "CowsSlot"]) apply {toLower _x};
    private _bipodCompatible = (compatibleItems [_weaponClass, "UnderBarrelSlot"]) apply {toLower _x};

    private _attachmentFailure = createHashMap;

    {
        if ((count _attachmentFailure) isEqualTo 0) then {
            private _attachment = toLower _x;
            private _candidateIndexes = [];

            if (_attachment in _muzzleCompatible) then {_candidateIndexes pushBack 1;};
            if (_attachment in _pointerCompatible) then {_candidateIndexes pushBack 2;};
            if (_attachment in _opticCompatible) then {_candidateIndexes pushBack 3;};
            if (_attachment in _bipodCompatible) then {_candidateIndexes pushBack 6;};

            if ((count _candidateIndexes) isEqualTo 0) then {
                _attachmentFailure = [
                    "ERR_ATTACHMENT_SLOT_UNMAPPED",
                    format ["Validated attachment '%1' has no physical slot on weapon '%2'.", _attachment, _weaponClass]
                ] call _slotFail;
            } else {
                if ((count _candidateIndexes) > 1) then {
                    _attachmentFailure = [
                        "ERR_ATTACHMENT_SLOT_AMBIGUOUS",
                        format ["Validated attachment '%1' maps to more than one physical slot on weapon '%2'.", _attachment, _weaponClass]
                    ] call _slotFail;
                } else {
                    private _targetIndex = _candidateIndexes select 0;

                    if !((_weaponSlot select _targetIndex) isEqualTo "") then {
                        _attachmentFailure = [
                            "ERR_ATTACHMENT_SLOT_COLLISION",
                            format ["Weapon '%1' received multiple attachments for loadout slot index %2.", _weaponClass, _targetIndex]
                        ] call _slotFail;
                    } else {
                        _weaponSlot set [_targetIndex, _attachment];
                    };
                };
            };
        };
    } forEach _ordinaryAttachments;

    if ((count _attachmentFailure) > 0) exitWith {
        _attachmentFailure
    };

    private _muzzles = getArray (_weaponCfg >> "muzzles");
    if ((count _muzzles) <= 0) then {
        _muzzles = ["this"];
    };

    private _magazineFailure = createHashMap;

    {
        if ((count _magazineFailure) isEqualTo 0) then {
            private _magazine = toLower _x;
            private _matchingMuzzles = [];

            {
                private _muzzleName = _x;
                private _muzzleCfg = if ((toLower _muzzleName) isEqualTo "this") then {
                    _weaponCfg
                } else {
                    _weaponCfg >> _muzzleName
                };

                if (isClass _muzzleCfg) then {
                    private _muzzleMagazines = (getArray (_muzzleCfg >> "magazines")) apply {toLower _x};
                    if (_magazine in _muzzleMagazines) then {
                        _matchingMuzzles pushBack _muzzleName;
                    };
                };
            } forEach _muzzles;

            if ((count _matchingMuzzles) isEqualTo 0) then {
                _magazineFailure = [
                    "ERR_MAGAZINE_MUZZLE_UNMAPPED",
                    format ["Validated magazine '%1' does not map to a muzzle on weapon '%2'.", _magazine, _weaponClass]
                ] call _slotFail;
            } else {
                if ((count _matchingMuzzles) > 1) then {
                    _magazineFailure = [
                        "ERR_MAGAZINE_MUZZLE_AMBIGUOUS",
                        format ["Validated magazine '%1' maps to multiple muzzles on weapon '%2'.", _magazine, _weaponClass]
                    ] call _slotFail;
                } else {
                    private _muzzleName = _matchingMuzzles select 0;
                    private _targetIndex = if ((toLower _muzzleName) isEqualTo "this") then {4} else {5};

                    if !((_weaponSlot select _targetIndex) isEqualTo []) then {
                        _magazineFailure = [
                            "ERR_MAGAZINE_MUZZLE_COLLISION",
                            format ["Weapon '%1' received multiple loaded magazines for loadout muzzle index %2.", _weaponClass, _targetIndex]
                        ] call _slotFail;
                    } else {
                        private _magazineCfg = configFile >> "CfgMagazines" >> _magazine;

                        if !(isClass _magazineCfg) then {
                            _magazineFailure = [
                                "ERR_MAGAZINE_CONFIG_MISSING",
                                format ["Validated magazine '%1' is missing from CfgMagazines.", _magazine]
                            ] call _slotFail;
                        } else {
                            private _ammoCount = getNumber (_magazineCfg >> "count");

                            if (_ammoCount <= 0) then {
                                _magazineFailure = [
                                    "ERR_MAGAZINE_CAPACITY_INVALID",
                                    format ["Validated magazine '%1' has invalid capacity %2.", _magazine, _ammoCount]
                                ] call _slotFail;
                            } else {
                                _weaponSlot set [_targetIndex, [_magazine, _ammoCount]];
                            };
                        };
                    };
                };
            };
        };
    } forEach _magazines;

    if ((count _magazineFailure) > 0) exitWith {
        _magazineFailure
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", format ["Validated %1 weapon slot built.", _slotName]],
        ["slot", _weaponSlot]
    ]
};

private _slotDefinitions = [
    ["primary", 0],
    ["launcher", 1],
    ["handgun", 2]
];

private _buildFailure = createHashMap;
private _validatedWeaponKeys = keys _validatedWeapons;

{
    if ((count _buildFailure) isEqualTo 0) then {
        _x params ["_slotName", "_loadoutIndex"];

        if (_slotName in _validatedWeaponKeys) then {
            private _slotResult = [
                _slotName,
                _validatedWeapons get _slotName
            ] call _buildWeaponSlot;

            if (_slotResult getOrDefault ["success", false]) then {
                _builtLoadout set [_loadoutIndex, _slotResult getOrDefault ["slot", []]];
            } else {
                _buildFailure = _slotResult;
            };
        };
    };
} forEach _slotDefinitions;

if ((count _buildFailure) > 0) exitWith {
    [
        _buildFailure getOrDefault ["code", "ERR_WEAPON_SLOT_BUILD"],
        _buildFailure getOrDefault ["message", "Validated weapon slot build failed."],
        _sideToken,
        _loadoutId
    ] call _fail
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", "Validated weapon selections built into complete starter-based loadout."],
    ["sideToken", _sideToken],
    ["loadoutId", _loadoutId],
    ["loadout", _builtLoadout]
]

/*
    File: fn_validateMutation.sqf
    Author: Legend
    Description: Validates and applies one authoritative mutation intent against the player's intended loadout state.
    Execution: Server
    Parameters:
        0: Requesting player object <OBJECT>
        1: Mutation request map <HASHMAP>
        2: Canonical compatibility config root <CONFIG>
        3: Canonical arsenal config root <CONFIG>
        4: Authoritative player side <SIDE>
        5: Authoritative side token <STRING>
        6: Authoritative intended baseline loadout (optional) <ARRAY>
    Returns:
        Validation result <HASHMAP>
    Public: No
*/

params [
    ["_player", objNull, [objNull]],
    ["_mutation", createHashMap, [createHashMap]],
    ["_compatibilityCfg", configNull, [configNull]],
    ["_arsenalCfg", configNull, [configNull]],
    ["_assignedSide", sideUnknown, [sideUnknown]],
    ["_authoritativeSideToken", "", [""]],
    ["_authoritativeBaselineLoadout", [], [[]]]
];

private _resultFail = {
    params ["_code", "_message", ["_loadoutId", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["loadoutId", _loadoutId],
        ["sideToken", _authoritativeSideToken],
        ["validatedLoadout", []],
        ["validatedPrimary", createHashMap],
        ["validatedWeapons", createHashMap],
        ["validatedBy", ""]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Loadout mutation validation must run on server."] call _resultFail
};

if !(isClass _compatibilityCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "Loadout mutation validation requires canonical compatibility config."] call _resultFail
};

if !(isClass _arsenalCfg) exitWith {
    ["ERR_CATALOGUE_MISSING", "Loadout mutation validation requires canonical arsenal config."] call _resultFail
};

if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    ["ERR_ASSIGNED_SIDE_INVALID", "Loadout mutation validation requires a valid assigned side."] call _resultFail
};

if !(_mutation isEqualType createHashMap) exitWith {
    ["ERR_MALFORMED_REQUEST", "Mutation request must be a map."] call _resultFail
};

private _uid = getPlayerUID _player;
if (_uid isEqualTo "") exitWith {
    ["ERR_INVALID_PLAYER", "Mutation validation requires a player UID."] call _resultFail
};

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";

if !(isClass _sourceWeaponsCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "SourceWeapons compatibility data is missing."] call _resultFail
};
if !(isClass _sourceMagazinesCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "SourceMagazines compatibility data is missing."] call _resultFail
};
if !(isClass _sourceItemsCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "SourceItems compatibility data is missing."] call _resultFail
};
if !(isClass _weaponMagazinesCfg) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "WeaponMagazines compatibility data is missing."] call _resultFail
};

private _getStarterFallback = {
    private _starterResult = [_assignedSide] call bn_koth_fnc_loadouts_getStarterLoadout;
    if !(_starterResult getOrDefault ["success", false]) exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", _starterResult getOrDefault ["code", "ERR_STARTER_LOOKUP"]],
            ["message", _starterResult getOrDefault ["message", "Starter loadout lookup failed."]],
            ["loadout", []],
            ["loadoutId", _starterResult getOrDefault ["loadoutId", ""]]
        ]
    };

    private _starterLoadout = _starterResult getOrDefault ["loadout", []];
    if !((_starterLoadout isEqualType []) && {(count _starterLoadout) >= 10}) exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_STARTER_LOADOUT_SHAPE"],
            ["message", "Starter loadout shape is invalid."],
            ["loadout", []],
            ["loadoutId", _starterResult getOrDefault ["loadoutId", ""]]
        ]
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Starter loadout resolved."],
        ["loadout", +_starterLoadout],
        ["loadoutId", _starterResult getOrDefault ["loadoutId", ""]]
    ]
};

private _baseLoadout = [];
private _baseLoadoutId = "";
if ((_authoritativeBaselineLoadout isEqualType []) && {(count _authoritativeBaselineLoadout) >= 10}) then {
    _baseLoadout = +_authoritativeBaselineLoadout;
};
if ((count _baseLoadout) < 10) then {
    private _starterFallback = call _getStarterFallback;
    if !(_starterFallback getOrDefault ["success", false]) exitWith {
        [
            _starterFallback getOrDefault ["code", "ERR_STARTER_LOOKUP"],
            _starterFallback getOrDefault ["message", "Starter loadout lookup failed."],
            _starterFallback getOrDefault ["loadoutId", ""]
        ] call _resultFail
    };

    _baseLoadout = _starterFallback getOrDefault ["loadout", []];
    _baseLoadoutId = _starterFallback getOrDefault ["loadoutId", ""];
};

if !((_baseLoadout isEqualType []) && {(count _baseLoadout) >= 10}) exitWith {
    ["ERR_BASELINE_LOADOUT_SHAPE", "Authoritative baseline loadout shape is invalid.", _baseLoadoutId] call _resultFail
};

private _resolveBaseWeapon = {
    params ["_weaponClass"];

    private _resolved = toLower _weaponClass;
    if (_resolved isEqualTo "") exitWith {""};

    private _safety = 0;
    while {_safety < 16} do {
        private _cfg = _sourceWeaponsCfg >> _resolved;
        if !(isClass _cfg) exitWith {};

        private _variantOf = toLower (getText (_cfg >> "variantOf"));
        if (_variantOf isEqualTo "") exitWith {};

        _resolved = _variantOf;
        _safety = _safety + 1;
    };

    _resolved
};

private _extractWeaponComposition = {
    params ["_weaponSlot", "_slotToken", "_slotLabel"];

    private _slotFail = {
        params ["_code", "_message"];
        createHashMapFromArray [
            ["success", false],
            ["code", _code],
            ["message", _message],
            ["composition", createHashMap]
        ]
    };

    if !((_weaponSlot isEqualType []) && {(count _weaponSlot) >= 7}) exitWith {
        ["ERR_LOADOUT_SLOT_SHAPE", format ["%1 slot shape is invalid.", _slotLabel]] call _slotFail
    };

    private _resolvedWeaponClass = toLower (_weaponSlot select 0);
    if (_resolvedWeaponClass isEqualTo "") exitWith {
        if (_slotToken isEqualTo "LAUNCHER") then {
            createHashMapFromArray [
                ["success", true],
                ["code", "OK"],
                ["message", "Launcher slot is empty."],
                ["composition", createHashMapFromArray [
                    ["isEmpty", true],
                    ["baseWeaponClass", ""],
                    ["weaponClass", ""],
                    ["magazines", []],
                    ["attachments", []]
                ]]
            ]
        } else {
            ["ERR_LOADOUT_SLOT_EMPTY", format ["%1 slot is empty.", _slotLabel]] call _slotFail
        }
    };

    if !(isClass (_sourceWeaponsCfg >> _resolvedWeaponClass)) exitWith {
        ["ERR_UNKNOWN_WEAPON", format ["%1 weapon '%2' is missing from canonical source weapons.", _slotLabel, _resolvedWeaponClass]] call _slotFail
    };

    private _baseWeaponClass = [_resolvedWeaponClass] call _resolveBaseWeapon;
    if (_baseWeaponClass isEqualTo "") then {
        _baseWeaponClass = _resolvedWeaponClass;
    };

    if !(isClass (_sourceWeaponsCfg >> _baseWeaponClass)) exitWith {
        ["ERR_UNKNOWN_BASE_WEAPON", format ["%1 base weapon '%2' is missing from canonical source weapons.", _slotLabel, _baseWeaponClass]] call _slotFail
    };

    private _attachments = [];
    {
        private _attachmentClass = toLower (_weaponSlot select _x);
        if !(_attachmentClass isEqualTo "") then {
            _attachments pushBackUnique _attachmentClass;
        };
    } forEach [1, 2, 3, 6];
    _attachments sort true;

    private _magazines = [];
    {
        private _magSlot = _weaponSlot select _x;
        if ((_magSlot isEqualType []) && {(count _magSlot) > 0}) then {
            private _magClass = toLower (_magSlot select 0);
            if !(_magClass isEqualTo "") then {
                _magazines pushBackUnique _magClass;
            };
        };
    } forEach [4, 5];

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Weapon slot composition extracted."],
        ["composition", createHashMapFromArray [
            ["isEmpty", false],
            ["baseWeaponClass", _baseWeaponClass],
            ["weaponClass", _resolvedWeaponClass],
            ["magazines", _magazines],
            ["attachments", _attachments]
        ]]
    ]
};

private _validateAssignedClassForIndex = {
    params ["_assignedIndex", "_itemClass"];

    private _assignedFail = {
        params ["_code", "_message"];
        createHashMapFromArray [
            ["success", false],
            ["code", _code],
            ["message", _message]
        ]
    };

    if (_itemClass isEqualTo "") exitWith {
        createHashMapFromArray [
            ["success", true],
            ["code", "OK"],
            ["message", "Assigned slot clear intent accepted."]
        ]
    };

    if !(isClass (_sourceItemsCfg >> _itemClass)) exitWith {
        [
            "ERR_ASSIGNED_ITEM_UNKNOWN",
            format ["Assigned item '%1' is missing from canonical SourceItems.", _itemClass]
        ] call _assignedFail
    };

    if !(isClass (configFile >> "CfgWeapons" >> _itemClass)) exitWith {
        ["ERR_ASSIGNED_ITEM_CONFIG_MISSING", format ["Assigned item '%1' is missing from CfgWeapons.", _itemClass]] call _assignedFail
    };

    private _itemType = [_itemClass] call BIS_fnc_itemType;
    if !((_itemType isEqualType []) && {(count _itemType) >= 2}) exitWith {
        ["ERR_ASSIGNED_ITEM_TYPE_UNKNOWN", format ["Assigned item '%1' type could not be resolved.", _itemClass]] call _assignedFail
    };

    private _subType = toLower (_itemType select 1);

    private _allowed = switch (_assignedIndex) do {
        case 0: {_subType isEqualTo "map"};
        case 1: {(_subType isEqualTo "gps") || {_subType find "uav" >= 0}};
        case 2: {_subType isEqualTo "radio"};
        case 3: {_subType isEqualTo "compass"};
        case 4: {_subType isEqualTo "watch"};
        case 5: {_subType find "nvg" >= 0};
        default {false};
    };

    if (!_allowed) exitWith {
        [
            "ERR_ASSIGNED_ITEM_SLOT_MISMATCH",
            format ["Assigned item '%1' subtype '%2' is not valid for assigned slot index %3.", _itemClass, _subType, _assignedIndex]
        ] call _assignedFail
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Assigned slot item validated."]
    ]
};

private _resolveAllowedCargoMagazines = {
    params ["_loadout"];

    private _allowed = [];

    {
        private _slotData = _loadout select _x;
        if ((_slotData isEqualType []) && {(count _slotData) >= 7}) then {
            private _weaponClass = toLower (_slotData select 0);
            if !(_weaponClass isEqualTo "") then {
                private _weaponMagCfg = _weaponMagazinesCfg >> _weaponClass;
                if (isClass _weaponMagCfg) then {
                    {
                        _allowed pushBackUnique (toLower _x);
                    } forEach (getArray (_weaponMagCfg >> "values"));
                };
            };
        };
    } forEach [0, 1, 2];

    _allowed
};

private _validateCargoClass = {
    params ["_className", "_loadout"];

    private _classLower = toLower _className;

    private _isCanonicalMagazine = isClass (_sourceMagazinesCfg >> _classLower);
    private _isCanonicalItem = isClass (_sourceItemsCfg >> _classLower);

    if !(_isCanonicalMagazine || {_isCanonicalItem}) exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_CARGO_CLASS_UNKNOWN"],
            ["message", format ["Cargo class '%1' is not present in canonical source items/magazines.", _classLower]],
            ["kind", ""],
            ["ammoCount", 0]
        ]
    };

    if (_isCanonicalMagazine) then {
        private _magCfg = configFile >> "CfgMagazines" >> _classLower;
        if !(isClass _magCfg) exitWith {
            createHashMapFromArray [
                ["success", false],
                ["code", "ERR_MAGAZINE_CONFIG_MISSING"],
                ["message", format ["Cargo magazine '%1' is missing from CfgMagazines.", _classLower]],
                ["kind", ""],
                ["ammoCount", 0]
            ]
        };

        private _allowedMagazines = [_loadout] call _resolveAllowedCargoMagazines;
        private _magCategory = toLower (getText ((_sourceMagazinesCfg >> _classLower) >> "category"));
        private _isGrenadeCategory = (_magCategory find "grenade") >= 0;
        private _isSmokeCategory = (_magCategory find "smoke") >= 0;

        if !((_classLower in _allowedMagazines) || {_isGrenadeCategory} || {_isSmokeCategory}) exitWith {
            createHashMapFromArray [
                ["success", false],
                ["code", "ERR_CARGO_MAGAZINE_INCOMPATIBLE"],
                ["message", format ["Cargo magazine '%1' is not compatible with intended weapons and is not a grenade/smoke magazine.", _classLower]],
                ["kind", ""],
                ["ammoCount", 0]
            ]
        };

        private _ammoCount = getNumber (_magCfg >> "count");
        if (_ammoCount <= 0) then {
            _ammoCount = 1;
        };

        createHashMapFromArray [
            ["success", true],
            ["code", "OK"],
            ["message", "Cargo magazine validated."],
            ["kind", "magazine"],
            ["ammoCount", _ammoCount]
        ]
    } else {
        createHashMapFromArray [
            ["success", true],
            ["code", "OK"],
            ["message", "Cargo item validated."],
            ["kind", "item"],
            ["ammoCount", 0]
        ]
    }
};

private _sanitizeContainerCargo = {
    params ["_cargoEntries"];

    private _result = [];
    {
        if (_x isEqualType []) then {
            if ((count _x) >= 2) then {
                private _entryClass = toLower (_x select 0);
                private _entryCount = _x select 1;

                if ((_entryClass isEqualType "") && {(_entryCount isEqualType 0)}) then {
                    if ((count _x) >= 3) then {
                        private _entryAmmo = _x select 2;
                        if (_entryAmmo isEqualType 0) then {
                            _result pushBack [_entryClass, _entryCount, _entryAmmo];
                        };
                    } else {
                        _result pushBack [_entryClass, _entryCount];
                    };
                };
            };
        };
    } forEach _cargoEntries;

    _result
};

private _resolveCargoUnitMass = {
    params ["_className"];

    private _magCfg = configFile >> "CfgMagazines" >> _className;
    if (isClass _magCfg && {isNumber (_magCfg >> "mass")}) exitWith {
        createHashMapFromArray [
            ["success", true],
            ["mass", (getNumber (_magCfg >> "mass")) max 0]
        ]
    };

    private _itemInfoCfg = configFile >> "CfgWeapons" >> _className >> "ItemInfo";
    if (isClass _itemInfoCfg && {isNumber (_itemInfoCfg >> "mass")}) exitWith {
        createHashMapFromArray [
            ["success", true],
            ["mass", (getNumber (_itemInfoCfg >> "mass")) max 0]
        ]
    };

    createHashMapFromArray [
        ["success", false],
        ["mass", 0]
    ]
};

private _resolveContainerMaximumLoad = {
    params ["_containerName", "_containerClass"];

    if (_containerName isEqualTo "backpack") exitWith {
        private _cfg = configFile >> "CfgVehicles" >> _containerClass;
        if !(isClass _cfg) exitWith {-1};
        if !(isNumber (_cfg >> "maximumLoad")) exitWith {-1};
        (getNumber (_cfg >> "maximumLoad")) max 0
    };

    private _itemInfoCfg = configFile >> "CfgWeapons" >> _containerClass >> "ItemInfo";
    if !(isClass _itemInfoCfg) exitWith {-1};

    private _cargoContainerClass = getText (_itemInfoCfg >> "containerClass");
    if (_cargoContainerClass isEqualTo "") exitWith {-1};

    private _cargoCfg = configFile >> "CfgVehicles" >> _cargoContainerClass;
    if !(isClass _cargoCfg) exitWith {-1};
    if !(isNumber (_cargoCfg >> "maximumLoad")) exitWith {-1};

    (getNumber (_cargoCfg >> "maximumLoad")) max 0
};

private _validateContainerCapacity = {
    params ["_containerName", "_containerClass", "_cargoEntries"];

    private _maximumLoad = [_containerName, _containerClass] call _resolveContainerMaximumLoad;
    if (_maximumLoad < 0) exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_CONTAINER_CAPACITY_UNKNOWN"],
            ["message", format ["Could not resolve %1 capacity for '%2'.", _containerName, _containerClass]]
        ]
    };

    private _usedLoad = 0;
    private _unknownClass = "";

    {
        if ((_x isEqualType []) && {(count _x) >= 2}) then {
            private _entryClass = toLower (_x select 0);
            private _entryCount = _x select 1;

            if ((_entryClass isEqualType "") && {_entryCount isEqualType 0} && {_entryCount > 0}) then {
                private _massResult = [_entryClass] call _resolveCargoUnitMass;
                if !(_massResult getOrDefault ["success", false]) then {
                    _unknownClass = _entryClass;
                } else {
                    _usedLoad = _usedLoad + ((_massResult getOrDefault ["mass", 0]) * _entryCount);
                };
            };
        };
    } forEach _cargoEntries;

    if !(_unknownClass isEqualTo "") exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_CARGO_MASS_UNKNOWN"],
            ["message", format ["Could not resolve cargo mass for '%1'.", _unknownClass]]
        ]
    };

    if (_usedLoad > (_maximumLoad + 0.001)) exitWith {
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_CONTAINER_CAPACITY_EXCEEDED"],
            ["message", format [
                "%1 is full: requested load %2 exceeds capacity %3.",
                toUpper _containerName,
                round _usedLoad,
                round _maximumLoad
            ]]
        ]
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Container capacity validated."]
    ]
};

private _slotIdRaw = _mutation getOrDefault ["slotId", "slot1"];
if !(_slotIdRaw isEqualType "") then {
    _slotIdRaw = "slot1";
};
private _slotId = toLower _slotIdRaw;
if !(_slotId in ["slot1", "slot2", "slot3"]) then {
    _slotId = "slot1";
};

private _opRaw = _mutation getOrDefault ["op", ""];
if !(_opRaw isEqualType "") exitWith {
    ["ERR_MALFORMED_REQUEST", "Mutation op must be a string.", _baseLoadoutId] call _resultFail
};
private _op = toLower _opRaw;
if (_op isEqualTo "") exitWith {
    ["ERR_MALFORMED_REQUEST", "Mutation op is required.", _baseLoadoutId] call _resultFail
};

private _mutatedLoadout = +_baseLoadout;
private _shouldApply = true;
private _resultMessage = "Loadout mutation validated.";
private _resultCode = "OK";

switch (_op) do {
    case "snapshot": {
        _shouldApply = false;
        _resultMessage = "Authoritative intended loadout snapshot provided.";
    };

    case "save_session_kit": {
        private _savedByUid = missionNamespace getVariable ["BN_KOTH_savedLoadoutsByUid", createHashMap];
        if !(_savedByUid isEqualType createHashMap) then {
            _savedByUid = createHashMap;
        };

        private _playerSaves = _savedByUid getOrDefault [_uid, createHashMap];
        if !(_playerSaves isEqualType createHashMap) then {
            _playerSaves = createHashMap;
        };

        _playerSaves set [_slotId, +_mutatedLoadout];
        _savedByUid set [_uid, _playerSaves];
        missionNamespace setVariable ["BN_KOTH_savedLoadoutsByUid", _savedByUid];

        _shouldApply = false;
        _resultMessage = format ["Session kit '%1' saved.", _slotId];
    };

    case "delete_session_kit": {
        private _savedByUid = missionNamespace getVariable ["BN_KOTH_savedLoadoutsByUid", createHashMap];
        if !(_savedByUid isEqualType createHashMap) then {
            _savedByUid = createHashMap;
        };

        private _playerSaves = _savedByUid getOrDefault [_uid, createHashMap];
        if !(_playerSaves isEqualType createHashMap) then {
            _playerSaves = createHashMap;
        };

        _playerSaves deleteAt _slotId;
        _savedByUid set [_uid, _playerSaves];
        missionNamespace setVariable ["BN_KOTH_savedLoadoutsByUid", _savedByUid];

        _shouldApply = false;
        _resultMessage = format ["Session kit '%1' deleted.", _slotId];
    };

    case "load_session_kit": {
        private _savedByUid = missionNamespace getVariable ["BN_KOTH_savedLoadoutsByUid", createHashMap];
        if !(_savedByUid isEqualType createHashMap) then {
            _savedByUid = createHashMap;
        };

        private _playerSaves = _savedByUid getOrDefault [_uid, createHashMap];
        if !(_playerSaves isEqualType createHashMap) then {
            _playerSaves = createHashMap;
        };

        private _savedLoadout = _playerSaves getOrDefault [_slotId, []];
        if !((_savedLoadout isEqualType []) && {(count _savedLoadout) >= 10}) exitWith {
            ["ERR_SAVED_KIT_MISSING", format ["Session kit '%1' does not exist.", _slotId], _baseLoadoutId] call _resultFail
        };

        _mutatedLoadout = +_savedLoadout;

        // Revalidate saved primary/launcher/handgun composition through canonical compatibility.
        private _validatedWeapons = createHashMap;

        {
            _x params ["_slotName", "_slotIndex", "_slotToken", "_slotLabel"];
            if (_resultCode isEqualTo "OK") then {
                private _extractResult = [
                    _mutatedLoadout select _slotIndex,
                    _slotToken,
                    _slotLabel
                ] call _extractWeaponComposition;

                if !(_extractResult getOrDefault ["success", false]) then {
                    _resultCode = _extractResult getOrDefault ["code", "ERR_LOADOUT_SLOT_SHAPE"];
                    _resultMessage = _extractResult getOrDefault ["message", "Saved weapon slot extraction failed."];
                } else {
                    private _composition = _extractResult getOrDefault ["composition", createHashMap];
                    private _isEmpty = _composition getOrDefault ["isEmpty", false];

                    if (_isEmpty) then {
                        if (_slotName isEqualTo "launcher") then {
                            _validatedWeapons set [_slotName, createHashMapFromArray [["clear", true]]];
                        } else {
                            _resultCode = "ERR_LOADOUT_SLOT_EMPTY";
                            _resultMessage = format ["Saved %1 slot is empty.", toLower _slotLabel];
                        };
                    } else {
                        private _compositionResult = [
                            createHashMapFromArray [
                                ["weaponClass", _composition getOrDefault ["baseWeaponClass", ""]],
                                ["magazines", _composition getOrDefault ["magazines", []]],
                                ["attachments", _composition getOrDefault ["attachments", []]]
                            ],
                            _compatibilityCfg,
                            _slotToken,
                            _slotLabel
                        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

                        if !(_compositionResult getOrDefault ["success", false]) then {
                            _resultCode = _compositionResult getOrDefault ["code", "ERR_WEAPON_COMPOSITION"];
                            _resultMessage = _compositionResult getOrDefault ["message", "Saved weapon composition validation failed."];
                        } else {
                            private _validatedWeapon = _compositionResult getOrDefault ["validatedWeapon", createHashMap];
                            private _weaponClass = _validatedWeapon getOrDefault ["weaponClass", ""];
                            if (_weaponClass isEqualTo "") then {
                                _weaponClass = _validatedWeapon getOrDefault ["baseWeaponClass", ""];
                            };

                            private _entitlement = [
                                _uid,
                                _weaponClass
                            ] call bn_koth_fnc_progression_evaluateWeaponEntitlement;

                            if !(_entitlement getOrDefault ["entitled", false]) then {
                                _resultCode = _entitlement getOrDefault ["code", "ERR_WEAPON_ENTITLEMENT"];
                                _resultMessage = _entitlement getOrDefault [
                                    "message",
                                    format ["Saved %1 weapon is no longer entitled for this player.", toLower _slotLabel]
                                ];
                            } else {
                                _validatedWeapons set [_slotName, _validatedWeapon];
                            };
                        };
                    };
                };
            };
        } forEach [
            ["primary", 0, "PRIMARY", "Primary"],
            ["launcher", 1, "LAUNCHER", "Launcher"],
            ["handgun", 2, "HANDGUN", "Handgun"]
        ];

        if !(_resultCode isEqualTo "OK") exitWith {
            [_resultCode, _resultMessage, _baseLoadoutId] call _resultFail
        };

        private _buildResult = [
            _assignedSide,
            _validatedWeapons,
            _mutatedLoadout
        ] call bn_koth_fnc_loadouts_buildValidatedLoadout;

        if !(_buildResult getOrDefault ["success", false]) exitWith {
            [
                _buildResult getOrDefault ["code", "ERR_LOADOUT_BUILD"],
                _buildResult getOrDefault ["message", "Saved kit weapon revalidation failed."],
                _buildResult getOrDefault ["loadoutId", _baseLoadoutId]
            ] call _resultFail
        };

        _mutatedLoadout = _buildResult getOrDefault ["loadout", []];

        // Validate assigned-items shape and each entry.
        private _assignedSlot = _mutatedLoadout select 9;
        if !(_assignedSlot isEqualType []) then {
            _assignedSlot = [];
        };
        while {(count _assignedSlot) < 6} do {
            _assignedSlot pushBack "";
        };

        for "_i" from 0 to 5 do {
            private _itemClass = toLower (_assignedSlot select _i);
            private _assignedCheck = [_i, _itemClass] call _validateAssignedClassForIndex;
            if !(_assignedCheck getOrDefault ["success", false]) exitWith {
                _resultCode = _assignedCheck getOrDefault ["code", "ERR_ASSIGNED_ITEM_SLOT_MISMATCH"];
                _resultMessage = _assignedCheck getOrDefault ["message", "Saved kit assigned item is invalid."];
            };
            _assignedSlot set [_i, _itemClass];
        };

        if !(_resultCode isEqualTo "OK") exitWith {
            [_resultCode, _resultMessage, _baseLoadoutId] call _resultFail
        };

        _mutatedLoadout set [9, _assignedSlot];

        // Validate binocular slot.
        private _binocSlot = _mutatedLoadout select 8;
        if !(_binocSlot isEqualType "") then {
            if (_binocSlot isEqualType []) then {
                if ((count _binocSlot) > 0) then {
                    _resultCode = "ERR_BINOCULAR_SLOT_SHAPE";
                    _resultMessage = "Saved binocular slot array shape is invalid.";
                };
            } else {
                _resultCode = "ERR_BINOCULAR_SLOT_SHAPE";
                _resultMessage = "Saved binocular slot has invalid type.";
            };
        } else {
            private _binocClass = toLower _binocSlot;
            if !(_binocClass isEqualTo "") then {
                private _binocType = [_binocClass] call BIS_fnc_itemType;
                if !((_binocType isEqualType []) && {(count _binocType) >= 2} && {(toLower (_binocType select 1)) isEqualTo "binocular"}) then {
                    _resultCode = "ERR_BINOCULAR_INVALID";
                    _resultMessage = format ["Saved binocular class '%1' is invalid.", _binocClass];
                };
            };
        };

        if !(_resultCode isEqualTo "OK") exitWith {
            [_resultCode, _resultMessage, _baseLoadoutId] call _resultFail
        };

        // Validate container cargo entries.
        {
            if (_resultCode isEqualTo "OK") then {
                private _containerIndex = _x;
                private _containerSlot = _mutatedLoadout select _containerIndex;

                if ((_containerSlot isEqualType []) && {(count _containerSlot) > 1}) then {
                    private _containerCargo = [_containerSlot select 1] call _sanitizeContainerCargo;

                    {
                        if (_resultCode isEqualTo "OK") then {
                            private _entryClass = toLower (_x select 0);
                            private _entryCount = _x select 1;

                            if !(_entryCount isEqualType 0) then {
                                _resultCode = "ERR_CARGO_ENTRY_COUNT_TYPE";
                                _resultMessage = format ["Saved cargo entry '%1' has invalid count type.", _entryClass];
                            } else {
                                if ((_entryCount < 0) || {_entryCount > 20}) then {
                                    _resultCode = "ERR_CARGO_ENTRY_COUNT_RANGE";
                                    _resultMessage = format ["Saved cargo entry '%1' count %2 is outside allowed range.", _entryClass, _entryCount];
                                } else {
                                    if (_entryCount > 0) then {
                                        private _cargoClassCheck = [_entryClass, _mutatedLoadout] call _validateCargoClass;
                                        if !(_cargoClassCheck getOrDefault ["success", false]) then {
                                            _resultCode = _cargoClassCheck getOrDefault ["code", "ERR_CARGO_CLASS_UNKNOWN"];
                                            _resultMessage = _cargoClassCheck getOrDefault ["message", "Saved cargo class validation failed."];
                                        };
                                    };
                                };
                            };
                        };
                    } forEach _containerCargo;
                };
            };
        } forEach [3, 4, 5];

        if !(_resultCode isEqualTo "OK") exitWith {
            [_resultCode, _resultMessage, _baseLoadoutId] call _resultFail
        };

        _resultMessage = format ["Session kit '%1' loaded and revalidated.", _slotId];
    };

    case "set_binocular": {
        private _binocularClassRaw = _mutation getOrDefault ["binocularClass", "UNSET"];
        if !(_binocularClassRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_binocular requires binocularClass as a string.", _baseLoadoutId] call _resultFail
        };

        private _binocularClass = toLower _binocularClassRaw;

        if (_binocularClass isEqualTo "") then {
            private _baselineBinoc = _mutatedLoadout select 8;
            private _emptyBinoc = if (_baselineBinoc isEqualType []) then {[]} else {""};
            _mutatedLoadout set [8, _emptyBinoc];
            _resultMessage = "Binocular slot cleared.";
        } else {
            if !(isClass (_sourceItemsCfg >> _binocularClass)) exitWith {
                ["ERR_BINOCULAR_NOT_CANONICAL", format ["Binocular '%1' is not present in canonical source items.", _binocularClass], _baseLoadoutId] call _resultFail
            };

            private _itemType = [_binocularClass] call BIS_fnc_itemType;
            if !((_itemType isEqualType []) && {(count _itemType) >= 2} && {(toLower (_itemType select 1)) isEqualTo "binocular"}) exitWith {
                ["ERR_BINOCULAR_INVALID", format ["Class '%1' is not a binocular item.", _binocularClass], _baseLoadoutId] call _resultFail
            };

            _mutatedLoadout set [8, _binocularClass];
            _resultMessage = "Binocular slot updated.";
        };
    };

    case "set_assigned": {
        private _assignedIndexRaw = _mutation getOrDefault ["assignedIndex", -1];
        if !(_assignedIndexRaw isEqualType 0) exitWith {
            ["ERR_MALFORMED_REQUEST", "set_assigned requires assignedIndex as an integer.", _baseLoadoutId] call _resultFail
        };

        private _assignedIndex = _assignedIndexRaw;
        if !(_assignedIndex in [0, 1, 2, 3, 4, 5]) exitWith {
            ["ERR_MALFORMED_REQUEST", "assignedIndex must be between 0 and 5.", _baseLoadoutId] call _resultFail
        };

        private _itemClassRaw = _mutation getOrDefault ["itemClass", "UNSET"];
        if !(_itemClassRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_assigned requires itemClass as a string.", _baseLoadoutId] call _resultFail
        };

        private _itemClass = toLower _itemClassRaw;
        private _assignedCheck = [_assignedIndex, _itemClass] call _validateAssignedClassForIndex;
        if !(_assignedCheck getOrDefault ["success", false]) exitWith {
            [
                _assignedCheck getOrDefault ["code", "ERR_ASSIGNED_ITEM_SLOT_MISMATCH"],
                _assignedCheck getOrDefault ["message", "Assigned item validation failed."],
                _baseLoadoutId
            ] call _resultFail
        };

        private _assignedItems = _mutatedLoadout select 9;
        if !(_assignedItems isEqualType []) then {
            _assignedItems = [];
        };
        while {(count _assignedItems) < 6} do {
            _assignedItems pushBack "";
        };

        _assignedItems set [_assignedIndex, _itemClass];
        _mutatedLoadout set [9, _assignedItems];
        _resultMessage = format ["Assigned equipment slot %1 updated.", _assignedIndex];
    };

    case "set_attachment": {
        private _weaponSlotRaw = _mutation getOrDefault ["weaponSlot", ""];
        private _attachmentClassRaw = _mutation getOrDefault ["attachmentClass", ""];
        private _attachmentModeRaw = _mutation getOrDefault ["mode", "add"];

        if !(_weaponSlotRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment requires weaponSlot as a string.", _baseLoadoutId] call _resultFail
        };
        if !(_attachmentClassRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment requires attachmentClass as a string.", _baseLoadoutId] call _resultFail
        };
        if !(_attachmentModeRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment requires mode as a string.", _baseLoadoutId] call _resultFail
        };

        private _weaponSlot = toLower _weaponSlotRaw;
        private _attachmentClass = toLower _attachmentClassRaw;
        private _attachmentMode = toLower _attachmentModeRaw;

        if !(_weaponSlot in ["primary", "launcher", "handgun"]) exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment weaponSlot must be primary, launcher, or handgun.", _baseLoadoutId] call _resultFail
        };

        if (_attachmentClass isEqualTo "") exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment attachmentClass must be non-empty.", _baseLoadoutId] call _resultFail
        };

        if !(_attachmentMode in ["add", "remove"]) exitWith {
            ["ERR_MALFORMED_REQUEST", "set_attachment mode must be add or remove.", _baseLoadoutId] call _resultFail
        };

        if !(isClass (_sourceItemsCfg >> _attachmentClass)) exitWith {
            ["ERR_UNKNOWN_ATTACHMENT", format ["Attachment '%1' is not present in canonical source items.", _attachmentClass], _baseLoadoutId] call _resultFail
        };

        private _slotIndex = switch (_weaponSlot) do {
            case "primary": {0};
            case "launcher": {1};
            default {2};
        };

        private _slotToken = switch (_weaponSlot) do {
            case "primary": {"PRIMARY"};
            case "launcher": {"LAUNCHER"};
            default {"HANDGUN"};
        };

        private _slotLabel = switch (_weaponSlot) do {
            case "primary": {"Primary"};
            case "launcher": {"Launcher"};
            default {"Handgun"};
        };

        private _extractResult = [
            _mutatedLoadout select _slotIndex,
            _slotToken,
            _slotLabel
        ] call _extractWeaponComposition;

        if !(_extractResult getOrDefault ["success", false]) exitWith {
            [
                _extractResult getOrDefault ["code", "ERR_LOADOUT_SLOT_SHAPE"],
                _extractResult getOrDefault ["message", "Attachment request could not resolve current weapon slot."],
                _baseLoadoutId
            ] call _resultFail
        };

        private _composition = _extractResult getOrDefault ["composition", createHashMap];
        if (_composition getOrDefault ["isEmpty", false]) exitWith {
            ["ERR_WEAPON_SLOT_EMPTY", format ["Cannot change attachment: %1 slot is empty.", toLower _slotLabel], _baseLoadoutId] call _resultFail
        };

        private _attachments = +(_composition getOrDefault ["attachments", []]);
        if (_attachmentMode isEqualTo "add") then {
            _attachments pushBackUnique _attachmentClass;
        } else {
            _attachments = _attachments - [_attachmentClass];
        };
        _attachments sort true;

        private _compositionResult = [
            createHashMapFromArray [
                ["weaponClass", _composition getOrDefault ["baseWeaponClass", ""]],
                ["magazines", _composition getOrDefault ["magazines", []]],
                ["attachments", _attachments]
            ],
            _compatibilityCfg,
            _slotToken,
            _slotLabel
        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

        if !(_compositionResult getOrDefault ["success", false]) exitWith {
            [
                _compositionResult getOrDefault ["code", "ERR_WEAPON_COMPOSITION"],
                _compositionResult getOrDefault ["message", "Attachment request failed compatibility validation."],
                _baseLoadoutId
            ] call _resultFail
        };

        private _buildResult = [
            _assignedSide,
            createHashMapFromArray [[_weaponSlot, _compositionResult getOrDefault ["validatedWeapon", createHashMap]]],
            _mutatedLoadout
        ] call bn_koth_fnc_loadouts_buildValidatedLoadout;

        if !(_buildResult getOrDefault ["success", false]) exitWith {
            [
                _buildResult getOrDefault ["code", "ERR_LOADOUT_BUILD"],
                _buildResult getOrDefault ["message", "Attachment request could not be built into a complete loadout."],
                _buildResult getOrDefault ["loadoutId", _baseLoadoutId]
            ] call _resultFail
        };

        _mutatedLoadout = _buildResult getOrDefault ["loadout", []];
        _resultMessage = format ["%1 attachment updated.", _slotLabel];
    };

    case "adjust_cargo": {
        private _containerRaw = _mutation getOrDefault ["container", ""];
        private _classRaw = _mutation getOrDefault ["className", ""];
        private _deltaRaw = _mutation getOrDefault ["delta", 0];

        if !(_containerRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo requires container as a string.", _baseLoadoutId] call _resultFail
        };
        if !(_classRaw isEqualType "") exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo requires className as a string.", _baseLoadoutId] call _resultFail
        };
        if !(_deltaRaw isEqualType 0) exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo requires delta as an integer.", _baseLoadoutId] call _resultFail
        };

        private _container = toLower _containerRaw;
        private _className = toLower _classRaw;
        private _delta = _deltaRaw;

        if !(_container in ["uniform", "vest", "backpack"]) exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo container must be uniform, vest, or backpack.", _baseLoadoutId] call _resultFail
        };

        if (_className isEqualTo "") exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo className must be non-empty.", _baseLoadoutId] call _resultFail
        };

        if (_delta isEqualTo 0) exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo delta must be non-zero.", _baseLoadoutId] call _resultFail
        };

        if ((abs _delta) > 20) exitWith {
            ["ERR_MALFORMED_REQUEST", "adjust_cargo delta magnitude must be <= 20.", _baseLoadoutId] call _resultFail
        };

        private _containerIndex = switch (_container) do {
            case "uniform": {3};
            case "vest": {4};
            default {5};
        };

        private _containerSlot = _mutatedLoadout select _containerIndex;
        if !((_containerSlot isEqualType []) && {(count _containerSlot) >= 2}) exitWith {
            ["ERR_CONTAINER_MISSING", format ["Container '%1' does not exist on intended loadout.", _container], _baseLoadoutId] call _resultFail
        };

        private _containerClass = toLower (_containerSlot select 0);
        if (_containerClass isEqualTo "") exitWith {
            ["ERR_CONTAINER_MISSING", format ["Container '%1' class is empty.", _container], _baseLoadoutId] call _resultFail
        };

        private _containerCargo = _containerSlot select 1;
        if !(_containerCargo isEqualType []) then {
            _containerCargo = [];
        };

        _containerCargo = [_containerCargo] call _sanitizeContainerCargo;

        private _classCheck = [_className, _mutatedLoadout] call _validateCargoClass;
        if !(_classCheck getOrDefault ["success", false]) exitWith {
            [
                _classCheck getOrDefault ["code", "ERR_CARGO_CLASS_UNKNOWN"],
                _classCheck getOrDefault ["message", "Cargo class validation failed."],
                _baseLoadoutId
            ] call _resultFail
        };

        private _kind = _classCheck getOrDefault ["kind", ""];
        private _ammoCount = _classCheck getOrDefault ["ammoCount", 0];

        private _existingCount = 0;
        {
            private _entryClass = toLower (_x select 0);
            if (_entryClass isEqualTo _className) then {
                if ((_kind isEqualTo "magazine") && {(count _x) >= 3}) then {
                    _existingCount = _existingCount + (_x select 1);
                };
                if ((_kind isEqualTo "item") && {(count _x) == 2}) then {
                    _existingCount = _existingCount + (_x select 1);
                };
            };
        } forEach _containerCargo;

        private _newCount = _existingCount + _delta;
        if (_newCount < 0) then {
            _newCount = 0;
        };
        if (_newCount > 20) then {
            _newCount = 20;
        };

        _containerCargo = _containerCargo select {toLower (_x select 0) != _className};

        if (_newCount > 0) then {
            if (_kind isEqualTo "magazine") then {
                _containerCargo pushBack [_className, _newCount, _ammoCount];
            } else {
                _containerCargo pushBack [_className, _newCount];
            };
        };

        private _capacityCheck = createHashMapFromArray [
            ["success", true],
            ["code", "OK"],
            ["message", "Container capacity check not required for removal."]
        ];

        if (_delta > 0) then {
            _capacityCheck = [
                _container,
                _containerClass,
                _containerCargo
            ] call _validateContainerCapacity;
        };

        // IMPORTANT: this exitWith is at the adjust_cargo case scope.
        // A nested exitWith inside the _delta > 0 block only exits that block
        // and the mutation would continue applying the overloaded cargo.
        if !(_capacityCheck getOrDefault ["success", false]) exitWith {
            [
                _capacityCheck getOrDefault ["code", "ERR_CONTAINER_CAPACITY_EXCEEDED"],
                _capacityCheck getOrDefault ["message", "Container capacity validation failed."],
                _baseLoadoutId
            ] call _resultFail
        };

        _containerSlot set [1, _containerCargo];
        _mutatedLoadout set [_containerIndex, _containerSlot];
        _resultMessage = format ["Cargo updated: %1 %2 (%3).", _container, _className, _newCount];
    };

    default {
        ["ERR_MALFORMED_REQUEST", format ["Unsupported mutation op '%1'.", _op], _baseLoadoutId] call _resultFail
    };
};

if !((_mutatedLoadout isEqualType []) && {(count _mutatedLoadout) >= 10}) exitWith {
    ["ERR_MUTATED_LOADOUT_SHAPE", "Mutated loadout shape is invalid.", _baseLoadoutId] call _resultFail
};

createHashMapFromArray [
    ["success", true],
    ["code", _resultCode],
    ["message", _resultMessage],
    ["loadoutId", _baseLoadoutId],
    ["sideToken", _authoritativeSideToken],
    ["validatedLoadout", +_mutatedLoadout],
    ["validatedPrimary", createHashMap],
    ["validatedWeapons", createHashMap],
    ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"],
    ["shouldApply", _shouldApply],
    ["savedSlotId", _slotId],
    ["mutationOp", _op]
]

/*
    File: fn_validateLoadout.sqf
    Author: Legend
    Description: Server-authoritative validation for configured loadouts and weapon composition requests.
    Execution: Server
    Parameters:
        0: Requesting player object <OBJECT>
        1: Loadout request <HASHMAP|ARRAY>
           HASHMAP schema (exactly one intent):
             loadoutId <STRING>
             primary <HASHMAP> (legacy single-slot composition)
             weapons <HASHMAP> (primary/launcher/handgun slot maps)
             side <STRING> (optional, cross-check only)
    Returns:
        Validation result <HASHMAP>
    Public: Yes
*/

params [
    ["_player", objNull, [objNull]],
    ["_request", createHashMap, [createHashMap, []]]
];

private _fail = {
    params ["_code", "_message", ["_loadoutId", "", [""]], ["_sideToken", "", [""]]];

    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message],
        ["loadoutId", _loadoutId],
        ["sideToken", _sideToken],
        ["validatedLoadout", []],
        ["validatedPrimary", createHashMap],
        ["validatedWeapons", createHashMap],
        ["validatedBy", ""]
    ]
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Loadout validation must run on server."] call _fail
};

if (isNull _player || {!isPlayer _player}) exitWith {
    ["ERR_INVALID_PLAYER", "Loadout validation requires a connected player object."] call _fail
};

private _requestedLoadoutId = "";
private _requestedLoadoutIdRaw = objNull;
private _requestedSideRaw = "";
private _requestedSideToken = "";
private _primaryRequest = createHashMap;
private _weaponsRequest = createHashMap;
private _hasLoadoutIntent = false;
private _hasPrimaryIntent = false;
private _hasWeaponsIntent = false;
private _requestMode = "";

if (_request isEqualType createHashMap) then {
    private _requestKeys = keys _request;
    _hasLoadoutIntent = "loadoutId" in _requestKeys;
    if (_hasLoadoutIntent) then {
        _requestedLoadoutIdRaw = _request get "loadoutId";
    };
    _requestedSideRaw = _request getOrDefault ["side", ""];
    _hasPrimaryIntent = "primary" in _requestKeys;
    if (_hasPrimaryIntent) then {
        _primaryRequest = _request getOrDefault ["primary", objNull];
    };
    _hasWeaponsIntent = "weapons" in _requestKeys;
    if (_hasWeaponsIntent) then {
        _weaponsRequest = _request getOrDefault ["weapons", objNull];
    };
} else {
    if ((_request isEqualType []) && {(count _request) > 0}) then {
        _hasLoadoutIntent = true;
        _requestedLoadoutIdRaw = _request select 0;
    };
};

if !(_requestedSideRaw isEqualType "") exitWith {
    ["ERR_MALFORMED_REQUEST", "Requested side must be a string."] call _fail
};

_requestedSideToken = toUpper _requestedSideRaw;

private _intentCount =
    (if (_hasLoadoutIntent) then {1} else {0}) +
    (if (_hasPrimaryIntent) then {1} else {0}) +
    (if (_hasWeaponsIntent) then {1} else {0});

if (_intentCount != 1) exitWith {
    ["ERR_MALFORMED_REQUEST", "Loadout request must choose exactly one mode: loadoutId, primary, or weapons."] call _fail
};

if (_hasPrimaryIntent) then {
    _requestMode = "primary";
} else {
    if (_hasWeaponsIntent) then {
        _requestMode = "weapons";
    } else {
        _requestMode = "configured";
    };
};

if ((_requestMode isEqualTo "primary") && {!(_primaryRequest isEqualType createHashMap)}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Primary validation request must provide primary as a map."] call _fail
};

if ((_requestMode isEqualTo "weapons") && {!(_weaponsRequest isEqualType createHashMap)}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Weapons validation request must provide weapons as a map."] call _fail
};

if ((_requestMode isEqualTo "configured") && {!(_requestedLoadoutIdRaw isEqualType "")}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Configured loadout request requires loadoutId as a non-empty string."] call _fail
};

if ((_requestMode isEqualTo "configured") && {_requestedLoadoutIdRaw isEqualTo ""}) exitWith {
    ["ERR_MALFORMED_REQUEST", "Configured loadout request requires loadoutId as a non-empty string."] call _fail
};

if (_requestMode isEqualTo "configured") then {
    _requestedLoadoutId = toLower _requestedLoadoutIdRaw;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["ERR_RECORDS_UNAVAILABLE", "Player records are unavailable.", _requestedLoadoutId] call _fail
};

private _uid = getPlayerUID _player;
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    ["ERR_PLAYER_NOT_REGISTERED", "Player is not registered in authoritative team records.", _requestedLoadoutId] call _fail
};

private _authoritativeBaselineLoadout = [];
private _authoritativeBaselineSideToken = "";

private _loadoutStateByUid = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
if (_loadoutStateByUid isEqualType createHashMap) then {
    private _loadoutState = _loadoutStateByUid getOrDefault [_uid, createHashMap];

    if (_loadoutState isEqualType createHashMap) then {
        _authoritativeBaselineLoadout = _loadoutState getOrDefault ["intendedLoadout", []];
        if !(_authoritativeBaselineLoadout isEqualType []) then {
            _authoritativeBaselineLoadout = [];
        };

        _authoritativeBaselineSideToken = toUpper (_loadoutState getOrDefault ["sideToken", ""]);
    };
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    ["ERR_ASSIGNED_SIDE_INVALID", "Player does not have a valid assigned playable side.", _requestedLoadoutId] call _fail
};

private _authoritativeSideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    case resistance: {"RESISTANCE"};
    case civilian: {"CIVILIAN"};
    default {""};
};

if (_authoritativeSideToken isEqualTo "") exitWith {
    ["ERR_SIDE_TOKEN_UNMAPPED", "Assigned side does not map to a supported side token.", _requestedLoadoutId] call _fail
};

if !(_authoritativeBaselineSideToken isEqualTo _authoritativeSideToken) then {
    _authoritativeBaselineLoadout = [];
};

if (
    !(_requestedSideToken isEqualTo "") &&
    {!(_requestedSideToken isEqualTo _authoritativeSideToken)}
) exitWith {
    [
        "ERR_REQUEST_SIDE_MISMATCH",
        format [
            "Requested side '%1' does not match authoritative assigned side '%2'.",
            _requestedSideToken,
            _authoritativeSideToken
        ],
        _requestedLoadoutId,
        _authoritativeSideToken
    ] call _fail
};

private _definitions = missionNamespace getVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
if !(_definitions isEqualType createHashMap) then {
    _definitions = createHashMap;
};

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = if (isClass _settingsCfg) then {
    getText (_settingsCfg >> "catalogueClass")
} else {
    "CfgBnKothArsenal"
};
if (_catalogueClass isEqualTo "") then {
    _catalogueClass = "CfgBnKothArsenal";
};

private _arsenalCfg = missionConfigFile >> _catalogueClass;
if !(isClass _arsenalCfg) exitWith {
    ["ERR_CATALOGUE_MISSING", format ["Canonical arsenal config class '%1' is missing.", _catalogueClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";
if !(_requestMode isEqualTo "configured") then {
    if !(isClass _compatibilityCfg) exitWith {
        ["ERR_COMPATIBILITY_MISSING", "Weapon composition validation requires canonical compatibility config.", _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

if (_requestMode isEqualTo "primary") exitWith {
    private _compositionResult = [
        _primaryRequest,
        _compatibilityCfg,
        "PRIMARY",
        "Primary"
    ] call bn_koth_fnc_loadouts_validateWeaponComposition;

    if !(_compositionResult getOrDefault ["success", false]) exitWith {
        [
            _compositionResult getOrDefault ["code", "ERR_WEAPON_COMPOSITION"],
            _compositionResult getOrDefault ["message", "Primary weapon composition validation failed."],
            _requestedLoadoutId,
            _authoritativeSideToken
        ] call _fail
    };

    private _validatedPrimary = _compositionResult getOrDefault [
        "validatedWeapon",
        createHashMap
    ];

    private _validatedWeapons = createHashMapFromArray [
        ["primary", _validatedPrimary]
    ];

    private _buildResult = [
        _assignedSide,
        _validatedWeapons,
        _authoritativeBaselineLoadout
    ] call bn_koth_fnc_loadouts_buildValidatedLoadout;

    if !(_buildResult getOrDefault ["success", false]) exitWith {
        [
            _buildResult getOrDefault ["code", "ERR_LOADOUT_BUILD"],
            _buildResult getOrDefault ["message", "Validated primary weapon could not be built into a complete loadout."],
            _buildResult getOrDefault ["loadoutId", ""],
            _authoritativeSideToken
        ] call _fail
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Primary composition request validated and built."],
        ["loadoutId", _buildResult getOrDefault ["loadoutId", ""]],
        ["sideToken", _authoritativeSideToken],
        ["validatedLoadout", _buildResult getOrDefault ["loadout", []]],
        ["validatedPrimary", _validatedPrimary],
        ["validatedWeapons", _validatedWeapons],
        ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
    ]
};


if (_requestMode isEqualTo "weapons") exitWith {
    private _slotKeys = keys _weaponsRequest;
    private _supportedSlots = ["primary", "launcher", "handgun", "uniform"];
    private _unknownSlotIndex = _slotKeys findIf {!(_x in _supportedSlots)};

    if (_unknownSlotIndex >= 0) exitWith {
        [
            "ERR_MALFORMED_REQUEST",
            format ["Weapons request contains unsupported slot '%1'.", _slotKeys select _unknownSlotIndex],
            _requestedLoadoutId,
            _authoritativeSideToken
        ] call _fail
    };

    if ((count _slotKeys) <= 0) exitWith {
        [
            "ERR_MALFORMED_REQUEST",
            "Weapons request must contain at least one of: primary, launcher, handgun, uniform.",
            _requestedLoadoutId,
            _authoritativeSideToken
        ] call _fail
    };

    private _validatedWeapons = createHashMap;
    private _slotFailure = createHashMap;

    private _validateSlot = {
        params ["_slotName", "_slotToken", "_slotLabel"];

        private _slotRequest = _weaponsRequest getOrDefault [_slotName, objNull];
        if !(_slotRequest isEqualType createHashMap) exitWith {
            createHashMapFromArray [
                ["success", false],
                ["code", "ERR_MALFORMED_REQUEST"],
                ["message", format ["Weapons.%1 must be a map.", _slotName]]
            ]
        };

        [
            _slotRequest,
            _compatibilityCfg,
            _slotToken,
            _slotLabel
        ] call bn_koth_fnc_loadouts_validateWeaponComposition
    };

    if ("primary" in _slotKeys) then {
        private _primaryResult = ["primary", "PRIMARY", "Primary"] call _validateSlot;
        if (_primaryResult getOrDefault ["success", false]) then {
            _validatedWeapons set ["primary", _primaryResult getOrDefault ["validatedWeapon", createHashMap]];
        } else {
            _slotFailure = _primaryResult;
        };
    };

    if (((count _slotFailure) isEqualTo 0) && {"launcher" in _slotKeys}) then {
        private _launcherRequest = _weaponsRequest getOrDefault ["launcher", objNull];
        if !(_launcherRequest isEqualType createHashMap) then {
            _slotFailure = createHashMapFromArray [
                ["success", false],
                ["code", "ERR_MALFORMED_REQUEST"],
                ["message", "Weapons.launcher must be a map."]
            ];
        } else {
            private _launcherClassRaw = _launcherRequest getOrDefault ["weaponClass", ""];
            if !(_launcherClassRaw isEqualType "") then {
                _slotFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_MALFORMED_REQUEST"],
                    ["message", "Launcher weaponClass must be a string."]
                ];
            } else {
                private _launcherClass = toLower _launcherClassRaw;
                if (_launcherClass isEqualTo "") then {
                    private _launcherMags = _launcherRequest getOrDefault ["magazines", []];
                    private _launcherAttachments = _launcherRequest getOrDefault ["attachments", []];

                    if !((_launcherMags isEqualType []) && {_launcherAttachments isEqualType []}) then {
                        _slotFailure = createHashMapFromArray [
                            ["success", false],
                            ["code", "ERR_MALFORMED_REQUEST"],
                            ["message", "Launcher clear intent requires magazines/attachments arrays."]
                        ];
                    } else {
                        if ((count _launcherMags) > 0 || {(count _launcherAttachments) > 0}) then {
                            _slotFailure = createHashMapFromArray [
                                ["success", false],
                                ["code", "ERR_MALFORMED_REQUEST"],
                                ["message", "Launcher clear intent must not provide magazines or attachments."]
                            ];
                        } else {
                            _validatedWeapons set ["launcher", createHashMapFromArray [["clear", true]]];
                        };
                    };
                } else {
                    private _launcherResult = ["launcher", "LAUNCHER", "Launcher"] call _validateSlot;
                    if (_launcherResult getOrDefault ["success", false]) then {
                        _validatedWeapons set ["launcher", _launcherResult getOrDefault ["validatedWeapon", createHashMap]];
                    } else {
                        _slotFailure = _launcherResult;
                    };
                };
            };
        };
    };

    if (((count _slotFailure) isEqualTo 0) && {"handgun" in _slotKeys}) then {
        private _handgunResult = ["handgun", "HANDGUN", "Handgun"] call _validateSlot;
        if (_handgunResult getOrDefault ["success", false]) then {
            _validatedWeapons set ["handgun", _handgunResult getOrDefault ["validatedWeapon", createHashMap]];
        } else {
            _slotFailure = _handgunResult;
        };
    };

    if (((count _slotFailure) isEqualTo 0) && {"uniform" in _slotKeys}) then {
        private _uniformRequest = _weaponsRequest getOrDefault ["uniform", objNull];
        if !(_uniformRequest isEqualType createHashMap) then {
            _slotFailure = createHashMapFromArray [
                ["success", false],
                ["code", "ERR_MALFORMED_REQUEST"],
                ["message", "Weapons.uniform must be a map."]
            ];
        } else {
            private _uniformClassRaw = _uniformRequest getOrDefault ["uniformClass", ""];

            if !(_uniformClassRaw isEqualType "") then {
                _slotFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_MALFORMED_REQUEST"],
                    ["message", "Uniform uniformClass must be a string."]
                ];
            } else {
                private _uniformClass = toLower _uniformClassRaw;

                if (_uniformClass isEqualTo "") then {
                    _slotFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_MALFORMED_REQUEST"],
                        ["message", "Uniform uniformClass must be non-empty."]
                    ];
                } else {
                    if !((_uniformClass find "vn_") isEqualTo 0) then {
                        _slotFailure = createHashMapFromArray [
                            ["success", false],
                            ["code", "ERR_UNIFORM_NOT_CANONICAL"],
                            ["message", format ["Uniform '%1' is not a canonical S.O.G. uniform class.", _uniformClass]]
                        ];
                    } else {
                        private _uniformCfg = configFile >> "CfgWeapons" >> _uniformClass;

                        if !(isClass _uniformCfg) then {
                            _slotFailure = createHashMapFromArray [
                                ["success", false],
                                ["code", "ERR_UNIFORM_CONFIG_MISSING"],
                                ["message", format ["Uniform '%1' is missing from CfgWeapons.", _uniformClass]]
                            ];
                        } else {
                            if ((getNumber (_uniformCfg >> "scope")) < 2) then {
                                _slotFailure = createHashMapFromArray [
                                    ["success", false],
                                    ["code", "ERR_UNIFORM_NOT_PUBLIC"],
                                    ["message", format ["Uniform '%1' is not publicly available.", _uniformClass]]
                                ];
                            } else {
                                private _uniformItemInfoCfg = _uniformCfg >> "ItemInfo";

                                if !(isClass _uniformItemInfoCfg) then {
                                    _slotFailure = createHashMapFromArray [
                                        ["success", false],
                                        ["code", "ERR_UNIFORM_ITEMINFO_MISSING"],
                                        ["message", format ["Uniform '%1' is missing ItemInfo metadata.", _uniformClass]]
                                    ];
                                } else {
                                    if !((getNumber (_uniformItemInfoCfg >> "type")) isEqualTo 801) then {
                                        _slotFailure = createHashMapFromArray [
                                            ["success", false],
                                            ["code", "ERR_UNIFORM_ITEMINFO_INVALID"],
                                            ["message", format ["Class '%1' is not a uniform item.", _uniformClass]]
                                        ];
                                    } else {
                                        _validatedWeapons set [
                                            "uniform",
                                            createHashMapFromArray [["uniformClass", _uniformClass]]
                                        ];
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };

    if ((count _slotFailure) > 0) exitWith {
        [
            _slotFailure getOrDefault ["code", "ERR_WEAPON_COMPOSITION"],
            _slotFailure getOrDefault ["message", "Weapon composition validation failed."],
            _requestedLoadoutId,
            _authoritativeSideToken
        ] call _fail
    };

    private _buildResult = [
        _assignedSide,
        _validatedWeapons,
        _authoritativeBaselineLoadout
    ] call bn_koth_fnc_loadouts_buildValidatedLoadout;

    if !(_buildResult getOrDefault ["success", false]) exitWith {
        [
            _buildResult getOrDefault ["code", "ERR_LOADOUT_BUILD"],
            _buildResult getOrDefault ["message", "Validated weapon composition could not be built into a complete loadout."],
            _buildResult getOrDefault ["loadoutId", ""],
            _authoritativeSideToken
        ] call _fail
    };

    createHashMapFromArray [
        ["success", true],
        ["code", "OK"],
        ["message", "Weapon composition request validated and built."],
        ["loadoutId", _buildResult getOrDefault ["loadoutId", ""]],
        ["sideToken", _authoritativeSideToken],
        ["validatedLoadout", _buildResult getOrDefault ["loadout", []]],
        ["validatedPrimary", _validatedWeapons getOrDefault ["primary", createHashMap]],
        ["validatedWeapons", _validatedWeapons],
        ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
    ]
};

private _definition = _definitions getOrDefault [_requestedLoadoutId, objNull];
if !(_definition isEqualType createHashMap) exitWith {
    ["ERR_UNKNOWN_LOADOUT", format ["Loadout '%1' is not configured in canonical catalogue.", _requestedLoadoutId], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _loadoutSideToken = _definition getOrDefault ["sideToken", ""];
if !(_loadoutSideToken isEqualTo _authoritativeSideToken) exitWith {
    ["ERR_SIDE_RESTRICTED", format ["Loadout '%1' is restricted to side '%2'.", _requestedLoadoutId, _loadoutSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _itemsCfg = _arsenalCfg >> "Equipment" >> "Items";
private _unitClass = _definition getOrDefault ["unitClass", ""];

if !(_unitClass isEqualTo "") then {
    if !(isClass (_itemsCfg >> _unitClass)) exitWith {
        ["ERR_CATALOGUE_ITEM_MISSING", format ["Template unit class '%1' is not present in canonical equipment items.", _unitClass], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };

    private _allowedSides = getArray ((_itemsCfg >> _unitClass) >> "allowedSides");
    if ((count _allowedSides) > 0 && {!(_authoritativeSideToken in _allowedSides)}) exitWith {
        ["ERR_ITEM_SIDE_RESTRICTED", format ["Template unit class '%1' is not allowed for side '%2'.", _unitClass, _authoritativeSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

private _validatedLoadout = _definition getOrDefault ["loadout", []];
if !(_validatedLoadout isEqualType []) then {
    _validatedLoadout = [];
};

if ((count _validatedLoadout) <= 0) exitWith {
    ["ERR_LOADOUT_EMPTY", format ["Loadout '%1' resolved empty.", _requestedLoadoutId], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

// Deliberate future boundary:
// progression entitlement will be checked here via an explicit registered
// progression API function owned by functions/progression when implemented.

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", "Loadout request validated."],
    ["loadoutId", _requestedLoadoutId],
    ["sideToken", _authoritativeSideToken],
    ["validatedLoadout", _validatedLoadout],
    ["validatedPrimary", createHashMap],
    ["validatedWeapons", createHashMap],
    ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
]

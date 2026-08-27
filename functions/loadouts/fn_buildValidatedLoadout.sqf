/*
    File: fn_buildValidatedLoadout.sqf
    Author: Legend
    Description: Builds a complete canonical Unit Loadout Array by applying validated weapon/uniform slots to the authoritative side starter loadout.
    Execution: Server
    Parameters:
        0: Authoritative player side <SIDE>
        1: validatedWeapons map produced by bn_koth_fnc_loadouts_validateLoadout <HASHMAP>
        2: Optional authoritative baseline loadout array <ARRAY>
    Returns:
        Build result <HASHMAP>
    Public: No
*/

params [
    ["_side", sideUnknown, [sideUnknown]],
    ["_validatedWeapons", createHashMap, [createHashMap]],
    ["_baselineLoadout", [], [[]]]
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

private _baseLoadout = +_starterLoadout;
if ((_baselineLoadout isEqualType []) && {(count _baselineLoadout) >= 10}) then {
    _baseLoadout = +_baselineLoadout;
};

// Apply only validated requested slots to the authoritative baseline. Slots
// absent from the validated map remain untouched.
private _builtLoadout = +_baseLoadout;

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
            private _slotPayload = _validatedWeapons get _slotName;

            if (
                (_slotName isEqualTo "launcher") &&
                (_slotPayload isEqualType createHashMap) &&
                {_slotPayload getOrDefault ["clear", false]}
            ) then {
                private _baselineLauncher = _builtLoadout select _loadoutIndex;
                private _clearedLauncher = if ((_baselineLauncher isEqualType []) && {(count _baselineLauncher) >= 7}) then {
                    ["", "", "", "", [], [], ""]
                } else {
                    []
                };

                _builtLoadout set [_loadoutIndex, _clearedLauncher];
            } else {
                private _slotResult = [
                    _slotName,
                    _slotPayload
                ] call bn_koth_fnc_loadouts_buildWeaponSlot;

                if (_slotResult getOrDefault ["success", false]) then {
                    _builtLoadout set [_loadoutIndex, _slotResult getOrDefault ["slot", []]];
                } else {
                    _buildFailure = _slotResult;
                };
            };
        };
    };
} forEach _slotDefinitions;

if (((count _buildFailure) isEqualTo 0) && {"uniform" in _validatedWeaponKeys}) then {
    private _uniformPayload = _validatedWeapons get "uniform";

    if !(_uniformPayload isEqualType createHashMap) then {
        _buildFailure = createHashMapFromArray [
            ["success", false],
            ["code", "ERR_VALIDATED_UNIFORM_TYPE"],
            ["message", "Validated uniform payload must be a hashmap."]
        ];
    } else {
        private _uniformClass = _uniformPayload getOrDefault ["uniformClass", ""];

        if !(_uniformClass isEqualType "") then {
            _buildFailure = createHashMapFromArray [
                ["success", false],
                ["code", "ERR_VALIDATED_UNIFORM_CLASS_TYPE"],
                ["message", "Validated uniformClass must be a string."]
            ];
        } else {
            if (_uniformClass isEqualTo "") then {
                _buildFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_VALIDATED_UNIFORM_CLASS_EMPTY"],
                    ["message", "Validated uniformClass is empty."]
                ];
            } else {
                private _uniformCfg = configFile >> "CfgWeapons" >> _uniformClass;
                if !(isClass _uniformCfg) then {
                    _buildFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_UNIFORM_CONFIG_MISSING"],
                        ["message", format ["Validated uniform '%1' is missing from CfgWeapons.", _uniformClass]]
                    ];
                } else {
                    private _existingUniformSlot = _builtLoadout select 3;
                    private _uniformCargo = [];

                    if ((_existingUniformSlot isEqualType []) && {(count _existingUniformSlot) > 1}) then {
                        _uniformCargo = _existingUniformSlot select 1;
                        if !(_uniformCargo isEqualType []) then {
                            _uniformCargo = [];
                        };
                    };

                    _builtLoadout set [3, [_uniformClass, _uniformCargo]];
                };
            };
        };
    };
};

if (((count _buildFailure) isEqualTo 0) && {"vest" in _validatedWeaponKeys}) then {
    private _vestPayload = _validatedWeapons get "vest";

    if !(_vestPayload isEqualType createHashMap) then {
        _buildFailure = createHashMapFromArray [
            ["success", false],
            ["code", "ERR_VALIDATED_VEST_TYPE"],
            ["message", "Validated vest payload must be a hashmap."]
        ];
    } else {
        private _vestClass = _vestPayload getOrDefault ["vestClass", ""];

        if !(_vestClass isEqualType "") then {
            _buildFailure = createHashMapFromArray [
                ["success", false],
                ["code", "ERR_VALIDATED_VEST_CLASS_TYPE"],
                ["message", "Validated vestClass must be a string."]
            ];
        } else {
            if (_vestClass isEqualTo "") then {
                _buildFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_VALIDATED_VEST_CLASS_EMPTY"],
                    ["message", "Validated vestClass is empty."]
                ];
            } else {
                private _vestCfg = configFile >> "CfgWeapons" >> _vestClass;
                if !(isClass _vestCfg) then {
                    _buildFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_VEST_CONFIG_MISSING"],
                        ["message", format ["Validated vest '%1' is missing from CfgWeapons.", _vestClass]]
                    ];
                } else {
                    // Read authoritative slot 4: preserve existing cargo, replace only classname.
                    private _existingVestSlot = _builtLoadout select 4;
                    private _vestCargo = [];

                    if ((_existingVestSlot isEqualType []) && {(count _existingVestSlot) > 1}) then {
                        _vestCargo = _existingVestSlot select 1;
                        if !(_vestCargo isEqualType []) then {
                            _vestCargo = [];
                        };
                    };

                    _builtLoadout set [4, [_vestClass, _vestCargo]];
                };
            };
        };
    };
};

if (((count _buildFailure) isEqualTo 0) && {"backpack" in _validatedWeaponKeys}) then {
    private _backpackPayload = _validatedWeapons get "backpack";

    if !(_backpackPayload isEqualType createHashMap) then {
        _buildFailure = createHashMapFromArray [
            ["success", false],
            ["code", "ERR_VALIDATED_BACKPACK_TYPE"],
            ["message", "Validated backpack payload must be a hashmap."]
        ];
    } else {
        if (_backpackPayload getOrDefault ["clear", false]) then {
            // NONE intent: clear slot 5. Authoritative backpack cargo is deliberately discarded.
            _builtLoadout set [5, []];
        } else {
            private _backpackClass = _backpackPayload getOrDefault ["backpackClass", ""];

            if !(_backpackClass isEqualType "") then {
                _buildFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_VALIDATED_BACKPACK_CLASS_TYPE"],
                    ["message", "Validated backpackClass must be a string."]
                ];
            } else {
                if (_backpackClass isEqualTo "") then {
                    _buildFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_VALIDATED_BACKPACK_CLASS_EMPTY"],
                        ["message", "Validated backpackClass is empty without a clear flag."]
                    ];
                } else {
                    private _backpackCfg = configFile >> "CfgVehicles" >> _backpackClass;
                    if !(isClass _backpackCfg) then {
                        _buildFailure = createHashMapFromArray [
                            ["success", false],
                            ["code", "ERR_BACKPACK_CONFIG_MISSING"],
                            ["message", format ["Validated backpack '%1' is missing from CfgVehicles.", _backpackClass]]
                        ];
                    } else {
                        // Read authoritative slot 5: preserve existing cargo, replace only classname.
                        private _existingBackpackSlot = _builtLoadout select 5;
                        private _backpackCargo = [];

                        if ((_existingBackpackSlot isEqualType []) && {(count _existingBackpackSlot) > 1}) then {
                            _backpackCargo = _existingBackpackSlot select 1;
                            if !(_backpackCargo isEqualType []) then {
                                _backpackCargo = [];
                            };
                        };

                        _builtLoadout set [5, [_backpackClass, _backpackCargo]];
                    };
                };
            };
        };
    };
};

if (((count _buildFailure) isEqualTo 0) && {"headgear" in _validatedWeaponKeys}) then {
    private _headgearPayload = _validatedWeapons get "headgear";

    if !(_headgearPayload isEqualType createHashMap) then {
        _buildFailure = createHashMapFromArray [
            ["success", false],
            ["code", "ERR_VALIDATED_HEADGEAR_TYPE"],
            ["message", "Validated headgear payload must be a hashmap."]
        ];
    } else {
        if (_headgearPayload getOrDefault ["clear", false]) then {
            // NONE intent: slot 6 is a plain string; empty string = no headgear.
            _builtLoadout set [6, ""];
        } else {
            private _headgearClass = _headgearPayload getOrDefault ["headgearClass", ""];

            if !(_headgearClass isEqualType "") then {
                _buildFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_VALIDATED_HEADGEAR_CLASS_TYPE"],
                    ["message", "Validated headgearClass must be a string."]
                ];
            } else {
                if (_headgearClass isEqualTo "") then {
                    _buildFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_VALIDATED_HEADGEAR_CLASS_EMPTY"],
                        ["message", "Validated headgearClass is empty without a clear flag."]
                    ];
                } else {
                    // Slot 6 is a plain classname string — no cargo to preserve.
                    _builtLoadout set [6, _headgearClass];
                };
            };
        };
    };
};

if (((count _buildFailure) isEqualTo 0) && {"facewear" in _validatedWeaponKeys}) then {
    private _facewearPayload = _validatedWeapons get "facewear";

    if !(_facewearPayload isEqualType createHashMap) then {
        _buildFailure = createHashMapFromArray [
            ["success", false],
            ["code", "ERR_VALIDATED_FACEWEAR_TYPE"],
            ["message", "Validated facewear payload must be a hashmap."]
        ];
    } else {
        if (_facewearPayload getOrDefault ["clear", false]) then {
            // NONE intent: slot 7 is a plain string; empty string = no facewear.
            _builtLoadout set [7, ""];
        } else {
            private _facewearClass = _facewearPayload getOrDefault ["facewearClass", ""];

            if !(_facewearClass isEqualType "") then {
                _buildFailure = createHashMapFromArray [
                    ["success", false],
                    ["code", "ERR_VALIDATED_FACEWEAR_CLASS_TYPE"],
                    ["message", "Validated facewearClass must be a string."]
                ];
            } else {
                if (_facewearClass isEqualTo "") then {
                    _buildFailure = createHashMapFromArray [
                        ["success", false],
                        ["code", "ERR_VALIDATED_FACEWEAR_CLASS_EMPTY"],
                        ["message", "Validated facewearClass is empty without a clear flag."]
                    ];
                } else {
                    // Slot 7 is a plain classname string — no cargo to preserve.
                    _builtLoadout set [7, _facewearClass];
                };
            };
        };
    };
};

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
    ["message", "Validated equipment selections built into complete loadout from authoritative baseline or starter fallback."],
    ["sideToken", _sideToken],
    ["loadoutId", _loadoutId],
    ["loadout", _builtLoadout]
]

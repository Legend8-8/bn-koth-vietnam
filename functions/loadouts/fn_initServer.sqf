/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Builds server-local resolved loadout definitions from canonical arsenal config.
    Execution: Server
    Parameters:
        None
    Returns:
        Loadout definition count <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

// Session-scoped authoritative loadout intent state keyed by UID.
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMap];
missionNamespace setVariable ["BN_KOTH_savedLoadoutsByUid", createHashMap];
missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", false];

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
    [format ["Loadouts init skipped: missing config class %1", _catalogueClass], "WARN"] call bn_koth_fnc_common_log;
    missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
    missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", false];
    0
};

private _loadoutsCfg = _arsenalCfg >> "Loadouts";
if !(isClass _loadoutsCfg) exitWith {
    [format ["Loadouts init skipped: %1.Loadouts missing", _catalogueClass], "WARN"] call bn_koth_fnc_common_log;
    missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
    missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", false];
    0
};

private _resolveSideFromToken = {
    params ["_token"];

    switch (toUpper _token) do {
        case "WEST": {west};
        case "EAST": {east};
        case "RESISTANCE": {resistance};
        case "GUER": {resistance};
        case "CIVILIAN": {civilian};
        default {sideUnknown};
    }
};

private _buildTemplateLoadout = {
    params ["_unitClass", "_sideToken"];

    private _side = [_sideToken] call _resolveSideFromToken;
    if (_side isEqualTo sideUnknown) exitWith {[]};
    if !(isClass (configFile >> "CfgVehicles" >> _unitClass)) exitWith {[]};

    private _group = createGroup [_side, true];
    private _unit = _group createUnit [_unitClass, [0, 0, 0], [], 0, "NONE"];
    private _loadout = getUnitLoadout _unit;

    deleteVehicle _unit;
    if (!isNull _group && {(count units _group) isEqualTo 0}) then {
        deleteGroup _group;
    };

    _loadout
};

private _definitions = createHashMap;
private _loadedCount = 0;

{
    private _loadoutCfg = _x;
    private _loadoutId = configName _loadoutCfg;
    private _sideToken = toUpper (getText (_loadoutCfg >> "side"));
    private _source = toUpper (getText (_loadoutCfg >> "source"));
    private _unitClass = getText (_loadoutCfg >> "unitClass");
    private _resolvedLoadout = [];

    if (_loadoutId isEqualTo "") then {
        continue;
    };

    if (_sideToken isEqualTo "") then {
        [format ["Loadout '%1' skipped: missing side", _loadoutId], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    if (_source isEqualTo "") then {
        [format ["Loadout '%1' skipped: missing source", _loadoutId], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    switch (_source) do {
        case "UNIT_CLASS_TEMPLATE": {
            if (_unitClass isEqualTo "") then {
                [format ["Loadout '%1' skipped: UNIT_CLASS_TEMPLATE missing unitClass", _loadoutId], "WARN"] call bn_koth_fnc_common_log;
                continue;
            };

            _resolvedLoadout = [_unitClass, _sideToken] call _buildTemplateLoadout;
            if !(_resolvedLoadout isEqualType []) then {
                _resolvedLoadout = [];
            };
        };
        default {
            [format ["Loadout '%1' skipped: unsupported source '%2'", _loadoutId, _source], "WARN"] call bn_koth_fnc_common_log;
            continue;
        };
    };

    if ((count _resolvedLoadout) <= 0) then {
        [format ["Loadout '%1' skipped: could not resolve template loadout", _loadoutId], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    if (
        (_loadoutId isEqualTo "starter_west") &&
        (_sideToken isEqualTo "WEST") &&
        (_resolvedLoadout isEqualType []) &&
        {(count _resolvedLoadout) >= 10}
    ) then {
        private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";
        private _westPrimaryResult = [
            createHashMapFromArray [
                ["weaponClass", "vn_m1903"],
                ["magazines", ["vn_m1903_mag"]],
                ["attachments", []]
            ],
            _compatibilityCfg,
            "PRIMARY",
            "Primary"
        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

        private _westHandgunResult = [
            createHashMapFromArray [
                ["weaponClass", "vn_m1911"],
                ["magazines", ["vn_m1911_mag"]],
                ["attachments", []]
            ],
            _compatibilityCfg,
            "HANDGUN",
            "Handgun"
        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

        if (
            (_westPrimaryResult getOrDefault ["success", false]) &&
            (_westHandgunResult getOrDefault ["success", false])
        ) then {
            private _westPrimaryWeapon = ((_westPrimaryResult getOrDefault ["validatedWeapon", createHashMap]) getOrDefault ["weaponClass", "vn_m1903"]);
            private _westHandgunWeapon = ((_westHandgunResult getOrDefault ["validatedWeapon", createHashMap]) getOrDefault ["weaponClass", "vn_m1911"]);

            private _m1903Mag = "vn_m1903_mag";
            private _m1911Mag = "vn_m1911_mag";
            private _m1903Capacity = getNumber (configFile >> "CfgMagazines" >> _m1903Mag >> "count");
            private _m1911Capacity = getNumber (configFile >> "CfgMagazines" >> _m1911Mag >> "count");

            if ((_m1903Capacity > 0) && (_m1911Capacity > 0)) then {
                private _launcherTemplate = _resolvedLoadout select 1;
                private _binocularTemplate = _resolvedLoadout select 8;

                private _emptyLauncher = if ((_launcherTemplate isEqualType []) && {(count _launcherTemplate) >= 7}) then {
                    ["", "", "", "", [], [], ""]
                } else {
                    []
                };

                private _emptyBackpack = [];

                private _emptyBinocular = if (_binocularTemplate isEqualType []) then {[]} else {""};

                // Slot 0: Primary weapon
                _resolvedLoadout set [
                    0,
                    [_westPrimaryWeapon, "", "", "", [_m1903Mag, _m1903Capacity], [], ""]
                ];

                // Slot 1: Launcher / secondary weapon
                _resolvedLoadout set [1, _emptyLauncher];

                // Slot 2: Handgun
                _resolvedLoadout set [
                    2,
                    [_westHandgunWeapon, "", "", "", [_m1911Mag, _m1911Capacity], [], ""]
                ];

                // Slot 3: Uniform + uniform contents
                _resolvedLoadout set [
                    3,
                    ["vn_b_uniform_aus_01_01", [["vn_b_item_firstaidkit", 2]]]
                ];

                // Slot 4: Vest + vest contents
                _resolvedLoadout set [
                    4,
                    ["vn_b_vest_sog_04", [[_m1903Mag, 4, _m1903Capacity], [_m1911Mag, 1, _m1911Capacity]]]
                ];

                // Slot 5: Backpack + backpack contents
                _resolvedLoadout set [5, _emptyBackpack];

                // Slot 6: Headgear
                _resolvedLoadout set [6, ""];

                // Slot 7: Goggles / facewear
                _resolvedLoadout set [7, ""];

                // Slot 8: Binocular / rangefinder
                _resolvedLoadout set [8, _emptyBinocular];

                // Slot 9: Assigned items
                _resolvedLoadout set [
                    9,
                    [
                        "vn_b_item_map",             // Assigned slot 0: Map
                        "",                          // Assigned slot 1: GPS / UAV terminal
                        "vn_b_item_radio_urc10",     // Assigned slot 2: Radio
                        "vn_b_item_compass_sog",     // Assigned slot 3: Compass
                        "vn_b_item_watch",           // Assigned slot 4: Watch
                        ""                           // Assigned slot 5: NVG
                    ]
                ];

                [
                    format [
                        "Loadout '%1' WEST starter postprocessed (M1903 cap=%2, M1911 cap=%3).",
                        _loadoutId,
                        _m1903Capacity,
                        _m1911Capacity
                    ],
                    "INFO"
                ] call bn_koth_fnc_common_log;
            } else {
                [
                    format [
                        "Loadout '%1' WEST starter postprocess skipped: invalid magazine capacities (M1903=%2, M1911=%3).",
                        _loadoutId,
                        _m1903Capacity,
                        _m1911Capacity
                    ],
                    "WARN"
                ] call bn_koth_fnc_common_log;
            };
        } else {
            [
                format [
                    "Loadout '%1' WEST starter postprocess skipped: canonical weapon validation failed (%2 / %3).",
                    _loadoutId,
                    _westPrimaryResult getOrDefault ["code", "ERR_PRIMARY"],
                    _westHandgunResult getOrDefault ["code", "ERR_HANDGUN"]
                ],
                "WARN"
            ] call bn_koth_fnc_common_log;
        };
    };

    if (
        (_loadoutId isEqualTo "starter_east") &&
        (_sideToken isEqualTo "EAST") &&
        (_resolvedLoadout isEqualType []) &&
        {(count _resolvedLoadout) >= 10}
    ) then {
        private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";
        private _eastPrimaryResult = [
            createHashMapFromArray [
                ["weaponClass", "vn_k98k"],
                ["magazines", ["vn_k98k_mag"]],
                ["attachments", []]
            ],
            _compatibilityCfg,
            "PRIMARY",
            "Primary"
        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

        private _eastHandgunResult = [
            createHashMapFromArray [
                ["weaponClass", "vn_pm"],
                ["magazines", ["vn_pm_mag"]],
                ["attachments", []]
            ],
            _compatibilityCfg,
            "HANDGUN",
            "Handgun"
        ] call bn_koth_fnc_loadouts_validateWeaponComposition;

        if (
            (_eastPrimaryResult getOrDefault ["success", false]) &&
            (_eastHandgunResult getOrDefault ["success", false])
        ) then {
            private _eastPrimaryWeapon = ((_eastPrimaryResult getOrDefault ["validatedWeapon", createHashMap]) getOrDefault ["weaponClass", "vn_k98k"]);
            private _eastHandgunWeapon = ((_eastHandgunResult getOrDefault ["validatedWeapon", createHashMap]) getOrDefault ["weaponClass", "vn_pm"]);

            private _k98kMag = "vn_k98k_mag";
            private _pmMag = "vn_pm_mag";
            private _k98kCapacity = getNumber (configFile >> "CfgMagazines" >> _k98kMag >> "count");
            private _pmCapacity = getNumber (configFile >> "CfgMagazines" >> _pmMag >> "count");

            if ((_k98kCapacity > 0) && (_pmCapacity > 0)) then {
                private _launcherTemplate = _resolvedLoadout select 1;
                private _binocularTemplate = _resolvedLoadout select 8;

                private _emptyLauncher = if ((_launcherTemplate isEqualType []) && {(count _launcherTemplate) >= 7}) then {
                    ["", "", "", "", [], [], ""]
                } else {
                    []
                };

                private _emptyBackpack = [];

                private _emptyBinocular = if (_binocularTemplate isEqualType []) then {[]} else {""};

                // Slot 0: Primary weapon
                _resolvedLoadout set [
                    0,
                    [_eastPrimaryWeapon, "", "", "", [_k98kMag, _k98kCapacity], [], ""]
                ];

                // Slot 1: Launcher / secondary weapon
                _resolvedLoadout set [1, _emptyLauncher];

                // Slot 2: Handgun
                _resolvedLoadout set [
                    2,
                    [_eastHandgunWeapon, "", "", "", [_pmMag, _pmCapacity], [], ""]
                ];

                // Slot 3: Uniform + uniform contents
                _resolvedLoadout set [
                    3,
                    ["vn_o_uniform_nva_army_03_03", [["vn_o_item_firstaidkit", 2]]]
                ];

                // Slot 4: Vest + vest contents
                _resolvedLoadout set [
                    4,
                    ["vn_o_vest_01", [[_k98kMag, 4, _k98kCapacity], [_pmMag, 1, _pmCapacity]]]
                ];

                // Slot 5: Backpack + backpack contents
                _resolvedLoadout set [5, _emptyBackpack];

                // Slot 6: Headgear
                _resolvedLoadout set [6, ""];

                // Slot 7: Goggles / facewear
                _resolvedLoadout set [7, ""];

                // Slot 8: Binocular / rangefinder
                _resolvedLoadout set [8, _emptyBinocular];

                // Slot 9: Assigned items
                _resolvedLoadout set [
                    9,
                    [
                        "vn_o_item_map",             // Assigned slot 0: Map
                        "",                          // Assigned slot 1: GPS / UAV terminal
                        "vn_b_item_radio_urc10",     // Assigned slot 2: Radio
                        "vn_b_item_compass_sog",     // Assigned slot 3: Compass
                        "vn_b_item_watch",           // Assigned slot 4: Watch
                        ""                           // Assigned slot 5: NVG
                    ]
                ];

                [
                    format [
                        "Loadout '%1' EAST starter postprocessed (K98k cap=%2, PM cap=%3).",
                        _loadoutId,
                        _k98kCapacity,
                        _pmCapacity
                    ],
                    "INFO"
                ] call bn_koth_fnc_common_log;
            } else {
                [
                    format [
                        "Loadout '%1' EAST starter postprocess skipped: invalid magazine capacities (K98k=%2, PM=%3).",
                        _loadoutId,
                        _k98kCapacity,
                        _pmCapacity
                    ],
                    "WARN"
                ] call bn_koth_fnc_common_log;
            };
        } else {
            [
                format [
                    "Loadout '%1' EAST starter postprocess skipped: canonical weapon validation failed (%2 / %3).",
                    _loadoutId,
                    _eastPrimaryResult getOrDefault ["code", "ERR_PRIMARY"],
                    _eastHandgunResult getOrDefault ["code", "ERR_HANDGUN"]
                ],
                "WARN"
            ] call bn_koth_fnc_common_log;
        };
    };

    private _definition = createHashMapFromArray [
        ["id", _loadoutId],
        ["sideToken", _sideToken],
        ["source", _source],
        ["unitClass", _unitClass],
        ["loadout", _resolvedLoadout]
    ];

    _definitions set [_loadoutId, _definition];
    _loadedCount = _loadedCount + 1;
} forEach ("true" configClasses _loadoutsCfg);

missionNamespace setVariable ["BN_KOTH_loadoutDefinitions", _definitions];
missionNamespace setVariable ["BN_KOTH_loadoutsInitialized", true];

[format ["Loadouts initialized: %1 definition(s) loaded", _loadedCount], "INFO"] call bn_koth_fnc_common_log;

_loadedCount

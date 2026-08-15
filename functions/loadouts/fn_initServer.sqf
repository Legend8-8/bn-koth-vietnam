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

    private _resolvedLoadout = [];
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

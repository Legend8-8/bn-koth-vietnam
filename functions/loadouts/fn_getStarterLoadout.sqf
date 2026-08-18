/*
    File: fn_getStarterLoadout.sqf
    Author: Legend
    Description: Resolves configured starter loadout for a side from canonical loadout definitions.
    Execution: Server
    Parameters:
        0: Side <SIDE>
    Returns:
        Starter lookup result <HASHMAP>
    Public: Yes
*/

params ["_side"];

if (!isServer) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_NOT_SERVER"],
        ["message", "Starter loadout lookup must run on server."],
        ["loadoutId", ""],
        ["sideToken", ""],
        ["loadout", []]
    ]
};

if !([_side] call bn_koth_fnc_teams_validateSide) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_INVALID_SIDE"],
        ["message", "Starter loadout lookup failed: side is not playable."],
        ["loadoutId", ""],
        ["sideToken", ""],
        ["loadout", []]
    ]
};

private _sideToken = switch (_side) do {
    case west: {"WEST"};
    case east: {"EAST"};
    case resistance: {"RESISTANCE"};
    case civilian: {"CIVILIAN"};
    default {""};
};

if (_sideToken isEqualTo "") exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_UNMAPPED_SIDE"],
        ["message", "Starter loadout lookup failed: side token mapping missing."],
        ["loadoutId", ""],
        ["sideToken", ""],
        ["loadout", []]
    ]
};

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _starterId = "";
private _loadout = [];
if (isClass _settingsCfg) then {
    _starterId = switch (_sideToken) do {
        case "WEST": {getText (_settingsCfg >> "starterLoadoutWest")};
        case "EAST": {getText (_settingsCfg >> "starterLoadoutEast")};
        default {""};
    };
};

if (_starterId isEqualTo "") exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_STARTER_NOT_CONFIGURED"],
        ["message", format ["Starter loadout ID is not configured for side %1.", _sideToken]],
        ["loadoutId", ""],
        ["sideToken", _sideToken],
        ["loadout", []]
    ]
};

private _definitions = missionNamespace getVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
if !(_definitions isEqualType createHashMap) then {
    _definitions = createHashMap;
};

private _definition = _definitions getOrDefault [_starterId, createHashMap];
if !(_definition isEqualType createHashMap) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_STARTER_NOT_RESOLVED"],
        ["message", format ["Configured starter loadout '%1' is not available.", _starterId]],
        ["loadoutId", _starterId],
        ["sideToken", _sideToken],
        ["loadout", []]
    ]
};

private _definitionSide = _definition getOrDefault ["sideToken", ""];
if !(_definitionSide isEqualTo _sideToken) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_STARTER_SIDE_MISMATCH"],
        ["message", format ["Starter loadout '%1' side mismatch. Configured=%2 Requested=%3", _starterId, _definitionSide, _sideToken]],
        ["loadoutId", _starterId],
        ["sideToken", _sideToken],
        ["loadout", []]
    ]
};

_loadout = _definition getOrDefault ["loadout", []];
if !(_loadout isEqualType []) then {
    _loadout = [];
};

if ((count _loadout) <= 0) exitWith {
    createHashMapFromArray [
        ["success", false],
        ["code", "ERR_STARTER_LOADOUT_EMPTY"],
        ["message", format ["Starter loadout '%1' resolved empty.", _starterId]],
        ["loadoutId", _starterId],
        ["sideToken", _sideToken],
        ["loadout", []]
    ]
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["message", "Starter loadout resolved."],
    ["loadoutId", _starterId],
    ["sideToken", _sideToken],
    ["loadout", _loadout]
]

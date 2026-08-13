/*
    File: fn_validateLoadout.sqf
    Author: Legend
    Description: Server-authoritative validation for requested loadout IDs using canonical arsenal configuration.
    Execution: Server
    Parameters:
        0: Requesting player object <OBJECT>
        1: Loadout request <HASHMAP|ARRAY>
           HASHMAP schema:
             loadoutId <STRING> (required)
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
private _requestedSideToken = "";

if (_request isEqualType createHashMap) then {
    _requestedLoadoutId = _request getOrDefault ["loadoutId", ""];
    _requestedSideToken = toUpper (_request getOrDefault ["side", ""]);
} else {
    if ((_request isEqualType []) && {(count _request) > 0}) then {
        _requestedLoadoutId = _request select 0;
    };
};

if !(_requestedLoadoutId isEqualType "") then {
    _requestedLoadoutId = "";
};

_requestedLoadoutId = toLower _requestedLoadoutId;
if (_requestedLoadoutId isEqualTo "") exitWith {
    ["ERR_MALFORMED_REQUEST", "Loadout request missing valid loadoutId."] call _fail
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

if !(_requestedSideToken isEqualTo "") then {
    if !(_requestedSideToken isEqualTo _authoritativeSideToken) exitWith {
        ["ERR_REQUEST_SIDE_MISMATCH", format ["Requested side '%1' does not match authoritative assigned side '%2'.", _requestedSideToken, _authoritativeSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
    };
};

private _definitions = missionNamespace getVariable ["BN_KOTH_loadoutDefinitions", createHashMap];
if !(_definitions isEqualType createHashMap) then {
    _definitions = createHashMap;
};

private _definition = _definitions getOrDefault [_requestedLoadoutId, createHashMap];
if !(_definition isEqualType createHashMap) exitWith {
    ["ERR_UNKNOWN_LOADOUT", format ["Loadout '%1' is not configured in canonical catalogue.", _requestedLoadoutId], _requestedLoadoutId, _authoritativeSideToken] call _fail
};

private _loadoutSideToken = _definition getOrDefault ["sideToken", ""];
if !(_loadoutSideToken isEqualTo _authoritativeSideToken) exitWith {
    ["ERR_SIDE_RESTRICTED", format ["Loadout '%1' is restricted to side '%2'.", _requestedLoadoutId, _loadoutSideToken], _requestedLoadoutId, _authoritativeSideToken] call _fail
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
    ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"]
]

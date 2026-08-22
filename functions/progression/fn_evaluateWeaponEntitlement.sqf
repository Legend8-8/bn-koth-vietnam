/*
    File: fn_evaluateWeaponEntitlement.sqf
    Author: Legend
    Description: Gathers server-owned player state then evaluates entitlement
        through the shared pure rule interpreter.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Requested weapon classname <STRING>
    Returns:
        Entitlement result <HASHMAP>
    Public: Yes
*/

params [
    ["_uid", "", [""]],
    ["_weaponClass", "", [""]]
];

private _fail = {
    params [
        ["_code", "ERR_ENTITLEMENT", [""]],
        ["_message", "Weapon entitlement rejected.", [""]],
        ["_extra", createHashMap, [createHashMap]]
    ];

    private _result = createHashMapFromArray [
        ["success", false],
        ["entitled", false],
        ["code", _code],
        ["message", _message],
        ["uid", _uid],
        ["requestedClass", toLower _weaponClass]
    ];

    {
        _result set [_x, _extra get _x];
    } forEach (keys _extra);

    _result
};

if (!isServer) exitWith {
    ["ERR_NOT_SERVER", "Weapon entitlement must be evaluated on the server."] call _fail
};

if (_uid isEqualTo "") exitWith {
    ["ERR_INVALID_PLAYER", "Weapon entitlement requires a player UID."] call _fail
};

if (_weaponClass isEqualTo "") exitWith {
    ["ERR_WEAPON_CLASS_EMPTY", "Weapon entitlement requires a weapon classname."] call _fail
};

private _playerRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_playerRecords isEqualType createHashMap) exitWith {
    ["ERR_PLAYER_REGISTRY", "Server player registry is unavailable."] call _fail
};

private _playerRecord = _playerRecords getOrDefault [_uid, createHashMap];
if !(_playerRecord isEqualType createHashMap) exitWith {
    ["ERR_INVALID_PLAYER", "Player is not present in the authoritative registry."] call _fail
};

private _assignedSide = _playerRecord getOrDefault ["assignedSide", sideUnknown];
if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
    ["ERR_ASSIGNED_SIDE_INVALID", "Player does not have a valid authoritative side."] call _fail
};

private _sideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};

if (_sideToken isEqualTo "") exitWith {
    ["ERR_ASSIGNED_SIDE_INVALID", "Player side cannot be mapped to a KOTH side token."] call _fail
};

private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {
    [
        _metadata getOrDefault ["code", "ERR_WEAPON_METADATA"],
        "Weapon metadata lookup failed.",
        createHashMapFromArray [
            ["canonicalClass", _metadata getOrDefault ["canonicalClass", ""]],
            ["sideToken", _sideToken]
        ]
    ] call _fail
};

private _progression = createHashMap;
if (_metadata getOrDefault ["configured", false]) then {
    private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
    if !(_progressionByUid isEqualType createHashMap) exitWith {
        ["ERR_PROGRESSION_STATE", "Authoritative progression state is unavailable."] call _fail
    };

    _progression = _progressionByUid getOrDefault [_uid, createHashMap];
    if !(_progression isEqualType createHashMap) then {
        _progression = createHashMap;
    };
};

[
    _uid,
    _sideToken,
    _progression,
    _metadata,
    _weaponClass
] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules

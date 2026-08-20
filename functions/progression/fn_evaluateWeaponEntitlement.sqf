/*
    File: fn_evaluateWeaponEntitlement.sqf
    Author: Legend
    Description: Evaluates authoritative player entitlement for one canonical
        progression-controlled weapon. Level is always the first gameplay gate.
        The function reads server-owned progression and team state only.
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

private _canonicalClass = _metadata getOrDefault ["canonicalClass", toLower _weaponClass];
private _configured = _metadata getOrDefault ["configured", false];

if (!_configured) exitWith {
    createHashMapFromArray [
        ["success", true],
        ["entitled", true],
        ["code", "ENTITLED_UNCONTROLLED"],
        ["message", "Weapon has no KOTH progression metadata."],
        ["uid", _uid],
        ["requestedClass", toLower _weaponClass],
        ["canonicalClass", _canonicalClass],
        ["sideToken", _sideToken],
        ["configured", false],
        ["accessType", "UNCONTROLLED"]
    ]
};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {
    ["ERR_PROGRESSION_STATE", "Authoritative progression state is unavailable."] call _fail
};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};

private _playerLevel = (_progression getOrDefault ["level", 1]) max 1;
private _minLevel = (_metadata getOrDefault ["minLevel", 1]) max 1;
private _nativeSide = toUpper (_metadata getOrDefault ["nativeSide", ""]);
private _licenseKillsRequired = (_metadata getOrDefault ["licenseKills", 0]) max 0;
private _requiredPerks = _metadata getOrDefault ["requiredPerks", []];

if (_playerLevel < _minLevel) exitWith {
    [
        "LOCKED_LEVEL",
        format ["Requires level %1.", _minLevel],
        createHashMapFromArray [
            ["canonicalClass", _canonicalClass],
            ["sideToken", _sideToken],
            ["nativeSide", _nativeSide],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["configured", true]
        ]
    ] call _fail
};

private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};

private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};

private _playerPerks = _progression getOrDefault ["perks", []];
if !(_playerPerks isEqualType []) then {_playerPerks = []};

private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};

private _normalizedOwned = _ownedWeapons apply {toLower _x};
private _normalizedRented = _rentedWeapons apply {toLower _x};
private _normalizedPerks = _playerPerks apply {toLower _x};

private _isOwned = _canonicalClass in _normalizedOwned;
private _isRented = _canonicalClass in _normalizedRented;
private _kills = (_weaponKills getOrDefault [_canonicalClass, 0]) max 0;
private _licenseComplete = _kills >= _licenseKillsRequired;

private _missingPerks = [];
{
    private _perk = toLower _x;
    if !(_perk in _normalizedPerks) then {
        _missingPerks pushBack _x;
    };
} forEach _requiredPerks;

if ((count _missingPerks) > 0) exitWith {
    [
        "LOCKED_PERK",
        "Required perk entitlement is incomplete.",
        createHashMapFromArray [
            ["canonicalClass", _canonicalClass],
            ["sideToken", _sideToken],
            ["nativeSide", _nativeSide],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["missingPerks", _missingPerks],
            ["configured", true]
        ]
    ] call _fail
};

private _isNativeSide = _nativeSide isEqualTo "" || {_sideToken isEqualTo _nativeSide};

if (!_isNativeSide && {!_licenseComplete}) exitWith {
    [
        "LOCKED_SIDE_LICENSE",
        format ["Cross-faction access requires %1 weapon kills.", _licenseKillsRequired],
        createHashMapFromArray [
            ["canonicalClass", _canonicalClass],
            ["sideToken", _sideToken],
            ["nativeSide", _nativeSide],
            ["playerLevel", _playerLevel],
            ["minLevel", _minLevel],
            ["weaponKills", _kills],
            ["licenseKills", _licenseKillsRequired],
            ["licenseComplete", false],
            ["configured", true]
        ]
    ] call _fail
};

if (_isOwned) exitWith {
    createHashMapFromArray [
        ["success", true],
        ["entitled", true],
        ["code", "ENTITLED"],
        ["message", "Permanent weapon entitlement is valid."],
        ["uid", _uid],
        ["requestedClass", toLower _weaponClass],
        ["canonicalClass", _canonicalClass],
        ["sideToken", _sideToken],
        ["nativeSide", _nativeSide],
        ["playerLevel", _playerLevel],
        ["minLevel", _minLevel],
        ["weaponKills", _kills],
        ["licenseKills", _licenseKillsRequired],
        ["licenseComplete", _licenseComplete],
        ["owned", true],
        ["rented", _isRented],
        ["accessType", "OWNED"],
        ["configured", true]
    ]
};

if (_isRented) exitWith {
    createHashMapFromArray [
        ["success", true],
        ["entitled", true],
        ["code", "ENTITLED"],
        ["message", "Temporary weapon rental entitlement is valid."],
        ["uid", _uid],
        ["requestedClass", toLower _weaponClass],
        ["canonicalClass", _canonicalClass],
        ["sideToken", _sideToken],
        ["nativeSide", _nativeSide],
        ["playerLevel", _playerLevel],
        ["minLevel", _minLevel],
        ["weaponKills", _kills],
        ["licenseKills", _licenseKillsRequired],
        ["licenseComplete", _licenseComplete],
        ["owned", false],
        ["rented", true],
        ["accessType", "RENTED"],
        ["configured", true]
    ]
};

private _canRent = _isNativeSide || {_licenseComplete};

createHashMapFromArray [
    ["success", true],
    ["entitled", false],
    ["code", "REQUIRES_ACQUISITION"],
    ["message", if (_isNativeSide) then {
        "Weapon is level-eligible but requires ownership or rental."
    } else {
        "Cross-faction weapon is licensed but requires ownership or rental."
    }],
    ["uid", _uid],
    ["requestedClass", toLower _weaponClass],
    ["canonicalClass", _canonicalClass],
    ["sideToken", _sideToken],
    ["nativeSide", _nativeSide],
    ["playerLevel", _playerLevel],
    ["minLevel", _minLevel],
    ["weaponKills", _kills],
    ["licenseKills", _licenseKillsRequired],
    ["licenseComplete", _licenseComplete],
    ["owned", false],
    ["rented", false],
    ["canPurchase", true],
    ["canRent", _canRent],
    ["accessType", "NONE"],
    ["configured", true]
]

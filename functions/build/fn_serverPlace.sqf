/*
    File: fn_serverPlace.sqf
    Author: tylervip
    Description: Server-authoritative validation and placement of player-built objects.
    Execution: Server
    Parameters:
        0: Position ATL <ARRAY>
        1: Direction <NUMBER>
        2: Catalog key <STRING>
        3: Classname <STRING>
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

params [
    ["_position", [0,0,0], [[]]],
    ["_direction", 0, [0]],
    ["_catalogKey", "", [""]],
    ["_className", "", [""]]
];

if (_className isEqualTo "") exitWith {};
if !(_position isEqualType []) exitWith {};
if ((count _position) < 3) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Build request rejected without a valid remote owner.", "WARN"] call bn_koth_fnc_common_log;
};

private _player = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _player) exitWith {
    [format ["Build request rejected: no player for owner %1.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _playerUid = getPlayerUID _player;
if (_playerUid isEqualTo "") exitWith {
    [format ["Build request rejected: player for owner %1 has no UID.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

diag_log format ["[BN_KOTH Build] Server received place request owner=%1 key=%2 class=%3 pos=%4 dir=%5", _ownerId, _catalogKey, _className, _position, _direction];

private _buildCfg = missionConfigFile >> "CfgBnKothBuild";
if !(isClass _buildCfg) exitWith {};
if ((getNumber (_buildCfg >> "enabled")) <= 0) exitWith {};

if !(alive _player) exitWith {};

if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {
    ["Build failed: placement is available only during an active round."] remoteExecCall ["hint", _ownerId];
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_playerUid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    ["Build failed: player state is unavailable."] remoteExecCall ["hint", _ownerId];
};
if !(_record getOrDefault ["deployed", false]) exitWith {
    ["Build failed: deploy before placing objects."] remoteExecCall ["hint", _ownerId];
};

private _safeZoneMembership = [_position] call bn_koth_fnc_respawn_getSafeZoneMembership;
if ((_safeZoneMembership select 0) || {_safeZoneMembership select 1}) exitWith {
    ["Build failed: placement is not allowed inside a safe zone."] remoteExecCall ["hint", _ownerId];
};

private _distance = _player distance2D _position;
private _minDistance = getNumber (_buildCfg >> "placeDistanceMin");
private _maxDistance = getNumber (_buildCfg >> "placeDistanceMax");
if (_distance < _minDistance || {_distance > _maxDistance}) exitWith {
    ["Build failed: you are too far away."] remoteExecCall ["hint", owner _player];
};

if (_catalogKey isEqualTo "") exitWith {
    ["Build failed: missing object key."] remoteExecCall ["hint", owner _player];
};

private _root = _buildCfg >> "Objects" >> _catalogKey;
if !(isClass _root) exitWith {
    diag_log format ["[BN_KOTH Build] Server rejected invalid catalog key: %1", _catalogKey];
    ["Build failed: object not configured."] remoteExecCall ["hint", owner _player];
};

private _catalogClassname = getText (_root >> "classname");
if !(_catalogClassname isEqualTo _className) exitWith {
    ["Build failed: object mismatch."] remoteExecCall ["hint", _ownerId];
};
if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith {
    [format ["Build config rejected missing vehicle class %1.", _className], "ERROR"] call bn_koth_fnc_common_log;
    ["Build failed: object class is unavailable."] remoteExecCall ["hint", _ownerId];
};

private _side = side _player;
private _limit = getNumber (_buildCfg >> "maxObjectsPerPlayer");
private _sideLimit = getNumber (_buildCfg >> "maxObjectsPerSide");

private _tracked = missionNamespace getVariable ["BN_KOTH_buildObjects", []];
if !(_tracked isEqualType []) then {
    _tracked = [];
};
_tracked = _tracked select {!isNull _x};
missionNamespace setVariable ["BN_KOTH_buildObjects", _tracked];

private _playerBuilds = _tracked select {
    private _owner = _x getVariable ["bn_koth_build_owner", ""];
    _owner isEqualTo _playerUid
};
if ((count _playerBuilds) >= _limit) exitWith {
    ["Build limit reached for your account."] remoteExecCall ["hint", _ownerId];
};

private _sideBuilds = _tracked select {
    private _sideVar = _x getVariable ["bn_koth_build_side", sideUnknown];
    _sideVar isEqualTo _side
};
if ((count _sideBuilds) >= _sideLimit) exitWith {
    ["Build limit reached for this side."] remoteExecCall ["hint", _ownerId];
};

private _object = createVehicle [_className, _position, [], 0, "CAN_COLLIDE"];
if (isNull _object) exitWith {
    [format ["Build creation failed for class %1.", _className], "ERROR"] call bn_koth_fnc_common_log;
    ["Build failed: object could not be created."] remoteExecCall ["hint", _ownerId];
};
_object setPosATL _position;
_object setDir _direction;
_object setVariable ["bn_koth_build_owner", _playerUid, true];
_object setVariable ["bn_koth_build_side", _side, true];
_object setVariable ["bn_koth_build_id", _catalogKey, true];
_object setVariable ["bn_koth_build_locked", false, true];

[_object] call bn_koth_fnc_build_registerObject;

[format ["Placed %1.", _className]] remoteExecCall ["hint", _ownerId];

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
    ["_className", "", [""]],
    ["_playerUid", "", [""]]
];

if (_className isEqualTo "") exitWith {};
if (_playerUid isEqualTo "") exitWith {};

private _buildCfg = missionConfigFile >> "CfgBnKothBuild";
if !(isClass _buildCfg) exitWith {};
if ((getNumber (_buildCfg >> "enabled")) <= 0) exitWith {};

private _player = objNull;
{
    if (getPlayerUID _x isEqualTo _playerUid) exitWith {_player = _x};
} forEach allPlayers;

if (isNull _player) exitWith {
    ["Build request rejected: invalid player.", "WARN"] call bn_koth_fnc_common_log;
};

if !(alive _player) exitWith {};

private _distance = _player distance2D _position;
private _minDistance = getNumber (_buildCfg >> "placeDistanceMin");
private _maxDistance = getNumber (_buildCfg >> "placeDistanceMax");
if (_distance < _minDistance || {_distance > _maxDistance}) exitWith {
    ["Build failed: you are too far away."] remoteExecCall ["hint", owner _player];
};

private _root = _buildCfg >> "Objects" >> _catalogKey;
if !(isClass _root) exitWith {
    ["Build failed: object not configured."] remoteExecCall ["hint", owner _player];
};

private _catalogClassname = getText (_root >> "classname");
if !(_catalogClassname isEqualTo _className) exitWith {
    ["Build failed: object mismatch."] remoteExecCall ["hint", owner _player];
};

private _side = side _player;
private _limit = getNumber (_buildCfg >> "maxObjectsPerPlayer");
private _sideLimit = getNumber (_buildCfg >> "maxObjectsPerSide");

private _playerBuilds = allMissionObjects "Thing" select {
    private _owner = _x getVariable ["bn_koth_build_owner", ""];
    _owner isEqualTo _playerUid
};
if ((count _playerBuilds) >= _limit) exitWith {
    ["Build limit reached for your account."] remoteExecCall ["hint", owner _player];
};

private _sideBuilds = allMissionObjects "Thing" select {
    private _sideVar = _x getVariable ["bn_koth_build_side", sideUnknown];
    _sideVar isEqualTo _side
};
if ((count _sideBuilds) >= _sideLimit) exitWith {
    ["Build limit reached for this side."] remoteExecCall ["hint", owner _player];
};

private _object = createVehicle [_className, _position, [], 0, "CAN_COLLIDE"];
_object setPosATL _position;
_object setDir _direction;
_object setVariable ["bn_koth_build_owner", _playerUid, true];
_object setVariable ["bn_koth_build_side", _side, true];
_object setVariable ["bn_koth_build_id", _catalogKey, true];
_object setVariable ["bn_koth_build_locked", false, true];

[format ["Placed %1.", _className]] remoteExecCall ["hint", owner _player];

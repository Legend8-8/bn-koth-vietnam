/*
    File: fn_assignLobbyRepresentation.sqf
    Author: Legend
    Description: Assigns a connected player to a neutral civilian lobby representation.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        True when lobby representation is active, otherwise false <BOOL>
    Public: Yes
*/

params ["_uid"];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
if (_ownerId <= 0) exitWith {false};

private _ownerPlayer = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _ownerPlayer) exitWith {
    [format ["assignLobbyRepresentation deferred: no player resolved for owner=%1 uid=%2", _ownerId, _uid], "INFO"] call bn_koth_fnc_common_log;
    false
};

private _currentUnit = _record getOrDefault ["currentUnit", _ownerPlayer];
if (isNull _currentUnit) then {
    _currentUnit = _ownerPlayer;
};

if ((side group _currentUnit) isEqualTo civilian && {getPlayerUID _currentUnit isEqualTo _uid}) exitWith {
    _record set ["state", "LOBBY"];
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    true
};

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _lobbyUnitClass = if (isClass _lobbyCfg) then {getText (_lobbyCfg >> "lobbyUnitClass")} else {"C_man_1"};
if (_lobbyUnitClass isEqualTo "" || {!(isClass (configFile >> "CfgVehicles" >> _lobbyUnitClass))}) then {
    _lobbyUnitClass = "C_man_1";
};

private _spawnPosAsl = _record getOrDefault ["lobbySpawnPosASL", getPosASL _currentUnit];
private _spawnDir = _record getOrDefault ["lobbySpawnDir", getDir _currentUnit];

private _lobbyGroup = createGroup [civilian, true];
private _lobbyUnit = _lobbyGroup createUnit [_lobbyUnitClass, ASLToAGL _spawnPosAsl, [], 0, "NONE"];
_lobbyUnit setDir _spawnDir;

[format ["assignLobbyRepresentation created CIV lobby unit uid=%1 owner=%2 class=%3", _uid, _ownerId, _lobbyUnitClass], "INFO"] call bn_koth_fnc_common_log;

private _success = [_uid, _lobbyUnit, "LOBBY", true] call bn_koth_fnc_teams_transferRepresentation;
if (!_success) exitWith {
    deleteVehicle _lobbyUnit;
    deleteGroup _lobbyGroup;
    false
};

[format ["Player entered neutral lobby representation UID=%1", _uid]] call bn_koth_fnc_common_log;
true

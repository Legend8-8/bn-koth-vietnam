/*
    File: fn_evaluatePlayer.sqf
    Author: Legend
    Description: Evaluates current server-owned tactical insertion eligibility.
    Execution: Server
    Parameters:
        0: Player unit <OBJECT>
        1: Required side, or sideUnknown <SIDE>
    Returns: Eligibility result <HASHMAP>
    Public: No
*/

params [["_player", objNull, [objNull]], ["_requiredSide", sideUnknown, [sideUnknown]]];

private _fail = {
    params ["_code", "_message"];
    createHashMapFromArray [["success", false], ["code", _code], ["message", _message]]
};

if (!isServer) exitWith {["NOT_SERVER", "Server authority required."] call _fail};
if (isNull _player || {!isPlayer _player} || {!alive _player}) exitWith {["INVALID_PLAYER", "You must be alive and connected."] call _fail};
if ([_player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {["PLAYER_INCAPACITATED", "Air insertion is unavailable while incapacitated."] call _fail};

private _uid = getPlayerUID _player;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if (_uid isEqualTo "" || {!(_record isEqualType createHashMap)}) exitWith {["PLAYER_NOT_REGISTERED", "Player state is not ready."] call _fail};
if !((_record getOrDefault ["ownerId", -1]) isEqualTo (owner _player)) exitWith {["OWNER_MISMATCH", "Air insertion is unavailable. Try again."] call _fail};
if !((_record getOrDefault ["currentUnit", objNull]) isEqualTo _player) exitWith {["STALE_UNIT", "Air insertion is unavailable. Try again."] call _fail};

private _side = _record getOrDefault ["assignedSide", sideUnknown];
if !([_side] call bn_koth_fnc_teams_validateSide) exitWith {["INVALID_SIDE", "Choose a team first."] call _fail};
if (!(_requiredSide isEqualTo sideUnknown) && {!(_side isEqualTo _requiredSide)}) exitWith {["WRONG_SIDE", "Only teammates may join this insertion."] call _fail};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {["INVALID_ROUND_STATE", "Air insertion is unavailable right now."] call _fail};
if ((missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]) isEqualTo "") exitWith {["NO_ACTIVE_AO", "Air insertion is unavailable right now."] call _fail};
if !((_record getOrDefault ["state", ""]) isEqualTo "ACTIVE" && {_record getOrDefault ["deployed", false]}) exitWith {["NOT_DEPLOYED", "You must be deployed."] call _fail};
if !(_uid in (missionNamespace getVariable ["BN_KOTH_activeParticipants", []])) exitWith {["NOT_PARTICIPATING", "Air insertion is unavailable right now."] call _fail};

private _membership = [_player] call bn_koth_fnc_respawn_getSafeZoneMembership;
private _insideOwnSafeZone = if (_side isEqualTo west) then {_membership select 0} else {_membership select 1};
if (!_insideOwnSafeZone) exitWith {["OUTSIDE_SAFE_ZONE", "You must be in your team safe zone."] call _fail};

createHashMapFromArray [["success", true], ["code", "OK"], ["uid", _uid], ["record", _record], ["side", _side]]

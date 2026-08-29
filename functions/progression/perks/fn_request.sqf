/*
    File: fn_request.sqf
    Author: Legend
    Description: Accepts narrow perk intent and derives the authoritative caller.
    Execution: Client/Server
    Public: Yes
*/
params [["_operation", "", [""]], ["_perkId", "", [""]]];
if (hasInterface && {!isServer}) exitWith {[_operation, _perkId] remoteExecCall ["bn_koth_fnc_progression_perks_request", 2]};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {[_operation, _perkId] remoteExecCall ["bn_koth_fnc_progression_perks_request", 2]};
if (!isServer) exitWith {};
private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {["Rejected perk request without remote owner.", "WARN"] call bn_koth_fnc_common_log};
private _reply = {params ["_result"]; [_result] remoteExecCall ["bn_koth_fnc_ui_receivePerkResult", _ownerId]};
private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {[createHashMapFromArray [["success", false], ["code", "PLAYER_NOT_REGISTERED"], ["message", "Player state is not ready."]]] call _reply};
private _uid = getPlayerUID _playerObj;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {[createHashMapFromArray [["success", false], ["code", "PLAYER_NOT_REGISTERED"], ["message", "Player state is not ready."]]] call _reply};
private _now = serverTime;
if ((_now - (_record getOrDefault ["lastPerkRequestAt", -999])) < 0.25) exitWith {[createHashMapFromArray [["success", false], ["code", "REQUEST_THROTTLED"], ["message", "Perk request was sent too quickly."]]] call _reply};
_record set ["lastPerkRequestAt", _now];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
private _op = toUpper _operation;
private _result = if (_op isEqualTo "PURCHASE") then {[_uid, _perkId] call bn_koth_fnc_progression_perks_purchase} else {[_uid, _perkId, _op] call bn_koth_fnc_progression_perks_setActive};
[_result] call _reply;

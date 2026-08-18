/*
    File: fn_addXp.sqf
    Author: Tylervip
    Description: Adds validated XP to a server-owned player record.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: XP amount <NUMBER>
        2: Reward reason <STRING>
    Returns:
        Updated progression state, or an empty hash map when rejected <HASHMAP>
    Public: Yes
*/

params ["_uid", ["_amount", 0, [0]], ["_reason", "", [""]]];

if (!isServer) exitWith {createHashMap};
if (_uid isEqualTo "") exitWith {createHashMap};
if (_amount <= 0) exitWith {createHashMap};
if (_reason isEqualTo "") exitWith {createHashMap};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {createHashMap};

private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {createHashMap};

private _oldXp = _record getOrDefault ["xp", 0];
private _newXp = (_oldXp max 0) + _amount;
private _newLevel = [_newXp] call bn_koth_fnc_progression_xp_getLevel;

_record set ["xp", _newXp];
_record set ["level", _newLevel];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _state = createHashMapFromArray [
    ["uid", _uid],
    ["xp", _newXp],
    ["level", _newLevel],
    ["reason", _reason]
];

[format [
    "XP award UID=%1 reason=%2 amount=%3 total=%4 level=%5",
    _uid,
    _reason,
    _amount,
    _newXp,
    _newLevel
]] call bn_koth_fnc_common_log;

_state

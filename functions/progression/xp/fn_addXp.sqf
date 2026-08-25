/*
    File: fn_addXp.sqf
    Author: Tylervip
    Edited: Legend
    Description: Adds validated XP to progression-owned server session state.
        Player identity/lifecycle remains owned by BN_KOTH_playerRecords.
        XP and level are owned only by BN_KOTH_playerProgression.
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

private _playerRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_playerRecords isEqualType createHashMap) exitWith {createHashMap};

private _playerRecord = _playerRecords getOrDefault [_uid, createHashMap];
if !(_playerRecord isEqualType createHashMap) exitWith {createHashMap};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {
    ["XP award rejected: BN_KOTH_playerProgression missing/invalid", "WARN"] call bn_koth_fnc_common_log;
    createHashMap
};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};

private _oldXp = _progression getOrDefault ["xp", 0];
private _newXp = (_oldXp max 0) + _amount;
private _newLevel = [_newXp] call bn_koth_fnc_progression_xp_getLevel;

_progression set ["uid", _uid];
_progression set ["xp", _newXp];
_progression set ["level", _newLevel];
_progressionByUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];
[_uid, "xp"] call bn_koth_fnc_persistence_markDirty;

private _result = createHashMapFromArray [
    ["uid", _uid],
    ["xp", _newXp],
    ["level", _newLevel],
    ["reason", _reason]
];

[_uid, "xp", _amount, _reason] call bn_koth_fnc_progression_publishUpdate;

[format [
    "XP award UID=%1 reason=%2 amount=%3 total=%4 level=%5",
    _uid,
    _reason,
    _amount,
    _newXp,
    _newLevel
]] call bn_koth_fnc_common_log;

_result

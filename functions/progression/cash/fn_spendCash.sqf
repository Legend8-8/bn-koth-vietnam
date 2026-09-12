/*
    File: fn_spendCash.sqf
    Author: Legend
    Description: Atomically validates and deducts cash from server session state.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Positive cash amount <NUMBER>
        2: Spend reason <STRING>
    Returns:
        Structured operation result <HASHMAP>
    Public: Yes
*/

params [
    ["_uid", "", [""]],
    ["_amount", 0, [0]],
    ["_reason", "", [""]]
];

private _rejected = {
    params ["_code", ["_cash", -1]];
    createHashMapFromArray [["success", false], ["code", _code], ["uid", _uid], ["cash", _cash]]
};

if (!isServer) exitWith {["NOT_SERVER"] call _rejected};
if (_uid isEqualTo "") exitWith {["INVALID_UID"] call _rejected};
if !(finite _amount) exitWith {["INVALID_AMOUNT"] call _rejected};
if (_amount <= 0) exitWith {["INVALID_AMOUNT"] call _rejected};
if (_reason isEqualTo "") exitWith {["INVALID_REASON"] call _rejected};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {["PLAYER_RECORDS_UNAVAILABLE"] call _rejected};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {["PLAYER_NOT_REGISTERED"] call _rejected};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE"] call _rejected};
private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE"] call _rejected};

private _oldCash = _progression getOrDefault ["cash", -1];
if !(_oldCash isEqualType 0 && {finite _oldCash} && {_oldCash >= 0}) exitWith {["CASH_UNINITIALIZED"] call _rejected};
if (_oldCash < _amount) exitWith {["INSUFFICIENT_CASH", _oldCash] call _rejected};

private _newCash = _oldCash - _amount;
_progression set ["cash", _newCash];
_progressionByUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];
[_uid, "cash"] call bn_koth_fnc_persistence_markDirty;

[_uid, "cash", -_amount, _reason] call bn_koth_fnc_progression_publishUpdate;
[format ["Cash spend UID=%1 reason=%2 amount=%3 total=%4", _uid, _reason, _amount, _newCash]] call bn_koth_fnc_common_log;

createHashMapFromArray [
    ["success", true], ["code", "CASH_SPENT"], ["uid", _uid],
    ["amount", _amount], ["cash", _newCash], ["reason", _reason]
]

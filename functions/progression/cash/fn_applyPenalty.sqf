/*
    File: fn_applyPenalty.sqf
    Author: Legend
    Description: Applies a bounded server-owned cash penalty without allowing negative cash.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: Positive requested penalty <NUMBER>, 2: Reason <STRING>
    Returns: Actual cash deducted <NUMBER>
    Public: No
*/

params [["_uid", "", [""]], ["_amount", 0, [0]], ["_reason", "", [""]]];
if (!isServer || {_uid isEqualTo ""} || {!finite _amount} || {_amount <= 0} || {_reason isEqualTo ""}) exitWith {0};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !((_records getOrDefault [_uid, createHashMap]) isEqualType createHashMap) exitWith {0};
private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _progression = _byUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {0};

private _oldCash = _progression getOrDefault ["cash", -1];
if !(_oldCash isEqualType 0 && {finite _oldCash} && {_oldCash >= 0}) exitWith {0};
private _deducted = _amount min _oldCash;
if (_deducted <= 0) exitWith {0};
_progression set ["cash", _oldCash - _deducted];
_byUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
[_uid, "cash"] call bn_koth_fnc_persistence_markDirty;
[_uid, "cash", -_deducted, _reason] call bn_koth_fnc_progression_publishUpdate;
[_uid, "cash", -_deducted] call bn_koth_fnc_roundStats_recordReward;
_deducted

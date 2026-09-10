/*
    File: fn_applyPenalty.sqf
    Author: Legend
    Description: Applies a bounded server-owned XP penalty without allowing negative XP.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: Positive requested penalty <NUMBER>, 2: Reason <STRING>
    Returns: Actual XP deducted <NUMBER>
    Public: No
*/

params [["_uid", "", [""]], ["_amount", 0, [0]], ["_reason", "", [""]]];
if (!isServer || {_uid isEqualTo ""} || {!finite _amount} || {_amount <= 0} || {_reason isEqualTo ""}) exitWith {0};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !((_records getOrDefault [_uid, createHashMap]) isEqualType createHashMap) exitWith {0};
private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _progression = _byUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {0};

private _oldXp = _progression getOrDefault ["xp", 0];
if !(_oldXp isEqualType 0 && {finite _oldXp} && {_oldXp >= 0}) exitWith {0};
private _deducted = _amount min _oldXp;
if (_deducted <= 0) exitWith {0};
private _newXp = _oldXp - _deducted;
private _oldLevel = _progression getOrDefault ["level", [_oldXp] call bn_koth_fnc_progression_xp_getLevel];
private _newLevel = [_newXp] call bn_koth_fnc_progression_xp_getLevel;
_progression set ["xp", _newXp];
_progression set ["level", _newLevel];
_byUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
[_uid, "xp"] call bn_koth_fnc_persistence_markDirty;
[_uid, "xp", -_deducted, _reason] call bn_koth_fnc_progression_publishUpdate;
[_uid, "xp", -_deducted] call bn_koth_fnc_roundStats_recordReward;
if !(_newLevel isEqualTo _oldLevel) then {[] call bn_koth_fnc_teams_publishState};
_deducted

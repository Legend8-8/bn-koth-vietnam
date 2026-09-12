/*
    File: fn_registerParticipant.sqf
    Author: Legend
    Description: Creates the canonical round-accounting entry for one deployed participant.
    Execution: Server
    Parameters: 0: Player UID <STRING>
    Returns: Whether the participant was registered <BOOL>
    Public: No
*/

params [["_uid", "", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {false};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};
if !(_record getOrDefault ["deployed", false]) exitWith {false};

private _side = _record getOrDefault ["assignedSide", sideUnknown];
if !([_side] call bn_koth_fnc_teams_validateSide) exitWith {false};

private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
if !(_stats isEqualType createHashMap) then {_stats = createHashMap};
private _entry = _stats getOrDefault [_uid, createHashMap];
if !(_entry isEqualType createHashMap) then {_entry = createHashMap};

if !(_entry getOrDefault ["registered", false]) then {
    private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
    private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
    if !(_progression isEqualType createHashMap) then {_progression = createHashMap};

    _entry set ["registered", true];
    _entry set ["joinedAt", serverTime];
    _entry set ["startLevel", _progression getOrDefault ["level", 1]];
    _entry set ["xpEarned", 0];
    _entry set ["cashEarned", 0];
};

_entry set ["name", _record getOrDefault ["name", _uid]];
_entry set ["side", _side];
_stats set [_uid, _entry];
missionNamespace setVariable ["BN_KOTH_roundStats", _stats];
true

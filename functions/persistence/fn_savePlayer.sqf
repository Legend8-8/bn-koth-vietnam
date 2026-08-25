/*
    File: fn_savePlayer.sqf
    Author: Legend
    Description: Saves one authoritative player projection through the persistence adapter.
    Execution: Server
    Public: Yes
*/

params [["_uid", "", [""]], ["_reason", "explicit", [""]]];

private _fail = {
    params ["_code"];
    createHashMapFromArray [["success", false], ["code", _code], ["uid", _uid], ["reason", _reason]]
};

if (!isServer) exitWith {["NOT_SERVER"] call _fail};
if (_uid isEqualTo "") exitWith {["INVALID_UID"] call _fail};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_byUid isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE"] call _fail};
private _state = _byUid getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {["PLAYER_STATE_UNAVAILABLE"] call _fail};
private _projection = [_uid, _state] call bn_koth_fnc_persistence_projectPlayerState;
if !(_projection isEqualType createHashMap && {(count _projection) > 0}) exitWith {["PROJECTION_FAILED"] call _fail};

private _backendResult = [_uid, _projection] call bn_koth_fnc_persistence_backendSavePlayer;
if !(_backendResult getOrDefault ["success", false]) exitWith {
    private _failedDirty = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
    if !(_failedDirty isEqualType createHashMap) then {_failedDirty = createHashMap};
    private _failedEntry = _failedDirty getOrDefault [_uid, createHashMap];
    if !(_failedEntry isEqualType createHashMap) then {_failedEntry = createHashMap};
    _failedEntry set ["dirty", true];
    _failedEntry set ["lastFailure", _backendResult getOrDefault ["code", "SAVE_FAILED"]];
    _failedEntry set ["lastAttemptAt", diag_tickTime];
    _failedDirty set [_uid, _failedEntry];
    missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", _failedDirty];
    [format ["Persistence save failed UID=%1 reason=%2 code=%3", _uid, _reason, _backendResult getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
    [_backendResult getOrDefault ["code", "SAVE_FAILED"]] call _fail
};

private _dirty = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
if (_dirty isEqualType createHashMap) then {
    _dirty deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", _dirty];
};
[format ["Persistence save succeeded UID=%1 reason=%2", _uid, _reason]] call bn_koth_fnc_common_log;
createHashMapFromArray [["success", true], ["code", "SAVED"], ["uid", _uid], ["reason", _reason]]

/*
    File: fn_loadPlayer.sqf
    Author: Legend
    Description: Establishes one authoritative session progression state from persistence or deliberate fallback.
    Execution: Server
    Public: Yes
*/

params [["_uid", "", [""]]];

private _result = {
    params ["_success", "_code", "_state", ["_persistent", false], ["_reason", ""]];
    createHashMapFromArray [["success", _success], ["code", _code], ["uid", _uid], ["state", _state], ["persistent", _persistent], ["reason", _reason]]
};

if (!isServer) exitWith {[false, "NOT_SERVER", createHashMap] call _result};
if (_uid isEqualTo "") exitWith {[false, "INVALID_UID", createHashMap] call _result};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_byUid isEqualType createHashMap) then {_byUid = createHashMap};
private _loaded = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
if !(_loaded isEqualType createHashMap) then {_loaded = createHashMap};

if !(isNil {_loaded get _uid}) exitWith {
    private _existing = _byUid getOrDefault [_uid, createHashMap];
    if (_existing isEqualType createHashMap) then {
        [true, "ALREADY_LOADED", _existing, (_loaded getOrDefault [_uid, ""]) isEqualTo "LOADED"] call _result
    } else {
        [false, "LOADED_STATE_MISSING", createHashMap] call _result
    }
};

private _commit = {
    params ["_state", "_loadedCode"];
    _byUid set [_uid, _state];
    missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
    _loaded set [_uid, _loadedCode];
    missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", _loaded];
};
private _fallbackAllowed = missionNamespace getVariable ["BN_KOTH_persistenceSessionFallback", true];
private _backendResult = [_uid] call bn_koth_fnc_persistence_backendLoadPlayer;

if !(_backendResult getOrDefault ["success", false]) exitWith {
    if (!_fallbackAllowed) then {
        [false, _backendResult getOrDefault ["code", "LOAD_FAILED"], createHashMap, false, "Persistence load failed and session fallback is disabled."] call _result
    } else {
        private _state = [_uid] call bn_koth_fnc_persistence_createDefaultState;
        [_state, "SESSION_FALLBACK"] call _commit;
        [format ["Persistence load fallback UID=%1 backendCode=%2", _uid, _backendResult getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
        [true, "SESSION_FALLBACK", _state, false, _backendResult getOrDefault ["code", "LOAD_FAILED"]] call _result
    }
};

if !(_backendResult getOrDefault ["found", false]) exitWith {
    private _state = [_uid] call bn_koth_fnc_persistence_createDefaultState;
    [_state, "FIRST_TIME"] call _commit;
    [_uid, "first_time"] call bn_koth_fnc_persistence_markDirty;
    [format ["Persistence first-time state created UID=%1", _uid]] call bn_koth_fnc_common_log;
    [true, "FIRST_TIME", _state, false] call _result
};

private _normalized = [_uid, _backendResult getOrDefault ["record", createHashMap]] call bn_koth_fnc_persistence_normalizePlayerState;
if !(_normalized getOrDefault ["success", false]) exitWith {
    if (!_fallbackAllowed) then {
        [false, _normalized getOrDefault ["code", "NORMALIZATION_FAILED"], createHashMap, false, _normalized getOrDefault ["message", ""]] call _result
    } else {
        private _state = [_uid] call bn_koth_fnc_persistence_createDefaultState;
        [_state, "SESSION_FALLBACK"] call _commit;
        [format ["Persistence malformed-record fallback UID=%1 code=%2", _uid, _normalized getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
        [true, "SESSION_FALLBACK", _state, false, _normalized getOrDefault ["code", "NORMALIZATION_FAILED"]] call _result
    }
};

private _state = _normalized get "state";
[_state, "LOADED"] call _commit;
private _dirty = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
if (_dirty isEqualType createHashMap) then {
    _dirty deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", _dirty];
};
[format ["Persistence state loaded UID=%1 schemaCode=%2 warnings=%3", _uid, _normalized getOrDefault ["code", ""], _normalized getOrDefault ["warnings", []]]] call bn_koth_fnc_common_log;
[true, "LOADED", _state, true] call _result

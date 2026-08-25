/*
    File: fn_backendSavePlayer.sqf
    Author: Legend
    Description: Saves one persistent projection through the configured backend adapter.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]], ["_projection", createHashMap, [createHashMap]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_uid isEqualTo "" || {!(_projection isEqualType createHashMap)}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_SAVE_REQUEST"], ["uid", _uid]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"], ["uid", _uid]]};
if (missionNamespace getVariable ["BN_KOTH_persistenceTestFailSave", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_SAVE_FAILED"], ["uid", _uid]]};

private _backend = missionNamespace getVariable ["BN_KOTH_persistenceBackend", ""];
if !(_backend isEqualTo "MEMORY") exitWith {createHashMapFromArray [["success", false], ["code", "UNSUPPORTED_BACKEND"], ["uid", _uid]]};

private _records = missionNamespace getVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
if !(_records isEqualType createHashMap) then {_records = createHashMap};
_records set [_uid, _projection];
missionNamespace setVariable ["BN_KOTH_persistenceMemoryBackend", _records];

createHashMapFromArray [["success", true], ["code", "SAVED"], ["uid", _uid]]


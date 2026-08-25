/*
    File: fn_backendLoadPlayer.sqf
    Author: Legend
    Description: Loads one raw record through the configured persistence backend adapter.
    Execution: Server
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_uid isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_UID"]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"], ["uid", _uid]]};
if (missionNamespace getVariable ["BN_KOTH_persistenceTestFailLoad", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_LOAD_FAILED"], ["uid", _uid]]};

private _backend = missionNamespace getVariable ["BN_KOTH_persistenceBackend", ""];
if !(_backend isEqualTo "MEMORY") exitWith {createHashMapFromArray [["success", false], ["code", "UNSUPPORTED_BACKEND"], ["uid", _uid]]};

private _records = missionNamespace getVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
if !(_records isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_STATE_INVALID"], ["uid", _uid]]};
if (isNil {_records get _uid}) exitWith {createHashMapFromArray [["success", true], ["code", "NOT_FOUND"], ["uid", _uid], ["found", false]]};

createHashMapFromArray [["success", true], ["code", "LOADED"], ["uid", _uid], ["found", true], ["record", _records get _uid]]


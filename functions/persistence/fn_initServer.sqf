/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes the server-only persistence service and its configured backend adapter.
    Execution: Server
    Public: Yes
*/

if (!isServer) exitWith {};

private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _schemaVersion = if (isNumber (_cfg >> "schemaVersion")) then {getNumber (_cfg >> "schemaVersion")} else {1};
private _backend = if (isText (_cfg >> "backend")) then {toUpper getText (_cfg >> "backend")} else {"EXTDB3"};
private _debounce = if (isNumber (_cfg >> "saveDebounceSeconds")) then {getNumber (_cfg >> "saveDebounceSeconds")} else {15};
private _fallback = if (isNumber (_cfg >> "sessionFallbackOnFailure")) then {(getNumber (_cfg >> "sessionFallbackOnFailure")) > 0} else {true};
private _extdbDatabase = if (isText (_cfg >> "extdbDatabase")) then {getText (_cfg >> "extdbDatabase")} else {""};
private _extdbProtocol = if (isText (_cfg >> "extdbProtocol")) then {getText (_cfg >> "extdbProtocol")} else {""};
private _extdbFile = if (isText (_cfg >> "extdbSqlCustomFile")) then {getText (_cfg >> "extdbSqlCustomFile")} else {""};
private _queryTimeout = if (isNumber (_cfg >> "queryTimeoutSeconds")) then {getNumber (_cfg >> "queryTimeoutSeconds")} else {5};

missionNamespace setVariable ["BN_KOTH_persistenceSchemaVersion", floor (_schemaVersion max 1)];
missionNamespace setVariable ["BN_KOTH_persistenceBackend", _backend];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", false];
missionNamespace setVariable ["BN_KOTH_persistenceSaveDebounceSeconds", _debounce max 0];
missionNamespace setVariable ["BN_KOTH_persistenceSessionFallback", _fallback];
missionNamespace setVariable ["BN_KOTH_persistenceExtdbDatabase", _extdbDatabase];
missionNamespace setVariable ["BN_KOTH_persistenceExtdbProtocol", _extdbProtocol];
missionNamespace setVariable ["BN_KOTH_persistenceExtdbSqlCustomFile", _extdbFile];
missionNamespace setVariable ["BN_KOTH_persistenceQueryTimeoutSeconds", _queryTimeout max 0.1];
missionNamespace setVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];

if !(missionNamespace getVariable ["BN_KOTH_persistenceShutdownHandlerInstalled", false]) then {
    addMissionEventHandler ["MPEnded", {
        ["mission_end"] call bn_koth_fnc_persistence_saveAllDirty;
    }];
    missionNamespace setVariable ["BN_KOTH_persistenceShutdownHandlerInstalled", true];
};

private _backendResult = switch (_backend) do {
    case "MEMORY": {createHashMapFromArray [["success", true], ["code", "MEMORY_READY"]]};
    case "EXTDB3": {[] call bn_koth_fnc_persistence_extdbInitialize};
    default {createHashMapFromArray [["success", false], ["code", "UNSUPPORTED_BACKEND"]]};
};
private _ready = _backendResult getOrDefault ["success", false];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", _ready];
private _level = if (_ready) then {"INFO"} else {"ERROR"};
[format ["Persistence service initialized backend=%1 schemaVersion=%2 fallback=%3 ready=%4 code=%5", _backend, missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1], _fallback, _ready, _backendResult getOrDefault ["code", "UNKNOWN"]], _level] call bn_koth_fnc_common_log;

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
private _backend = if (isText (_cfg >> "backend")) then {toUpper getText (_cfg >> "backend")} else {"MEMORY"};
private _debounce = if (isNumber (_cfg >> "saveDebounceSeconds")) then {getNumber (_cfg >> "saveDebounceSeconds")} else {15};
private _fallback = if (isNumber (_cfg >> "sessionFallbackOnFailure")) then {(getNumber (_cfg >> "sessionFallbackOnFailure")) > 0} else {true};

missionNamespace setVariable ["BN_KOTH_persistenceSchemaVersion", floor (_schemaVersion max 1)];
missionNamespace setVariable ["BN_KOTH_persistenceBackend", _backend];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", _backend isEqualTo "MEMORY"];
missionNamespace setVariable ["BN_KOTH_persistenceSaveDebounceSeconds", _debounce max 0];
missionNamespace setVariable ["BN_KOTH_persistenceSessionFallback", _fallback];
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

private _level = if (_backend isEqualTo "MEMORY") then {"INFO"} else {"ERROR"};
[format ["Persistence service initialized backend=%1 schemaVersion=%2 fallback=%3", _backend, missionNamespace getVariable ["BN_KOTH_persistenceSchemaVersion", 1], _fallback], _level] call bn_koth_fnc_common_log;


/*
    File: fn_extdbInitialize.sqf
    Author: Legend
    Description: Initializes the server-local extDB3 database and SQL_CUSTOM protocol.
    Execution: Server
    Public: No
*/

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};

private _database = missionNamespace getVariable ["BN_KOTH_persistenceExtdbDatabase", ""];
private _protocol = missionNamespace getVariable ["BN_KOTH_persistenceExtdbProtocol", ""];
private _file = missionNamespace getVariable ["BN_KOTH_persistenceExtdbSqlCustomFile", ""];
if (_database isEqualTo "" || {_protocol isEqualTo ""} || {_file isEqualTo ""}) exitWith {createHashMapFromArray [["success", false], ["code", "EXTDB_CONFIG_INVALID"]]};

private _version = "extDB3" callExtension "9:VERSION";
if (_version isEqualTo "" || {(parseNumber _version) <= 0}) exitWith {createHashMapFromArray [["success", false], ["code", "EXTENSION_NOT_LOADED"]]};

private _databaseRaw = "extDB3" callExtension format ["9:ADD_DATABASE:%1", _database];
private _databaseResult = [_databaseRaw, "DATABASE"] call bn_koth_fnc_persistence_parseExtdbSystemResponse;
private _databaseState = _databaseResult getOrDefault ["state", "FAILED"];
if (_databaseState isEqualTo "REUSE_CANDIDATE") then {_databaseState = "REUSED_EXISTING"};
if (_databaseState isEqualTo "FAILED") exitWith {
    [format ["Persistence extDB3 database registration failed database=%1 responseCode=%2 message=%3", _database, _databaseResult getOrDefault ["code", "UNKNOWN"], _databaseResult getOrDefault ["message", ""]], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", "DATABASE_CONNECTION_FAILED"], ["databaseState", _databaseState], ["protocolState", "NOT_ATTEMPTED"]]
};
[format ["Persistence extDB3 database registration state=%1 database=%2", _databaseState, _database], "INFO"] call bn_koth_fnc_common_log;

private _protocolRaw = "extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:SQL_CUSTOM:%2:%3", _database, _protocol, _file];
private _protocolResult = [_protocolRaw, "PROTOCOL"] call bn_koth_fnc_persistence_parseExtdbSystemResponse;
private _protocolState = _protocolResult getOrDefault ["state", "FAILED"];
if (_protocolState isEqualTo "FAILED") exitWith {
    [format ["Persistence extDB3 protocol registration failed protocol=%1 responseCode=%2 message=%3", _protocol, _protocolResult getOrDefault ["code", "UNKNOWN"], _protocolResult getOrDefault ["message", ""]], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", "DATABASE_PROTOCOL_FAILED"], ["databaseState", _databaseState], ["protocolState", "FAILED"]]
};

private _probeStarted = diag_tickTime;
private _probeRaw = "extDB3" callExtension format ["0:%1:healthCheck", _protocol];
private _probeElapsed = diag_tickTime - _probeStarted;
private _probeTimeout = missionNamespace getVariable ["BN_KOTH_persistenceQueryTimeoutSeconds", 5];
if (_probeElapsed > _probeTimeout) exitWith {
    [format ["Persistence extDB3 protocol verification timed out protocol=%1 elapsed=%2", _protocol, _probeElapsed], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", "DATABASE_PROTOCOL_PROBE_TIMEOUT"], ["databaseState", _databaseState], ["protocolState", "FAILED"]]
};

private _probeResult = [_probeRaw, "BN_KOTH_PERSISTENCE_V4"] call bn_koth_fnc_persistence_parseExtdbResponse;
if !(_probeResult getOrDefault ["success", false]) exitWith {
    [format ["Persistence extDB3 protocol verification failed protocol=%1 registrationCode=%2 registrationMessage=%3 probeCode=%4", _protocol, _protocolResult getOrDefault ["code", "UNKNOWN"], _protocolResult getOrDefault ["message", ""], _probeResult getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", "DATABASE_PROTOCOL_UNUSABLE"], ["databaseState", _databaseState], ["protocolState", "FAILED"]]
};

if (_protocolState isEqualTo "REUSE_CANDIDATE") then {_protocolState = "REUSED_EXISTING"};
[format ["Persistence extDB3 protocol registration state=%1 protocol=%2 verification=HEALTH_CHECK_OK", _protocolState, _protocol], "INFO"] call bn_koth_fnc_common_log;

private _lifecycle = if (_databaseState isEqualTo "COLD_REGISTERED" && {_protocolState isEqualTo "COLD_REGISTERED"}) then {"COLD_INIT"} else {"MISSION_RELOAD_REUSE"};

createHashMapFromArray [
    ["success", true], ["code", "EXTDB_READY"], ["version", _version], ["lifecycle", _lifecycle],
    ["databaseState", _databaseState], ["protocolState", _protocolState]
]

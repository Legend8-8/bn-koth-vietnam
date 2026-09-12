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
if (_version isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "EXTENSION_NOT_LOADED"]]};

private _systemSucceeded = {
    params ["_raw"];
    private _parsed = [];
    private _failed = false;
    try {_parsed = parseSimpleArray _raw} catch {_failed = true};
    !_failed && {_parsed isEqualType []} && {(count _parsed) >= 1} && {(_parsed select 0) isEqualType 0} && {(_parsed select 0) isEqualTo 1}
};
private _databaseRaw = "extDB3" callExtension format ["9:ADD_DATABASE:%1", _database];
if !([_databaseRaw] call _systemSucceeded) exitWith {createHashMapFromArray [["success", false], ["code", "DATABASE_CONNECTION_FAILED"]]};

private _protocolRaw = "extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:SQL_CUSTOM:%2:%3", _database, _protocol, _file];
if !([_protocolRaw] call _systemSucceeded) exitWith {createHashMapFromArray [["success", false], ["code", "DATABASE_PROTOCOL_FAILED"]]};

createHashMapFromArray [["success", true], ["code", "EXTDB_READY"], ["version", _version]]

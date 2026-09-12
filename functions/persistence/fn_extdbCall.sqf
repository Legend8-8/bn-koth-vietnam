/*
    File: fn_extdbCall.sqf
    Author: Legend
    Description: Executes one synchronous named SQL_CUSTOM call through the initialized extDB3 protocol.
    Execution: Server
    Public: No
*/

params [["_statement", "", [""]], ["_parameters", [], [[]]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_statement isEqualTo "" || {!(_parameters isEqualType [])}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_EXTDB_CALL"]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"]]};

private _protocol = missionNamespace getVariable ["BN_KOTH_persistenceExtdbProtocol", ""];
if (_protocol isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "EXTDB_PROTOCOL_UNAVAILABLE"]]};
private _parts = [format ["0:%1:%2", _protocol, _statement]];
{_parts pushBack (if (_x isEqualType "") then {_x} else {str _x})} forEach _parameters;
private _query = _parts joinString ":";
private _started = diag_tickTime;
private _raw = "extDB3" callExtension _query;
private _elapsed = diag_tickTime - _started;
private _timeout = missionNamespace getVariable ["BN_KOTH_persistenceQueryTimeoutSeconds", 5];
if (_elapsed > _timeout) exitWith {
    [format ["Persistence extDB3 query exceeded timeout statement=%1 elapsed=%2", _statement, _elapsed], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", "QUERY_TIMEOUT"], ["elapsed", _elapsed]]
};
private _result = [_raw] call bn_koth_fnc_persistence_parseExtdbResponse;
_result set ["elapsed", _elapsed];
_result

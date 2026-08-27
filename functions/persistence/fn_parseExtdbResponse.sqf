/*
    File: fn_parseExtdbResponse.sqf
    Author: Legend
    Description: Parses one bounded extDB3 response as data and rejects malformed/error replies.
    Execution: Server
    Public: No
*/

params [["_raw", "", [""]]];

if (_raw isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "EXTENSION_NO_RESPONSE"], ["rows", []]]};
private _parsed = [];
private _parseFailed = false;
try {
    _parsed = parseSimpleArray _raw;
} catch {
    _parseFailed = true;
};
if (_parseFailed || {!(_parsed isEqualType [])} || {(count _parsed) < 1} || {!((_parsed select 0) isEqualType 0)}) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_EXTDB_RESPONSE"], ["rows", []]]
};
if ((_parsed select 0) != 1) exitWith {createHashMapFromArray [["success", false], ["code", "EXTDB_QUERY_REJECTED"], ["rows", []]]};
if ((count _parsed) != 2 || {!((_parsed select 1) isEqualType [])}) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_EXTDB_SUCCESS"], ["rows", []]]
};
createHashMapFromArray [["success", true], ["code", "EXTDB_OK"], ["rows", _parsed select 1]]

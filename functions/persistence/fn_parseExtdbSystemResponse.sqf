/*
    File: fn_parseExtdbSystemResponse.sqf
    Author: Legend
    Description: Parses and classifies one extDB3 registration response using its documented/source-defined exact messages.
    Execution: Server
    Parameters:
        0: Raw extDB3 response <STRING>
        1: Registration kind: DATABASE or PROTOCOL <STRING>
    Returns: Parsed response metadata <HASHMAP>
    Public: No
*/

params [["_raw", "", [""]], ["_kind", "", [""]]];

_kind = toUpper _kind;
if !(_kind in ["DATABASE", "PROTOCOL"]) exitWith {
    createHashMapFromArray [["valid", false], ["success", false], ["code", "INVALID_REGISTRATION_KIND"], ["message", ""], ["state", "FAILED"]]
};

if (_raw isEqualTo "") exitWith {
    createHashMapFromArray [["valid", false], ["success", false], ["code", "SYSTEM_NO_RESPONSE"], ["message", ""], ["state", "FAILED"]]
};

private _parsed = [];
private _parseFailed = false;
try {
    _parsed = parseSimpleArray _raw;
} catch {
    _parseFailed = true;
};

if (_parseFailed || {!(_parsed isEqualType [])} || {(count _parsed) < 1} || {!((_parsed select 0) isEqualType 0)}) exitWith {
    createHashMapFromArray [["valid", false], ["success", false], ["code", "MALFORMED_SYSTEM_RESPONSE"], ["message", ""], ["state", "FAILED"]]
};

private _status = _parsed select 0;
if (_status isEqualTo 1) exitWith {
    if ((count _parsed) isEqualTo 1) then {
        createHashMapFromArray [["valid", true], ["success", true], ["code", "SYSTEM_OK"], ["message", ""], ["state", "COLD_REGISTERED"]]
    } else {
        createHashMapFromArray [["valid", false], ["success", false], ["code", "MALFORMED_SYSTEM_SUCCESS"], ["message", ""], ["state", "FAILED"]]
    }
};

if !(_status isEqualTo 0) exitWith {
    createHashMapFromArray [["valid", false], ["success", false], ["code", "MALFORMED_SYSTEM_STATUS"], ["message", ""], ["state", "FAILED"]]
};

if ((count _parsed) != 2 || {!((_parsed select 1) isEqualType "")}) exitWith {
    createHashMapFromArray [["valid", false], ["success", false], ["code", "MALFORMED_SYSTEM_REJECTION"], ["message", ""], ["state", "FAILED"]]
};

private _message = _parsed select 1;
// extDB3 returns these exact strings before attempting a second connection or
// protocol load. Every other rejection represents a real setup failure.
private _duplicateMessage = if (_kind isEqualTo "DATABASE") then {"Already Connected to Database"} else {"Error Protocol Name Already Taken"};
private _state = if (_message isEqualTo _duplicateMessage) then {"REUSE_CANDIDATE"} else {"FAILED"};
createHashMapFromArray [["valid", true], ["success", false], ["code", "SYSTEM_REJECTED"], ["message", _message], ["state", _state]]

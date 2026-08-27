/*
    File: fn_receiveTransferHandoffAck.sqf
    Author: Legend
    Description: Receives a client's self-reported local player-handoff outcome
        for one pending representation transfer and records it for
        fn_transferRepresentation.sqf to observe. Resolves the pending
        transfer from remoteExecutedOwner, never a client-supplied UID, and
        only accepts an ack whose token and target match what the server is
        currently expecting for that owner; anything else is ignored/logged.
    Execution: Server
    Parameters:
        0: Transfer token <STRING>
        1: Target unit the client attempted to switch to <OBJECT>
        2: Locally observed switch outcome <BOOL>
    Returns:
        None
    Public: Yes
*/

params [["_token", "", [""]], ["_targetUnit", objNull, [objNull]], ["_confirmed", false, [false]]];

if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected transfer handoff ack without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _pending = missionNamespace getVariable ["BN_KOTH_transferHandoffPending", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {};

private _uid = "";
{
    private _candidate = _pending get _x;
    if (_candidate isEqualType createHashMap && {(_candidate getOrDefault ["ownerId", -1]) isEqualTo _ownerId}) exitWith {
        _uid = _x;
    };
} forEach (keys _pending);

if (_uid isEqualTo "") exitWith {
    [format ["Ignored transfer handoff ack: no pending transfer for owner=%1 token=%2", _ownerId, _token], "WARN"] call bn_koth_fnc_common_log;
};

private _pendingRecord = _pending get _uid;
private _expectedToken = _pendingRecord getOrDefault ["token", ""];
private _expectedTarget = _pendingRecord getOrDefault ["targetUnit", objNull];

if (_token isEqualTo "" || {!(_token isEqualTo _expectedToken)} || {!(_targetUnit isEqualTo _expectedTarget)}) exitWith {
    [format ["Ignored stale/mismatched transfer handoff ack UID=%1 owner=%2 expectedToken=%3 gotToken=%4", _uid, _ownerId, _expectedToken, _token], "WARN"] call bn_koth_fnc_common_log;
};

_pendingRecord set ["ack", if (_confirmed) then {"CONFIRMED"} else {"REJECTED"}];
_pending set [_uid, _pendingRecord];
missionNamespace setVariable ["BN_KOTH_transferHandoffPending", _pending];

[format ["Transfer handoff ack received UID=%1 owner=%2 token=%3 confirmed=%4", _uid, _ownerId, _token, _confirmed], "INFO"] call bn_koth_fnc_common_log;

/*
    File: fn_transferRepresentation.sqf
    Author: Legend
    Description: Transfers a connected human to a server-selected representation unit.
        Commits only once the client has explicitly acknowledged the local
        player-handoff outcome for this exact attempt (token+target matched);
        owner locality alone is a necessary but not sufficient condition.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Target unit <OBJECT>
        2: Target logical state <STRING>
        3: Delete previous unit on success <BOOL>
    Returns:
        True on successful ownership handoff, otherwise false <BOOL>
    Public: Yes
*/

params ["_uid", "_targetUnit", ["_targetState", "LOBBY", [""]], ["_deletePrevious", true, [true]]];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};
if (isNull _targetUnit) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
if (_ownerId <= 0) exitWith {false};

private _oldUnit = _record getOrDefault ["currentUnit", objNull];
if (isNull _oldUnit) then {
    _oldUnit = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
};

private _clearPending = {
    params ["_uid"];
    private _pending = missionNamespace getVariable ["BN_KOTH_transferHandoffPending", createHashMap];
    if (_pending isEqualType createHashMap) then {
        _pending deleteAt _uid;
        missionNamespace setVariable ["BN_KOTH_transferHandoffPending", _pending];
    };
};

private _token = format ["%1-%2-%3", _uid, diag_tickTime, floor (random 1000000)];
private _pending = missionNamespace getVariable ["BN_KOTH_transferHandoffPending", createHashMap];
if !(_pending isEqualType createHashMap) then {_pending = createHashMap};
private _existingPending = _pending getOrDefault [_uid, createHashMap];
if (_existingPending isEqualType createHashMap && {(_existingPending getOrDefault ["ack", ""]) in ["PENDING", "CONFIRMED"]}) exitWith {
    [format ["Representation handoff rejected: transfer already pending for UID %1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};
_pending set [_uid, createHashMapFromArray [
    ["token", _token],
    ["targetUnit", _targetUnit],
    ["ownerId", _ownerId],
    ["ack", "PENDING"]
]];
missionNamespace setVariable ["BN_KOTH_transferHandoffPending", _pending];

[format ["transferRepresentation dispatch uid=%1 owner=%2 target=%3 state=%4 token=%5", _uid, _ownerId, typeOf _targetUnit, _targetState, _token], "INFO"] call bn_koth_fnc_common_log;
[_targetUnit, _token] remoteExecCall ["bn_koth_fnc_ui_selectControlledUnit", _ownerId];

private _deadline = serverTime + 5;
private _ackStatus = "PENDING";
waitUntil {
    private _currentPending = (missionNamespace getVariable ["BN_KOTH_transferHandoffPending", createHashMap]) getOrDefault [_uid, createHashMap];
    _ackStatus = _currentPending getOrDefault ["ack", "PENDING"];
    private _ownerReady = !isNull _targetUnit && {(owner _targetUnit) isEqualTo _ownerId};
    (serverTime >= _deadline)
    || {_ackStatus isEqualTo "REJECTED"}
    || {_ackStatus isEqualTo "CONFIRMED" && {_ownerReady}}
};

private _ownerConfirmed = !isNull _targetUnit && {(owner _targetUnit) isEqualTo _ownerId};
if (_ackStatus isEqualTo "CONFIRMED" && {_ownerConfirmed}) exitWith {
    [format ["Representation handoff success for UID %1 to unit %2 owner=%3 token=%4", _uid, _targetUnit, owner _targetUnit, _token], "INFO"] call bn_koth_fnc_common_log;

    if (_deletePrevious && {!isNull _oldUnit} && {!(_oldUnit isEqualTo _targetUnit)}) then {
        private _oldGroup = group _oldUnit;
        deleteVehicle _oldUnit;

        if (!isNull _oldGroup && {(count units _oldGroup) isEqualTo 0}) then {
            deleteGroup _oldGroup;
        };
    };

    _record set ["currentUnit", _targetUnit];
    _record set ["state", _targetState];
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
    [_uid] call _clearPending;
    [_targetUnit, _uid] call bn_koth_fnc_curator_init;
    [_targetUnit] remoteExecCall ["bn_koth_fnc_playerMapMarkers_initPlayerLocal", _ownerId];
    [_targetUnit] remoteExecCall ["bn_koth_fnc_player3DIcons_initPlayerLocal", _ownerId];
    [_targetUnit] remoteExecCall ["bn_koth_fnc_escMenu_initPlayerLocal", _ownerId];
    [] remoteExecCall ["bn_koth_fnc_build_initPlayerLocal", _ownerId];

    true
};

[format ["Representation handoff failed for UID %1 to unit %2 owner=%3 token=%4 ackStatus=%5 ownerConfirmed=%6", _uid, _targetUnit, owner _targetUnit, _token, _ackStatus, _ownerConfirmed], "ERROR"] call bn_koth_fnc_common_log;
[_uid] call _clearPending;
false

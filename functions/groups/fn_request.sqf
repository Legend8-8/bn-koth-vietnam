/*
    File: fn_request.sqf
    Author: Legend
    Description: Resolves a remote caller and handles group snapshot/mutation intent.
    Execution: Client/Server
    Parameters:
        0: Operation <STRING>
        1: Target group/member ID <STRING>
    Returns: None
    Public: Yes
*/

params [["_operation", "SNAPSHOT", [""]], ["_target", "", [""]]];

if (hasInterface && {!isServer}) exitWith {
    [_operation, _target] remoteExecCall ["bn_koth_fnc_groups_request", 2];
};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [_operation, _target] remoteExecCall ["bn_koth_fnc_groups_request", 2];
};
if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected group request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _player = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _player || {!isPlayer _player}) exitWith {
    [format ["Rejected group request: no human player for owner %1", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _player;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    ["Rejected group request: player registry unavailable.", "WARN"] call bn_koth_fnc_common_log;
};
private _record = _records getOrDefault [_uid, createHashMap];
if (_uid isEqualTo "" || {!(_record isEqualType createHashMap)}
    || {(_record getOrDefault ["uid", ""]) isNotEqualTo _uid}
    || {(_record getOrDefault ["ownerId", -1]) isNotEqualTo _ownerId}
    || {!((_record getOrDefault ["currentUnit", objNull]) isEqualTo _player)}) exitWith {
    [format ["Rejected group request: registry identity mismatch owner=%1 uid=%2", _ownerId, _uid], "WARN"] call bn_koth_fnc_common_log;
};

_operation = toUpper _operation;
if (_operation isEqualTo "SNAPSHOT") exitWith {
    [[_uid] call bn_koth_fnc_groups_buildPresentationState] remoteExecCall ["bn_koth_fnc_groupMenu_receiveState", _ownerId];
};

private _directInviteOperation = _operation in ["INVITE", "DECLINE_INVITE"];
private _impactBefore = if (_directInviteOperation) then {
    [[], []] call bn_koth_fnc_groups_capturePresentationImpact
} else {
    [[_uid, _target], [_target]] call bn_koth_fnc_groups_capturePresentationImpact
};
private _mutation = [_uid, _operation, _target] call bn_koth_fnc_groups_mutate;
private _message = _mutation getOrDefault ["message", "Group request rejected."];
[_ownerId, _message] call bn_koth_fnc_teams_notifyPlayer;

if (_mutation getOrDefault ["changed", false]) then {
    private _impactAfter = if (_directInviteOperation) then {
        [[], []] call bn_koth_fnc_groups_capturePresentationImpact
    } else {
        [[_uid, _target], (_impactBefore getOrDefault ["groupIds", []]) + [_target]] call bn_koth_fnc_groups_capturePresentationImpact
    };
    private _groupIds = (_impactBefore getOrDefault ["groupIds", []]) + (_impactAfter getOrDefault ["groupIds", []]);
    _groupIds = _groupIds arrayIntersect _groupIds;
    if ((count _groupIds) > 0) then {
        [_groupIds] call bn_koth_fnc_groups_reconcile;
    };
    private _impactReconciled = [[], _groupIds] call bn_koth_fnc_groups_capturePresentationImpact;
    private _directImpact = createHashMapFromArray [
        ["memberUids", []],
        ["directUids", _mutation getOrDefault ["directUids", []]],
        ["sides", []],
        ["inviteCandidateSides", []]
    ];
    [[_impactBefore, _impactAfter, _impactReconciled, _directImpact]] call bn_koth_fnc_groups_publishUpdate;
};

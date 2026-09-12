/*
    File: fn_mutate.sqf
    Author: Legend
    Description: Atomically validates and commits one logical group mutation.
    Execution: Server
    Parameters:
        0: Server-derived requester UID <STRING>
        1: Operation <STRING>
        2: Target group/member ID <STRING>
    Returns: Mutation result <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_operation", "", [""]],
    ["_target", "", [""]]
];

private _result = {
    params ["_success", "_code", "_message", ["_changed", false], ["_directUids", [], [[]]]];
    createHashMapFromArray [["success", _success], ["code", _code], ["message", _message], ["changed", _changed], ["directUids", _directUids]]
};

if (!isServer) exitWith {[false, "NOT_SERVER", "Server authority required."] call _result};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_records isEqualType createHashMap && {_groups isEqualType createHashMap} && {_active isEqualType []}) exitWith {
    [false, "STATE_UNAVAILABLE", "Group state is not ready."] call _result
};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap && {(_record getOrDefault ["uid", ""]) isEqualTo _uid}) exitWith {
    [false, "PLAYER_NOT_REGISTERED", "Player state is not ready."] call _result
};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
private _eligible = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE"
    && {_uid in _active}
    && {_record getOrDefault ["deployed", false]}
    && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {[_assignedSide] call bn_koth_fnc_teams_validateSide};
if (!_eligible) exitWith {[false, "NOT_DEPLOYED", "Group management is available only while deployed."] call _result};

private _currentGroupId = "";
{
    private _logical = _groups getOrDefault [_x, createHashMap];
    if (_logical isEqualType createHashMap && {_uid in (_logical getOrDefault ["memberUids", []])}) exitWith {
        _currentGroupId = _x;
    };
} forEach (keys _groups);

_operation = toUpper _operation;
switch (_operation) do {
    case "CREATE": {
        if !(_currentGroupId isEqualTo "") exitWith {[false, "ALREADY_GROUPED", "You are already in a group."] call _result};
        private _sequence = missionNamespace getVariable ["BN_KOTH_nextGroupId", 1];
        private _groupId = format ["group_%1", _sequence];
        missionNamespace setVariable ["BN_KOTH_nextGroupId", _sequence + 1];
        _groups set [_groupId, createHashMapFromArray [
            ["id", _groupId],
            ["sequence", _sequence],
            ["displayName", format ["SQUAD %1", _sequence]],
            ["locked", false],
            ["leaderUid", _uid],
            ["memberUids", [_uid]],
            ["revision", 1],
            ["nativeGroup", grpNull],
            ["nativeSide", sideUnknown]
        ]];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "CREATED", "Group created.", true] call _result
    };
    case "JOIN": {
        if !(_currentGroupId isEqualTo "") exitWith {[false, "ALREADY_GROUPED", "Leave your current group before joining another."] call _result};
        private _targetGroup = _groups getOrDefault [_target, createHashMap];
        if !(_targetGroup isEqualType createHashMap && {(count _targetGroup) > 0}) exitWith {[false, "GROUP_NOT_FOUND", "That group no longer exists."] call _result};
        private _leaderUid = _targetGroup getOrDefault ["leaderUid", ""];
        private _members = +(_targetGroup getOrDefault ["memberUids", []]);
        if (_leaderUid isEqualTo "" || {!(_leaderUid in _members)}) exitWith {[false, "GROUP_INVALID", "That group is not currently available."] call _result};
        if (_targetGroup getOrDefault ["locked", false]) exitWith {[false, "GROUP_LOCKED", "That group is locked. Accept a current invitation to join."] call _result};
        private _leaderRecord = _records getOrDefault [_leaderUid, createHashMap];
        private _leaderSide = if (_leaderRecord isEqualType createHashMap) then {_leaderRecord getOrDefault ["assignedSide", sideUnknown]} else {sideUnknown};
        private _leaderUnit = if (_leaderRecord isEqualType createHashMap) then {_leaderRecord getOrDefault ["currentUnit", objNull]} else {objNull};
        private _leaderEligible = _leaderRecord isEqualType createHashMap
            && {_leaderUid in _active}
            && {_leaderRecord getOrDefault ["deployed", false]}
            && {(_leaderRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
            && {_leaderSide isEqualTo _assignedSide}
            && {!isNull _leaderUnit}
            && {alive _leaderUnit}
            && {isPlayer _leaderUnit}
            && {(getPlayerUID _leaderUnit) isEqualTo _leaderUid};
        if (!_leaderEligible) exitWith {[false, "GROUP_UNAVAILABLE", "That group is not currently available to your team."] call _result};
        _members pushBack _uid;
        _targetGroup set ["memberUids", _members];
        _targetGroup set ["revision", (_targetGroup getOrDefault ["revision", 0]) + 1];
        _groups set [_target, _targetGroup];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "JOINED", "Joined group.", true] call _result
    };
    case "LEAVE": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        private _leaderLeaving = (_logical getOrDefault ["leaderUid", ""]) isEqualTo _uid;
        private _invalidated = [[_uid], if (_leaderLeaving) then {[_currentGroupId]} else {[]}, [_uid], false] call bn_koth_fnc_groups_clearInvites;
        if !([_uid] call bn_koth_fnc_groups_removeMember) exitWith {[false, "LEAVE_FAILED", "Unable to leave the group."] call _result};
        [true, "LEFT", "Left group.", true, _invalidated] call _result
    };
    case "KICK": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can kick members."] call _result};
        if (_target isEqualTo _uid) exitWith {[false, "INVALID_TARGET", "The leader cannot kick themselves."] call _result};
        if !(_target in (_logical getOrDefault ["memberUids", []])) exitWith {[false, "MEMBER_NOT_FOUND", "That member is no longer in the group."] call _result};
        if !([_target] call bn_koth_fnc_groups_removeMember) exitWith {[false, "KICK_FAILED", "Unable to remove that member."] call _result};
        private _targetRecord = _records getOrDefault [_target, createHashMap];
        if (_targetRecord isEqualType createHashMap) then {
            [_targetRecord getOrDefault ["ownerId", -1], "You were removed from the group by its leader."] call bn_koth_fnc_teams_notifyPlayer;
        };
        [true, "KICKED", "Member removed from group.", true] call _result
    };
    case "TRANSFER": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can transfer leadership."] call _result};
        if (_target isEqualTo _uid || {!(_target in (_logical getOrDefault ["memberUids", []]))}) exitWith {[false, "INVALID_TARGET", "Select another current member."] call _result};
        private _targetRecord = _records getOrDefault [_target, createHashMap];
        private _targetUnit = if (_targetRecord isEqualType createHashMap) then {_targetRecord getOrDefault ["currentUnit", objNull]} else {objNull};
        private _targetEligible = _targetRecord isEqualType createHashMap
            && {_target in _active}
            && {_targetRecord getOrDefault ["deployed", false]}
            && {(_targetRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
            && {(_targetRecord getOrDefault ["assignedSide", sideUnknown]) isEqualTo _assignedSide}
            && {!isNull _targetUnit}
            && {alive _targetUnit}
            && {isPlayer _targetUnit}
            && {(getPlayerUID _targetUnit) isEqualTo _target};
        if (!_targetEligible) exitWith {[false, "TARGET_NOT_DEPLOYED", "Leadership can be transferred only to a deployed same-team member."] call _result};
        _logical set ["leaderUid", _target];
        _logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
        _groups set [_currentGroupId, _logical];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        private _invalidated = [[], [_currentGroupId], [], false] call bn_koth_fnc_groups_clearInvites;
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "TRANSFERRED", "Leadership transferred.", true, _invalidated] call _result
    };
    case "DISBAND": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can disband the group."] call _result};
        [[_currentGroupId]] call bn_koth_fnc_groups_releaseNativeGroups;
        private _invalidated = [[], [_currentGroupId], [], false] call bn_koth_fnc_groups_clearInvites;
        _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
        _groups deleteAt _currentGroupId;
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "DISBANDED", "Group disbanded.", true, _invalidated] call _result
    };
    case "LOCK": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can lock the group."] call _result};
        if (_logical getOrDefault ["locked", false]) exitWith {[false, "ALREADY_LOCKED", "The group is already locked."] call _result};
        _logical set ["locked", true];
        _logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
        _groups set [_currentGroupId, _logical];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "LOCKED", "Group locked.", true] call _result
    };
    case "UNLOCK": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can unlock the group."] call _result};
        if !(_logical getOrDefault ["locked", false]) exitWith {[false, "ALREADY_OPEN", "The group is already open."] call _result};
        _logical set ["locked", false];
        _logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
        _groups set [_currentGroupId, _logical];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "UNLOCKED", "Group unlocked.", true] call _result
    };
    case "RENAME": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can rename the group."] call _result};
        private _characters = toArray _target;
        while {(count _characters) > 0 && {(_characters select 0) in [9, 32]}} do {_characters deleteAt 0};
        while {(count _characters) > 0 && {(_characters select ((count _characters) - 1)) in [9, 32]}} do {_characters deleteAt ((count _characters) - 1)};
        private _name = toString _characters;
        private _maxLength = (getNumber (missionConfigFile >> "CfgBnKothGroups" >> "maxDisplayNameLength")) max 1;
        if (_name isEqualTo "") exitWith {[false, "INVALID_NAME", "Enter a group name."] call _result};
        if ((count _characters) > _maxLength) exitWith {[false, "NAME_TOO_LONG", format ["Group names may contain at most %1 characters.", _maxLength]] call _result};
        if ((_characters findIf {_x < 32 || {_x isEqualTo 127} || {_x in (toArray "<>&")}}) >= 0) exitWith {[false, "INVALID_NAME", "That group name contains unsupported characters."] call _result};
        _logical set ["displayName", _name];
        _logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
        _groups set [_currentGroupId, _logical];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "RENAMED", "Group renamed.", true] call _result
    };
    case "INVITE": {
        if (_currentGroupId isEqualTo "") exitWith {[false, "NOT_GROUPED", "You are not in a group."] call _result};
        private _logical = _groups get _currentGroupId;
        if ((_logical getOrDefault ["leaderUid", ""]) isNotEqualTo _uid) exitWith {[false, "NOT_LEADER", "Only the group leader can invite players."] call _result};
        if !([_target, _assignedSide, _uid] call bn_koth_fnc_groups_isInviteCandidate) exitWith {[false, "TARGET_INELIGIBLE", "That player is not an eligible same-team invite candidate."] call _result};
        private _expiry = (getNumber (missionConfigFile >> "CfgBnKothGroups" >> "inviteExpirySeconds")) max 1;
        private _expiresAt = serverTime + _expiry;
        private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
        private _existingInvite = _invites getOrDefault [_target, createHashMap];
        if (_existingInvite isEqualType createHashMap && {(count _existingInvite) > 0} && {serverTime < (_existingInvite getOrDefault ["expiresAt", -1])}) exitWith {
            [false, "INVITE_PENDING", "That player already has a pending group invitation."] call _result
        };
        _invites set [_target, createHashMapFromArray [["targetUid", _target], ["groupId", _currentGroupId], ["issuerUid", _uid], ["expiresAt", _expiresAt]]];
        missionNamespace setVariable ["BN_KOTH_groupInvites", _invites];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [_target, _currentGroupId, _expiresAt] spawn bn_koth_fnc_groups_expireInvite;
        private _targetRecord = _records getOrDefault [_target, createHashMap];
        private _targetOwnerId = if (_targetRecord isEqualType createHashMap) then {_targetRecord getOrDefault ["ownerId", -1]} else {-1};
        private _groupName = _logical getOrDefault ["displayName", format ["SQUAD %1", _logical getOrDefault ["sequence", 0]]];
        private _leaderName = _record getOrDefault ["name", _uid];
        [_targetOwnerId, createHashMapFromArray [
            ["title", "GROUP INVITE"],
            ["body", format ["%1 invited you to %2", _leaderName, _groupName]],
            ["footer", "Open Group Menu to respond"]
        ]] call bn_koth_fnc_teams_notifyPlayer;
        [true, "INVITED", "Invitation sent.", true, [_target, _uid]] call _result
    };
    case "ACCEPT_INVITE": {
        if !(_currentGroupId isEqualTo "") exitWith {[false, "ALREADY_GROUPED", "Leave your current group before accepting an invitation."] call _result};
        private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
        private _invite = _invites getOrDefault [_uid, createHashMap];
        if !(_invite isEqualType createHashMap && {(count _invite) > 0}) exitWith {[false, "INVITE_NOT_FOUND", "That invitation is no longer available."] call _result};
        private _inviteGroupId = _invite getOrDefault ["groupId", ""];
        private _inviteGroup = _groups getOrDefault [_inviteGroupId, createHashMap];
        private _issuerUid = _invite getOrDefault ["issuerUid", ""];
        if (serverTime >= (_invite getOrDefault ["expiresAt", -1])
            || {!(_inviteGroup isEqualType createHashMap && {(count _inviteGroup) > 0})}
            || {(_inviteGroup getOrDefault ["leaderUid", ""]) isNotEqualTo _issuerUid}
            || {!([_uid, _assignedSide, _issuerUid] call bn_koth_fnc_groups_isInviteCandidate)}) exitWith {
            [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
            [false, "INVITE_INVALID", "That invitation is no longer valid.", true, [_uid]] call _result
        };
        private _issuerRecord = _records getOrDefault [_issuerUid, createHashMap];
        private _issuerOwner = if (_issuerRecord isEqualType createHashMap) then {_issuerRecord getOrDefault ["ownerId", -1]} else {-1};
        private _issuerUnit = [_issuerOwner] call bn_koth_fnc_teams_getPlayerByOwner;
        if !(_issuerRecord isEqualType createHashMap
            && {_issuerUid in _active}
            && {_issuerRecord getOrDefault ["deployed", false]}
            && {(_issuerRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
            && {(_issuerRecord getOrDefault ["assignedSide", sideUnknown]) isEqualTo _assignedSide}
            && {_issuerOwner > 0}
            && {!isNull _issuerUnit}
            && {isPlayer _issuerUnit}
            && {alive _issuerUnit}
            && {(getPlayerUID _issuerUnit) isEqualTo _issuerUid}
            && {(_issuerRecord getOrDefault ["currentUnit", objNull]) isEqualTo _issuerUnit}) exitWith {
            [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
            [false, "INVITE_INVALID", "That invitation is no longer valid.", true, [_uid]] call _result
        };
        private _members = +(_inviteGroup getOrDefault ["memberUids", []]);
        _members pushBack _uid;
        _inviteGroup set ["memberUids", _members];
        _inviteGroup set ["revision", (_inviteGroup getOrDefault ["revision", 0]) + 1];
        _groups set [_inviteGroupId, _inviteGroup];
        missionNamespace setVariable ["BN_KOTH_groups", _groups];
        [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "INVITE_ACCEPTED", "Invitation accepted.", true] call _result
    };
    case "DECLINE_INVITE": {
        private _removed = [[_uid], [], [], false] call bn_koth_fnc_groups_clearInvites;
        if ((count _removed) isEqualTo 0) exitWith {[false, "INVITE_NOT_FOUND", "That invitation is no longer available."] call _result};
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        [true, "INVITE_DECLINED", "Invitation declined.", true, [_uid]] call _result
    };
    default {[false, "INVALID_OPERATION", "Unknown group action."] call _result};
}

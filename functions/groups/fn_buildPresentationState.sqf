/*
    File: fn_buildPresentationState.sqf
    Author: Legend
    Description: Builds a safe requester-specific group UI projection.
    Execution: Server
    Parameters:
        0: Requester UID <STRING>
    Returns: Group presentation state <HASHMAP>
    Public: No
*/

params [["_uid", "", [""]]];

private _empty = createHashMapFromArray [
    ["revision", missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]],
    ["availableGroups", []],
    ["currentGroup", createHashMap],
    ["inviteCandidates", []],
    ["pendingInvite", createHashMap],
    ["canCreate", false]
];

if (!isServer || {_uid isEqualTo ""}) exitWith {_empty};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_records isEqualType createHashMap && {_groups isEqualType createHashMap} && {_active isEqualType []}) exitWith {_empty};
private _requester = _records getOrDefault [_uid, createHashMap];
if !(_requester isEqualType createHashMap) exitWith {_empty};

private _side = _requester getOrDefault ["assignedSide", sideUnknown];
private _eligible = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE"
    && {_uid in _active}
    && {_requester getOrDefault ["deployed", false]}
    && {(_requester getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {[_side] call bn_koth_fnc_teams_validateSide};
if (!_eligible) exitWith {_empty};

private _currentGroupId = "";
{
    private _logical = _groups getOrDefault [_x, createHashMap];
    if (_logical isEqualType createHashMap && {_uid in (_logical getOrDefault ["memberUids", []])}) exitWith {
        _currentGroupId = _x;
    };
} forEach (keys _groups);

private _projectMember = {
    params ["_memberUid", "_records", "_active"];
    private _record = _records getOrDefault [_memberUid, createHashMap];
    private _known = _record isEqualType createHashMap;
    private _state = if (_known) then {_record getOrDefault ["state", "LOBBY"]} else {"OFFLINE"};
    private _deployed = _known
        && {_memberUid in _active}
        && {_record getOrDefault ["deployed", false]}
        && {_state isEqualTo "ACTIVE"};
    createHashMapFromArray [
        ["uid", _memberUid],
        ["name", if (_known) then {_record getOrDefault ["name", _memberUid]} else {_memberUid}],
        ["state", _state],
        ["deployed", _deployed]
    ]
};

private _available = [];
private _current = createHashMap;
{
    private _groupId = _x;
    private _logical = _groups getOrDefault [_groupId, createHashMap];
    if !(_logical isEqualType createHashMap) then {continue};
    private _leaderUid = _logical getOrDefault ["leaderUid", ""];
    private _members = _logical getOrDefault ["memberUids", []];
    private _leaderRecord = _records getOrDefault [_leaderUid, createHashMap];
    private _leaderDeployed = _leaderRecord isEqualType createHashMap
        && {_leaderUid in _active}
        && {_leaderRecord getOrDefault ["deployed", false]}
        && {(_leaderRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"};
    private _leaderSide = if (_leaderRecord isEqualType createHashMap) then {
        _leaderRecord getOrDefault ["assignedSide", sideUnknown]
    } else {
        sideUnknown
    };

    private _deployedCount = 0;
    private _memberRows = [];
    {
        private _row = [_x, _records, _active] call _projectMember;
        if (_row getOrDefault ["deployed", false]) then {_deployedCount = _deployedCount + 1};
        _row set ["leader", _x isEqualTo _leaderUid];
        _memberRows pushBack _row;
    } forEach _members;

    private _label = _logical getOrDefault ["displayName", format ["SQUAD %1", _logical getOrDefault ["sequence", 0]]];
    private _locked = _logical getOrDefault ["locked", false];
    private _leaderName = if (_leaderRecord isEqualType createHashMap) then {
        _leaderRecord getOrDefault ["name", _leaderUid]
    } else {
        _leaderUid
    };

    if (_groupId isEqualTo _currentGroupId) then {
        _current = createHashMapFromArray [
            ["groupId", _groupId],
            ["label", _label],
            ["leaderUid", _leaderUid],
            ["leaderName", _leaderName],
            ["members", _memberRows],
            ["memberCount", count _members],
            ["deployedCount", _deployedCount],
            ["locked", _locked],
            ["isLeader", _leaderUid isEqualTo _uid]
        ];
    } else {
        if (_leaderDeployed && {_leaderSide isEqualTo _side}) then {
            _available pushBack createHashMapFromArray [
                ["groupId", _groupId],
                ["label", _label],
                ["leaderName", _leaderName],
                ["memberCount", count _members],
                ["deployedCount", _deployedCount],
                ["locked", _locked]
            ];
        };
    };
} forEach (keys _groups);

_available = [_available, [], {_x getOrDefault ["label", ""]}, "ASCEND"] call BIS_fnc_sortBy;
private _inviteCandidates = [];
private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
if (_current isEqualType createHashMap && {(count _current) > 0} && {_current getOrDefault ["isLeader", false]}) then {
    {
        private _existingInvite = if (_invites isEqualType createHashMap) then {_invites getOrDefault [_x, createHashMap]} else {createHashMap};
        private _hasActiveInvite = _existingInvite isEqualType createHashMap
            && {(count _existingInvite) > 0}
            && {serverTime < (_existingInvite getOrDefault ["expiresAt", -1])};
        if (!_hasActiveInvite && {[_x, _side, _uid] call bn_koth_fnc_groups_isInviteCandidate}) then {
            private _candidate = _records get _x;
            _inviteCandidates pushBack createHashMapFromArray [["uid", _x], ["name", _candidate getOrDefault ["name", _x]]];
        };
    } forEach (keys _records);
    _inviteCandidates = [_inviteCandidates, [], {_x getOrDefault ["name", ""]}, "ASCEND"] call BIS_fnc_sortBy;
};

private _pendingInvite = createHashMap;
private _invite = if (_invites isEqualType createHashMap) then {_invites getOrDefault [_uid, createHashMap]} else {createHashMap};
if (_invite isEqualType createHashMap && {(count _invite) > 0} && {serverTime < (_invite getOrDefault ["expiresAt", -1])}) then {
    private _inviteGroup = _groups getOrDefault [_invite getOrDefault ["groupId", ""], createHashMap];
    private _issuerUid = _invite getOrDefault ["issuerUid", ""];
    private _issuerRecord = _records getOrDefault [_issuerUid, createHashMap];
    if (_inviteGroup isEqualType createHashMap
        && {(_inviteGroup getOrDefault ["leaderUid", ""]) isEqualTo _issuerUid}
        && {_issuerRecord isEqualType createHashMap}
        && {(_issuerRecord getOrDefault ["assignedSide", sideUnknown]) isEqualTo _side}
        && {[_uid, _side, _issuerUid] call bn_koth_fnc_groups_isInviteCandidate}) then {
        _pendingInvite = createHashMapFromArray [
            ["groupId", _invite getOrDefault ["groupId", ""]],
            ["groupName", _inviteGroup getOrDefault ["displayName", format ["SQUAD %1", _inviteGroup getOrDefault ["sequence", 0]]]],
            ["leaderName", _issuerRecord getOrDefault ["name", _issuerUid]],
            ["expiresIn", ceil ((_invite getOrDefault ["expiresAt", serverTime]) - serverTime)]
        ];
    };
};
createHashMapFromArray [
    ["revision", missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]],
    ["availableGroups", _available],
    ["currentGroup", _current],
    ["inviteCandidates", _inviteCandidates],
    ["pendingInvite", _pendingInvite],
    ["canCreate", _currentGroupId isEqualTo ""]
]

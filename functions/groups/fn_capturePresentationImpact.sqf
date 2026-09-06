/*
    File: fn_capturePresentationImpact.sqf
    Author: Legend
    Description: Captures transient recipients affected by specified logical groups or members.
    Execution: Server
    Parameters:
        0: Member UIDs used to locate affected groups <ARRAY>
        1: Logical group IDs known to be affected <ARRAY>
    Returns: Presentation impact containing group IDs, member UIDs and sides <HASHMAP>
    Public: No
*/

params [
    ["_memberUids", [], [[]]],
    ["_groupIds", [], [[]]]
];

private _impact = createHashMapFromArray [
    ["groupIds", []],
    ["memberUids", []],
    ["sides", []],
    ["directUids", []],
    ["inviteCandidateSides", []]
];
if (!isServer) exitWith {_impact};

private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_groups isEqualType createHashMap && {_records isEqualType createHashMap} && {_active isEqualType []}) exitWith {_impact};

private _affectedGroupIds = [];
{
    if (_x isEqualType "" && {!(_x isEqualTo "")} && {_x in (keys _groups)}) then {
        _affectedGroupIds pushBackUnique _x;
    };
} forEach _groupIds;

{
    private _groupId = _x;
    private _logical = _groups getOrDefault [_groupId, createHashMap];
    if !(_logical isEqualType createHashMap) then {continue};
    private _members = _logical getOrDefault ["memberUids", []];
    if ((_members findIf {_x in _memberUids}) >= 0) then {
        _affectedGroupIds pushBackUnique _groupId;
    };
} forEach (keys _groups);

private _affectedMembers = [];
private _affectedSides = [];
private _candidateSides = [];
{
    private _logical = _groups getOrDefault [_x, createHashMap];
    if !(_logical isEqualType createHashMap) then {continue};

    private _nativeSide = _logical getOrDefault ["nativeSide", sideUnknown];
    if ([_nativeSide] call bn_koth_fnc_teams_validateSide) then {
        _affectedSides pushBackUnique _nativeSide;
    };

    private _leaderUid = _logical getOrDefault ["leaderUid", ""];
    private _leaderRecord = _records getOrDefault [_leaderUid, createHashMap];
    if (_leaderRecord isEqualType createHashMap
        && {_leaderUid in _active}
        && {_leaderRecord getOrDefault ["deployed", false]}
        && {(_leaderRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}) then {
        private _leaderSide = _leaderRecord getOrDefault ["assignedSide", sideUnknown];
        if ([_leaderSide] call bn_koth_fnc_teams_validateSide) then {
            _affectedSides pushBackUnique _leaderSide;
        };
    };

    {
        _affectedMembers pushBackUnique _x;
    } forEach (_logical getOrDefault ["memberUids", []]);
} forEach _affectedGroupIds;

{
    private _memberUid = _x;
    private _grouped = false;
    {
        private _logical = _groups getOrDefault [_x, createHashMap];
        if (_logical isEqualType createHashMap && {_memberUid in (_logical getOrDefault ["memberUids", []])}) exitWith {_grouped = true};
    } forEach (keys _groups);
    if (!_grouped) then {
        private _record = _records getOrDefault [_memberUid, createHashMap];
        private _side = if (_record isEqualType createHashMap) then {_record getOrDefault ["assignedSide", sideUnknown]} else {sideUnknown};
        if ([_side] call bn_koth_fnc_teams_validateSide) then {_candidateSides pushBackUnique _side};
    };
} forEach _memberUids;

private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
if (_invites isEqualType createHashMap) then {
    {
        private _invite = _invites getOrDefault [_x, createHashMap];
        if (_invite isEqualType createHashMap && {(_invite getOrDefault ["groupId", ""]) in _affectedGroupIds}) then {
            _affectedMembers pushBackUnique _x;
        };
    } forEach (keys _invites);
};

_impact set ["groupIds", _affectedGroupIds];
_impact set ["memberUids", _affectedMembers];
_impact set ["sides", _affectedSides];
_impact set ["inviteCandidateSides", _candidateSides];
_impact

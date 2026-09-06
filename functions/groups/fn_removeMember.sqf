/*
    File: fn_removeMember.sqf
    Author: Legend
    Description: Removes one UID and maintains leader/non-empty invariants.
    Execution: Server
    Parameters:
        0: Member UID <STRING>
    Returns: Whether membership changed <BOOL>
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer || {_uid isEqualTo ""}) exitWith {false};

private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_groups isEqualType createHashMap && {_records isEqualType createHashMap}) exitWith {false};

private _groupId = "";
{
    private _candidate = _groups getOrDefault [_x, createHashMap];
    if (_candidate isEqualType createHashMap && {_uid in (_candidate getOrDefault ["memberUids", []])}) exitWith {
        _groupId = _x;
    };
} forEach (keys _groups);
if (_groupId isEqualTo "") exitWith {false};

private _logical = _groups get _groupId;
private _members = (_logical getOrDefault ["memberUids", []]) - [_uid];
private _leaderLeaving = (_logical getOrDefault ["leaderUid", ""]) isEqualTo _uid;
[[_uid], if (_leaderLeaving) then {[_groupId]} else {[]}, [_uid], false] call bn_koth_fnc_groups_clearInvites;

if ((count _members) isEqualTo 0) exitWith {
    [[_groupId]] call bn_koth_fnc_groups_releaseNativeGroups;
    _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
    _groups deleteAt _groupId;
    missionNamespace setVariable ["BN_KOTH_groups", _groups];
    missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
    true
};

if ((_logical getOrDefault ["leaderUid", ""]) isEqualTo _uid) then {
    private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
    private _successor = "";
    {
        private _record = _records getOrDefault [_x, createHashMap];
        if (_record isEqualType createHashMap
            && {_x in _active}
            && {_record getOrDefault ["deployed", false]}
            && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}) exitWith {
            _successor = _x;
        };
    } forEach _members;
    if (_successor isEqualTo "") then {_successor = _members select 0};
    _logical set ["leaderUid", _successor];
};

_logical set ["memberUids", _members];
_logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
_groups set [_groupId, _logical];
missionNamespace setVariable ["BN_KOTH_groups", _groups];
missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
true

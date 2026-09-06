/*
    File: fn_clearInvites.sqf
    Author: Legend
    Description: Removes matching transient group invites from server-owned state.
    Execution: Server
    Parameters:
        0: Target UIDs <ARRAY>
        1: Logical group IDs <ARRAY>
        2: Issuer UIDs <ARRAY>
        3: Clear all invites <BOOL>
    Returns: Removed target UIDs <ARRAY>
    Public: No
*/

params [["_targetUids", [], [[]]], ["_groupIds", [], [[]]], ["_issuerUids", [], [[]]], ["_clearAll", false, [false]]];
if (!isServer) exitWith {[]};
private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
if !(_invites isEqualType createHashMap) exitWith {[]};
private _removed = [];
{
    private _invite = _invites getOrDefault [_x, createHashMap];
    if (_invite isEqualType createHashMap && {
        _clearAll
        || {_x in _targetUids}
        || {(_invite getOrDefault ["groupId", ""]) in _groupIds}
        || {(_invite getOrDefault ["issuerUid", ""]) in _issuerUids}
    }) then {
        _removed pushBack _x;
        _invites deleteAt _x;
    };
} forEach (keys _invites);
missionNamespace setVariable ["BN_KOTH_groupInvites", _invites];
_removed

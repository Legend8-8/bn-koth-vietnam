/*
    File: fn_expireInvite.sqf
    Author: Legend
    Description: Expires one transient invite at its authoritative deadline.
    Execution: Scheduled server task
    Parameters:
        0: Target UID <STRING>
        1: Logical group ID <STRING>
        2: Expiry server time <NUMBER>
    Returns: None
    Public: No
*/

params ["_targetUid", "_groupId", "_expiresAt"];
if (!isServer) exitWith {};
sleep (((_expiresAt - serverTime) max 0) + 0.1);
private _invites = missionNamespace getVariable ["BN_KOTH_groupInvites", createHashMap];
private _invite = _invites getOrDefault [_targetUid, createHashMap];
if !(_invite isEqualType createHashMap
    && {(_invite getOrDefault ["groupId", ""]) isEqualTo _groupId}
    && {(_invite getOrDefault ["expiresAt", -1]) isEqualTo _expiresAt}
    && {serverTime >= _expiresAt}) exitWith {};
_invites deleteAt _targetUid;
missionNamespace setVariable ["BN_KOTH_groupInvites", _invites];
missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
private _impact = createHashMapFromArray [["memberUids", [_targetUid]], ["sides", []], ["inviteCandidateSides", []]];
[[_impact]] call bn_koth_fnc_groups_publishUpdate;

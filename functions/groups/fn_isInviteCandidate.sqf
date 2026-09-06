/*
    File: fn_isInviteCandidate.sqf
    Author: Legend
    Description: Validates a current same-side ungrouped invite candidate from server-owned state.
    Execution: Server
    Parameters:
        0: Candidate UID <STRING>
        1: Authoritative leader side <SIDE>
        2: Requester UID to exclude <STRING>
    Returns: Whether the candidate is eligible <BOOL>
    Public: No
*/

params ["_candidateUid", "_leaderSide", ["_requesterUid", "", [""]]];
if (!isServer || {_candidateUid isEqualTo ""} || {_candidateUid isEqualTo _requesterUid}) exitWith {false};
if !([_leaderSide] call bn_koth_fnc_teams_validateSide) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_records isEqualType createHashMap && {_groups isEqualType createHashMap} && {_active isEqualType []}) exitWith {false};
private _grouped = false;
{
    private _logical = _groups getOrDefault [_x, createHashMap];
    if (_logical isEqualType createHashMap && {_candidateUid in (_logical getOrDefault ["memberUids", []])}) exitWith {_grouped = true};
} forEach (keys _groups);
if (_grouped) exitWith {false};

private _record = _records getOrDefault [_candidateUid, createHashMap];
if !(_record isEqualType createHashMap && {(count _record) > 0}) exitWith {false};
private _ownerId = _record getOrDefault ["ownerId", -1];
private _unit = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
_candidateUid in _active
    && {_record getOrDefault ["deployed", false]}
    && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {(_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo _leaderSide}
    && {_ownerId > 0}
    && {!isNull _unit}
    && {isPlayer _unit}
    && {alive _unit}
    && {(getPlayerUID _unit) isEqualTo _candidateUid}
    && {(_record getOrDefault ["currentUnit", objNull]) isEqualTo _unit}

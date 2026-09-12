/*
    File: fn_publishUpdate.sqf
    Author: Legend
    Description: Sends group presentation only to clients affected by transient impact records.
    Execution: Server
    Parameters:
        0: Presentation impact records <ARRAY>
    Returns: Number of clients updated <NUMBER>
    Public: No
*/

params [["_impacts", [], [[]]]];

if (!isServer || {(count _impacts) isEqualTo 0}) exitWith {0};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {0};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_records isEqualType createHashMap && {_active isEqualType []}) exitWith {0};

private _targets = [];
private _affectedSides = [];
private _candidateSides = [];
{
    if !(_x isEqualType createHashMap) then {continue};
    {_targets pushBackUnique _x} forEach (_x getOrDefault ["memberUids", []]);
    {_targets pushBackUnique _x} forEach (_x getOrDefault ["directUids", []]);
    {_affectedSides pushBackUnique _x} forEach (_x getOrDefault ["sides", []]);
    {_candidateSides pushBackUnique _x} forEach (_x getOrDefault ["inviteCandidateSides", []]);
} forEach _impacts;

{
    private _record = _records getOrDefault [_x, createHashMap];
    if (_record isEqualType createHashMap
        && {(_record getOrDefault ["assignedSide", sideUnknown]) in _affectedSides}) then {
        _targets pushBackUnique _x;
    };
} forEach _active;

if ((count _candidateSides) > 0) then {
    private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
    if (_groups isEqualType createHashMap) then {
        {
            private _logical = _groups getOrDefault [_x, createHashMap];
            if !(_logical isEqualType createHashMap) then {continue};
            private _leaderUid = _logical getOrDefault ["leaderUid", ""];
            private _record = _records getOrDefault [_leaderUid, createHashMap];
            if (_record isEqualType createHashMap
                && {_leaderUid in _active}
                && {_record getOrDefault ["deployed", false]}
                && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
                && {(_record getOrDefault ["assignedSide", sideUnknown]) in _candidateSides}) then {
                _targets pushBackUnique _leaderUid;
            };
        } forEach (keys _groups);
    };
};

private _sent = 0;
{
    private _uid = _x;
    private _record = _records getOrDefault [_uid, createHashMap];
    if !(_record isEqualType createHashMap) then {continue};
    if !(_uid in _active
        && {_record getOrDefault ["deployed", false]}
        && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}) then {continue};
    private _ownerId = _record getOrDefault ["ownerId", -1];
    private _player = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (_ownerId <= 0 || {isNull _player} || {!isPlayer _player} || {(getPlayerUID _player) isNotEqualTo _uid}) then {continue};
    [[_uid] call bn_koth_fnc_groups_buildPresentationState] remoteExecCall ["bn_koth_fnc_groupMenu_receiveState", _ownerId];
    _sent = _sent + 1;
} forEach _targets;

_sent

/*
    File: fn_reconcile.sqf
    Author: Legend
    Description: Reconciles logical groups into same-side native Arma groups.
    Execution: Server
    Parameters:
        0: Logical group IDs; empty means all <ARRAY>
    Returns: Whether logical or native state changed <BOOL>
    Public: No
*/

params [["_groupIds", [], [[]]]];

if (!isServer) exitWith {false};

private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _active = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
if !(_groups isEqualType createHashMap && {_records isEqualType createHashMap}) exitWith {false};

private _targets = if ((count _groupIds) > 0) then {+_groupIds} else {keys _groups};
private _changed = false;

private _resolveMaterialized = {
    params ["_uid", "_records", "_active"];
    private _record = _records getOrDefault [_uid, createHashMap];
    if !(_record isEqualType createHashMap) exitWith {[false, objNull, sideUnknown, "LOBBY"]};
    private _unit = _record getOrDefault ["currentUnit", objNull];
    private _side = _record getOrDefault ["assignedSide", sideUnknown];
    private _state = _record getOrDefault ["state", "LOBBY"];
    private _valid = _uid in _active
        && {_record getOrDefault ["deployed", false]}
        && {_state in ["DEPLOYING", "ACTIVE"]}
        && {[_side] call bn_koth_fnc_teams_validateSide}
        && {!isNull _unit}
        && {alive _unit}
        && {isPlayer _unit}
        && {(getPlayerUID _unit) isEqualTo _uid};
    [_valid, _unit, _side, _state]
};

{
    private _groupId = _x;
    private _logical = _groups getOrDefault [_groupId, createHashMap];
    if !(_logical isEqualType createHashMap) then {continue};

    private _leaderUid = _logical getOrDefault ["leaderUid", ""];
    private _leaderRecord = _records getOrDefault [_leaderUid, createHashMap];
    private _leaderResolved = [_leaderUid, _records, _active] call _resolveMaterialized;
    _leaderResolved params ["_leaderMaterialized", "_leaderUnit", "_leaderSide", "_leaderState"];

    private _leaderSideKnown = _leaderMaterialized;
    if (!_leaderSideKnown && {_leaderRecord isEqualType createHashMap} && {_leaderState isEqualTo "RESPAWNING"}) then {
        _leaderSide = _leaderRecord getOrDefault ["assignedSide", sideUnknown];
        _leaderSideKnown = [_leaderSide] call bn_koth_fnc_teams_validateSide;
    };

    // A connected leader who has not deployed supplies no side authority. Preserve
    // logical leadership/membership and leave deployed members in singleton groups.
    if (!_leaderSideKnown) then {
        if ([[_groupId]] call bn_koth_fnc_groups_releaseNativeGroups) then {_changed = true};
        _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
        continue;
    };

    private _members = +(_logical getOrDefault ["memberUids", []]);
    private _matching = [];
    private _removed = [];
    {
        private _resolved = [_x, _records, _active] call _resolveMaterialized;
        _resolved params ["_materialized", "_unit", "_side"];
        if (!_materialized) then {continue};
        if (_side isEqualTo _leaderSide) then {
            _matching pushBack [_x, _unit];
        } else {
            _removed pushBack _x;
        };
    } forEach _members;

    if ((count _removed) > 0) then {
        {
            _members = _members - [_x];
            private _record = _records getOrDefault [_x, createHashMap];
            if (_record isEqualType createHashMap) then {
                private _ownerId = _record getOrDefault ["ownerId", -1];
                [_ownerId, "You were removed from the group because your deployed team differs from the group leader's team."] call bn_koth_fnc_teams_notifyPlayer;
            };
        } forEach _removed;
        _logical set ["memberUids", _members];
        _logical set ["revision", (_logical getOrDefault ["revision", 0]) + 1];
        missionNamespace setVariable ["BN_KOTH_groupsRevision", (missionNamespace getVariable ["BN_KOTH_groupsRevision", 0]) + 1];
        _changed = true;
    };

    private _native = _logical getOrDefault ["nativeGroup", grpNull];
    private _nativeLogicalId = if (isNull _native) then {""} else {_native getVariable ["BN_KOTH_logicalGroupId", ""]};
    if (isNull _native
        || {(side _native) isNotEqualTo _leaderSide}
        || {!(_nativeLogicalId in ["", _groupId])}) then {
        if (!isNull _native) then {
            [[_groupId]] call bn_koth_fnc_groups_releaseNativeGroups;
            _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
            _logical = _groups getOrDefault [_groupId, _logical];
        };
        _native = grpNull;
        if (_leaderMaterialized) then {
            _native = group _leaderUnit;
        } else {
            if ((count _matching) > 0) then {_native = group ((_matching select 0) select 1)};
        };
        _changed = true;
    };

    if (isNull _native || {(count _matching) isEqualTo 0}) then {
        if (!isNull _native) then {
            [[_groupId]] call bn_koth_fnc_groups_releaseNativeGroups;
            _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
            _logical = _groups getOrDefault [_groupId, _logical];
            _changed = true;
        };
        _logical set ["nativeGroup", grpNull];
        _logical set ["nativeSide", sideUnknown];
        _groups set [_groupId, _logical];
        continue;
    };

    private _matchingUnits = _matching apply {_x select 1};
    {
        private _unit = _x;
        if (!isNull _unit && {group _unit isNotEqualTo _native}) then {
            [_unit] joinSilent _native;
            _changed = true;
        };
    } forEach _matchingUnits;

    // Eject any unexpected live entity from a native group owned by this system.
    {
        private _unit = _x;
        if (isNull _unit || {!alive _unit} || {_unit in _matchingUnits}) then {continue};
        private _uid = [_unit, _records] call bn_koth_fnc_common_resolvePlayerUid;
        private _record = _records getOrDefault [_uid, createHashMap];
        private _side = if (_record isEqualType createHashMap) then {
            _record getOrDefault ["assignedSide", side _native]
        } else {
            side _native
        };
        if !([_side] call bn_koth_fnc_teams_validateSide) then {_side = side _native};
        private _singleton = createGroup [_side, true];
        if (!isNull _singleton) then {[_unit] joinSilent _singleton};
        _changed = true;
    } forEach (units _native);

    private _revision = _logical getOrDefault ["revision", 0];
    _native setVariable ["BN_KOTH_logicalGroupId", _groupId, true];
    _native setVariable ["BN_KOTH_logicalGroupRevision", _revision, true];
    _native setGroupIdGlobal [_logical getOrDefault ["displayName", format ["SQUAD %1", _logical getOrDefault ["sequence", 0]]]];

    private _desiredNativeLeader = if (_leaderMaterialized) then {_leaderUnit} else {_matchingUnits select 0};
    if (!isNull _desiredNativeLeader && {leader _native isNotEqualTo _desiredNativeLeader}) then {
        if (local _native) then {
            _native selectLeader _desiredNativeLeader;
        } else {
            private _groupOwnerId = groupOwner _native;
            if (_groupOwnerId > 0) then {
                [_native, _desiredNativeLeader, _revision] remoteExecCall ["bn_koth_fnc_groups_applyNativeLeadership", _groupOwnerId];
            };
        };
        _changed = true;
    };

    _logical set ["nativeGroup", _native];
    _logical set ["nativeSide", _leaderSide];
    _groups set [_groupId, _logical];
} forEach _targets;

missionNamespace setVariable ["BN_KOTH_groups", _groups];
_changed

/*
    File: fn_releaseNativeGroups.sqf
    Author: Legend
    Description: Releases derived native groups without changing logical membership.
    Execution: Server
    Parameters:
        0: Logical group IDs to release; empty means all <ARRAY>
    Returns: Whether any native representation was released <BOOL>
    Public: No
*/

params [["_groupIds", [], [[]]]];

if (!isServer) exitWith {false};

private _groups = missionNamespace getVariable ["BN_KOTH_groups", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_groups isEqualType createHashMap && {_records isEqualType createHashMap}) exitWith {false};

private _targets = if ((count _groupIds) > 0) then {+_groupIds} else {keys _groups};
private _changed = false;

{
    private _groupId = _x;
    private _logical = _groups getOrDefault [_groupId, createHashMap];
    if !(_logical isEqualType createHashMap) then {continue};

    private _native = _logical getOrDefault ["nativeGroup", grpNull];
    if (!isNull _native) then {
        private _revision = _logical getOrDefault ["revision", -1];
        private _cleanupOwned = (_native getVariable ["BN_KOTH_logicalGroupId", ""]) isEqualTo _groupId
            && {(_native getVariable ["BN_KOTH_logicalGroupRevision", -2]) isEqualTo _revision};
        {
            private _unit = _x;
            if (isNull _unit || {!alive _unit}) then {continue};

            private _uid = [_unit, _records] call bn_koth_fnc_common_resolvePlayerUid;
            private _record = _records getOrDefault [_uid, createHashMap];
            private _assignedSide = if (_record isEqualType createHashMap) then {
                _record getOrDefault ["assignedSide", sideUnknown]
            } else {
                sideUnknown
            };
            if !([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
                _assignedSide = side _native;
            };

            if ([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
                private _singleton = createGroup [_assignedSide, true];
                if (!isNull _singleton) then {
                    [_unit] joinSilent _singleton;
                };
            };
        } forEach (units _native);

        // Cleanup belongs to the native group's current locality owner. Enabling
        // delete-when-empty also covers dead units removed after logical release.
        if (_cleanupOwned && {!isNull _native}) then {
            if (local _native) then {
                _native deleteGroupWhenEmpty true;
                if (!isNull _native && {(count units _native) isEqualTo 0}) then {
                    deleteGroup _native;
                };
            } else {
                private _groupOwnerId = groupOwner _native;
                if (_groupOwnerId > 0) then {
                    [_native, _groupId, _revision] remoteExecCall ["bn_koth_fnc_groups_prepareNativeCleanup", _groupOwnerId];
                } else {
                    [format ["Native group cleanup owner unavailable group=%1 revision=%2", _groupId, _revision], "WARN"] call bn_koth_fnc_common_log;
                };
            };
        };
        _changed = true;
    };

    _logical set ["nativeGroup", grpNull];
    _logical set ["nativeSide", sideUnknown];
    _groups set [_groupId, _logical];
} forEach _targets;

missionNamespace setVariable ["BN_KOTH_groups", _groups];
_changed

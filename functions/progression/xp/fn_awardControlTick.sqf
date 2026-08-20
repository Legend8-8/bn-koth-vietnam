/*
    File: fn_awardControlTick.sqf
    Author: Tylervip
    Description: Awards control participation XP to eligible active teammates.
    Execution: Server
    Parameters:
        0: Validated controlling side <SIDE>
    Returns:
        Number of players rewarded <NUMBER>
    Public: No
*/

params [["_controller", sideUnknown, [sideUnknown]]];

if (!isServer) exitWith {0};
if !([_controller] call bn_koth_fnc_teams_validateSide) exitWith {0};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {0};
if !((missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"]) isEqualTo "CONTROLLED") exitWith {0};
if !((missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown]) isEqualTo _controller) exitWith {0};

private _controlXpAmount = missionNamespace getVariable ["BN_KOTH_xpPerControlTick", 10];
private _priorityXpAmount = missionNamespace getVariable ["BN_KOTH_xpPerPriorityTick", 25];

if (_controlXpAmount <= 0 && {_priorityXpAmount <= 0}) exitWith {0};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _maximumControlHeight = missionNamespace getVariable ["BN_KOTH_maximumControlHeight", 50];
private _priorityActive = missionNamespace getVariable ["BN_KOTH_priorityZoneActive", false]
    && {!((markerShape _priorityMarker) isEqualTo "")};
private _rewarded = 0;

{
    private _uid = _x;
    private _record = _records getOrDefault [_uid, createHashMap];
    if (_record isEqualType createHashMap) then {
        private _unit = _record getOrDefault ["currentUnit", objNull];
        private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
        private _eligible = !isNull _unit
            && {alive _unit}
            && {!(_unit getVariable ["BIS_revive_incapacitated", false])}
            && {_record getOrDefault ["state", "LOBBY"] isEqualTo "ACTIVE"}
            && {_record getOrDefault ["deployed", false]};

        if (_eligible) then {
            if (_controlXpAmount > 0 && {_assignedSide isEqualTo _controller}) then {
                [_uid, _controlXpAmount, "control"] call bn_koth_fnc_progression_xp_addXp;
                _rewarded = _rewarded + 1;
            };

            if (_priorityActive
                && {_priorityXpAmount > 0}
                && {(getPosATL _unit select 2) < _maximumControlHeight}
                && {_unit inArea _priorityMarker}) then {
                [_uid, _priorityXpAmount, "priority"] call bn_koth_fnc_progression_xp_addXp;
                _rewarded = _rewarded + 1;
            };
        };
    };
} forEach _activeParticipants;

_rewarded

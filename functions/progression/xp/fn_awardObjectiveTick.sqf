/*
    File: fn_awardObjectiveTick.sqf
    Author: Tylervip
    Edited: Legend
    Description: Awards configured objective XP and cash from the zone-owned
        eligibility snapshot.
        Zone owns AO and Priority eligibility. Progression consumes that
        authoritative result and only decides reward amounts.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of eligible reward entries processed <NUMBER>
    Public: No
*/

if (!isServer) exitWith {0};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {0};
private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];
if !(_zoneState in ["CONTROLLED", "CONTESTED"]) exitWith {0};
private _controller = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
if (_zoneState isEqualTo "CONTROLLED" && {!([_controller] call bn_koth_fnc_teams_validateSide)}) exitWith {0};

private _snapshot = missionNamespace getVariable ["BN_KOTH_zoneEligibleSnapshot", createHashMap];
if !(_snapshot isEqualType createHashMap) exitWith {0};
private _sides = _snapshot getOrDefault ["sides", []];
private _eligibleBySide = _snapshot getOrDefault ["eligibleUids", []];
private _priorityBySide = _snapshot getOrDefault ["priorityUids", []];
if ((count _sides) < 2 || {count _eligibleBySide != count _sides} || {count _priorityBySide != count _sides}) exitWith {0};

private _participationXp = missionNamespace getVariable ["BN_KOTH_xpPerParticipationTick", 0];
private _controlXp = missionNamespace getVariable ["BN_KOTH_xpPerControlBonus", 0];
private _priorityXp = missionNamespace getVariable ["BN_KOTH_xpPerPriorityBonus", 0];
private _participationCash = missionNamespace getVariable ["BN_KOTH_cashPerParticipationTick", 0];
private _controlCash = missionNamespace getVariable ["BN_KOTH_cashPerControlBonus", 0];
private _priorityCash = missionNamespace getVariable ["BN_KOTH_cashPerPriorityBonus", 0];
private _rewarded = 0;

{
    private _side = _x;
    private _priorityUids = _priorityBySide select _forEachIndex;
    private _hasControl = _zoneState isEqualTo "CONTROLLED" && {_side isEqualTo _controller};
    {
        private _uid = _x;
        if !(_uid isEqualTo "") then {
            private _xp = _participationXp;
            private _cash = _participationCash;
            if (_hasControl) then {
                _xp = _xp + _controlXp;
                _cash = _cash + _controlCash;
            };
            if (_uid in _priorityUids) then {
                _xp = _xp + _priorityXp;
                _cash = _cash + _priorityCash;
            };
            if (_xp > 0) then {
                [_uid, _xp, "objective"] call bn_koth_fnc_progression_xp_addXp;
            };
            if (_cash > 0) then {
                [_uid, _cash, "objective"] call bn_koth_fnc_progression_cash_addCash;
            };
            _rewarded = _rewarded + 1;
        };
    } forEach (_eligibleBySide select _forEachIndex);
} forEach _sides;

_rewarded

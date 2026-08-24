/*
    File: fn_awardControlTick.sqf
    Author: Tylervip
    Edited: Legend
    Description: Awards configured objective XP and cash from the zone-owned
        eligibility snapshot.
        Zone owns AO and Priority eligibility. Progression consumes that
        authoritative result and only decides reward amounts.
    Execution: Server
    Parameters:
        0: Validated controlling side <SIDE>
    Returns:
        Number of eligible reward entries processed <NUMBER>
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
private _controlCashAmount = missionNamespace getVariable ["BN_KOTH_cashPerControlTick", 0];
private _priorityCashAmount = missionNamespace getVariable ["BN_KOTH_cashPerPriorityTick", 0];
if (
    _controlXpAmount <= 0 &&
    {_priorityXpAmount <= 0} &&
    {_controlCashAmount <= 0} &&
    {_priorityCashAmount <= 0}
) exitWith {0};

private _snapshot = missionNamespace getVariable ["BN_KOTH_zoneEligibleSnapshot", createHashMap];
if !(_snapshot isEqualType createHashMap) exitWith {0};

private _sides = _snapshot getOrDefault ["sides", []];
private _eligibleBySide = _snapshot getOrDefault ["eligibleUids", []];
private _priorityBySide = _snapshot getOrDefault ["priorityUids", []];

if ((count _sides) < 2 || {(count _eligibleBySide) < 2} || {(count _priorityBySide) < 2}) exitWith {0};

private _controllerIndex = _sides find _controller;
if (_controllerIndex < 0) exitWith {0};

private _rewarded = 0;

if (_controlXpAmount > 0 || {_controlCashAmount > 0}) then {
    {
        if !(_x isEqualTo "") then {
            if (_controlXpAmount > 0) then {
                [_x, _controlXpAmount, "control"] call bn_koth_fnc_progression_xp_addXp;
            };
            if (_controlCashAmount > 0) then {
                [_x, _controlCashAmount, "control"] call bn_koth_fnc_progression_cash_addCash;
            };
            _rewarded = _rewarded + 1;
        };
    } forEach (_eligibleBySide select _controllerIndex);
};

if (_priorityXpAmount > 0 || {_priorityCashAmount > 0}) then {
    {
        {
            if !(_x isEqualTo "") then {
                if (_priorityXpAmount > 0) then {
                    [_x, _priorityXpAmount, "priority"] call bn_koth_fnc_progression_xp_addXp;
                };
                if (_priorityCashAmount > 0) then {
                    [_x, _priorityCashAmount, "priority"] call bn_koth_fnc_progression_cash_addCash;
                };
                _rewarded = _rewarded + 1;
            };
        } forEach _x;
    } forEach _priorityBySide;
};

_rewarded

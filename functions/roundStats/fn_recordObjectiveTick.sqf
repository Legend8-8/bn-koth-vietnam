/*
    File: fn_recordObjectiveTick.sqf
    Author: Legend
    Description: Credits physical objective points to players present in the authoritative
        zone eligibility snapshot when a validated team score tick is actually awarded.
        Priority XP does not inflate this statistic.
    Execution: Server
    Parameters:
        0: Validated controlling side <SIDE>
        1: Team score points awarded this tick <NUMBER>
    Returns:
        Number of players credited <NUMBER>
    Public: No
*/

params [
    ["_controller", sideUnknown, [sideUnknown]],
    ["_points", 0, [0]]
];

if (!isServer) exitWith {0};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {0};
if !([_controller] call bn_koth_fnc_teams_validateSide) exitWith {0};
if (_points <= 0) exitWith {0};

private _snapshot = missionNamespace getVariable ["BN_KOTH_zoneEligibleSnapshot", createHashMap];
if !(_snapshot isEqualType createHashMap) exitWith {0};

private _sides = _snapshot getOrDefault ["sides", []];
private _eligibleBySide = _snapshot getOrDefault ["eligibleUids", []];

private _controllerIndex = _sides find _controller;
if (_controllerIndex < 0) exitWith {0};
if (_controllerIndex >= count _eligibleBySide) exitWith {0};

private _eligibleUids = _eligibleBySide select _controllerIndex;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];

if !(_records isEqualType createHashMap) then {_records = createHashMap};
if !(_stats isEqualType createHashMap) then {_stats = createHashMap};

private _credited = 0;

{
    private _uid = _x;
    if !(_uid isEqualTo "") then {
        private _playerStats = _stats getOrDefault [_uid, createHashMap];
        if !(_playerStats isEqualType createHashMap) then {_playerStats = createHashMap};

        private _record = _records getOrDefault [_uid, createHashMap];
        private _name = if (_record isEqualType createHashMap) then {
            _record getOrDefault ["name", _uid]
        } else {
            _uid
        };

        private _objectivePoints = (_playerStats getOrDefault ["objectivePoints", 0]) + _points;

        _playerStats set ["name", _name];
        _playerStats set ["objectivePoints", _objectivePoints];
        _stats set [_uid, _playerStats];

        ["objective", _uid, _name, _objectivePoints] call bn_koth_fnc_roundStats_updateLeader;
        _credited = _credited + 1;
    };
} forEach _eligibleUids;

missionNamespace setVariable ["BN_KOTH_roundStats", _stats];
_credited

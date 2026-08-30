/*
    File: fn_execute.sqf
    Author: Legend
    Edited: Legend
    Description: Moves the local unit along the measured cubic traversal path.
    Execution: Owning client in scheduled environment
    Parameters:
        0: Traversing unit <OBJECT>
        1: Valid traversal probe result <HASHMAP>
    Returns:
        Completion result from traversal_finish or traversal_cancel <BOOL>
    Public: Yes
*/

params [
    ["_unit", objNull, [objNull]],
    ["_result", createHashMap, [createHashMap]]
];

private _stateCheck = [_unit] call bn_koth_fnc_traversal_canTraverse;
if !(_stateCheck getOrDefault ["valid", false]) exitWith {
    [_unit, _result, _stateCheck getOrDefault ["reason", "INVALID_PLAYER_STATE"], false, []] call bn_koth_fnc_traversal_cancel
};

private _landing = _result getOrDefault ["landingPositionASL", []];
private _origin = _result getOrDefault ["originASL", []];
private _ledge = _result getOrDefault ["ledgePositionASL", []];
if (((count _landing) != 3) || {(count _origin) != 3} || {(count _ledge) != 3}) exitWith {
    [_unit, _result, "NO_LANDING_SUPPORT", false, []] call bn_koth_fnc_traversal_cancel
};

private _cfg = missionConfigFile >> "CfgBnKothTraversal";
private _start = getPosASL _unit;
private _originTolerance = getNumber (_cfg >> "executionOriginTolerance");
if ((_start vectorDistance _origin) > _originTolerance) exitWith {
    [_unit, _result, "ORIGIN_MOVED", false, []] call bn_koth_fnc_traversal_cancel
};

private _action = _result getOrDefault ["action", "VAULT"];
private _landingMode = _result getOrDefault ["landingMode", "ON_TOP"];
private _animation = [_unit, _action, _landingMode, "START"] call bn_koth_fnc_traversal_selectAnimation;
private _finishAnimation = [_unit, _action, _landingMode, "FINISH"] call bn_koth_fnc_traversal_selectAnimation;
private _forward = vectorNormalized (_result getOrDefault ["facingDirection", vectorDir _unit]);
private _height = _result getOrDefault ["height", 0.80];
private _loadFactor = load _unit;
private _baseDuration = switch (_action) do {
    case "STEP_OVER": {getNumber (_cfg >> "stepOverDuration")};
    case "VAULT": {getNumber (_cfg >> "vaultDuration")};
    case "MANTLE_LOW": {getNumber (_cfg >> "lowMantleDuration")};
    case "MANTLE_MEDIUM": {getNumber (_cfg >> "mediumMantleDuration")};
    case "MANTLE_HIGH": {getNumber (_cfg >> "highMantleDuration")};
    default {getNumber (_cfg >> "vaultDuration")};
};
private _requestedSpeed = (getNumber (_cfg >> "traversalSpeed")) max 0.20;
private _duration = (_baseDuration * (1 + (_loadFactor * 0.25))) / _requestedSpeed;
private _staminaCost = 1.5 + (_height * 2.75) + (_loadFactor * 3.0);

private _horizontalDistance = sqrt (
    ((_landing select 0) - (_start select 0)) ^ 2
    + ((_landing select 1) - (_start select 1)) ^ 2
);
private _edgeClearance = getNumber (_cfg >> "edgeClearance");
private _arcZ = ((_ledge select 2) + _edgeClearance) max (((_start select 2) max (_landing select 2)) + 0.18);
private _lead = (0.12 + (_horizontalDistance * 0.18)) min 0.32;
private _follow = (0.16 + (_horizontalDistance * 0.16)) min 0.34;
private _controlOne = _start vectorAdd (_forward vectorMultiply _lead);
_controlOne set [2, _arcZ];
private _controlTwo = _landing vectorDiff (_forward vectorMultiply _follow);
_controlTwo set [2, if (_landingMode isEqualTo "OVER") then {_arcZ} else {_arcZ max ((_landing select 2) + 0.12)}];

_result set ["selectedAnimation", _animation];
_result set ["finishAnimation", _finishAnimation];
_result set ["staminaCost", _staminaCost];
_result set ["movementWaypoints", [_start, _controlOne, _controlTwo, _landing]];
_result set ["state", "TRAVERSING"];
_result set ["timestamp", diag_tickTime];
missionNamespace setVariable ["BN_KOTH_traversalLastResult", _result];
_unit setVariable ["BN_KOTH_traversalState", "TRAVERSING"];

private _checkInterruption = {
    if (isNull _unit) exitWith {"PLAYER_DELETED"};
    if (!local _unit) exitWith {"PLAYER_NOT_LOCAL"};
    if (!alive _unit) exitWith {"PLAYER_DEAD"};
    if ((lifeState _unit) isEqualTo "INCAPACITATED") exitWith {"PLAYER_UNCONSCIOUS"};
    if !(isNull (objectParent _unit)) exitWith {"PLAYER_IN_VEHICLE"};
    if !(isNull (attachedTo _unit)) exitWith {"PLAYER_ATTACHED"};
    if !((_unit getVariable ["BN_KOTH_traversalState", "IDLE"]) isEqualTo "TRAVERSING") exitWith {"TRAVERSAL_STATE_LOST"};
    ""
};

private _cubicPoint = {
    params ["_phase"];
    private _inverse = 1 - _phase;
    private _weight0 = _inverse ^ 3;
    private _weight1 = 3 * (_inverse ^ 2) * _phase;
    private _weight2 = 3 * _inverse * (_phase ^ 2);
    private _weight3 = _phase ^ 3;
    [
        ((_start select 0) * _weight0) + ((_controlOne select 0) * _weight1) + ((_controlTwo select 0) * _weight2) + ((_landing select 0) * _weight3),
        ((_start select 1) * _weight0) + ((_controlOne select 1) * _weight1) + ((_controlTwo select 1) * _weight2) + ((_landing select 1) * _weight3),
        ((_start select 2) * _weight0) + ((_controlOne select 2) * _weight1) + ((_controlTwo select 2) * _weight2) + ((_landing select 2) * _weight3)
    ]
};

_unit setVectorDir _forward;
_unit playMoveNow _animation;
[
    "INFO",
    format [
        "Traversal started: %1 %2 animation=%3 finish=%4 duration=%5 stamina=%6",
        _action,
        _landingMode,
        _animation,
        _finishAnimation,
        _duration toFixed 2,
        _staminaCost toFixed 1
    ]
] call bn_koth_fnc_traversal_log;

private _interruption = "";
private _startedAt = diag_tickTime;
private _tick = (getNumber (_cfg >> "pathTick")) max 0.005;
while {_interruption isEqualTo "" && {(diag_tickTime - _startedAt) < _duration}} do {
    _interruption = call _checkInterruption;
    if (_interruption isEqualTo "") then {
        private _phase = ((diag_tickTime - _startedAt) / _duration) min 1;
        private _easedPhase = _phase * _phase * (3 - (2 * _phase));
        _unit setVelocity [0, 0, 0];
        _unit setPosASL ([_easedPhase] call _cubicPoint);
        sleep _tick;
    };
};

if (_interruption != "") exitWith {
    [_unit, _result, _interruption, true, _start] call bn_koth_fnc_traversal_cancel
};

[_unit, _result] call bn_koth_fnc_traversal_finish

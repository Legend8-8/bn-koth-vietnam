/*
    File: fn_updatePriorityZone.sqf
    Author: Mango Mongo
    Description: Moves the rectangular priority-zone marker inside the active AO.
    Execution: Server
    Parameters:
        None
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _priorityWasActive = missionNamespace getVariable ["BN_KOTH_priorityZoneActive", false];

if (_activeMarker isEqualTo "" || {(markerShape _activeMarker) isEqualTo ""}) exitWith {
    if (_priorityWasActive && {!((markerShape _priorityMarker) isEqualTo "")}) then {
        _priorityMarker setMarkerAlpha 0;
    };
    missionNamespace setVariable ["BN_KOTH_priorityZoneActive", false];
    false
};

private _activeShape = markerShape _activeMarker;
if !(_activeShape in ["RECTANGLE", "ELLIPSE"]) exitWith {
    if (_priorityWasActive && {!((markerShape _priorityMarker) isEqualTo "")}) then {
        _priorityMarker setMarkerAlpha 0;
    };
    missionNamespace setVariable ["BN_KOTH_priorityZoneActive", false];

    if !(missionNamespace getVariable ["BN_KOTH_warnedUnsupportedPriorityAoShape", false]) then {
        missionNamespace setVariable ["BN_KOTH_warnedUnsupportedPriorityAoShape", true];
        [format ["Priority zone disabled: unsupported AO marker shape '%1'.", _activeShape], "WARN"] call bn_koth_fnc_common_log;
    };
    false
};
missionNamespace setVariable ["BN_KOTH_warnedUnsupportedPriorityAoShape", false];

private _aoSize = markerSize _activeMarker;
private _aoHalfWidth = if ((count _aoSize) > 0) then {_aoSize select 0} else {40};
private _aoHalfHeight = if ((count _aoSize) > 1) then {_aoSize select 1} else {30};
private _priorityRatio = missionNamespace getVariable ["BN_KOTH_priorityZoneRatio", sqrt 0.10];
private _priorityMinimumHalfSize = missionNamespace getVariable ["BN_KOTH_priorityZoneMinimumHalfSize", 1];
private _priorityHalfWidth = (_aoHalfWidth * _priorityRatio) max _priorityMinimumHalfSize;
private _priorityHalfHeight = (_aoHalfHeight * _priorityRatio) max _priorityMinimumHalfSize;
private _aoDirection = markerDir _activeMarker;
private _aoCenter = markerPos _activeMarker;

private _fnc_footprintInsideAo = {
    params ["_candidateCenter"];

    private _cosDirection = cos _aoDirection;
    private _sinDirection = sin _aoDirection;
    private _localCorners = [
        [-_priorityHalfWidth, -_priorityHalfHeight],
        [-_priorityHalfWidth, _priorityHalfHeight],
        [_priorityHalfWidth, -_priorityHalfHeight],
        [_priorityHalfWidth, _priorityHalfHeight]
    ];

    (_localCorners findIf {
        private _localX = _x select 0;
        private _localY = _x select 1;
        private _worldCorner = [
            (_candidateCenter select 0) + (_localX * _cosDirection) + (_localY * _sinDirection),
            (_candidateCenter select 1) - (_localX * _sinDirection) + (_localY * _cosDirection),
            0
        ];
        !(_worldCorner inArea _activeMarker)
    }) isEqualTo -1
};

if !([_aoCenter] call _fnc_footprintInsideAo) exitWith {
    if (_priorityWasActive && {!((markerShape _priorityMarker) isEqualTo "")}) then {
        _priorityMarker setMarkerAlpha 0;
    };
    missionNamespace setVariable ["BN_KOTH_priorityZoneActive", false];

    if !(missionNamespace getVariable ["BN_KOTH_warnedPriorityZoneTooLarge", false]) then {
        missionNamespace setVariable ["BN_KOTH_warnedPriorityZoneTooLarge", true];
        [format ["Priority zone disabled: configured footprint does not fit inside AO '%1'.", _activeMarker], "WARN"] call bn_koth_fnc_common_log;
    };
    false
};
missionNamespace setVariable ["BN_KOTH_warnedPriorityZoneTooLarge", false];

private _priorityMarkerExists = !((markerShape _priorityMarker) isEqualTo "");
if (!_priorityMarkerExists) then {
    createMarker [_priorityMarker, _aoCenter];
};

private _previousAoMarker = missionNamespace getVariable ["BN_KOTH_priorityZoneAoMarker", ""];
private _requiresInitialization = !_priorityWasActive || {!(_previousAoMarker isEqualTo _activeMarker)};

if (_requiresInitialization) exitWith {
    _priorityMarker setMarkerShapeLocal "RECTANGLE";
    _priorityMarker setMarkerBrushLocal (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerBrush", "Solid"]);
    _priorityMarker setMarkerColorLocal (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerColor", "ColorGreen"]);
    _priorityMarker setMarkerTextLocal "Priority Zone";
    _priorityMarker setMarkerSizeLocal [_priorityHalfWidth, _priorityHalfHeight];
    _priorityMarker setMarkerDirLocal _aoDirection;
    _priorityMarker setMarkerPosLocal _aoCenter;

    missionNamespace setVariable ["BN_KOTH_priorityZoneActive", true];
    missionNamespace setVariable ["BN_KOTH_priorityZoneAoMarker", _activeMarker];
    missionNamespace setVariable ["BN_KOTH_priorityZoneHeading", random 360];
    missionNamespace setVariable ["BN_KOTH_priorityZoneLastUpdateAt", serverTime];

    // One global marker command publishes the complete locally prepared marker state.
    _priorityMarker setMarkerAlpha (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerAlpha", 0.75]);
    true
};

private _now = serverTime;
private _lastUpdateAt = missionNamespace getVariable ["BN_KOTH_priorityZoneLastUpdateAt", _now];
private _elapsed = (_now - _lastUpdateAt) max 0;
missionNamespace setVariable ["BN_KOTH_priorityZoneLastUpdateAt", _now];

if (_elapsed <= 0) exitWith {true};

private _moveTickInterval = missionNamespace getVariable ["BN_KOTH_priorityZoneMoveTickInterval", 0.5];
private _moveDistancePerTick = missionNamespace getVariable ["BN_KOTH_priorityZoneMoveDistancePerTick", 0.25];
private _moveSpeed = _moveDistancePerTick / (_moveTickInterval max 0.01);
private _moveDistance = _moveSpeed * _elapsed;
private _currentPos = markerPos _priorityMarker;
private _heading = missionNamespace getVariable ["BN_KOTH_priorityZoneHeading", random 360];
private _candidatePos = [
    (_currentPos select 0) + ((sin _heading) * _moveDistance),
    (_currentPos select 1) + ((cos _heading) * _moveDistance),
    0
];

private _attempts = 0;
private _maximumAttempts = 8;
while {(_attempts < _maximumAttempts) && {!([_candidatePos] call _fnc_footprintInsideAo)}} do {
    _heading = (_heading + 90 + random 45) mod 360;
    _candidatePos = [
        (_currentPos select 0) + ((sin _heading) * _moveDistance),
        (_currentPos select 1) + ((cos _heading) * _moveDistance),
        0
    ];
    _attempts = _attempts + 1;
};

if !([_candidatePos] call _fnc_footprintInsideAo) then {
    _candidatePos = _currentPos;
    _heading = random 360;
};

missionNamespace setVariable ["BN_KOTH_priorityZoneHeading", _heading];

if !(_candidatePos isEqualTo _currentPos) then {
    _priorityMarker setMarkerPos _candidatePos;
};

true

/*
    File: fn_updatePriorityZone.sqf
    Author: Mongo
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
if ((missionNamespace getVariable ["BN_KOTH_activePriorityMode", "ROAMING_2D"]) isEqualTo "VERTICAL_FLOORS") exitWith {
    private _locationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
    private _locationData = createHashMap;
    private _geometry = missionNamespace getVariable ["BN_KOTH_verticalPriorityGeometry", createHashMap];
    private _state = missionNamespace getVariable ["BN_KOTH_verticalPriorityState", createHashMap];
    if ((count _geometry) isEqualTo 0) then {
        _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
        _geometry = [_locationData] call bn_koth_fnc_zone_resolveVerticalPriorityGeometry;
        if ((count _geometry) > 0) then {
            ["BN_KOTH_verticalPriorityGeometry", _geometry] call bn_koth_fnc_common_publicState;
        };
    };
    if ((count _geometry) isEqualTo 0) exitWith {false};

    private _footprint = _geometry get "marker";
    private _floors = _geometry get "floors";
    if ((count _state) isEqualTo 0) then {
        if ((count _locationData) isEqualTo 0) then {_locationData = [_locationId] call bn_koth_fnc_zone_getLocationData};
        if ((markerShape _priorityMarker) isEqualTo "") then {
            createMarker [_priorityMarker, markerPos _footprint];
        };
        _priorityMarker setMarkerShape "RECTANGLE";
        _priorityMarker setMarkerBrush (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerBrush", "Solid"]);
        _priorityMarker setMarkerColor (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerColor", "ColorGreen"]);
        _priorityMarker setMarkerSize (markerSize _footprint);
        _priorityMarker setMarkerDir (markerDir _footprint);
        _priorityMarker setMarkerPos (markerPos _footprint);
        _priorityMarker setMarkerText "Priority Zone";
        _priorityMarker setMarkerAlpha (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerAlpha", 0.75]);
        _state = createHashMapFromArray [
            ["phase", "DWELL"], ["activeIndex", 0], ["sourceIndex", 0],
            ["destinationIndex", 0], ["startAt", serverTime], ["endAt", serverTime],
            ["nextMoveAt", serverTime + ((_locationData getOrDefault ["priorityDwellSeconds", 25]) max 1)],
            ["direction", 1]
        ];
        missionNamespace setVariable ["BN_KOTH_priorityZoneActive", true];
        missionNamespace setVariable ["BN_KOTH_priorityZoneAoMarker", _activeMarker];
        ["BN_KOTH_verticalPriorityState", _state, true] call bn_koth_fnc_common_publicState;
        true
    } else {
        private _now = serverTime;
        if ((_state getOrDefault ["phase", ""]) isEqualTo "MOVING") then {
            if (_now >= (_state getOrDefault ["endAt", _now])) then {
                _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
                private _destination = _state get "destinationIndex";
                _state set ["phase", "DWELL"];
                _state set ["activeIndex", _destination];
                _state set ["sourceIndex", _destination];
                _state set ["nextMoveAt", _now + ((_locationData getOrDefault ["priorityDwellSeconds", 25]) max 1)];
                ["BN_KOTH_verticalPriorityState", _state, true] call bn_koth_fnc_common_publicState;
            };
        } else {
            if (_now >= (_state getOrDefault ["nextMoveAt", _now + 1])) then {
                _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
                private _current = _state getOrDefault ["activeIndex", 0];
                private _direction = _state getOrDefault ["direction", 1];
                if (_current isEqualTo 0) then {_direction = 1} else {
                    if (_current isEqualTo ((count _floors) - 1)) then {_direction = -1} else {
                        if ((random 1) > (((_locationData getOrDefault ["priorityContinueChance", 0.75]) max 0) min 1)) then {
                            _direction = -_direction;
                        };
                    };
                };
                _state set ["phase", "MOVING"];
                _state set ["activeIndex", _current];
                _state set ["sourceIndex", _current];
                _state set ["destinationIndex", _current + _direction];
                _state set ["direction", _direction];
                _state set ["startAt", _now];
                _state set ["endAt", _now + ((_locationData getOrDefault ["priorityTransitionSeconds", 8]) max 0.1)];
                ["BN_KOTH_verticalPriorityState", _state, true] call bn_koth_fnc_common_publicState;
            };
        };
        true
    }
};

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

    // One global marker command publishes the complete locally prepared marker state.
    _priorityMarker setMarkerAlpha (missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerAlpha", 0.75]);
    true
};

private _moveDistancePerFrame = missionNamespace getVariable ["BN_KOTH_priorityZoneMoveDistancePerTick", 0.25];
private _frameDelta = diag_deltaTime max 0.01;
private _moveDistance = _moveDistancePerFrame * _frameDelta;
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

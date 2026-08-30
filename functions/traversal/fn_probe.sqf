/*
    File: fn_probe.sqf
    Author: Mango Mongo
    Edited: Mango Mongo
    Description: Finds a climbable face, ledge profile, clear path, and supported destination.
    Execution: Owning client; the supplied unit must be local
    Parameters:
        0: Unit performing the traversal probe <OBJECT>
    Returns:
        Detailed traversal probe result <HASHMAP>
    Public: Yes
*/

params [["_unit", objNull, [objNull]]];

private _originASL = if (isNull _unit) then {[0, 0, 0]} else {getPosASL _unit};
private _rawForward = if (isNull _unit) then {[0, 1, 0]} else {vectorDir _unit};
private _forward = vectorNormalized [_rawForward select 0, _rawForward select 1, 0];
private _right = _forward vectorCrossProduct [0, 0, 1];

private _result = createHashMapFromArray [
    ["valid", false],
    ["reason", "NO_OBSTACLE"],
    ["state", "PROBING"],
    ["action", "NONE"],
    ["selectedAnimation", "NONE"],
    ["finishAnimation", ""],
    ["timestamp", diag_tickTime],
    ["originASL", _originASL],
    ["forward", _forward],
    ["right", _right],
    ["forwardRays", []],
    ["ledgeRays", []],
    ["supportRays", []],
    ["clearanceRays", []],
    ["pathRays", []],
    ["movementWaypoints", []],
    ["wallPositionASL", []],
    ["wallNormal", []],
    ["wallObject", objNull],
    ["obstacleDistance", -1],
    ["ledgePositionASL", []],
    ["topNormal", []],
    ["height", -1],
    ["landingPositionASL", []],
    ["landingObject", objNull],
    ["landingClear", false],
    ["landingMode", "NONE"],
    ["facingDirection", _forward]
];

if (isNull _unit) exitWith {
    _result set ["reason", "NO_PLAYER"];
    _result
};
if (!local _unit) exitWith {
    _result set ["reason", "PLAYER_NOT_LOCAL"];
    _result
};

private _cfg = missionConfigFile >> "CfgBnKothTraversal";
private _minHeight = getNumber (_cfg >> "minObstacleHeight");
private _maxHeight = getNumber (_cfg >> "maxMantleHeight");
private _faceDistance = getNumber (_cfg >> "faceProbeDistance");
private _faceHeights = getArray (_cfg >> "faceProbeHeights");
private _faceOffsets = getArray (_cfg >> "faceProbeOffsets");

private _forwardRays = [];
private _facePosition = [];
private _faceNormal = [];
private _faceObject = objNull;
private _faceLocal = [];
private _nearestDistance = 1e6;

{
    private _lateral = _x;
    {
        private _height = _x;
        private _startASL = AGLToASL (_unit modelToWorld [_lateral, 0.02, _height]);
        private _endASL = AGLToASL (_unit modelToWorld [_lateral, _faceDistance, _height]);
        private _hits = lineIntersectsSurfaces [
            _startASL,
            _endASL,
            _unit,
            objNull,
            true,
            1,
            "GEOM",
            "FIRE"
        ];

        private _hitPosition = [];
        private _accepted = false;
        if ((count _hits) > 0) then {
            private _hit = _hits select 0;
            private _candidatePosition = _hit select 0;
            private _candidateNormal = _hit select 1;
            private _candidateLocal = _unit worldToModel (ASLToAGL _candidatePosition);
            private _candidateDistance = _candidateLocal select 1;
            if (
                (_candidateDistance > 0.04)
                && {_candidateDistance <= (_faceDistance + 0.05)}
                && {(_candidateNormal select 2) < 0.75}
            ) then {
                _accepted = true;
                _hitPosition = _candidatePosition;
                if (_candidateDistance < _nearestDistance) then {
                    _nearestDistance = _candidateDistance;
                    _facePosition = _candidatePosition;
                    _faceNormal = _candidateNormal;
                    _faceObject = _hit select 2;
                    _faceLocal = _candidateLocal;
                };
            };
        };
        _forwardRays pushBack [_startASL, _endASL, _hitPosition, _accepted];
    } forEach _faceHeights;
} forEach _faceOffsets;

_result set ["forwardRays", _forwardRays];
if ((count _facePosition) != 3) exitWith {_result};

_result set ["wallPositionASL", _facePosition];
_result set ["wallNormal", _faceNormal];
_result set ["wallObject", _faceObject];
_result set ["obstacleDistance", _nearestDistance];

private _normalLimit = getNumber (_cfg >> "minSurfaceNormalZ");
private _probeMargin = getNumber (_cfg >> "topProbeMargin");
private _probeVertical = {
    params ["_localX", "_localY", "_minimumZ", "_maximumZ"];
    private _baseASL = AGLToASL (_unit modelToWorld [_localX, _localY, 0]);
    private _rayStart = [_baseASL select 0, _baseASL select 1, _maximumZ + _probeMargin];
    private _rayEnd = [_baseASL select 0, _baseASL select 1, _minimumZ - 0.10];
    private _hits = lineIntersectsSurfaces [
        _rayStart,
        _rayEnd,
        _unit,
        objNull,
        true,
        -1,
        "GEOM",
        "FIRE"
    ];

    private _position = [];
    private _normal = [];
    private _object = objNull;
    {
        private _candidatePosition = _x select 0;
        private _candidateNormal = _x select 1;
        if (
            ((_candidateNormal select 2) >= _normalLimit)
            && {(_candidatePosition select 2) >= _minimumZ}
            && {(_candidatePosition select 2) <= (_maximumZ + 0.05)}
        ) exitWith {
            _position = _candidatePosition;
            _normal = _candidateNormal;
            _object = _x select 2;
        };
    } forEach _hits;
    [_position, _normal, _object, _rayStart, _rayEnd]
};

private _faceX = _faceLocal select 0;
private _faceY = _faceLocal select 1;
private _minimumTopZ = (_originASL select 2) + _minHeight;
private _maximumTopZ = (_originASL select 2) + _maxHeight;
private _depthSamples = getArray (_cfg >> "topDepthSamples");
private _supportRays = [];
private _topPosition = [];
private _topNormal = [];

{
    private _probe = [_faceX, _faceY + _x, _minimumTopZ, _maximumTopZ] call _probeVertical;
    private _position = _probe select 0;
    _supportRays pushBack [_probe select 3, _probe select 4, _position, (count _position) isEqualTo 3];
    if (
        ((count _position) isEqualTo 3)
        && {((count _topPosition) != 3) || {(_position select 2) > (_topPosition select 2)}}
    ) then {
        _topPosition = _position;
        _topNormal = _probe select 1;
    };
} forEach _depthSamples;

_result set ["supportRays", _supportRays];
_result set ["ledgeRays", _supportRays];
if ((count _topPosition) != 3) exitWith {
    _result set ["reason", "NO_LEDGE"];
    _result
};

private _height = (_topPosition select 2) - (_originASL select 2);
_result set ["height", _height];
_result set ["ledgePositionASL", _topPosition];
_result set ["topNormal", _topNormal];

private _classification = [_height] call bn_koth_fnc_traversal_classify;
if !(_classification getOrDefault ["valid", false]) exitWith {
    _result set ["reason", _classification getOrDefault ["reason", "INVALID_SURFACE"]];
    _result
};

private _profileDepth = getNumber (_cfg >> "profileDepth");
private _exitDepth = getNumber (_cfg >> "exitDepth");
private _profileTolerance = getNumber (_cfg >> "profileTolerance");
private _maxDropBeyond = getNumber (_cfg >> "maxDropBeyond");
private _floorMinimum = (_originASL select 2) - _maxDropBeyond;
private _profileProbe = [_faceX, _faceY + _profileDepth, _floorMinimum, _maximumTopZ] call _probeVertical;
private _profilePosition = _profileProbe select 0;
_supportRays pushBack [_profileProbe select 3, _profileProbe select 4, _profilePosition, (count _profilePosition) isEqualTo 3];

private _landOnTop = ((count _profilePosition) isEqualTo 3)
    && {abs ((_profilePosition select 2) - (_topPosition select 2)) <= _profileTolerance};
private _landingSurface = [];
private _landingObject = objNull;

if (_landOnTop) then {
    _landingSurface = _profilePosition;
    _landingObject = _profileProbe select 2;
} else {
    private _exitProbe = [_faceX, _faceY + _exitDepth, _floorMinimum, _maximumTopZ] call _probeVertical;
    _landingSurface = _exitProbe select 0;
    _landingObject = _exitProbe select 2;
    _supportRays pushBack [_exitProbe select 3, _exitProbe select 4, _landingSurface, (count _landingSurface) isEqualTo 3];
};

_result set ["supportRays", _supportRays];
_result set ["ledgeRays", _supportRays];
if ((count _landingSurface) != 3) exitWith {
    _result set ["reason", "NO_LANDING_SUPPORT"];
    _result
};

if (!_landOnTop && {((_originASL select 2) - (_landingSurface select 2)) > _maxDropBeyond}) exitWith {
    _result set ["reason", "DROP_TOO_HIGH"];
    _result
};

private _landingPosition = _landingSurface vectorAdd [0, 0, getNumber (_cfg >> "landingHeightOffset")];
private _halfWidth = getNumber (_cfg >> "bodyHalfWidth");
private _headroom = getNumber (_cfg >> "landingHeadroom");
private _clearanceRays = [];
private _landingClear = true;
private _recordClearance = {
    params ["_start", "_end"];
    private _hits = lineIntersectsSurfaces [_start, _end, _unit, objNull, true, 1, "GEOM", "FIRE"];
    private _clear = (count _hits) isEqualTo 0;
    private _hit = if (_clear) then {[]} else {(_hits select 0) select 0};
    _clearanceRays pushBack [_start, _end, _hit, _clear];
    if (!_clear) then {_landingClear = false};
};

{
    private _foot = (_landingPosition vectorAdd (_right vectorMultiply _x)) vectorAdd [0, 0, 0.10];
    [_foot, _foot vectorAdd [0, 0, _headroom]] call _recordClearance;
} forEach [-_halfWidth, 0, _halfWidth];

if (!_landOnTop) then {
    private _openingHeight = getNumber (_cfg >> "openingClearanceHeight");
    private _openingCentre = _topPosition vectorAdd [0, 0, _openingHeight];
    {
        private _row = _openingCentre vectorAdd (_forward vectorMultiply _x);
        [
            _row vectorAdd (_right vectorMultiply -_halfWidth),
            _row vectorAdd (_right vectorMultiply _halfWidth)
        ] call _recordClearance;
    } forEach [-0.08, 0, 0.08];
};

_result set ["clearanceRays", _clearanceRays];
if (!_landingClear) exitWith {
    _result set ["reason", "LANDING_BLOCKED"];
    _result
};

_result set ["valid", true];
_result set ["reason", "OK"];
_result set ["state", "READY"];
_result set ["action", _classification getOrDefault ["action", "NONE"]];
_result set ["landingPositionASL", _landingPosition];
_result set ["landingObject", _landingObject];
_result set ["landingClear", true];
_result set ["landingMode", if (_landOnTop) then {"ON_TOP"} else {"OVER"}];
_result

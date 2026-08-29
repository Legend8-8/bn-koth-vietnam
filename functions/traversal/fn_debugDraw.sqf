/*
    File: fn_debugDraw.sqf
    Author: Legend
    Description: Draws the latest traversal probe, clearance, path, and result diagnostics.
    Execution: Client, from the optional local Draw3D mission event handler
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _diagnosticsCfg = missionConfigFile >> "CfgBnKothTraversal" >> "Diagnostics";
if ((getNumber (_diagnosticsCfg >> "debugDraw")) <= 0) exitWith {};

private _result = missionNamespace getVariable ["BN_KOTH_traversalLastResult", createHashMap];
private _timestamp = _result getOrDefault ["timestamp", -1];
if (_timestamp < 0) exitWith {};

private _persistTime = getNumber (_diagnosticsCfg >> "persistTime");
if ((diag_tickTime - _timestamp) > _persistTime) exitWith {};

private _drawRaySet = {
    params ["_rays", "_baseColor"];
    {
        _x params ["_startASL", "_endASL", "_hitASL", "_accepted"];
        private _lineColor = if (_accepted) then {
            [_baseColor select 0, _baseColor select 1, _baseColor select 2, 1]
        } else {
            [_baseColor select 0, _baseColor select 1, _baseColor select 2, 0.35]
        };
        drawLine3D [ASLToAGL _startASL, ASLToAGL _endASL, _lineColor, 2];
        if ((count _hitASL) isEqualTo 3) then {
            drawIcon3D ["", _lineColor, ASLToAGL _hitASL, 0, 0, 0, "+", 2, 0.035, "RobotoCondensed", "center"];
        };
    } forEach _rays;
};

[_result getOrDefault ["forwardRays", []], [0.10, 0.55, 1.00]] call _drawRaySet;
[_result getOrDefault ["ledgeRays", []], [1.00, 0.55, 0.05]] call _drawRaySet;
[_result getOrDefault ["pathRays", []], [0.75, 0.30, 1.00]] call _drawRaySet;

{
    drawIcon3D ["", [0.75, 0.30, 1.00, 1], ASLToAGL _x, 0, 0, 0, "PATH", 2, 0.028, "RobotoCondensed", "center"];
} forEach (_result getOrDefault ["movementWaypoints", []]);

{
    _x params ["_startASL", "_endASL", "_hitASL", "_isClear"];
    private _color = if (_isClear) then {[0.10, 1.00, 0.20, 0.75]} else {[1.00, 0.05, 0.05, 1]};
    drawLine3D [ASLToAGL _startASL, ASLToAGL _endASL, _color, 3];
    if ((count _hitASL) isEqualTo 3) then {
        drawIcon3D ["", _color, ASLToAGL _hitASL, 0, 0, 0, "BLOCKED", 2, 0.032, "RobotoCondensed", "center"];
    };
} forEach (_result getOrDefault ["clearanceRays", []]);

private _origin = _result getOrDefault ["originASL", []];
if ((count _origin) isEqualTo 3) then {
    drawIcon3D ["", [1, 1, 1, 1], ASLToAGL _origin, 0, 0, 0, "ORIGIN", 2, 0.035, "RobotoCondensed", "center"];
};

private _wallPosition = _result getOrDefault ["wallPositionASL", []];
private _wallNormal = _result getOrDefault ["wallNormal", []];
if (((count _wallPosition) isEqualTo 3) && {(count _wallNormal) isEqualTo 3}) then {
    drawIcon3D ["", [1, 1, 0, 1], ASLToAGL _wallPosition, 0, 0, 0, "OBSTACLE", 2, 0.04, "RobotoCondensed", "center"];
    private _normalEnd = _wallPosition vectorAdd (_wallNormal vectorMultiply 0.75);
    drawLine3D [ASLToAGL _wallPosition, ASLToAGL _normalEnd, [1, 0, 1, 1], 5];
    drawIcon3D ["", [1, 0, 1, 1], ASLToAGL _normalEnd, 0, 0, 0, format ["NORMAL %1", _wallNormal], 2, 0.032, "RobotoCondensed", "center"];
};

private _ledgePosition = _result getOrDefault ["ledgePositionASL", []];
if ((count _ledgePosition) isEqualTo 3) then {
    drawIcon3D ["", [0, 1, 1, 1], ASLToAGL _ledgePosition, 0, 0, 0, format ["LEDGE h=%1m", (_result getOrDefault ["height", -1]) toFixed 2], 2, 0.04, "RobotoCondensed", "center"];

    if ((count _origin) isEqualTo 3) then {
        private _heightBase = +_ledgePosition;
        _heightBase set [2, _origin select 2];
        drawLine3D [ASLToAGL _heightBase, ASLToAGL _ledgePosition, [0, 1, 1, 1], 4];
    };
};

private _landingPosition = _result getOrDefault ["landingPositionASL", []];
if ((count _landingPosition) isEqualTo 3) then {
    private _landingColor = if (_result getOrDefault ["landingClear", false]) then {[0.10, 1, 0.20, 1]} else {[1, 0.05, 0.05, 1]};
    private _landingLabel = if (_result getOrDefault ["landingClear", false]) then {"LANDING CLEAR"} else {"LANDING BLOCKED"};
    drawIcon3D ["", _landingColor, ASLToAGL _landingPosition, 0, 0, 0, _landingLabel, 2, 0.045, "RobotoCondensed", "center"];
};

{
    _x params ["_supportStart", "_supportEnd", "_supportHit", "_supportValid"];
    private _supportColor = if (_supportValid) then {[0.20, 1, 0.20, 1]} else {[1, 0.10, 0.10, 1]};
    drawLine3D [ASLToAGL _supportStart, ASLToAGL _supportEnd, _supportColor, 4];
    if ((count _supportHit) isEqualTo 3) then {
        drawIcon3D ["", _supportColor, ASLToAGL _supportHit, 0, 0, 0, "SUPPORT", 2, 0.032, "RobotoCondensed", "center"];
    };
} forEach (_result getOrDefault ["supportRays", []]);

private _labelPosition = if ((count _landingPosition) isEqualTo 3) then {
    _landingPosition vectorAdd [0, 0, 2.05]
} else {
    if ((count _wallPosition) isEqualTo 3) then {
        _wallPosition vectorAdd [0, 0, 1.80]
    } else {
        if ((count _origin) isEqualTo 3) then {_origin vectorAdd [0, 0, 2.00]} else {[]}
    }
};

if ((count _labelPosition) isEqualTo 3) then {
    private _valid = _result getOrDefault ["valid", false];
    private _summary = if (_valid) then {
        format [
            "%1 | state=%2 | anim=%3 | d=%4m",
            _result getOrDefault ["action", "NONE"],
            _result getOrDefault ["state", "UNKNOWN"],
            _result getOrDefault ["selectedAnimation", "NONE"],
            (_result getOrDefault ["obstacleDistance", -1]) toFixed 2
        ]
    } else {
        format [
            "REJECTED: %1 | state=%2",
            _result getOrDefault ["reason", "UNKNOWN"],
            _result getOrDefault ["state", "UNKNOWN"]
        ]
    };
    private _summaryColor = if (_valid) then {[0.20, 1, 0.20, 1]} else {[1, 0.15, 0.10, 1]};
    drawIcon3D ["", _summaryColor, ASLToAGL _labelPosition, 0, 0, 0, _summary, 2, 0.05, "RobotoCondensed", "center"];
};

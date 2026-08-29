/*
    File: fn_classify.sqf
    Author: Legend
    Description: Classifies a measured obstacle using configured height thresholds.
    Execution: Any; pure calculation against mission configuration
    Parameters:
        0: Obstacle height in metres <NUMBER>
    Returns:
        Classification with valid, action, and reason fields <HASHMAP>
    Public: Yes
*/

params [["_height", -1, [0]]];

private _cfg = missionConfigFile >> "CfgBnKothTraversal";
private _minHeight = getNumber (_cfg >> "minObstacleHeight");
private _stepMax = getNumber (_cfg >> "stepMaxHeight");
private _vaultMax = getNumber (_cfg >> "vaultMaxHeight");
private _lowMantleMax = getNumber (_cfg >> "lowMantleMaxHeight");
private _mediumMantleMax = getNumber (_cfg >> "mediumMantleMaxHeight");
private _maxMantle = getNumber (_cfg >> "maxMantleHeight");

private _valid = true;
private _action = "NONE";
private _reason = "OK";

if (_height < _minHeight) then {
    _valid = false;
    _reason = "OBSTACLE_TOO_LOW";
} else {
    if (_height <= _stepMax) then {
        _action = "STEP_OVER";
    } else {
        if (_height <= _vaultMax) then {
            _action = "VAULT";
        } else {
            if (_height <= _lowMantleMax) then {
                _action = "MANTLE_LOW";
            } else {
                if (_height <= _mediumMantleMax) then {
                    _action = "MANTLE_MEDIUM";
                } else {
                    if (_height <= _maxMantle) then {
                        _action = "MANTLE_HIGH";
                    } else {
                        _valid = false;
                        _reason = "OBSTACLE_TOO_HIGH";
                    };
                };
            };
        };
    };
};

createHashMapFromArray [
    ["valid", _valid],
    ["action", _action],
    ["reason", _reason]
]

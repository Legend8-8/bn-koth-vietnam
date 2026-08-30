/*
    File: fn_request.sqf
    Author: Mango Mongo
    Description: Validates one local keybind request, probes geometry, and starts traversal.
    Execution: Owning client
    Parameters:
        None
    Returns:
        Traversal request result <HASHMAP>
    Public: Yes
*/

private _publish = {
    params ["_result"];
    _result set ["timestamp", diag_tickTime];
    missionNamespace setVariable ["BN_KOTH_traversalLastResult", _result];

    private _message = if (_result getOrDefault ["valid", false]) then {
        format [
            "%1 %2: height=%3m distance=%4m",
            _result getOrDefault ["action", "NONE"],
            _result getOrDefault ["landingMode", "NONE"],
            (_result getOrDefault ["height", -1]) toFixed 2,
            (_result getOrDefault ["obstacleDistance", -1]) toFixed 2
        ]
    } else {
        format ["Action rejected: %1", _result getOrDefault ["reason", "UNKNOWN"]]
    };

    ["INFO", _message] call bn_koth_fnc_traversal_log;
    _result
};

if (!hasInterface) exitWith {
    [createHashMapFromArray [
        ["valid", false],
        ["reason", "NO_INTERFACE"],
        ["state", "REJECTED"]
    ]] call _publish
};

private _now = diag_tickTime;
private _cooldown = getNumber (missionConfigFile >> "CfgBnKothTraversal" >> "traversalCooldown");
private _lastRequest = missionNamespace getVariable ["BN_KOTH_traversalLastRequestTime", -1000];
if ((_now - _lastRequest) < _cooldown) exitWith {
    [createHashMapFromArray [
        ["valid", false],
        ["reason", "COOLDOWN"],
        ["state", "REJECTED"]
    ]] call _publish
};
missionNamespace setVariable ["BN_KOTH_traversalLastRequestTime", _now];

private _unit = player;
private _stateCheck = [_unit] call bn_koth_fnc_traversal_canTraverse;
if !(_stateCheck getOrDefault ["valid", false]) exitWith {
    _stateCheck set ["state", "REJECTED"];
    [_stateCheck] call _publish
};

private _result = [_unit] call bn_koth_fnc_traversal_probe;
if !(_result getOrDefault ["valid", false]) exitWith {
    _result set ["state", "REJECTED"];
    [_result] call _publish
};

private _published = [_result] call _publish;
[_unit, _published] spawn bn_koth_fnc_traversal_execute;
_published

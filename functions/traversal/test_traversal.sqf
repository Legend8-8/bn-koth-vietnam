/*
    File: test_traversal.sqf
    Author: Mongo
    Description: Focused config, classification, animation, input, and networking checks.
    Execution: Hosted or dedicated session after mission functions initialize
    Parameters:
        None
    Returns:
        Failure descriptions; an empty array is a pass <ARRAY>
    Public: No; standalone developer test
*/

private _failures = [];
private _assert = {
    params ["_condition", "_message"];
    if (!_condition) then {
        _failures pushBack _message;
    };
};

private _cfg = missionConfigFile >> "CfgBnKothTraversal";
[isClass _cfg, "CfgBnKothTraversal is missing"] call _assert;

private _thresholds = [
    getNumber (_cfg >> "minObstacleHeight"),
    getNumber (_cfg >> "stepMaxHeight"),
    getNumber (_cfg >> "vaultMaxHeight"),
    getNumber (_cfg >> "lowMantleMaxHeight"),
    getNumber (_cfg >> "mediumMantleMaxHeight"),
    getNumber (_cfg >> "maxMantleHeight")
];

private _strictlyAscending = true;
for "_index" from 1 to ((count _thresholds) - 1) do {
    if ((_thresholds select _index) <= (_thresholds select (_index - 1))) then {
        _strictlyAscending = false;
    };
};
[_strictlyAscending, "Traversal height thresholds are not strictly ascending"] call _assert;

private _cases = [
    [(_thresholds select 0) - 0.01, false, "NONE", "OBSTACLE_TOO_LOW"],
    [_thresholds select 0, true, "STEP_OVER", "OK"],
    [_thresholds select 1, true, "STEP_OVER", "OK"],
    [(_thresholds select 1) + 0.01, true, "VAULT", "OK"],
    [(_thresholds select 2) + 0.01, true, "MANTLE_LOW", "OK"],
    [(_thresholds select 3) + 0.01, true, "MANTLE_MEDIUM", "OK"],
    [(_thresholds select 4) + 0.01, true, "MANTLE_HIGH", "OK"],
    [(_thresholds select 5) + 0.01, false, "NONE", "OBSTACLE_TOO_HIGH"]
];

{
    _x params ["_height", "_expectedValid", "_expectedAction", "_expectedReason"];
    private _result = [_height] call bn_koth_fnc_traversal_classify;
    [
        (_result getOrDefault ["valid", !_expectedValid]) isEqualTo _expectedValid,
        format ["Classification valid mismatch at height %1", _height]
    ] call _assert;
    [
        (_result getOrDefault ["action", ""]) isEqualTo _expectedAction,
        format ["Classification action mismatch at height %1", _height]
    ] call _assert;
    [
        (_result getOrDefault ["reason", ""]) isEqualTo _expectedReason,
        format ["Classification reason mismatch at height %1", _height]
    ] call _assert;
} forEach _cases;

private _keybindCfg = missionConfigFile >> "CfgBnKothEscMenuKeybinds" >> "traversal";
[isClass _keybindCfg, "Traversal gamemode keybind config is missing"] call _assert;
[
    getNumber (_keybindCfg >> "defaultKey") > 0,
    "Traversal default key must be configured in the mission keybind file"
] call _assert;
[
    (getText (_keybindCfg >> "shift")) isEqualTo "true",
    "Traversal must default to Shift modifier"
] call _assert;
[
    (getText (_keybindCfg >> "function")) isEqualTo "bn_koth_fnc_traversal_request",
    "Traversal keybind does not target traversal_request"
] call _assert;

[
    isClass (configFile >> "CfgMovesMaleSdr" >> "States" >> "AovrPercMstpSnonWnonDf"),
    "Base-game traversal fallback animation is missing"
] call _assert;
[
    isClass (configFile >> "CfgMovesMaleSdr" >> "States" >> "vn_weapon_on_back_evaF"),
    "S.O.G. step-over animation is missing"
] call _assert;

private _animationUnit = if (hasInterface && {!isNull player}) then {player} else {objNull};
{
    private _startAnimation = [_animationUnit, _x, "ON_TOP", "START"] call bn_koth_fnc_traversal_selectAnimation;
    private _finishAnimation = [_animationUnit, _x, "ON_TOP", "FINISH"] call bn_koth_fnc_traversal_selectAnimation;
    [
        _startAnimation in ["LadderRifleUpLoop", "LadderCivilUpLoop"],
        format ["%1 must start with a ladder climb animation, got %2", _x, _startAnimation]
    ] call _assert;
    [
        _finishAnimation in ["LadderRifleTopOff", "LadderCivilTopOff"],
        format ["%1 must finish with a ladder top-off animation, got %2", _x, _finishAnimation]
    ] call _assert;
    [
        _startAnimation isNotEqualTo _finishAnimation,
        format ["%1 start and finish animations must be distinct", _x]
    ] call _assert;
} forEach ["MANTLE_LOW", "MANTLE_MEDIUM", "MANTLE_HIGH"];

{
    [
        ([_animationUnit, _x, "ON_TOP", "FINISH"] call bn_koth_fnc_traversal_selectAnimation) isEqualTo "",
        format ["%1 must not schedule a mantle top-off animation", _x]
    ] call _assert;
} forEach ["STEP_OVER", "VAULT"];

private _remoteCfg = missionConfigFile >> "CfgRemoteExec" >> "Functions";
[
    !(isClass (_remoteCfg >> "bn_koth_fnc_traversal_request")),
    "Client-local traversal request must not be remotely allowlisted"
] call _assert;

_failures

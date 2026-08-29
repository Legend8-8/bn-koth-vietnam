/*
    File: fn_finish.sqf
    Author: Legend
    Description: Finalizes successful traversal, applies stamina cost, and releases the lock.
    Execution: Owning client
    Parameters:
        0: Traversing unit <OBJECT>
        1: Active traversal result <HASHMAP>
    Returns:
        True <BOOL>
    Public: Yes
*/

params [
    ["_unit", objNull, [objNull]],
    ["_result", createHashMap, [createHashMap]]
];

if (isNull _unit) exitWith {
    [_unit, _result, "PLAYER_DELETED", false, []] call bn_koth_fnc_traversal_cancel
};
if (!local _unit) exitWith {
    [_unit, _result, "PLAYER_NOT_LOCAL", false, []] call bn_koth_fnc_traversal_cancel
};
if (!alive _unit) exitWith {
    [_unit, _result, "PLAYER_DEAD", false, []] call bn_koth_fnc_traversal_cancel
};

private _landing = _result getOrDefault ["landingPositionASL", getPosASL _unit];
_unit setVelocity [0, 0, 0];
_unit setPosASL _landing;

private _selectedAnimation = _result getOrDefault ["selectedAnimation", ""];
if ((_selectedAnimation != "") && {(animationState _unit) isEqualTo (toLower _selectedAnimation)}) then {
    isNil {_unit switchMove ""};
};
private _staminaCost = _result getOrDefault ["staminaCost", 0];
_unit setStamina (((getStamina _unit) - _staminaCost) max 0);
_unit setVariable ["BN_KOTH_traversalState", "IDLE"];

_result set ["valid", true];
_result set ["reason", "OK"];
_result set ["state", "COMPLETED"];
_result set ["timestamp", diag_tickTime];
missionNamespace setVariable ["BN_KOTH_traversalLastResult", _result];
missionNamespace setVariable ["BN_KOTH_traversalLastRequestTime", diag_tickTime];

["INFO", format ["Traversal completed: %1 %2", _result getOrDefault ["action", "NONE"], _result getOrDefault ["landingMode", "NONE"]]] call bn_koth_fnc_traversal_log;
true

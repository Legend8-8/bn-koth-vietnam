/*
    File: fn_cancel.sqf
    Author: Mongo
    Description: Recovers from interrupted traversal and releases the local movement lock.
    Execution: Owning client
    Parameters:
        0: Traversing unit, possibly null or deleted <OBJECT>
        1: Active traversal result <HASHMAP>
        2: Failure reason <STRING>
        3: Whether to restore the verified start position <BOOL>
        4: Verified start PositionASL <ARRAY>
    Returns:
        False <BOOL>
    Public: Yes
*/

params [
    ["_unit", objNull, [objNull]],
    ["_result", createHashMap, [createHashMap]],
    ["_reason", "TRAVERSAL_STATE_LOST", [""]],
    ["_rollback", false, [false]],
    ["_startPosition", [], [[]]]
];

if (!isNull _unit) then {
    private _safeToRollback = _rollback
        && {local _unit}
        && {alive _unit}
        && {isNull (objectParent _unit)}
        && {isNull (attachedTo _unit)}
        && {(count _startPosition) isEqualTo 3};

    if (_safeToRollback) then {
        private _current = getPosASL _unit;
        private _direction = vectorDir _unit;
        private _up = vectorUp _unit;
        _unit setVelocityTransformation [
            _current,
            _startPosition,
            [0, 0, 0],
            [0, 0, 0],
            _direction,
            _direction,
            _up,
            _up,
            1
        ];
    };

    if (local _unit) then {
        private _selectedAnimation = _result getOrDefault ["selectedAnimation", ""];
        if (
            alive _unit
            && {_selectedAnimation != ""}
            && {(animationState _unit) isEqualTo (toLower _selectedAnimation)}
        ) then {
            isNil {_unit switchMove ""};
        };
        _unit setVariable ["BN_KOTH_traversalState", "IDLE"];
    };
};

_result set ["valid", false];
_result set ["reason", _reason];
_result set ["state", "CANCELLED"];
_result set ["timestamp", diag_tickTime];
missionNamespace setVariable ["BN_KOTH_traversalLastResult", _result];
missionNamespace setVariable ["BN_KOTH_traversalLastRequestTime", diag_tickTime];

["WARN", format ["Traversal interrupted: %1", _reason]] call bn_koth_fnc_traversal_log;
false

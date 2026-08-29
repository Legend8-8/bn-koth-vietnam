/*
    File: fn_updatePriorityTask.sqf
    Author: Legend
    Description: Maintains one silent client-local Simple Task at the globally replicated Priority marker.
    Execution: Client
    Parameters: None
    Returns: Whether the Priority task should exist <BOOL>
    Public: No
*/

if (!hasInterface) exitWith {false};

private _task = uiNamespace getVariable ["BN_KOTH_priorityTask", taskNull];
private _taskOwner = uiNamespace getVariable ["BN_KOTH_priorityTaskOwner", objNull];
private _taskExists = !isNull _task;
private _activeAoMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _activeAoAvailable = !(_activeAoMarker isEqualTo "")
    && {!((markerShape _activeAoMarker) isEqualTo "")};
private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _shouldExist = uiNamespace getVariable ["BN_KOTH_hudVisible", false]
    && {!isNull player}
    && {alive player}
    && {(missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE"}
    && {_activeAoAvailable}
    && {!((markerShape _priorityMarker) isEqualTo "")};

if (_taskExists && {(isNull _taskOwner) || {!(_taskOwner isEqualTo player)}}) then {
    if (!isNull _taskOwner) then {
        _taskOwner removeSimpleTask _task;
    };
    _task = taskNull;
    _taskOwner = objNull;
    _taskExists = false;
    uiNamespace setVariable ["BN_KOTH_priorityTask", taskNull];
    uiNamespace setVariable ["BN_KOTH_priorityTaskOwner", objNull];
};

if (!_shouldExist) exitWith {
    if (_taskExists) then {
        _taskOwner removeSimpleTask _task;
    };
    uiNamespace setVariable ["BN_KOTH_priorityTask", taskNull];
    uiNamespace setVariable ["BN_KOTH_priorityTaskOwner", objNull];
    uiNamespace setVariable ["BN_KOTH_priorityTaskNextUpdateAt", 0];
    false
};

private _destination = markerPos _priorityMarker;
if (!_taskExists) then {
    _task = player createSimpleTask ["BN_KOTH_PRIORITY"];
    _task setSimpleTaskDescription [
        "Move to and contest the active Priority Zone.",
        "PRIORITY",
        "Priority Zone"
    ];
    _task setSimpleTaskType "move";
    _task setSimpleTaskAlwaysVisible true;
    _task setSimpleTaskDestination _destination;
    _task setTaskState "ASSIGNED";
    _taskOwner = player;
    uiNamespace setVariable ["BN_KOTH_priorityTask", _task];
    uiNamespace setVariable ["BN_KOTH_priorityTaskOwner", _taskOwner];
    uiNamespace setVariable ["BN_KOTH_priorityTaskNextUpdateAt", diag_tickTime + 0.5];
    true
} else {
    private _nextUpdateAt = uiNamespace getVariable ["BN_KOTH_priorityTaskNextUpdateAt", 0];
    if (diag_tickTime >= _nextUpdateAt) then {
        if ((taskDestination _task) distance2D _destination > 0.25) then {
            _task setSimpleTaskDestination _destination;
        };
        uiNamespace setVariable ["BN_KOTH_priorityTaskNextUpdateAt", diag_tickTime + 0.5];
    };
    true
}

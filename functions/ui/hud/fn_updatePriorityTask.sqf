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

if !(uiNamespace getVariable ["BN_KOTH_priorityTaskEhAdded", false]) then {
    private _taskEh = addMissionEventHandler ["EachFrame", {
        if !(hasInterface) exitWith {};
        if !(uiNamespace getVariable ["BN_KOTH_hudVisible", false]) exitWith {};
        if (isNull player || {!alive player}) exitWith {};
        if !((missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE") exitWith {};

        private _activeAoMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
        if (_activeAoMarker isEqualTo "" || {(markerShape _activeAoMarker) isEqualTo ""}) exitWith {};

        private _priorityMarker = "BN_KOTH_priorityZoneMarker";
        if ((markerShape _priorityMarker) isEqualTo "") exitWith {};

        [] call bn_koth_fnc_ui_updatePriorityTask;
    }];

    uiNamespace setVariable ["BN_KOTH_priorityTaskEhAdded", true];
    uiNamespace setVariable ["BN_KOTH_priorityTaskEhId", _taskEh];
};

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
    _task setTaskState "ASSIGNED";
    _taskOwner = player;
    uiNamespace setVariable ["BN_KOTH_priorityTask", _task];
    uiNamespace setVariable ["BN_KOTH_priorityTaskOwner", _taskOwner];
};

if (!isNull _task) then {
    _task setSimpleTaskDestination _destination;
};

true

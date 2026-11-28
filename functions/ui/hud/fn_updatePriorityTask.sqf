/*
    File: fn_updatePriorityTask.sqf
    Author: Legend
    Description: Maintains the client-local Priority task, Tower floor destination, and notifications.
    Execution: Client
    Parameters: None
    Returns: Whether the Priority task should exist <BOOL>
    Public: No
*/

if (!hasInterface) exitWith {false};

if (isNil {missionNamespace getVariable "BN_KOTH_priorityTaskEhId"}) then {
    private _taskEh = addMissionEventHandler ["EachFrame", {
        if !(hasInterface) exitWith {};
        if !(uiNamespace getVariable ["BN_KOTH_hudVisible", false]) exitWith {};
        if (isNull player || {!alive player}) exitWith {};
        if ([player] call bn_koth_fnc_respawn_isIncapacitated) exitWith {};
        if !((missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE") exitWith {};

        private _activeAoMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
        if (_activeAoMarker isEqualTo "" || {(markerShape _activeAoMarker) isEqualTo ""}) exitWith {};

        private _priorityMarker = "BN_KOTH_priorityZoneMarker";
        if ((markerShape _priorityMarker) isEqualTo "") exitWith {};

        [] call bn_koth_fnc_ui_updatePriorityTask;
    }];

    missionNamespace setVariable ["BN_KOTH_priorityTaskEhId", _taskEh];
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
    && {!([player] call bn_koth_fnc_respawn_isIncapacitated)}
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
    uiNamespace setVariable ["BN_KOTH_priorityTaskLastTitle", ""];
    uiNamespace setVariable ["BN_KOTH_verticalPriorityTaskDiagnostic", ""];
};

if (!_shouldExist) exitWith {
    if (_taskExists) then {
        _taskOwner removeSimpleTask _task;
    };
    uiNamespace setVariable ["BN_KOTH_priorityTask", taskNull];
    uiNamespace setVariable ["BN_KOTH_priorityTaskOwner", objNull];
    uiNamespace setVariable ["BN_KOTH_priorityTaskNextUpdateAt", 0];
    uiNamespace setVariable ["BN_KOTH_priorityTaskLastTitle", ""];
    uiNamespace setVariable ["BN_KOTH_verticalPriorityLastNotice", ""];
    uiNamespace setVariable ["BN_KOTH_verticalPriorityTaskDiagnostic", ""];
    false
};

private _destination = markerPos _priorityMarker;
private _verticalGeometry = missionNamespace getVariable ["BN_KOTH_verticalPriorityGeometry", createHashMap];
private _verticalState = missionNamespace getVariable ["BN_KOTH_verticalPriorityState", createHashMap];
private _towerTitle = "";
if ((count _verticalGeometry) > 0 && {(count _verticalState) > 0}) then {
    private _floors = _verticalGeometry getOrDefault ["floors", []];
    private _floorIndex = if ((_verticalState getOrDefault ["phase", ""]) isEqualTo "MOVING") then {
        _verticalState getOrDefault ["destinationIndex", -1]
    } else {
        _verticalState getOrDefault ["activeIndex", -1]
    };
    private _sourceIndex = _verticalState getOrDefault ["sourceIndex", -1];
    if (_floorIndex >= 0 && {_floorIndex < count _floors} && {_sourceIndex >= 0} && {_sourceIndex < count _floors}) then {
        private _floor = _floors select _floorIndex;
        private _moving = (_verticalState getOrDefault ["phase", ""]) isEqualTo "MOVING";
        private _noticeKey = format ["%1:%2:%3:%4", _verticalState getOrDefault ["phase", ""], _verticalState getOrDefault ["sourceIndex", -1], _floorIndex, _verticalState getOrDefault ["startAt", -1]];
        if (_noticeKey isNotEqualTo (uiNamespace getVariable ["BN_KOTH_verticalPriorityLastNotice", ""])) then {
            private _floorName = _floor select 0;
            private _body = if (_floorName isEqualTo "GROUND") then {"GROUND FLOOR"} else {
                if (_floorName isEqualTo "ROOF") then {"ROOF"} else {format ["FLOOR %1", _floorName]}
            };
            private _title = if (_moving) then {
                format ["PRIORITY MOVING %1", if ((_verticalState getOrDefault ["direction", 1]) > 0) then {"UP"} else {"DOWN"}]
            } else {"PRIORITY"};
            [createHashMapFromArray [["title", _title], ["body", _body], ["duration", 3.5]]] call bn_koth_fnc_ui_notify;
            uiNamespace setVariable ["BN_KOTH_verticalPriorityLastNotice", _noticeKey];
        };
        private _sourceFloor = _floors select _sourceIndex;
        private _fraction = if (_moving) then {
            (((serverTime - (_verticalState getOrDefault ["startAt", serverTime])) / (((_verticalState getOrDefault ["endAt", serverTime]) - (_verticalState getOrDefault ["startAt", serverTime])) max 0.1)) max 0) min 1
        } else {1};
        private _low = (_sourceFloor select 2) + ((_floor select 2) - (_sourceFloor select 2)) * _fraction;
        private _high = (_sourceFloor select 3) + ((_floor select 3) - (_sourceFloor select 3)) * _fraction;
        private _surface = (_sourceFloor select 1) + ((_floor select 1) - (_sourceFloor select 1)) * _fraction;
        private _presentationZ = ((_surface + 0.3) max (_low + 0.15)) min (_high - 0.3);
        private _footprintCenter = markerPos (_verticalGeometry get "marker");
        _destination = ASLToAGL [_footprintCenter select 0, _footprintCenter select 1, _presentationZ];
        _towerTitle = if (_moving) then {
            format ["PRIORITY MOVING %1 — FLOOR %2", if ((_verticalState getOrDefault ["direction", 1]) > 0) then {"UP"} else {"DOWN"}, _floor select 0]
        } else {
            format ["PRIORITY — FLOOR %1", _floor select 0]
        };
    };
} else {
    uiNamespace setVariable ["BN_KOTH_verticalPriorityLastNotice", ""];
};
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
    private _enteringTower = _towerTitle isNotEqualTo "" && {(uiNamespace getVariable ["BN_KOTH_priorityTaskLastTitle", ""]) isEqualTo ""};
    if !(_towerTitle isEqualTo (uiNamespace getVariable ["BN_KOTH_priorityTaskLastTitle", ""])) then {
        _task setSimpleTaskDescription [
            if (_towerTitle isEqualTo "") then {"Move to and contest the active Priority Zone."} else {"Move to and contest the indicated tower floor."},
            if (_towerTitle isEqualTo "") then {"PRIORITY"} else {_towerTitle},
            "Priority Zone"
        ];
        uiNamespace setVariable ["BN_KOTH_priorityTaskLastTitle", _towerTitle];
    };
    _task setSimpleTaskDestination _destination;
    if (_towerTitle isNotEqualTo "") then {
        if (_enteringTower) then {
            player setCurrentTask _task;
        };

        private _movingMidpoint = (_verticalState getOrDefault ["phase", ""]) isEqualTo "MOVING"
            && {serverTime >= ((_verticalState getOrDefault ["startAt", serverTime]) + (_verticalState getOrDefault ["endAt", serverTime])) / 2};
        private _diagnosticKey = format ["%1:%2:%3:%4:%5", _verticalState getOrDefault ["phase", ""], _verticalState getOrDefault ["sourceIndex", -1], _verticalState getOrDefault ["destinationIndex", -1], _verticalState getOrDefault ["startAt", -1], _movingMidpoint];
        if (_diagnosticKey isNotEqualTo (uiNamespace getVariable ["BN_KOTH_verticalPriorityTaskDiagnostic", ""])) then {
            diag_log format ["[BN_KOTH][PriorityTask] exists=%1 state=%2 current=%3 alwaysVisible=%4 destinationAGL=%5 applied=%6 phase=%7 source=%8 destination=%9", !isNull _task, taskState _task, (currentTask player) isEqualTo _task, taskAlwaysVisible _task, _destination, taskDestination _task, _verticalState getOrDefault ["phase", ""], _verticalState getOrDefault ["sourceIndex", -1], _verticalState getOrDefault ["destinationIndex", -1]];
            uiNamespace setVariable ["BN_KOTH_verticalPriorityTaskDiagnostic", _diagnosticKey];
        };
    } else {
        uiNamespace setVariable ["BN_KOTH_verticalPriorityTaskDiagnostic", ""];
    };
};

true

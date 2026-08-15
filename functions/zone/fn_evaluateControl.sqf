/*
    File: fn_evaluateControl.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Computes raw, weighted, and Priority population plus controlling side in one pass.
    Execution: Server
    Parameters:
        0: Skip scoring update after publishing zone state <BOOL> (optional)
    Returns:
        Controlling side or sideUnknown <SIDE>
    Public: Yes
*/

params [["_skipScoringUpdate", false, [false]]];

if (!isServer) exitWith {sideUnknown};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "ACTIVE") exitWith {
    ["BN_KOTH_zoneController", sideUnknown] call bn_koth_fnc_common_publicState;
    ["BN_KOTH_zoneState", "NEUTRAL"] call bn_koth_fnc_common_publicState;
    ["BN_KOTH_zonePopulation", createHashMapFromArray [
        ["raw", [0, 0]],
        ["weighted", [0, 0]],
        ["priority", [0, 0]]
    ]] call bn_koth_fnc_common_publicState;
    if (!_skipScoringUpdate) then {
        [] call bn_koth_fnc_scoring_awardControlTick;
    };
    sideUnknown
};

private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (_marker isEqualTo "") exitWith {
    if !(missionNamespace getVariable ["BN_KOTH_warnedMissingZoneMarker", false]) then {
        missionNamespace setVariable ["BN_KOTH_warnedMissingZoneMarker", true];
        ["Zone evaluation skipped: BN_KOTH_activeZoneMarker is empty.", "WARN"] call bn_koth_fnc_common_log;
    };
    if (!_skipScoringUpdate) then {
        [] call bn_koth_fnc_scoring_awardControlTick;
    };
    sideUnknown
};

missionNamespace setVariable ["BN_KOTH_warnedMissingZoneMarker", false];

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _sideA = _playableSides select 0;
private _sideB = _playableSides select 1;

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _activeLookup = createHashMap;
{
    _activeLookup set [_x, true];
} forEach _activeParticipants;

private _priorityZoneMarker = "BN_KOTH_priorityZoneMarker";
private _priorityZoneActive = missionNamespace getVariable ["BN_KOTH_priorityZoneActive", false];
private _priorityZoneControlWeight = missionNamespace getVariable ["BN_KOTH_priorityZoneControlWeight", 2];
private _priorityZoneAvailable = _priorityZoneActive && {!((markerShape _priorityZoneMarker) isEqualTo "")};
private _players = allPlayers select {
    private _uid = getPlayerUID _x;
    private _record = if (_records isEqualType createHashMap) then {
        _records getOrDefault [_uid, createHashMap]
    } else {
        createHashMap
    };
    private _recordState = if (_record isEqualType createHashMap) then {
        _record getOrDefault ["state", "LOBBY"]
    } else {
        "LOBBY"
    };
    private _recordDeployed = if (_record isEqualType createHashMap) then {
        _record getOrDefault ["deployed", false]
    } else {
        false
    };
    private _recordAssignedSide = if (_record isEqualType createHashMap) then {
        _record getOrDefault ["assignedSide", sideUnknown]
    } else {
        sideUnknown
    };
    private _recordUnit = if (_record isEqualType createHashMap) then {
        _record getOrDefault ["currentUnit", objNull]
    } else {
        objNull
    };

    alive _x
    && {!(_x getVariable ["BIS_revive_incapacitated", false])}
    && {[(side group _x)] call bn_koth_fnc_teams_validateSide}
    && {_activeLookup getOrDefault [getPlayerUID _x, false]}
    && {_record isEqualType createHashMap}
    && {_recordState isEqualTo "ACTIVE"}
    && {_recordDeployed}
    && {_recordAssignedSide in _playableSides}
    && {!isNull _recordUnit}
    && {_recordUnit isEqualTo _x}
    && {_x inArea _marker}
};

private _sideARawCount = 0;
private _sideBRawCount = 0;
private _sideAWeightedCount = 0;
private _sideBWeightedCount = 0;
private _sideAPriorityCount = 0;
private _sideBPriorityCount = 0;
private _priorityWestCount = 0;
private _priorityEastCount = 0;

{
    private _player = _x;
    private _side = side group _player;
    private _inPriority = if (_priorityZoneAvailable) then {
        _player inArea _priorityZoneMarker
    } else {
        false
    };
    private _controlWeight = if (_inPriority) then {_priorityZoneControlWeight} else {1};

    if (_side isEqualTo _sideA) then {
        _sideARawCount = _sideARawCount + 1;
        _sideAWeightedCount = _sideAWeightedCount + _controlWeight;
        if (_inPriority) then {
            _sideAPriorityCount = _sideAPriorityCount + 1;
        };
    } else {
        if (_side isEqualTo _sideB) then {
            _sideBRawCount = _sideBRawCount + 1;
            _sideBWeightedCount = _sideBWeightedCount + _controlWeight;
            if (_inPriority) then {
                _sideBPriorityCount = _sideBPriorityCount + 1;
            };
        };
    };

    if (_inPriority) then {
        if (_side isEqualTo west) then {
            _priorityWestCount = _priorityWestCount + 1;
        } else {
            if (_side isEqualTo east) then {
                _priorityEastCount = _priorityEastCount + 1;
            };
        };
    };
} forEach _players;

if (_priorityZoneAvailable) then {
    private _targetColor = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerColor", "ColorGreen"];
    private _targetBrush = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerBrush", "Solid"];

    if (_priorityWestCount > _priorityEastCount) then {
        _targetColor = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerWestColor", "ColorBlue"];
    } else {
        if (_priorityEastCount > _priorityWestCount) then {
            _targetColor = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerEastColor", "ColorRed"];
        } else {
            if ((_priorityWestCount > 0) && {_priorityEastCount > 0}) then {
                _targetColor = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerTieColor", "ColorCIV"];
                _targetBrush = missionNamespace getVariable ["BN_KOTH_priorityZoneMarkerTieBrush", "FDiagonal"];
            };
        };
    };

    private _colorChanged = !((markerColor _priorityZoneMarker) isEqualTo _targetColor);
    private _brushChanged = !((markerBrush _priorityZoneMarker) isEqualTo _targetBrush);

    if (_colorChanged && {_brushChanged}) then {
        _priorityZoneMarker setMarkerColorLocal _targetColor;
        _priorityZoneMarker setMarkerBrush _targetBrush;
    } else {
        if (_colorChanged) then {
            _priorityZoneMarker setMarkerColor _targetColor;
        } else {
            if (_brushChanged) then {
                _priorityZoneMarker setMarkerBrush _targetBrush;
            };
        };
    };
};

private _controller = sideUnknown;
private _zoneState = "NEUTRAL";

if ((_sideAWeightedCount > 0) || (_sideBWeightedCount > 0)) then {
    if (_sideAWeightedCount == _sideBWeightedCount) then {
        _zoneState = "CONTESTED";
    } else {
        if (_sideAWeightedCount > _sideBWeightedCount) then {
            _controller = _sideA;
        } else {
            _controller = _sideB;
        };
        _zoneState = "CONTROLLED";
    };
};

private _previousController = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
private _previousState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];

if (!(_previousController isEqualTo _controller)) then {
    [format ["Zone controller changed to %1", _controller]] call bn_koth_fnc_common_log;
};

if !(_previousState isEqualTo _zoneState) then {
    [format ["Zone state changed to %1", _zoneState]] call bn_koth_fnc_common_log;
};

["BN_KOTH_zoneController", _controller] call bn_koth_fnc_common_publicState;
["BN_KOTH_zoneState", _zoneState] call bn_koth_fnc_common_publicState;
["BN_KOTH_zonePopulation", createHashMapFromArray [
    ["raw", [_sideARawCount, _sideBRawCount]],
    ["weighted", [_sideAWeightedCount, _sideBWeightedCount]],
    ["priority", [_sideAPriorityCount, _sideBPriorityCount]]
]] call bn_koth_fnc_common_publicState;

if (!_skipScoringUpdate) then {
    [] call bn_koth_fnc_scoring_awardControlTick;
};

_controller

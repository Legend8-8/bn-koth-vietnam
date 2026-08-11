/*
    File: fn_updatePriorityZone.sqf
    Author: Legend
    Description: Updates a moving priority-zone marker inside the active AO.
    Execution: Server
    Parameters:
        None
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

private _activeMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _priorityRatio = missionNamespace getVariable ["BN_KOTH_priorityZoneRatio", 0.1];

if (_activeMarker isEqualTo "") exitWith {
    if ((markerShape _priorityMarker) isEqualTo "") then {
        createMarker [_priorityMarker, [0, 0, 0]];
    };
    _priorityMarker setMarkerAlpha 0;
    ["BN_KOTH_priorityZoneActive", false] call bn_koth_fnc_common_publicState;
    ["BN_KOTH_priorityZonePosition", [0, 0, 0]] call bn_koth_fnc_common_publicState;
    ["BN_KOTH_priorityZoneSize", [0, 0]] call bn_koth_fnc_common_publicState;
    false
};

if ((markerShape _priorityMarker) isEqualTo "") then {
    createMarker [_priorityMarker, markerPos _activeMarker];
    _priorityMarker setMarkerShape "RECTANGLE";
    _priorityMarker setMarkerBrush "FDiagonal";
    _priorityMarker setMarkerColor "ColorOrange";
    _priorityMarker setMarkerAlpha 0.55;
    _priorityMarker setMarkerText "Priority Zone";
};

private _fnc_pointInMarkerArea = {
    params ["_point", "_marker"];

    if (_marker isEqualTo "") exitWith {false};
    if ((markerShape _marker) isEqualTo "") exitWith {false};

    private _center = markerPos _marker;
    private _size = markerSize _marker;
    private _dir = markerDir _marker;
    private _dx = (_point select 0) - (_center select 0);
    private _dy = (_point select 1) - (_center select 1);

    if !(_dir isEqualTo 0) then {
        private _rad = _dir * (pi / 180);
        private _cos = cos _rad;
        private _sin = sin _rad;
        private _rotX = (_dx * _cos) + (_dy * _sin);
        private _rotY = (_dy * _cos) - (_dx * _sin);
        _dx = _rotX;
        _dy = _rotY;
    };

    switch (markerShape _marker) do {
        case "ELLIPSE": {
            (((_dx ^ 2) / ((_size select 0) ^ 2)) + ((_dy ^ 2) / ((_size select 1) ^ 2))) <= 1
        };
        case "RECTANGLE": {
            (abs _dx <= (_size select 0)) && {abs _dy <= (_size select 1)}
        };
        default {false};
    };
};

private _aoSize = markerSize _activeMarker;
private _aoWidth = if ((count _aoSize) > 0) then {_aoSize select 0} else {40};
private _aoHeight = if ((count _aoSize) > 1) then {_aoSize select 1} else {30};
private _priorityWidth = (_aoWidth * _priorityRatio) max 6;
private _priorityHeight = (_aoHeight * _priorityRatio) max 6;
private _moveStep = (((_aoWidth max _aoHeight) * 0.02) max 1) min 4;
private _currentPos = missionNamespace getVariable ["BN_KOTH_priorityZonePosition", markerPos _activeMarker];
private _heading = missionNamespace getVariable ["BN_KOTH_priorityZoneHeading", random 360];
private _candidatePos = [
    (_currentPos select 0) + ((sin _heading) * _moveStep),
    (_currentPos select 1) + ((cos _heading) * _moveStep),
    0
];

private _attempts = 0;
while {(_attempts < 8) && {!([_candidatePos, _activeMarker] call _fnc_pointInMarkerArea)}} do {
    _heading = _heading + 90 + random 45;
    _candidatePos = [
        (_currentPos select 0) + ((sin _heading) * _moveStep),
        (_currentPos select 1) + ((cos _heading) * _moveStep),
        0
    ];
    _attempts = _attempts + 1;
};

if !([_candidatePos, _activeMarker] call _fnc_pointInMarkerArea) then {
    _candidatePos = markerPos _activeMarker;
    _heading = random 360;
};

_currentPos = _candidatePos;
missionNamespace setVariable ["BN_KOTH_priorityZonePosition", _currentPos];
missionNamespace setVariable ["BN_KOTH_priorityZoneHeading", _heading];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarker", _priorityMarker];
missionNamespace setVariable ["BN_KOTH_priorityZoneSize", [_priorityWidth, _priorityHeight]];

_priorityMarker setMarkerPos _currentPos;
_priorityMarker setMarkerSize [_priorityWidth, _priorityHeight];
_priorityMarker setMarkerDir (markerDir _activeMarker);
_priorityMarker setMarkerAlpha 0.55;
_priorityMarker setMarkerText "Priority Zone";

["BN_KOTH_priorityZoneActive", true] call bn_koth_fnc_common_publicState;
["BN_KOTH_priorityZonePosition", _currentPos] call bn_koth_fnc_common_publicState;
["BN_KOTH_priorityZoneMarker", _priorityMarker] call bn_koth_fnc_common_publicState;
["BN_KOTH_priorityZoneSize", [_priorityWidth, _priorityHeight]] call bn_koth_fnc_common_publicState;

true
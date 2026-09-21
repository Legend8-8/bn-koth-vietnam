/*
    File: fn_setServicePresentation.sqf
    Author: Legend
    Description: Creates or clears the requesting client's local Draw3D
        air-service gate. It owns presentation only.
    Execution: Client
    Parameters: action, session ID, gate ASL position, radius, price, heading,
        SERVICE | RETURN purpose, human vehicle display name
    Returns: None
    Public: Yes
*/

params [
    ["_action", "CLEAR", [""]],
    ["_sessionId", "", [""]],
    ["_positionAsl", [], [[]]],
    ["_radius", 0, [0]],
    ["_price", 0, [0]],
    ["_heading", 0, [0]],
    ["_purpose", "SERVICE", [""]],
    ["_displayName", "", [""]]
];
if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

private _old = missionNamespace getVariable ["BN_KOTH_vehicleServicePresentation", createHashMap];
private _oldMarker = _old getOrDefault ["marker", ""];
if !(_oldMarker isEqualTo "") then {deleteMarkerLocal _oldMarker};
missionNamespace setVariable ["BN_KOTH_vehicleServicePresentation", createHashMap];

if ((toUpper _action) isEqualTo "CLEAR") exitWith {};
if (_sessionId isEqualTo "" || {(count _positionAsl) isNotEqualTo 3} || {_radius <= 0}) exitWith {};

missionNamespace setVariable ["BN_KOTH_vehicleServicePresentation", createHashMapFromArray [
    ["sessionId", _sessionId],
    ["positionASL", +_positionAsl],
    ["radius", _radius],
    ["price", _price],
    ["heading", _heading],
    ["purpose", toUpper _purpose],
    ["displayName", _displayName],
    ["marker", ""]
]];

if (isNil {missionNamespace getVariable "BN_KOTH_vehicleServiceDraw3dEh"}) then {
    private _eh = addMissionEventHandler ["Draw3D", {
        private _presentation = missionNamespace getVariable ["BN_KOTH_vehicleServicePresentation", createHashMap];
        if !(_presentation isEqualType createHashMap && {(count _presentation) > 0}) exitWith {};
        private _centreAsl = _presentation getOrDefault ["positionASL", []];
        private _radius = _presentation getOrDefault ["radius", 0];
        if ((count _centreAsl) isNotEqualTo 3 || {_radius <= 0}) exitWith {};
        private _heading = _presentation getOrDefault ["heading", 0];
        private _right = [cos _heading, -(sin _heading), 0];
        private _purpose = _presentation getOrDefault ["purpose", "SERVICE"];
        {
            _x params ["_scale", "_colour", "_width"];
            private _ringRadius = _radius * _scale;
            private _previous = [];
            for "_angle" from 0 to 360 step 10 do {
                private _pointAsl = _centreAsl vectorAdd ((_right vectorMultiply (cos _angle * _ringRadius)) vectorAdd [0, 0, sin _angle * _ringRadius]);
                private _pointAgl = ASLToAGL _pointAsl;
                if ((count _previous) isEqualTo 3) then {
                    drawLine3D [_previous, _pointAgl, [0.02, 0.02, 0.015, 0.95], _width + 14];
                    drawLine3D [_previous, _pointAgl, _colour, _width];
                };
                _previous = _pointAgl;
            };
        } forEach [
            [0.84, [1, 0.32, 0.02, 1], 18],
            [1, [1, 0.92, 0.08, 1], 26],
            [1.16, [1, 0.32, 0.02, 1], 18]
        ];
        for "_angle" from 0 to 330 step 30 do {
            private _iconAsl = _centreAsl vectorAdd ((_right vectorMultiply (cos _angle * _radius)) vectorAdd [0, 0, sin _angle * _radius]);
            drawIcon3D ["\a3\ui_f\data\map\markers\military\triangle_ca.paa", [1, 0.78, 0.02, 1], ASLToAGL _iconAsl, 1.7, 1.7, _angle + 90, "", 2, 0.04, "PuristaSemiBold", "center"];
        };
        private _label = if (_purpose isEqualTo "RETURN") then {"RETURN VEHICLE"} else {"REPAIR & REARM"};
        drawIcon3D ["", [1, 0.92, 0.08, 1], ASLToAGL (_centreAsl vectorAdd [0, 0, _radius + 35]), 0, 0, 0, _label, 2, 0.075, "PuristaSemiBold", "center"];
    }];
    missionNamespace setVariable ["BN_KOTH_vehicleServiceDraw3dEh", _eh];
};

/*
    File: fn_setPersonalGuidance.sqf
    Author: Legend
    Description: Owns temporary client-local spawn and service guidance for
        the local player's active personal helicopter.
    Execution: Owning client
    Parameters:
        0: SET | CLEAR_SPAWN | CLEAR <STRING>
        1: Personal vehicle <OBJECT>
        2: Actual spawn ATL position <ARRAY>
        3: Friendly service ATL position <ARRAY>
        4: Service price <NUMBER>
        5: Service area radius <NUMBER>
    Returns: None
    Public: No
*/

params [
    ["_action", "CLEAR", [""]],
    ["_vehicle", objNull, [objNull]],
    ["_spawnPosition", [], [[]]],
    ["_servicePosition", [], [[]]],
    ["_servicePrice", -1, [0]],
    ["_serviceRadius", 0, [0]]
];
if (!hasInterface) exitWith {};
_action = toUpper _action;

private _state = missionNamespace getVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
if !(_state isEqualType createHashMap) then {_state = createHashMap};
private _deleteMarker = {
    params ["_key"];
    private _marker = _state getOrDefault [_key, ""];
    if !(_marker isEqualTo "") then {deleteMarkerLocal _marker};
    _state set [_key, ""];
};

if (_action isEqualTo "CLEAR") exitWith {
    ["spawnMarker"] call _deleteMarker;
    ["serviceMarker"] call _deleteMarker;
    missionNamespace setVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
};

if (_action isEqualTo "CLEAR_SPAWN") exitWith {
    if (!isNull _vehicle && {!((_state getOrDefault ["vehicle", objNull]) isEqualTo _vehicle)}) exitWith {};
    ["spawnMarker"] call _deleteMarker;
    private _serviceMarker = _state getOrDefault ["serviceMarker", ""];
    private _servicePos = _state getOrDefault ["servicePosition", []];
    private _serviceRadius = _state getOrDefault ["serviceRadius", 0];
    if (_serviceMarker isEqualTo "" && {(count _servicePos) >= 2} && {_serviceRadius > 0}) then {
        _serviceMarker = format ["BN_KOTH_personalHeloService_%1", floor diag_tickTime];
        createMarkerLocal [_serviceMarker, _servicePos];
        _serviceMarker setMarkerShapeLocal "ELLIPSE";
        _serviceMarker setMarkerBrushLocal "Border";
        _serviceMarker setMarkerColorLocal "ColorYellow";
        _serviceMarker setMarkerAlphaLocal 0.85;
        _serviceMarker setMarkerSizeLocal [_serviceRadius, _serviceRadius];
        _state set ["serviceMarker", _serviceMarker];
    };
    missionNamespace setVariable ["BN_KOTH_personalVehicleGuidance", _state];
};

if !(_action isEqualTo "SET" && {!isNull _vehicle} && {(count _spawnPosition) >= 2}) exitWith {};
["CLEAR"] call bn_koth_fnc_vehicles_setPersonalGuidance;

private _safeId = ((netId _vehicle) splitString ":.- " joinString "_");
private _spawnMarker = format ["BN_KOTH_personalHelo_%1", _safeId];
createMarkerLocal [_spawnMarker, _spawnPosition];
_spawnMarker setMarkerShapeLocal "ICON";
_spawnMarker setMarkerTypeLocal "mil_triangle";
_spawnMarker setMarkerColorLocal "ColorYellow";
_spawnMarker setMarkerTextLocal "YOUR HELICOPTER";

_state = createHashMapFromArray [
    ["vehicle", _vehicle],
    ["spawnPosition", +_spawnPosition],
    ["servicePosition", +_servicePosition],
    ["servicePrice", _servicePrice],
    ["serviceRadius", _serviceRadius],
    ["spawnMarker", _spawnMarker],
    ["serviceMarker", ""]
];
missionNamespace setVariable ["BN_KOTH_personalVehicleGuidance", _state];

_vehicle addEventHandler ["GetIn", {
    params ["_vehicle", "_role", "_unit"];
    if (_unit isEqualTo player) then {["CLEAR_SPAWN", _vehicle] call bn_koth_fnc_vehicles_setPersonalGuidance};
}];
_vehicle addEventHandler ["Killed", {
    params ["_vehicle"];
    private _state = missionNamespace getVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
    if ((_state getOrDefault ["vehicle", objNull]) isEqualTo _vehicle) then {["CLEAR"] call bn_koth_fnc_vehicles_setPersonalGuidance};
}];
_vehicle addEventHandler ["Deleted", {
    params ["_vehicle"];
    private _state = missionNamespace getVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
    if ((_state getOrDefault ["vehicle", objNull]) isEqualTo _vehicle) then {["CLEAR"] call bn_koth_fnc_vehicles_setPersonalGuidance};
}];

if (isNil {missionNamespace getVariable "BN_KOTH_personalVehicleGuidanceDraw3dEh"}) then {
    private _eh = addMissionEventHandler ["Draw3D", {
        private _state = missionNamespace getVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
        if !(_state isEqualType createHashMap && {(count _state) > 0}) exitWith {};
        private _vehicle = _state getOrDefault ["vehicle", objNull];
        if (isNull _vehicle || {!alive _vehicle}) exitWith {};
        private _spawnMarker = _state getOrDefault ["spawnMarker", ""];
        if !(_spawnMarker isEqualTo "") then {
            private _position = (getPosATL _vehicle) vectorAdd [0, 0, 4];
            if ((player distance2D _vehicle) <= 2000) then {
                drawIcon3D ["", [1, 0.75, 0.05, 0.95], _position, 0, 0, 0, "YOUR HELICOPTER", 2, 0.04, "RobotoCondensed", "center"];
            };
        } else {
            private _servicePosition = _state getOrDefault ["servicePosition", []];
            if ((count _servicePosition) >= 2 && {player getVariable ["BN_KOTH_safeZoneProtected", false]}) then {
                drawIcon3D ["", [1, 0.75, 0.05, 0.95], _servicePosition vectorAdd [0, 0, 4], 0, 0, 0, format ["HELICOPTER SERVICE AREA - $%1", _state getOrDefault ["servicePrice", -1]], 2, 0.04, "RobotoCondensed", "center"];
            };
        };
    }];
    missionNamespace setVariable ["BN_KOTH_personalVehicleGuidanceDraw3dEh", _eh];
};

[_vehicle] spawn {
    params ["_vehicle"];
    uiSleep 300;
    private _state = missionNamespace getVariable ["BN_KOTH_personalVehicleGuidance", createHashMap];
    if ((_state getOrDefault ["vehicle", objNull]) isEqualTo _vehicle) then {
        ["CLEAR_SPAWN", _vehicle] call bn_koth_fnc_vehicles_setPersonalGuidance;
    };
};

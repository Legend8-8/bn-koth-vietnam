/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Description: Initializes the client-local map marker subsystem.
    Execution: Client
    Parameters:
        0: Expected representation unit <OBJECT>
    Returns:
        True when the subsystem is initialized, otherwise false <BOOL>
    Public: Yes
*/

params [["_targetUnit", objNull, [objNull]]];

if (!hasInterface) exitWith {false};

if (!isNull _targetUnit && {!(_targetUnit isEqualTo player)}) then {
    private _deadline = time + 5;
    waitUntil {
        (player isEqualTo _targetUnit) || {time >= _deadline}
    };
};

if (isNull player) exitWith {false};

private _playerMapMarkersCfg = missionConfigFile >> "CfgBnKothPlayerMapMarkers";
private _refreshInterval = getNumber (_playerMapMarkersCfg >> "refreshIntervalSeconds");
if (_refreshInterval < 0.1) then {
    _refreshInterval = 0.5;
};
private _closedRefreshInterval = getNumber (_playerMapMarkersCfg >> "closedRefreshIntervalSeconds");
if (_closedRefreshInterval < 0.1) then {_closedRefreshInterval = 2;};
private _displayId = getNumber (_playerMapMarkersCfg >> "mapDisplayId");
if (_displayId <= 0) then {_displayId = 12;};

private _existingMarkers = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMarkers", createHashMap];
if (_existingMarkers isEqualType createHashMap) then {
    {
        deleteMarkerLocal _x;
    } forEach (values _existingMarkers);
};

missionNamespace setVariable ["BN_KOTH_playerMapMarkersEnabled", (getNumber (_playerMapMarkersCfg >> "enabled")) > 0];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersRefreshInterval", _refreshInterval];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersClosedRefreshInterval", _closedRefreshInterval];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersType", getText (_playerMapMarkersCfg >> "markerType")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersColor", getText (_playerMapMarkersCfg >> "markerColor")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersShadow", ((getNumber (_playerMapMarkersCfg >> "markerShadow")) > 0)];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersGroupColor", getText (_playerMapMarkersCfg >> "groupMarkerColor")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicType", getText (_playerMapMarkersCfg >> "micMarkerType")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicTexture", getText (_playerMapMarkersCfg >> "micTexture")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicColorArray", getArray (_playerMapMarkersCfg >> "micColor")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicSize", getNumber (_playerMapMarkersCfg >> "micSize")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMicNameSize", getNumber (_playerMapMarkersCfg >> "micNameSize")];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersAlpha", (getNumber (_playerMapMarkersCfg >> "iconAlpha")) max 0 min 1];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersShowPassengerCount", (getNumber (_playerMapMarkersCfg >> "showPassengerCount")) > 0];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersShowDriverName", (getNumber (_playerMapMarkersCfg >> "showDriverName")) > 0];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersMarkers", createHashMap];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersDisplayId", _displayId];

if !(missionNamespace getVariable ["BN_KOTH_playerMapMarkersLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_playerMapMarkers_refresh;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_playerMapMarkersLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_playerMapMarkersLocalMissionEhId", _eventId];
};

private _refreshLoop = missionNamespace getVariable ["BN_KOTH_playerMapMarkersLoopHandle", scriptNull];
if (_refreshLoop isEqualTo scriptNull || {scriptDone _refreshLoop}) then {
    private _loopHandle = [] spawn {
        while {hasInterface} do {
            try {
                [] call bn_koth_fnc_playerMapMarkers_refresh;
            } catch {
                diag_log format ["[BN_KOTH][WARN] Map marker refresh failed; retrying. Error: %1", _exception];
            };

            private _mapDisplayId = missionNamespace getVariable ["BN_KOTH_playerMapMarkersDisplayId", 12];
            private _intervalVariable = if (isNull (findDisplay _mapDisplayId)) then {"BN_KOTH_playerMapMarkersClosedRefreshInterval"} else {"BN_KOTH_playerMapMarkersRefreshInterval"};
            private _interval = missionNamespace getVariable [_intervalVariable, 0.5];
            if (_interval < 0.1) then {
                _interval = 0.1;
            };

            uiSleep _interval;
        };

        missionNamespace setVariable ["BN_KOTH_playerMapMarkersLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_playerMapMarkersLoopHandle", _loopHandle];
};

[] call bn_koth_fnc_playerMapMarkers_refresh;
[] call bn_koth_fnc_playerMapMarkers_initMicOverlay;

true
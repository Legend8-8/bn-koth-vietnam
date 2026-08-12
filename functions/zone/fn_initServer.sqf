/*
    File: fn_initServer.sqf
    Author: tylervip
    Edited: Legend
    Description: Initializes zone settings and starts periodic movement/control updates.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_zoneManagerRunning", false]) exitWith {
    ["Zone manager already running.", "WARN"] call bn_koth_fnc_common_log;
};

missionNamespace setVariable ["BN_KOTH_zoneManagerRunning", true];

private _zoneCfg = missionConfigFile >> "CfgBnKothZone";
private _readNumber = {
    params ["_name", "_fallback"];
    private _entry = _zoneCfg >> _name;
    if (isNumber _entry) then {getNumber _entry} else {_fallback}
};
private _readText = {
    params ["_name", "_fallback"];
    private _entry = _zoneCfg >> _name;
    if (isText _entry) then {getText _entry} else {_fallback}
};

private _prioritySizeRatio = (["prioritySizeRatio", 0.14142136] call _readNumber) max 0;
private _priorityMinimumHalfSize = (["priorityMinimumHalfSize", 8.4852814] call _readNumber) max 0;
private _priorityMoveTickInterval = (["priorityMoveTickInterval", 0.5] call _readNumber) max 0.01;
private _priorityMoveDistancePerTick = (["priorityMoveDistancePerTick", 0.25] call _readNumber) max 0;
private _priorityControlWeight = (["priorityControlWeight", 2] call _readNumber) max 1;
private _priorityMarkerAlpha = ((["priorityMarkerAlpha", 0.75] call _readNumber) max 0) min 1;

missionNamespace setVariable ["BN_KOTH_priorityZoneRatio", _prioritySizeRatio];
missionNamespace setVariable ["BN_KOTH_priorityZoneMinimumHalfSize", _priorityMinimumHalfSize];
missionNamespace setVariable ["BN_KOTH_priorityZoneMoveTickInterval", _priorityMoveTickInterval];
missionNamespace setVariable ["BN_KOTH_priorityZoneMoveDistancePerTick", _priorityMoveDistancePerTick];
missionNamespace setVariable ["BN_KOTH_priorityZoneControlWeight", _priorityControlWeight];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerAlpha", _priorityMarkerAlpha];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerColor", ["priorityMarkerColor", "ColorGreen"] call _readText];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerBrush", ["priorityMarkerBrush", "Solid"] call _readText];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerWestColor", ["priorityMarkerWestColor", "ColorBlue"] call _readText];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerEastColor", ["priorityMarkerEastColor", "ColorRed"] call _readText];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerTieColor", ["priorityMarkerTieColor", "ColorCIV"] call _readText];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarkerTieBrush", ["priorityMarkerTieBrush", "FDiagonal"] call _readText];

[] call bn_koth_fnc_zone_cacheStaticObjects;
[] call bn_koth_fnc_zone_clearActiveLocation;

[] spawn {
    private _controlInterval = 1;
    private _nextControlAt = serverTime;

    while {missionNamespace getVariable ["BN_KOTH_zoneManagerRunning", false]} do {
        if (([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") then {
            [] call bn_koth_fnc_zone_updatePriorityZone;
        };

        private _now = serverTime;
        if (_now >= _nextControlAt) then {
            [] call bn_koth_fnc_zone_evaluateControl;
            _nextControlAt = _now + _controlInterval;
        };

        sleep (missionNamespace getVariable ["BN_KOTH_priorityZoneMoveTickInterval", 0.5]);
    };

    missionNamespace setVariable ["BN_KOTH_zoneManagerRunning", false];
};

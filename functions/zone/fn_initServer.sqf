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

private _maximumControlHeight = ["maximumControlHeight", 50] call _readNumber;
missionNamespace setVariable ["BN_KOTH_maximumControlHeight", _maximumControlHeight max 0];
private _priorityAreaRatio = ((["priorityAreaRatio", 0.10] call _readNumber) max 0) min 1;
private _prioritySizeRatio = sqrt _priorityAreaRatio;
private _priorityMinimumHalfSize = (["priorityMinimumHalfSize", 1] call _readNumber) max 0;
private _priorityMoveDistancePerTick = (["priorityMoveDistancePerTick", 0.25] call _readNumber) max 0;
private _priorityControlWeight = (["priorityControlWeight", 2] call _readNumber) max 1;
private _priorityMarkerAlpha = ((["priorityMarkerAlpha", 0.75] call _readNumber) max 0) min 1;

missionNamespace setVariable ["BN_KOTH_priorityZoneRatio", _prioritySizeRatio];
missionNamespace setVariable ["BN_KOTH_priorityZoneAreaRatio", _priorityAreaRatio];
missionNamespace setVariable ["BN_KOTH_priorityZoneMinimumHalfSize", _priorityMinimumHalfSize];
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

if !(missionNamespace getVariable ["BN_KOTH_priorityZoneUpdateLoopAdded", false]) then {
    private _controlInterval = 1;
    missionNamespace setVariable ["BN_KOTH_priorityZoneControlInterval", _controlInterval];
    missionNamespace setVariable ["BN_KOTH_priorityZoneNextControlAt", serverTime + _controlInterval];

    private _handler = addMissionEventHandler ["EachFrame", {
        if !(missionNamespace getVariable ["BN_KOTH_zoneManagerRunning", false]) exitWith {};
        if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {};

        [] call bn_koth_fnc_zone_updatePriorityZone;

        private _now = serverTime;
        private _nextControlAt = missionNamespace getVariable ["BN_KOTH_priorityZoneNextControlAt", _now];
        if (_now >= _nextControlAt) then {
            [] call bn_koth_fnc_zone_evaluateControl;
            missionNamespace setVariable ["BN_KOTH_priorityZoneNextControlAt", _now + _controlInterval];
        };
    }];

    missionNamespace setVariable ["BN_KOTH_priorityZoneUpdateLoopAdded", true];
    missionNamespace setVariable ["BN_KOTH_priorityZoneUpdateHandlerId", _handler];
};

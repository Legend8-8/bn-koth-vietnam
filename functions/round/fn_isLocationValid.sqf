/*
    File: fn_isLocationValid.sqf
    Author: Legend
    Description: Validates that a configured location has all required markers.
    Execution: Server
    Parameters:
        0: Location ID <STRING>
    Returns:
        True when location is valid for vote/deploy, otherwise false <BOOL>
    Public: Yes
*/

params ["_locationId"];

if (_locationId isEqualTo "") exitWith {false};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {false};

private _cfg = _locationsCfg >> _locationId;
if !(isClass _cfg) exitWith {false};

private _zoneMarker = getText (_cfg >> "zoneMarker");
private _westRespawn = getText (_cfg >> "respawnWestMarker");
private _eastRespawn = getText (_cfg >> "respawnEastMarker");
private _westBaseZone = getText (_cfg >> "westBaseZoneMarker");
private _eastBaseZone = getText (_cfg >> "eastBaseZoneMarker");

if (_zoneMarker isEqualTo "" || {_westRespawn isEqualTo ""} || {_eastRespawn isEqualTo ""} || {_westBaseZone isEqualTo ""} || {_eastBaseZone isEqualTo ""}) exitWith {
    false
};

if ((markerShape _zoneMarker) isEqualTo "") exitWith {false};
if ((markerShape _westRespawn) isEqualTo "") exitWith {false};
if ((markerShape _eastRespawn) isEqualTo "") exitWith {false};
if ((markerShape _westBaseZone) isEqualTo "") exitWith {false};
if ((markerShape _eastBaseZone) isEqualTo "") exitWith {false};

true

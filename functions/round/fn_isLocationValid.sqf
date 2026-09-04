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

params [["_locationId", "", [""]]];

if (_locationId isEqualTo "") exitWith {false};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {false};

private _cfg = _locationsCfg >> _locationId;
if !(isClass _cfg) exitWith {false};

true

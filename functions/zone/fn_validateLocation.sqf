/*
    File: fn_validateLocation.sqf
    Author: tylervip
    Description: Validates that a location has all mandatory runtime entities for activation.
    Execution: Server
    Parameters:
        0: Location ID <STRING>
    Returns:
        True when safe to activate, otherwise false <BOOL>
    Public: Yes
*/

params [["_locationId", "", [""]]];

if (_locationId isEqualTo "") exitWith {false};

private _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
if !(_locationData isEqualType createHashMap) exitWith {false};
if (count _locationData <= 0) exitWith {false};

private _requiredRoles = [
    ["zoneMarker", "zoneMarker"],
    ["respawnWestMarker", "respawnWestMarker"],
    ["respawnEastMarker", "respawnEastMarker"],
    ["westBaseZoneMarker", "westBaseZoneMarker"],
    ["eastBaseZoneMarker", "eastBaseZoneMarker"],
    ["westCommand_spawnpoint", "westCommand_spawnpoint"],
    ["eastCommand_spawnpoint", "eastCommand_spawnpoint"],
    ["westCommand_mapboard", "westCommand_mapboard"],
    ["eastCommand_mapboard", "eastCommand_mapboard"]
];

private _valid = true;
{
    _x params ["_key", "_label"];
    private _expected = _locationData getOrDefault [_key, ""];

    if (_expected isEqualTo "") then {
        [format ["Location '%1' failed validation: missing required role '%2' (expected resolved name unavailable).", _locationId, _label], "ERROR"] call bn_koth_fnc_common_log;
        _valid = false;
    } else {
        if ((markerShape _expected) isEqualTo "") then {
            [format ["Location '%1' failed validation: required role '%2' marker '%3' is missing.", _locationId, _label, _expected], "ERROR"] call bn_koth_fnc_common_log;
            _valid = false;
        };
    };

    if !(_valid) exitWith {false};
} forEach _requiredRoles;

_valid

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
    ["eastBaseZoneMarker", "eastBaseZoneMarker"]
];

private _roleIsPresent = {
    params ["_roleName", "_roleLabel"];

    if (_roleName isEqualTo "") exitWith {
        [format ["Location '%1' failed validation: missing required role '%2' (expected resolved name unavailable).", _locationId, _roleLabel], "ERROR"] call bn_koth_fnc_common_log;
        false
    };

    if ((markerShape _roleName) isNotEqualTo "") exitWith {true};

    private _candidate = missionNamespace getVariable [_roleName, objNull];
    if (_candidate isEqualType []) exitWith {
        ({!isNull _x} count _candidate) > 0
    };

    if (!isNull _candidate) exitWith {true};

    {
        private _object = _x;
        if (isNull _object) then {continue};
        if ((_object getVariable ["BN_KOTH_roleName", ""]) isEqualTo _roleName) exitWith {true};
        if ((vehicleVarName _object) isEqualTo _roleName) exitWith {true};
        if ((str _object) isEqualTo _roleName) exitWith {true};
    } forEach (allMissionObjects "");

    [format ["Location '%1' failed validation: required role '%2' marker/object/agent '%3' is missing.", _locationId, _roleLabel, _roleName], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _valid = true;
{
    _x params ["_key", "_label"];
    private _expected = _locationData getOrDefault [_key, ""];

    if !([_expected, _label] call _roleIsPresent) exitWith {
        _valid = false;
    };
} forEach _requiredRoles;

_valid

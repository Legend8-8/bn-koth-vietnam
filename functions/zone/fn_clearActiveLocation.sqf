/*
    File: fn_clearActiveLocation.sqf
    Author: Legend
    Description: Clears active AO marker state and hides all cached AO static objects.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if (isClass _locationsCfg) then {
    {
        private _cfg = _x;
        private _zoneMarker = getText (_cfg >> "zoneMarker");
        private _westRespawn = getText (_cfg >> "respawnWestMarker");
        private _eastRespawn = getText (_cfg >> "respawnEastMarker");

        if !(_zoneMarker isEqualTo "") then {
            _zoneMarker setMarkerAlpha 0;
        };
        if !(_westRespawn isEqualTo "") then {
            _westRespawn setMarkerAlpha 0;
        };
        if !(_eastRespawn isEqualTo "") then {
            _eastRespawn setMarkerAlpha 0;
        };
    } forEach ("true" configClasses _locationsCfg);
};

private _cache = missionNamespace getVariable ["BN_KOTH_staticObjectsByLocation", createHashMap];
if (_cache isEqualType createHashMap) then {
    {
        private _objs = _cache get _x;
        {
            if (!isNull _x) then {
                _x hideObjectGlobal true;
            };
        } forEach _objs;
    } forEach (keys _cache);
};

{
    if !((markerShape _x) isEqualTo "") then {
        deleteMarker _x;
    };
} forEach ["respawn_west", "respawn_east"];

["BN_KOTH_activeLocationId", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeZoneMarker", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnWestMarker", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnEastMarker", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeWestBaseZoneMarker", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeEastBaseZoneMarker", ""] call bn_koth_fnc_common_publicState;

private _priorityMarker = "BN_KOTH_priorityZoneMarker";
private _priorityZoneWasActive = missionNamespace getVariable ["BN_KOTH_priorityZoneActive", false];
if (_priorityZoneWasActive && {!((markerShape _priorityMarker) isEqualTo "")}) then {
    _priorityMarker setMarkerAlpha 0;
};

missionNamespace setVariable ["BN_KOTH_priorityZoneActive", false];
missionNamespace setVariable ["BN_KOTH_priorityZoneAoMarker", nil];
missionNamespace setVariable ["BN_KOTH_priorityZoneHeading", nil];
missionNamespace setVariable ["BN_KOTH_priorityZoneLastUpdateAt", nil];
missionNamespace setVariable ["BN_KOTH_warnedUnsupportedPriorityAoShape", nil];
missionNamespace setVariable ["BN_KOTH_warnedPriorityZoneTooLarge", nil];

// Remove obsolete numerical/public state. The global marker is client presentation.
missionNamespace setVariable ["BN_KOTH_priorityZonePosition", nil];
missionNamespace setVariable ["BN_KOTH_priorityZoneMarker", nil];
missionNamespace setVariable ["BN_KOTH_priorityZoneSize", nil];

["Active AO cleared and static content hidden."] call bn_koth_fnc_common_log;

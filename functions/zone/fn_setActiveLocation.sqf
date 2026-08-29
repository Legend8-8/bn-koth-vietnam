/*
    File: fn_setActiveLocation.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Activates one configured location ID and publishes marker/base-zone state.
    Execution: Server
    Parameters:
        0: Location ID to activate <STRING>
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

params [["_locationId", "", [""]]];

if (!isServer) exitWith {false};

if !([_locationId] call bn_koth_fnc_round_isLocationValid) exitWith {
    [format ["Rejected setActiveLocation for invalid location '%1'", _locationId], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {
    ["CfgBnKothLocations missing.", "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _activeCfg = _locationsCfg >> _locationId;
private _activeZoneMarker = getText (_activeCfg >> "zoneMarker");
private _activeWestRespawn = getText (_activeCfg >> "respawnWestMarker");
private _activeEastRespawn = getText (_activeCfg >> "respawnEastMarker");
private _activeWestBaseZone = getText (_activeCfg >> "westBaseZoneMarker");
private _activeEastBaseZone = getText (_activeCfg >> "eastBaseZoneMarker");

private _nativeWestRespawnMarker = "respawn_west";
private _nativeEastRespawnMarker = "respawn_east";

private _ensureNativeRespawnMarker = {
    params ["_markerName"];

    if ((markerShape _markerName) isEqualTo "") then {
        createMarker [_markerName, [0, 0, 0]];
    };

    // Keep native side respawn markers invisible; they are mechanics-only.
    _markerName setMarkerShape "ICON";
    _markerName setMarkerType "Empty";
    _markerName setMarkerAlpha 0;
};

private _applyNativeRespawnMarker = {
    params ["_nativeMarker", "_sourceMarker", "_label"];

    if (_sourceMarker isEqualTo "") exitWith {
        [format ["Active location missing %1 source marker name", _label], "WARN"] call bn_koth_fnc_common_log;
        false
    };

    if ((markerShape _sourceMarker) isEqualTo "") exitWith {
        [format ["Active location source marker '%1' missing for %2", _sourceMarker, _label], "WARN"] call bn_koth_fnc_common_log;
        false
    };

    _nativeMarker setMarkerPos (markerPos _sourceMarker);
    _nativeMarker setMarkerDir (markerDir _sourceMarker);
    _nativeMarker setMarkerType "Empty";
    _nativeMarker setMarkerAlpha 0;
    true
};

["BN_KOTH_activeLocationId", _locationId] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeZoneMarker", _activeZoneMarker] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnWestMarker", _activeWestRespawn] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnEastMarker", _activeEastRespawn] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeWestBaseZoneMarker", _activeWestBaseZone] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeEastBaseZoneMarker", _activeEastBaseZone] call bn_koth_fnc_common_publicState;

[_nativeWestRespawnMarker] call _ensureNativeRespawnMarker;
[_nativeEastRespawnMarker] call _ensureNativeRespawnMarker;

private _westApplied = [_nativeWestRespawnMarker, _activeWestRespawn, "WEST native respawn"] call _applyNativeRespawnMarker;
private _eastApplied = [_nativeEastRespawnMarker, _activeEastRespawn, "EAST native respawn"] call _applyNativeRespawnMarker;

if (_westApplied && _eastApplied) then {
    [format [
        "Native side respawn markers updated for AO '%1': west=%2 east=%3",
        _locationId,
        _activeWestRespawn,
        _activeEastRespawn
    ]] call bn_koth_fnc_common_log;
};

{
    private _cfg = _x;
    private _cfgName = configName _cfg;
    private _zoneMarker = getText (_cfg >> "zoneMarker");
    private _westRespawn = getText (_cfg >> "respawnWestMarker");
    private _eastRespawn = getText (_cfg >> "respawnEastMarker");
    private _westBaseZone = getText (_cfg >> "westBaseZoneMarker");
    private _eastBaseZone = getText (_cfg >> "eastBaseZoneMarker");
    private _isActive = (_cfgName isEqualTo _locationId);

    if !(_zoneMarker isEqualTo "") then {
        _zoneMarker setMarkerAlpha (if (_isActive) then {1} else {0});
    };

    // Respawn markers are logical markers, but hiding inactive ones helps editor debug clarity.
    if !(_westRespawn isEqualTo "") then {
        _westRespawn setMarkerAlpha (if (_isActive) then {1} else {0});
    };

    if !(_eastRespawn isEqualTo "") then {
        _eastRespawn setMarkerAlpha (if (_isActive) then {1} else {0});
    };

    if !(_westBaseZone isEqualTo "") then {
        _westBaseZone setMarkerAlpha (if (_isActive) then {1} else {0});
    };

    if !(_eastBaseZone isEqualTo "") then {
        _eastBaseZone setMarkerAlpha (if (_isActive) then {1} else {0});
    };

} forEach ("true" configClasses _locationsCfg);

private _cache = [] call bn_koth_fnc_zone_cacheStaticObjects;
if (_cache isEqualType createHashMap) then {
    {
        private _cfgName = _x;
        private _isActive = (_cfgName isEqualTo _locationId);
        private _locationObjects = _cache getOrDefault [_cfgName, []];

        {
            if (!isNull _x) then {
                _x hideObjectGlobal (!_isActive);
            };
        } forEach _locationObjects;
    } forEach (keys _cache);
};

private _roundState = [] call bn_koth_fnc_round_getState;
if (_roundState in ["PREPARING", "ACTIVE"]) then {
    [] call bn_koth_fnc_vehicles_buildActiveLocationSlots;
};

[] call bn_koth_fnc_respawn_sweepSafeZoneGroundItems;
[] call bn_koth_fnc_zone_spawnBattlefieldPickups;

[format ["Active location set: %1 (%2)", _locationId, _activeZoneMarker]] call bn_koth_fnc_common_log;

true

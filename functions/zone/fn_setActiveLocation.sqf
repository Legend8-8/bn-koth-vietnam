/*
    File: fn_setActiveLocation.sqf
    Author: tylervip
    Edited: Legend
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

["BN_KOTH_activeLocationId", _locationId] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeZoneMarker", _activeZoneMarker] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnWestMarker", _activeWestRespawn] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeRespawnEastMarker", _activeEastRespawn] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeWestBaseZoneMarker", _activeWestBaseZone] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeEastBaseZoneMarker", _activeEastBaseZone] call bn_koth_fnc_common_publicState;

{
    private _cfg = _x;
    private _cfgName = configName _cfg;
    private _zoneMarker = getText (_cfg >> "zoneMarker");
    private _westRespawn = getText (_cfg >> "respawnWestMarker");
    private _eastRespawn = getText (_cfg >> "respawnEastMarker");
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

[format ["Active location set: %1 (%2)", _locationId, _activeZoneMarker]] call bn_koth_fnc_common_log;

true

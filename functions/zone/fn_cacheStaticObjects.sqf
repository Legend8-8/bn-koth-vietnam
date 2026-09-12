/*
    File: fn_cacheStaticObjects.sqf
    Author: Legend
    Description: Caches intended static AO objects inside configured base zones once.
    Execution: Server
    Parameters:
        None
    Returns:
        Static cache map <HASHMAP>
    Public: Yes
*/

if (!isServer) exitWith {createHashMap};

if (missionNamespace getVariable ["BN_KOTH_staticLocationCacheReady", false]) exitWith {
    missionNamespace getVariable ["BN_KOTH_staticObjectsByLocation", createHashMap]
};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {createHashMap};

private _cache = createHashMap;
private _allMissionObjects = allMissionObjects "";

{
    private _cfg = _x;
    private _locationId = configName _cfg;
    private _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
    private _westBaseZone = _locationData get "westBaseZoneMarker";
    private _eastBaseZone = _locationData get "eastBaseZoneMarker";

    private _collected = [];

    // Spatial AO ownership discovery is restricted to editor-placed mission objects
    // within configured base zones and excludes units, vehicles and modules.
    {
        private _obj = _x;

        if (isNull _obj) then {
            continue;
        };

        if (_obj isKindOf "CAManBase") then {
            continue;
        };

        if (_obj isKindOf "AllVehicles") then {
            continue;
        };

        if (_obj isKindOf "Logic") then {
            continue;
        };

        if (_obj in allPlayers) then {
            continue;
        };

        if (!(_westBaseZone isEqualTo "") && {_obj inArea _westBaseZone}) then {
            _collected pushBackUnique _obj;
            continue;
        };

        if (!(_eastBaseZone isEqualTo "") && {_obj inArea _eastBaseZone}) then {
            _collected pushBackUnique _obj;
        };
    } forEach _allMissionObjects;

    {
        private _objName = _x;
        private _obj = missionNamespace getVariable [_objName, objNull];

        if ((typeName _obj) isEqualTo "OBJECT" && {!isNull _obj} && {!(_obj isKindOf "CAManBase")} && {!(_obj isKindOf "AllVehicles")} && {!(_obj isKindOf "Logic")}) then {
            _collected pushBackUnique _obj;
        };
    } forEach (getArray (_cfg >> "objects"));

    _cache set [_locationId, _collected];
    [format ["Cached %1 static AO objects for location '%2'", count _collected, _locationId]] call bn_koth_fnc_common_log;
} forEach ("true" configClasses _locationsCfg);

missionNamespace setVariable ["BN_KOTH_staticObjectsByLocation", _cache];
missionNamespace setVariable ["BN_KOTH_staticLocationCacheReady", true];

_cache

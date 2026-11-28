/*
    File: fn_cacheStaticObjects.sqf
    Author: Legend
    Description: Resolves and caches exclusive ownership of intended static AO objects once.
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

private _locationClasses = "true" configClasses _locationsCfg;
private _cache = createHashMap;
private _locationIds = [];
private _baseZonesByLocation = createHashMap;
private _allMissionObjects = allMissionObjects "";
private _candidateObjects = +_allMissionObjects;
private _players = allPlayers;

private _isEligibleStaticObject = {
    params ["_obj"];

    if (isNull _obj) exitWith {false};
    if (_obj isKindOf "CAManBase") exitWith {false};
    if (_obj isKindOf "AllVehicles") exitWith {false};
    if (_obj isKindOf "Logic") exitWith {false};
    if (_obj in _players) exitWith {false};

    true
};

{
    private _cfg = _x;
    private _locationId = configName _cfg;
    private _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;

    _locationIds pushBack _locationId;
    _cache set [_locationId, []];
    _baseZonesByLocation set [_locationId, [
        _locationData get "westBaseZoneMarker",
        _locationData get "eastBaseZoneMarker"
    ]];
} forEach _locationClasses;

// Explicit objects[] claims are collected before any prefix or spatial ownership.
// Parallel arrays preserve object identity without inventing a second persistent map.
private _explicitObjects = [];
private _explicitOwners = [];

{
    private _cfg = _x;
    private _locationId = configName _cfg;

    {
        private _objName = _x;
        private _obj = missionNamespace getVariable [_objName, objNull];

        if !((typeName _obj) isEqualTo "OBJECT" && {!isNull _obj}) then {
            [format [
                "Static AO ownership ignored unresolved objects[] entry '%1' for location '%2'.",
                _objName,
                _locationId
            ], "ERROR"] call bn_koth_fnc_common_log;
            continue;
        };

        private _claimIndex = _explicitObjects find _obj;
        if (_claimIndex < 0) then {
            _explicitObjects pushBack _obj;
            _explicitOwners pushBack [_locationId];
            _candidateObjects pushBackUnique _obj;
        } else {
            (_explicitOwners select _claimIndex) pushBackUnique _locationId;
        };
    } forEach (getArray (_cfg >> "objects"));
} forEach _locationClasses;

{
    private _owners = _explicitOwners select _forEachIndex;
    if ((count _owners) > 1) then {
        private _obj = _x;
        private _objLabel = vehicleVarName _obj;
        if (_objLabel isEqualTo "") then {
            _objLabel = str _obj;
        };

        [format [
            "Static AO ownership conflict: object '%1' is explicitly listed by locations [%2]; it will not be cached.",
            _objLabel,
            _owners joinString ", "
        ], "ERROR"] call bn_koth_fnc_common_log;
    };
} forEach _explicitObjects;

// Every eligible object receives at most one owner, in precedence order:
// objects[], longest configured <locationId>_ variable-name prefix, spatial fallback.
{
    private _obj = _x;
    if !([_obj] call _isEligibleStaticObject) then {
        continue;
    };

    private _explicitIndex = _explicitObjects find _obj;
    if (_explicitIndex >= 0) then {
        private _owners = _explicitOwners select _explicitIndex;
        if ((count _owners) isEqualTo 1) then {
            private _ownerId = _owners select 0;
            private _ownedObjects = _cache get _ownerId;
            _ownedObjects pushBackUnique _obj;
        };
        continue;
    };

    private _variableName = toLower (vehicleVarName _obj);
    private _prefixOwner = "";
    private _prefixLength = -1;

    if !(_variableName isEqualTo "") then {
        {
            private _locationPrefix = format ["%1_", toLower _x];
            private _locationIdLength = count _x;

            if ((_variableName find _locationPrefix) isEqualTo 0 && {_locationIdLength > _prefixLength}) then {
                _prefixOwner = _x;
                _prefixLength = _locationIdLength;
            };
        } forEach _locationIds;
    };

    if !(_prefixOwner isEqualTo "") then {
        private _ownedObjects = _cache get _prefixOwner;
        _ownedObjects pushBackUnique _obj;
        continue;
    };

    private _spatialOwners = [];
    {
        private _baseZones = _baseZonesByLocation get _x;
        _baseZones params ["_westBaseZone", "_eastBaseZone"];

        if (
            (!(_westBaseZone isEqualTo "") && {_obj inArea _westBaseZone})
            || {(!(_eastBaseZone isEqualTo "") && {_obj inArea _eastBaseZone})}
        ) then {
            _spatialOwners pushBack _x;
        };
    } forEach _locationIds;

    if ((count _spatialOwners) isEqualTo 1) then {
        private _ownerId = _spatialOwners select 0;
        private _ownedObjects = _cache get _ownerId;
        _ownedObjects pushBackUnique _obj;
        continue;
    };

    if ((count _spatialOwners) > 1) then {
        private _objLabel = vehicleVarName _obj;
        if (_objLabel isEqualTo "") then {
            _objLabel = str _obj;
        };

        [format [
            "Static AO ownership conflict: object '%1' is spatially inside locations [%2] with no explicit or recognised prefix owner; it will not be cached.",
            _objLabel,
            _spatialOwners joinString ", "
        ], "ERROR"] call bn_koth_fnc_common_log;
    };
} forEach _candidateObjects;

{
    private _locationId = _x;
    [format [
        "Cached %1 static AO objects for location '%2'",
        count (_cache get _locationId),
        _locationId
    ]] call bn_koth_fnc_common_log;
} forEach _locationIds;

missionNamespace setVariable ["BN_KOTH_staticObjectsByLocation", _cache];
missionNamespace setVariable ["BN_KOTH_staticLocationCacheReady", true];

_cache

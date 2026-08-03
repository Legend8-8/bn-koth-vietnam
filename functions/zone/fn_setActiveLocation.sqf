/*
    File: fn_setActiveLocation.sqf
    Description: Activates one configured location ID and publishes marker state.
    Execution: Server
*/

params [["_locationId", "", [""]], ["_deleteInactiveObjects", true, [true]]];

if (!isServer) exitWith {false};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {
    ["CfgBnKothLocations missing.", "ERROR"] call bn_koth_fnc_log;
    false
};

if (_locationId isEqualTo "") then {
    _locationId = getText (missionConfigFile >> "CfgBnKothSettings" >> "defaultLocationId");
};

private _activeCfg = _locationsCfg >> _locationId;
if !(isClass _activeCfg) exitWith {
    [format ["Unknown location ID: %1", _locationId], "ERROR"] call bn_koth_fnc_log;
    false
};

private _activeZoneMarker = getText (_activeCfg >> "zoneMarker");
private _activeWestRespawn = getText (_activeCfg >> "respawnWestMarker");
private _activeEastRespawn = getText (_activeCfg >> "respawnEastMarker");

["BN_KOTH_activeLocationId", _locationId] call bn_koth_fnc_publicState;
["BN_KOTH_activeZoneMarker", _activeZoneMarker] call bn_koth_fnc_publicState;
["BN_KOTH_activeRespawnWestMarker", _activeWestRespawn] call bn_koth_fnc_publicState;
["BN_KOTH_activeRespawnEastMarker", _activeEastRespawn] call bn_koth_fnc_publicState;

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

if (_deleteInactiveObjects) then {
    {
        private _cfg = _x;
        private _cfgName = configName _cfg;

        if !(_cfgName isEqualTo _locationId) then {
            // First delete explicit object list from config.
            {
                private _objName = _x;
                private _obj = missionNamespace getVariable [_objName, objNull];
                if (!isNull _obj) then {
                    deleteVehicle _obj;
                };
            } forEach (getArray (_cfg >> "objects"));

            // Then delete any Eden object variables that follow the <locationId>_ prefix convention.
            private _prefix = format ["%1_", _cfgName];

            {
                private _varName = _x;

                if ((_varName find _prefix) isEqualTo 0) then {
                    private _value = missionNamespace getVariable [_varName, objNull];
                    if ((typeName _value) isEqualTo "OBJECT" && {!isNull _value}) then {
                        deleteVehicle _value;
                    };
                };
            } forEach (allVariables missionNamespace);
        };
    } forEach ("true" configClasses _locationsCfg);
};

[format ["Active location set: %1 (%2)", _locationId, _activeZoneMarker]] call bn_koth_fnc_log;

true

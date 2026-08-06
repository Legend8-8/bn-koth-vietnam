/*
    File: fn_setActiveLocation.sqf
    Author: tylervip
    Description: Activates one configured location ID and publishes marker state.
    Execution: Server
    Parameters:
        0: Location ID to activate <STRING>
        1: Deactivate inactive static objects <BOOL> (default: true)
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

params [["_locationId", "", [""]], ["_deactivateInactiveObjects", true, [true]]];

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

if (_deactivateInactiveObjects) then {
    private _staticObjectsByLocation = createHashMap;

    // Collect static Eden objects for each configured location once, then apply
    // active/inactive state without deleting objects from the mission.
    {
        private _cfg = _x;
        private _cfgName = configName _cfg;
        private _collected = [];

        {
            private _objName = _x;
            private _obj = missionNamespace getVariable [_objName, objNull];

            if ((typeName _obj) isEqualTo "OBJECT" && {!isNull _obj}) then {
                _collected pushBackUnique _obj;
            };
        } forEach (getArray (_cfg >> "objects"));

        private _prefix = format ["%1_", _cfgName];

        {
            private _varName = _x;

            if ((_varName find _prefix) isEqualTo 0) then {
                private _value = missionNamespace getVariable [_varName, objNull];
                if ((typeName _value) isEqualTo "OBJECT" && {!isNull _value}) then {
                    _collected pushBackUnique _value;
                };
            };
        } forEach (allVariables missionNamespace);

        _staticObjectsByLocation set [_cfgName, _collected];
    } forEach ("true" configClasses _locationsCfg);

    {
        private _cfg = _x;
        private _cfgName = configName _cfg;
        private _isActive = (_cfgName isEqualTo _locationId);
        private _locationObjects = _staticObjectsByLocation getOrDefault [_cfgName, []];

        {
            _x hideObjectGlobal (!_isActive);
            _x enableSimulationGlobal _isActive;
        } forEach _locationObjects;
    } forEach ("true" configClasses _locationsCfg);
};

[format ["Active location set: %1 (%2)", _locationId, _activeZoneMarker]] call bn_koth_fnc_log;

true

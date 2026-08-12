/*
    File: fn_buildActiveLocationSlots.sqf
    Author: tylervip
    Description: Builds and spawns managed free vehicle slots for the active location.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of valid managed slots <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

if !(missionNamespace getVariable ["BN_KOTH_vehicleSystemEnabled", false]) exitWith {0};

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
if (_activeLocationId isEqualTo "") exitWith {
    ["Vehicle slot build skipped: no active location.", "WARN"] call bn_koth_fnc_common_log;
    0
};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {
    ["Vehicle slot build failed: CfgBnKothLocations missing.", "ERROR"] call bn_koth_fnc_common_log;
    0
};

private _activeCfg = _locationsCfg >> _activeLocationId;
if !(isClass _activeCfg) exitWith {
    [format ["Vehicle slot build failed: active location '%1' missing config class.", _activeLocationId], "ERROR"] call bn_koth_fnc_common_log;
    0
};

[] call bn_koth_fnc_vehicles_cleanupManagedVehicles;

private _vehicleCfg = missionConfigFile >> "CfgBnKothVehicles";
private _cooldowns = createHashMapFromArray [
    ["ground", missionNamespace getVariable ["BN_KOTH_vehicleRespawnCooldownGroundSeconds", 10]],
    ["air", missionNamespace getVariable ["BN_KOTH_vehicleRespawnCooldownAirSeconds", 20]],
    ["sea", missionNamespace getVariable ["BN_KOTH_vehicleRespawnCooldownSeaSeconds", 15]]
];

private _defaultClasses = createHashMapFromArray [
    ["ground", getText (_vehicleCfg >> "groundVehicleClass")],
    ["air", getText (_vehicleCfg >> "airVehicleClass")],
    ["sea", getText (_vehicleCfg >> "seaVehicleClass")]
];

private _westOverrides = createHashMapFromArray [
    ["ground", getText (_vehicleCfg >> "westGroundVehicleClass")],
    ["air", getText (_vehicleCfg >> "westAirVehicleClass")],
    ["sea", getText (_vehicleCfg >> "westSeaVehicleClass")]
];

private _eastOverrides = createHashMapFromArray [
    ["ground", getText (_vehicleCfg >> "eastGroundVehicleClass")],
    ["air", getText (_vehicleCfg >> "eastAirVehicleClass")],
    ["sea", getText (_vehicleCfg >> "eastSeaVehicleClass")]
];

private _slotSpecs = [
    ["east_ground", east, "ground", "eastFreeGround_spawnpoint"],
    ["east_air", east, "air", "eastFreeAir_spawnpoint"],
    ["east_sea", east, "sea", "eastFreeSea_spawnpoint"],
    ["west_ground", west, "ground", "westFreeGround_spawnpoint"],
    ["west_air", west, "air", "westFreeAir_spawnpoint"],
    ["west_sea", west, "sea", "westFreeSea_spawnpoint"]
];

private _slots = createHashMap;
private _slotIds = [];

{
    _x params ["_slotId", "_side", "_category", "_cfgSpawnpointKey"];

    private _markerName = getText (_activeCfg >> _cfgSpawnpointKey);
    if (_markerName isEqualTo "") then {
        [format ["Vehicle slot '%1' skipped: missing marker key '%2' in location '%3'.", _slotId, _cfgSpawnpointKey, _activeLocationId], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    if ((markerShape _markerName) isEqualTo "") then {
        [format ["Vehicle slot '%1' skipped: marker '%2' does not exist.", _slotId, _markerName], "WARN"] call bn_koth_fnc_common_log;
        continue;
    };

    private _defaultClass = _defaultClasses getOrDefault [_category, ""];
    private _overrideClass = if (_side isEqualTo west) then {
        _westOverrides getOrDefault [_category, ""]
    } else {
        _eastOverrides getOrDefault [_category, ""]
    };

    private _vehicleClass = if !(_overrideClass isEqualTo "") then {_overrideClass} else {_defaultClass};
    if (_vehicleClass isEqualTo "") then {
        [format ["Vehicle slot '%1' skipped: no class configured for category '%2'.", _slotId, _category], "ERROR"] call bn_koth_fnc_common_log;
        continue;
    };

    private _slotData = createHashMapFromArray [
        ["slotId", _slotId],
        ["enabled", true],
        ["side", _side],
        ["category", _category],
        ["markerName", _markerName],
        ["vehicleClass", _vehicleClass],
        ["cooldownSeconds", _cooldowns getOrDefault [_category, 10]],
        ["vehicle", objNull],
        ["respawnAt", -1],
        ["emptySince", -1]
    ];

    _slots set [_slotId, _slotData];
    _slotIds pushBack _slotId;
} forEach _slotSpecs;

missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", _slots];
missionNamespace setVariable ["BN_KOTH_vehicleManagedSlotIds", _slotIds];

{
    [_x] call bn_koth_fnc_vehicles_spawnManagedSlot;
} forEach _slotIds;

[format ["Built %1 managed free vehicle slots for location '%2'.", count _slotIds, _activeLocationId], "INFO"] call bn_koth_fnc_common_log;
count _slotIds

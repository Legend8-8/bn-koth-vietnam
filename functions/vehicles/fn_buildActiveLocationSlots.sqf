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

private _activeLocationData = [_activeLocationId] call bn_koth_fnc_zone_getLocationData;
if !(_activeLocationData isEqualType createHashMap) exitWith {
    [format ["Vehicle slot build failed: active location '%1' missing resolver data.", _activeLocationId], "ERROR"] call bn_koth_fnc_common_log;
    0
};
private _capabilities = [_activeLocationData] call bn_koth_fnc_zone_getVehicleCapabilities;
private _capabilitySides = _capabilities getOrDefault ["sides", createHashMap];

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
    ["east_ground", east, "EAST", "ground", "GROUND", "FREE_GROUND"],
    ["east_air", east, "EAST", "air", "ROTARY", "FREE_AIR"],
    ["east_sea", east, "EAST", "sea", "SEA", "FREE_SEA"],
    ["west_ground", west, "WEST", "ground", "GROUND", "FREE_GROUND"],
    ["west_air", west, "WEST", "air", "ROTARY", "FREE_AIR"],
    ["west_sea", west, "WEST", "sea", "SEA", "FREE_SEA"]
];

private _slots = createHashMap;
private _slotIds = [];

{
    _x params ["_slotId", "_side", "_sideToken", "_category", "_familyName", "_roleName"];
    private _sideCapabilities = _capabilitySides getOrDefault [_sideToken, createHashMap];
    private _families = _sideCapabilities getOrDefault ["families", createHashMap];
    private _family = _families getOrDefault [_familyName, createHashMap];
    if !(_family getOrDefault ["free", false]) then {continue};
    private _roles = _sideCapabilities getOrDefault ["roles", createHashMap];
    private _role = _roles getOrDefault [_roleName, createHashMap];
    if !(_role getOrDefault ["exists", false]) then {continue};

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
        ["sideToken", _sideToken],
        ["category", _category],
        ["family", _familyName],
        ["roleName", _roleName],
        ["spawnRef", _role getOrDefault ["ref", ""]],
        ["spawnPosition", _role getOrDefault ["position", []]],
        ["spawnDirection", _role getOrDefault ["direction", 0]],
        ["locationId", _activeLocationId],
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

/*
    File: fn_initServer.sqf
    Author: tylervip
    Description: Initializes the server-authoritative free vehicle manager and monitor loop.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_vehicleSystemInitialized", false]) exitWith {
    ["Vehicle system already initialized.", "INFO"] call bn_koth_fnc_common_log;
};

private _vehicleCfg = missionConfigFile >> "CfgBnKothVehicles";
if !(isClass _vehicleCfg) exitWith {
    ["CfgBnKothVehicles missing; free vehicle system disabled.", "WARN"] call bn_koth_fnc_common_log;
};

private _enabled = (getNumber (_vehicleCfg >> "enableFreeVehicleSystem")) > 0;
missionNamespace setVariable ["BN_KOTH_vehicleSystemEnabled", _enabled, true];

if (!_enabled) exitWith {
    missionNamespace setVariable ["BN_KOTH_vehicleSystemInitialized", true];
    ["Free vehicle system disabled by configuration.", "INFO"] call bn_koth_fnc_common_log;
};

private _monitorInterval = (getNumber (_vehicleCfg >> "monitorIntervalSeconds")) max 1;
private _abandonmentTimeout = (getNumber (_vehicleCfg >> "abandonmentTimeoutSeconds")) max 1;
private _spawnClearRadius = (getNumber (_vehicleCfg >> "spawnClearRadiusMeters")) max 0;
private _spawnBlockedRetrySeconds = (getNumber (_vehicleCfg >> "spawnBlockedRetrySeconds")) max 1;
private _includePlayerBlockers = (getNumber (_vehicleCfg >> "includePlayersInSpawnBlockCheck")) > 0;
private _includeVehicleBlockers = (getNumber (_vehicleCfg >> "includeVehiclesInSpawnBlockCheck")) > 0;
private _cooldownGround = (getNumber (_vehicleCfg >> "respawnCooldownGroundSeconds")) max 1;
private _cooldownAir = (getNumber (_vehicleCfg >> "respawnCooldownAirSeconds")) max 1;
private _cooldownSea = (getNumber (_vehicleCfg >> "respawnCooldownSeaSeconds")) max 1;

missionNamespace setVariable ["BN_KOTH_vehicleMonitorIntervalSeconds", _monitorInterval, true];
missionNamespace setVariable ["BN_KOTH_vehicleAbandonmentTimeoutSeconds", _abandonmentTimeout, true];
missionNamespace setVariable ["BN_KOTH_vehicleSpawnClearRadiusMeters", _spawnClearRadius, true];
missionNamespace setVariable ["BN_KOTH_vehicleSpawnBlockedRetrySeconds", _spawnBlockedRetrySeconds, true];
missionNamespace setVariable ["BN_KOTH_vehicleSpawnIncludePlayers", _includePlayerBlockers, true];
missionNamespace setVariable ["BN_KOTH_vehicleSpawnIncludeVehicles", _includeVehicleBlockers, true];
missionNamespace setVariable ["BN_KOTH_vehicleRespawnCooldownGroundSeconds", _cooldownGround, true];
missionNamespace setVariable ["BN_KOTH_vehicleRespawnCooldownAirSeconds", _cooldownAir, true];
missionNamespace setVariable ["BN_KOTH_vehicleRespawnCooldownSeaSeconds", _cooldownSea, true];

missionNamespace setVariable ["BN_KOTH_vehicleManagedSlots", createHashMap];
missionNamespace setVariable ["BN_KOTH_vehicleManagedSlotIds", []];
missionNamespace setVariable ["BN_KOTH_vehicleActiveRentals", createHashMap];
missionNamespace setVariable ["BN_KOTH_vehicleRentalCooldowns", createHashMap];
missionNamespace setVariable ["BN_KOTH_vehiclePaidPadReservations", createHashMap];

private _paidPads = [];
{
    private _locationId = configName _x;
    private _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
    private _capabilities = [_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
    private _sides = _capabilities getOrDefault ["sides", createHashMap];
    {
        private _sideToken = _x;
        private _roles = (_sides getOrDefault [_sideToken, createHashMap]) getOrDefault ["roles", createHashMap];
        {
            _x params ["_roleName", "_category"];
            private _role = _roles getOrDefault [_roleName, createHashMap];
            if !(_role getOrDefault ["exists", false]) then {continue};
            _paidPads pushBack (createHashMapFromArray [
                ["id", format ["%1|%2|%3", _locationId, _sideToken, _category]],
                ["object", _role getOrDefault ["object", objNull]],
                ["position", _role getOrDefault ["position", []]],
                ["direction", _role getOrDefault ["direction", 0]],
                ["roleRef", _role getOrDefault ["ref", ""]],
                ["category", _category], ["side", _sideToken],
                ["location", toLower _locationId]
            ]);
        } forEach [["PAID_GROUND", "GROUND"], ["PAID_AIR", "AIR"], ["PAID_SEA", "SEA"]];
    } forEach ["WEST", "EAST"];
} forEach ("true" configClasses (missionConfigFile >> "CfgBnKothLocations"));
missionNamespace setVariable ["BN_KOTH_vehiclePaidPads", _paidPads];
missionNamespace setVariable ["BN_KOTH_vehicleSystemInitialized", true];

if !(missionNamespace getVariable ["BN_KOTH_vehicleMonitorRunning", false]) then {
    missionNamespace setVariable ["BN_KOTH_vehicleMonitorRunning", true];
    [] spawn bn_koth_fnc_vehicles_monitorManagedVehicles;
};

[format [
    "Vehicle system initialized: interval=%1 abandonment=%2 safeSpawn(radius=%3 retry=%4 players=%5 vehicles=%6) cooldowns(ground=%7, air=%8, sea=%9)",
    _monitorInterval,
    _abandonmentTimeout,
    _spawnClearRadius,
    _spawnBlockedRetrySeconds,
    _includePlayerBlockers,
    _includeVehicleBlockers,
    _cooldownGround,
    _cooldownAir,
    _cooldownSea
], "INFO"] call bn_koth_fnc_common_log;
[format ["Paid vehicle rental pads cached: %1", count _paidPads], "INFO"] call bn_koth_fnc_common_log;

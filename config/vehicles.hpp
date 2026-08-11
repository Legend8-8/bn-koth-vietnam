class CfgBnKothVehicles
{
    enableFreeVehicleSystem = 1;

    // Manager cadence.
    monitorIntervalSeconds = 1;

    // Empty this long with zero player crew before recycle.
    abandonmentTimeoutSeconds = 10;

    // Safe spawn checks for managed free vehicles.
    spawnClearRadiusMeters = 8;
    spawnBlockedRetrySeconds = 5;
    includePlayersInSpawnBlockCheck = 1;
    includeVehiclesInSpawnBlockCheck = 1;

    // Per-category respawn cooldowns used after destruction/recycle.
    respawnCooldownGroundSeconds = 10;
    respawnCooldownAirSeconds = 20;
    respawnCooldownSeaSeconds = 15;

    // Command vehicle respawn delay after destruction.
    commandVehicleRespawnCooldownSeconds = 30;

    // Default vehicle classes per category.
    groundVehicleClass = "vn_b_wheeled_m54_02_sog";
    airVehicleClass = "vn_b_air_ch47_02_01";
    seaVehicleClass = "vn_b_boat_09_01";

    // Optional side-specific overrides (empty string = use default class above).
    westGroundVehicleClass = "";
    westAirVehicleClass = "";
    westSeaVehicleClass = "";
    eastGroundVehicleClass = "";
    eastAirVehicleClass = "";
    eastSeaVehicleClass = "";

    // Command vehicle classes used by command mapboard teleport.
    // Must be explicitly set.
    westCommandVehicleClass = "vn_b_armor_m577_01";
    eastCommandVehicleClass = "vn_b_armor_m577_01";
};

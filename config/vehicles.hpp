class CfgBnKothVehicles
{
    enableFreeVehicleSystem = 1;

    // Manager cadence.
    monitorIntervalSeconds = 1;

    // Empty this long with zero player crew before recycle.
    abandonmentTimeoutSeconds = 300;

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

    // Anti-spam delay between server-authoritative command-teleport requests.
    commandTeleportRequestCooldownSeconds = 10;

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

    // Human-authored KOTH vehicle progression/economy metadata.
    //
    // Schema:
    //   variantOf = "<canonical classname>"; // optional structural relationship
    //   allowedSides[] = {"WEST", "EAST"};
    //   appearanceSide = "WEST" | "EAST" | ""; // optional visual identity
    //   minLevel = <number>;
    //   purchasePrice = <number>;
    //   rentalPrice = <number>;
    //   requiredPerks[] = {...}; // optional
    //   storeCategory = "GROUND" | "SEA" | "ROTARY" | "FIXED_WING";
    //   vehicleRole = "TRANSPORT" | "LOGISTICS" | "COMMAND" | "COMBAT";
    //
    // Progression policy belongs only to canonical roots. A structural entry
    // may declare variantOf only and inherits every policy field from its root.
    // These provisional values do not affect the managed free-vehicle system.
    class Metadata
    {
        class Vehicles
        {
            class vn_b_wheeled_m54_02_sog
            {
                allowedSides[] = {"WEST", "EAST"};
                minLevel = 10;
                purchasePrice = 12000;
                rentalPrice = 2400;
                storeCategory = "GROUND";
                vehicleRole = "LOGISTICS";
            };

            class vn_b_boat_09_01
            {
                allowedSides[] = {"WEST", "EAST"};
                minLevel = 15;
                purchasePrice = 10000;
                rentalPrice = 2000;
                storeCategory = "SEA";
                vehicleRole = "TRANSPORT";
            };

            class vn_b_armor_m577_01
            {
                allowedSides[] = {"WEST", "EAST"};
                minLevel = 40;
                purchasePrice = 20000;
                rentalPrice = 4000;
                storeCategory = "GROUND";
                vehicleRole = "COMMAND";
            };

            class vn_b_air_ch47_02_01
            {
                allowedSides[] = {"WEST", "EAST"};
                minLevel = 90;
                purchasePrice = 50000;
                rentalPrice = 10000;
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };
        };
    };
};

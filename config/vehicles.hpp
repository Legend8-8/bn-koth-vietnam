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

    // One-life paid vehicle rental policy: RENT is one immediate authoritative
    // spawn transaction; there is no separate requisition step.
    rentalCooldownSeconds = 90;
    rentedWreckCleanupSeconds = 180;
    rentedAbandonmentSeconds = 600;
    rentedOwnerDisconnectCleanupSeconds = 600;
    paidSpawnClearanceMeters = 12;
    paidFallbackSpawnRadiusMeters = 50;
    paidSpawnMinimumSurfaceNormalZ = 0.85;
    vehicleRentalRequestCooldownSeconds = 0.5;

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

    // Human-authored, curated combat-vehicle progression surface.
    class Metadata
    {
        class Vehicles
        {
            // Factual audit: data/vehicle_inventory.csv. Only selected
            // combat-relevant products are authored here. Similar paint or
            // faction copies are omitted; no unsupported variant graph is inferred.

            // GROUND products.
            // BTR-40 (RPD) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 25;
                purchasePrice = 18000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-40 (SGM) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_04
            {
                allowedSides[] = {"EAST"};
                minLevel = 35;
                purchasePrice = 24000;
                rentalPrice = 4800;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-40 (DShKM) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_02
            {
                allowedSides[] = {"EAST"};
                minLevel = 45;
                purchasePrice = 30000;
                rentalPrice = 6000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-50PK Transport | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_btr50pk_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 55;
                purchasePrice = 42000;
                rentalPrice = 8400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "TRANSPORT";
            };

            // M113A1 Transport (M2) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 60;
                purchasePrice = 45000;
                rentalPrice = 9000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "TRANSPORT";
            };

            // M113A1 ACAV (M60) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_acav_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 70;
                purchasePrice = 52000;
                rentalPrice = 10400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (M2) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_acav_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 78;
                purchasePrice = 60000;
                rentalPrice = 12000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-40 (Type 56 RR) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 82;
                purchasePrice = 62000;
                rentalPrice = 12400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-40 (Type 53 Mortar) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_06
            {
                allowedSides[] = {"EAST"};
                minLevel = 88;
                purchasePrice = 70000;
                rentalPrice = 14000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M125A1 M29 Mortar | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m125_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 96;
                purchasePrice = 78000;
                rentalPrice = 15600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-40 (ZPU-4) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 105;
                purchasePrice = 82000;
                rentalPrice = 16400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // BTR-50PK SPAAG （ZGU-1） | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_btr50pk_02
            {
                allowedSides[] = {"EAST"};
                minLevel = 112;
                purchasePrice = 90000;
                rentalPrice = 18000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M41A3 Walker Bulldog | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_m41_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 128;
                purchasePrice = 105000;
                rentalPrice = 21000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // PT-76A Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_pt76a_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 138;
                purchasePrice = 115000;
                rentalPrice = 23000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // PT-76B Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_pt76b_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 148;
                purchasePrice = 125000;
                rentalPrice = 25000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // Type 63 Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_type63_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 162;
                purchasePrice = 145000;
                rentalPrice = 29000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // OT-54 Flame Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_ot54_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 188;
                purchasePrice = 175000;
                rentalPrice = 35000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // T-54B Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_t54b_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 205;
                purchasePrice = 195000;
                rentalPrice = 39000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M151A1 Armoured | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 22;
                purchasePrice = 18000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M151A1 Patrol | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 30;
                purchasePrice = 22000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M151A1 M2 | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 40;
                purchasePrice = 28000;
                rentalPrice = 5600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 Transport (M2) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 58;
                purchasePrice = 45000;
                rentalPrice = 9000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "TRANSPORT";
            };

            // M113A1 ACAV (M60) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 68;
                purchasePrice = 52000;
                rentalPrice = 10400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (M2) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 76;
                purchasePrice = 60000;
                rentalPrice = 12000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M54 Gun Truck (Minigun) | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m54_mg_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 84;
                purchasePrice = 68000;
                rentalPrice = 13600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M151A1 M40A1 | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 90;
                purchasePrice = 70000;
                rentalPrice = 14000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (M1919) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 94;
                purchasePrice = 74000;
                rentalPrice = 14800;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M125A1 M29 Mortar | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m125_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 100;
                purchasePrice = 80000;
                rentalPrice = 16000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (M134) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 108;
                purchasePrice = 88000;
                rentalPrice = 17600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (Mk18) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 114;
                purchasePrice = 92000;
                rentalPrice = 18400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M151A1 TOW | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 120;
                purchasePrice = 95000;
                rentalPrice = 19000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M113A1 ACAV (M2/ M40) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 126;
                purchasePrice = 105000;
                rentalPrice = 21000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M55 AA Truck (Quad) | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m54_mg_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 132;
                purchasePrice = 110000;
                rentalPrice = 22000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M132A1 Flamethrower | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m132_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 142;
                purchasePrice = 120000;
                rentalPrice = 24000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M41A3 Walker Bulldog | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m41_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 155;
                purchasePrice = 135000;
                rentalPrice = 27000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M67A2 Flame Tank | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m67_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 195;
                purchasePrice = 185000;
                rentalPrice = 37000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };

            // M48A3 Patton Tank | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m48_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 215;
                purchasePrice = 210000;
                rentalPrice = 42000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                vehicleRole = "COMBAT";
            };


            // ROTARY products.
            // Mi-2P Hoplite (Transport) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_01_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 42;
                purchasePrice = 42000;
                rentalPrice = 8400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // Mi-2US Hoplite (MG) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_03_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 62;
                purchasePrice = 58000;
                rentalPrice = 11600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // Mi-2URN Viper (HE) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 78;
                purchasePrice = 76000;
                rentalPrice = 15200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // Mi-2URN Viper (APERS) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 88;
                purchasePrice = 88000;
                rentalPrice = 17600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // Mi-2URN Viper (HEAT) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 100;
                purchasePrice = 100000;
                rentalPrice = 20000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // Mi-2URP Salamander (AA) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_05_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 112;
                purchasePrice = 115000;
                rentalPrice = 23000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // Mi-2URP Salamander (AT) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_05_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 126;
                purchasePrice = 130000;
                rentalPrice = 26000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // OH-6A Cayuse | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 35;
                purchasePrice = 38000;
                rentalPrice = 7600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // OH-6A Cayuse (Scout MG) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 48;
                purchasePrice = 48000;
                rentalPrice = 9600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // OH-6A Cayuse (Gunship/ APERS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 64;
                purchasePrice = 62000;
                rentalPrice = 12400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // OH-6A Cayuse (Gunship/ AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 76;
                purchasePrice = 76000;
                rentalPrice = 15200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // UH-34D Seahorse (M60) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 52;
                purchasePrice = 52000;
                rentalPrice = 10400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // UH-34D Seahorse (M60 x2) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 66;
                purchasePrice = 66000;
                rentalPrice = 13200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // UH-34 Stinger (CAS) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_04_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 92;
                purchasePrice = 92000;
                rentalPrice = 18400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // UH-1E Iroquois Slick | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_03_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 60;
                purchasePrice = 62000;
                rentalPrice = 12400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // UH-1E Iroquois Gunship | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_01_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 82;
                purchasePrice = 84000;
                rentalPrice = 16800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // UH-1E Iroquois Heavy Gunship | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_02_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 98;
                purchasePrice = 100000;
                rentalPrice = 20000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // UH-1C Iroquois Gunship (Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_uh1c_02_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 108;
                purchasePrice = 115000;
                rentalPrice = 23000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // CH-47A Chinook (Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ch47_04_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 118;
                purchasePrice = 125000;
                rentalPrice = 25000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // CH-47A Chinook (M60/ Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ch47_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 132;
                purchasePrice = 145000;
                rentalPrice = 29000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "TRANSPORT";
            };

            // UH-1P Iroquois Hornet | factual: WEST / MACV / Helicopters (USAF)
            class vn_b_air_uh1c_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 145;
                purchasePrice = 155000;
                rentalPrice = 31000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // UH-1D Iroquois Bushranger | factual: WEST / Australia / Helicopters (RAAF)
            class vn_b_air_uh1d_03_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 158;
                purchasePrice = 170000;
                rentalPrice = 34000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // ACH-47A Guns-A-Go-Go (AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ach47_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 172;
                purchasePrice = 190000;
                rentalPrice = 38000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // ACH-47A Guns-A-Go-Go (Cannon) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ach47_05_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 188;
                purchasePrice = 210000;
                rentalPrice = 42000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // AH-1G Cobra (APERS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 180;
                purchasePrice = 195000;
                rentalPrice = 39000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // AH-1G Cobra (AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 198;
                purchasePrice = 220000;
                rentalPrice = 44000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // AH-1G Cobra (CAS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 210;
                purchasePrice = 235000;
                rentalPrice = 47000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // AH-1G Cobra (M195/AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_08
            {
                allowedSides[] = {"WEST"};
                minLevel = 226;
                purchasePrice = 255000;
                rentalPrice = 51000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };

            // AH-1G Cobra (M195/CAS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_09
            {
                allowedSides[] = {"WEST"};
                minLevel = 238;
                purchasePrice = 275000;
                rentalPrice = 55000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                vehicleRole = "COMBAT";
            };


            // FIXED_WING products.
            // MiG-19 S (CAP) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_cap
            {
                allowedSides[] = {"EAST"};
                minLevel = 170;
                purchasePrice = 180000;
                rentalPrice = 36000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-19 S (CAS) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_cas
            {
                allowedSides[] = {"EAST"};
                minLevel = 182;
                purchasePrice = 200000;
                rentalPrice = 40000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-19 S (AT) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_at
            {
                allowedSides[] = {"EAST"};
                minLevel = 194;
                purchasePrice = 220000;
                rentalPrice = 44000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-19 S (BMB) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_bmb
            {
                allowedSides[] = {"EAST"};
                minLevel = 206;
                purchasePrice = 240000;
                rentalPrice = 48000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-21 PFM (CAP) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_cap
            {
                allowedSides[] = {"EAST"};
                minLevel = 214;
                purchasePrice = 250000;
                rentalPrice = 50000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-21 PFM (CAS) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_cas
            {
                allowedSides[] = {"EAST"};
                minLevel = 226;
                purchasePrice = 280000;
                rentalPrice = 56000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-21 PFM (ATGM) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_atgm
            {
                allowedSides[] = {"EAST"};
                minLevel = 240;
                purchasePrice = 310000;
                rentalPrice = 62000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // MiG-21 PFM (HBMB) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_hbmb
            {
                allowedSides[] = {"EAST"};
                minLevel = 258;
                purchasePrice = 350000;
                rentalPrice = 70000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-100D (CAP) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_cap
            {
                allowedSides[] = {"WEST"};
                minLevel = 168;
                purchasePrice = 180000;
                rentalPrice = 36000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-100D (CAS) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_cas
            {
                allowedSides[] = {"WEST"};
                minLevel = 184;
                purchasePrice = 205000;
                rentalPrice = 41000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-100D (AT) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_at
            {
                allowedSides[] = {"WEST"};
                minLevel = 198;
                purchasePrice = 230000;
                rentalPrice = 46000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-100D (SEAD) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_sead
            {
                allowedSides[] = {"WEST"};
                minLevel = 218;
                purchasePrice = 260000;
                rentalPrice = 52000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4B Phantom II (CAP) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_cap
            {
                allowedSides[] = {"WEST"};
                minLevel = 220;
                purchasePrice = 275000;
                rentalPrice = 55000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4B Phantom II (AT) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_at
            {
                allowedSides[] = {"WEST"};
                minLevel = 232;
                purchasePrice = 300000;
                rentalPrice = 60000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4B Phantom II (SEAD) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_sead
            {
                allowedSides[] = {"WEST"};
                minLevel = 246;
                purchasePrice = 330000;
                rentalPrice = 66000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4C Phantom II (CAS) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_cas
            {
                allowedSides[] = {"WEST"};
                minLevel = 228;
                purchasePrice = 290000;
                rentalPrice = 58000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4C Phantom II (GBU) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_gbu
            {
                allowedSides[] = {"WEST"};
                minLevel = 252;
                purchasePrice = 360000;
                rentalPrice = 72000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

            // F-4C Phantom II (CHICO) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_chico
            {
                allowedSides[] = {"WEST"};
                minLevel = 265;
                purchasePrice = 400000;
                rentalPrice = 80000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                vehicleRole = "COMBAT";
            };

        };
    };
};

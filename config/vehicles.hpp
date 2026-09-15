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
    commandTeleportValidationThrottleSeconds = 0.25;

    // Personal paid vehicles share one authoritative life/cleanup owner whether
    // rented, purchased with the included first spawn, or requisitioned later.
    rentedWreckCleanupSeconds = 180;
    rentedAbandonmentSeconds = 600;
    rentedOwnerDisconnectCleanupSeconds = 600;
    // Personal paid-vehicle lifecycle is swept by the shared manager, not one loop per vehicle.
    rentalMonitorIntervalSeconds = 30;
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

    // Authoritative human-authored BN KOTH vehicle progression catalogue.
    // Family/loadout IDs are durable progression identifiers: edit metadata
    // directly here, and keep validation tools/tests read-only.
    //
    // Schema:
    //   variantOf = "<canonical classname>"; // optional structural relationship
    //   allowedSides[] = {"WEST", "EAST"};
    //   appearanceSide = "WEST" | "EAST" | ""; // optional visual identity
    //   minLevel = <number>;
    //   familyId = "<stable progression root>";
    //   loadoutId = "<stable product ID>";
    //   baseLoadout = 0 | 1;
    //   requiredLoadout = "<logical loadout ID>" | "";
    //   requiredMastery[] = {"counter", amount, ...};
    //   purchasePrice = <durable family ownership price>;
    //   replacementPrice = <later-life requisition price>;
    //   rentalPrice = <one-life rental price>;
    //   rentable = 0 | 1;
    //   replacementCooldownSeconds = <number>;
    //   requiredPerks[] = {...}; // optional
    //   storeCategory = "GROUND" | "SEA" | "ROTARY" | "FIXED_WING";
    //   capabilities[] = {"TRANSPORT", "COMBAT", "CAS", ...};
    //   crossSideEligible = 0; // dormant/default-deny in this release
    //   capturedRequirement = ""; // reserved, dormant
    //   visualProfile = ""; // inert hook; no texture application in this release
    //
    // Progression policy belongs only to canonical physical roots. A structural
    // entry may declare variantOf only and inherits every policy field from its
    // root. Logical family/loadout IDs, not classnames, own durable progression.
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
                rentalPrice = 2000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_RPD";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 1000;
                rentable = 1;
                replacementCooldownSeconds = 120;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-40 (SGM) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_04
            {
                allowedSides[] = {"EAST"};
                minLevel = 35;
                purchasePrice = 18000;
                rentalPrice = 2400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_SGM";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR40_BTR_40_RPD";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 1200;
                rentable = 1;
                replacementCooldownSeconds = 135;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-40 (DShKM) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_02
            {
                allowedSides[] = {"EAST"};
                minLevel = 45;
                purchasePrice = 18000;
                rentalPrice = 2800;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_DSHKM";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR40_BTR_40_SGM";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 1400;
                rentable = 1;
                replacementCooldownSeconds = 150;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-50PK Transport | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_btr50pk_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 55;
                purchasePrice = 32000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR50";
                loadoutId = "PAVN_BTR50_BTR_50PK_TRANSPORT";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 180;
                capabilities[] = {"TRANSPORT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 Transport (M2) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 60;
                purchasePrice = 40000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_M113";
                loadoutId = "PAVN_M113_M113A1_TRANSPORT_M2";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 180;
                capabilities[] = {"TRANSPORT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M60) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_acav_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 70;
                purchasePrice = 40000;
                rentalPrice = 5600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_M113";
                loadoutId = "PAVN_M113_M113A1_ACAV_M60";
                baseLoadout = 0;
                requiredLoadout = "PAVN_M113_M113A1_TRANSPORT_M2";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 2800;
                rentable = 1;
                replacementCooldownSeconds = 195;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M2) | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m113_acav_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 78;
                purchasePrice = 40000;
                rentalPrice = 6400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_M113";
                loadoutId = "PAVN_M113_M113A1_ACAV_M2";
                baseLoadout = 0;
                requiredLoadout = "PAVN_M113_M113A1_ACAV_M60";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 3200;
                rentable = 1;
                replacementCooldownSeconds = 210;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-40 (Type 56 RR) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 82;
                purchasePrice = 18000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_TYPE_56_RR";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR40_BTR_40_DSHKM";
                requiredMastery[] = {};
                replacementPrice = 1800;
                rentable = 1;
                replacementCooldownSeconds = 165;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-40 (Type 53 Mortar) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_06
            {
                allowedSides[] = {"EAST"};
                minLevel = 88;
                purchasePrice = 18000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_TYPE_53_MORTAR";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR40_BTR_40_TYPE_56_RR";
                requiredMastery[] = {"infantryKills", 15};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 180;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M125A1 M29 Mortar | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_m125_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 96;
                purchasePrice = 40000;
                rentalPrice = 7200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_M113";
                loadoutId = "PAVN_M113_M125A1_M29_MORTAR";
                baseLoadout = 0;
                requiredLoadout = "PAVN_M113_M113A1_ACAV_M2";
                requiredMastery[] = {"infantryKills", 15};
                replacementPrice = 3600;
                rentable = 0;
                replacementCooldownSeconds = 225;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-40 (ZPU-4) | factual: EAST / PAVN / Cars (PAVN 68)
            class vn_o_wheeled_btr40_mg_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 105;
                purchasePrice = 18000;
                rentalPrice = 5200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR40";
                loadoutId = "PAVN_BTR40_BTR_40_ZPU_4";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR40_BTR_40_TYPE_53_MORTAR";
                requiredMastery[] = {};
                replacementPrice = 2600;
                rentable = 0;
                replacementCooldownSeconds = 195;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // BTR-50PK SPAAG （ZGU-1） | factual: EAST / PAVN / APCs (PAVN 68)
            class vn_o_armor_btr50pk_02
            {
                allowedSides[] = {"EAST"};
                minLevel = 112;
                purchasePrice = 32000;
                rentalPrice = 6400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_BTR50";
                loadoutId = "PAVN_BTR50_BTR_50PK_SPAAG_ZGU_1";
                baseLoadout = 0;
                requiredLoadout = "PAVN_BTR50_BTR_50PK_TRANSPORT";
                requiredMastery[] = {};
                replacementPrice = 3200;
                rentable = 0;
                replacementCooldownSeconds = 195;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M41A3 Walker Bulldog | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_m41_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 128;
                purchasePrice = 60000;
                rentalPrice = 10000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_M41";
                loadoutId = "PAVN_M41_M41A3_WALKER_BULLDOG";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 5000;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // PT-76A Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_pt76a_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 138;
                purchasePrice = 60000;
                rentalPrice = 9000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_PT76";
                loadoutId = "PAVN_PT76_PT_76A_TANK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 4500;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // PT-76B Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_pt76b_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 148;
                purchasePrice = 60000;
                rentalPrice = 10400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_PT76";
                loadoutId = "PAVN_PT76_PT_76B_TANK";
                baseLoadout = 0;
                requiredLoadout = "PAVN_PT76_PT_76A_TANK";
                requiredMastery[] = {};
                replacementPrice = 5200;
                rentable = 0;
                replacementCooldownSeconds = 315;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Type 63 Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_type63_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 162;
                purchasePrice = 70000;
                rentalPrice = 12000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_TYPE63";
                loadoutId = "PAVN_TYPE63_TYPE_63_TANK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 6000;
                rentable = 1;
                replacementCooldownSeconds = 330;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // OT-54 Flame Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_ot54_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 188;
                purchasePrice = 80000;
                rentalPrice = 14000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_T54";
                loadoutId = "PAVN_T54_OT_54_FLAME_TANK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 7000;
                rentable = 1;
                replacementCooldownSeconds = 360;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // T-54B Tank | factual: EAST / PAVN / Tanks (PAVN 68)
            class vn_o_armor_t54b_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 205;
                purchasePrice = 80000;
                rentalPrice = 15200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "PAVN_T54";
                loadoutId = "PAVN_T54_T_54B_TANK";
                baseLoadout = 0;
                requiredLoadout = "PAVN_T54_OT_54_FLAME_TANK";
                requiredMastery[] = {};
                replacementPrice = 7600;
                rentable = 0;
                replacementCooldownSeconds = 375;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M151A1 Armoured | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 22;
                purchasePrice = 15000;
                rentalPrice = 1600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M151";
                loadoutId = "MACV_M151_M151A1_ARMOURED";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 800;
                rentable = 1;
                replacementCooldownSeconds = 90;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M151A1 Patrol | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 30;
                purchasePrice = 15000;
                rentalPrice = 2000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M151";
                loadoutId = "MACV_M151_M151A1_PATROL";
                baseLoadout = 0;
                requiredLoadout = "MACV_M151_M151A1_ARMOURED";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 1000;
                rentable = 1;
                replacementCooldownSeconds = 105;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M151A1 M2 | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 40;
                purchasePrice = 15000;
                rentalPrice = 2400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M151";
                loadoutId = "MACV_M151_M151A1_M2";
                baseLoadout = 0;
                requiredLoadout = "MACV_M151_M151A1_PATROL";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 1200;
                rentable = 1;
                replacementCooldownSeconds = 120;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 Transport (M2) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 58;
                purchasePrice = 40000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_TRANSPORT_M2";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 180;
                capabilities[] = {"TRANSPORT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M60) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 68;
                purchasePrice = 40000;
                rentalPrice = 5400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_M60";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_TRANSPORT_M2";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 2700;
                rentable = 1;
                replacementCooldownSeconds = 195;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M2) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 76;
                purchasePrice = 40000;
                rentalPrice = 6200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_M2";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_M60";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 3100;
                rentable = 1;
                replacementCooldownSeconds = 210;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M54 Gun Truck (Minigun) | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m54_mg_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 84;
                purchasePrice = 25000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M54";
                loadoutId = "MACV_M54_M54_GUN_TRUCK_MINIGUN";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 1800;
                rentable = 1;
                replacementCooldownSeconds = 150;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M151A1 M40A1 | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 90;
                purchasePrice = 15000;
                rentalPrice = 3200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M151";
                loadoutId = "MACV_M151_M151A1_M40A1";
                baseLoadout = 0;
                requiredLoadout = "MACV_M151_M151A1_M2";
                requiredMastery[] = {};
                replacementPrice = 1600;
                rentable = 1;
                replacementCooldownSeconds = 135;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M1919) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 94;
                purchasePrice = 40000;
                rentalPrice = 6600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_M1919";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_M2";
                requiredMastery[] = {"infantryKills", 15};
                replacementPrice = 3300;
                rentable = 1;
                replacementCooldownSeconds = 225;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M125A1 M29 Mortar | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m125_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 100;
                purchasePrice = 40000;
                rentalPrice = 7000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M125A1_M29_MORTAR";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_M1919";
                requiredMastery[] = {"infantryKills", 20};
                replacementPrice = 3500;
                rentable = 1;
                replacementCooldownSeconds = 240;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M134) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 108;
                purchasePrice = 40000;
                rentalPrice = 7400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_M134";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M125A1_M29_MORTAR";
                requiredMastery[] = {"infantryKills", 25};
                replacementPrice = 3700;
                rentable = 1;
                replacementCooldownSeconds = 255;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (Mk18) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 114;
                purchasePrice = 40000;
                rentalPrice = 7800;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_MK18";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_M134";
                requiredMastery[] = {"infantryKills", 30};
                replacementPrice = 3900;
                rentable = 1;
                replacementCooldownSeconds = 270;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M151A1 TOW | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m151_mg_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 120;
                purchasePrice = 15000;
                rentalPrice = 4000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M151";
                loadoutId = "MACV_M151_M151A1_TOW";
                baseLoadout = 0;
                requiredLoadout = "MACV_M151_M151A1_M40A1";
                requiredMastery[] = {};
                replacementPrice = 2000;
                rentable = 0;
                replacementCooldownSeconds = 150;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M113A1 ACAV (M2/ M40) | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m113_acav_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 126;
                purchasePrice = 40000;
                rentalPrice = 8400;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M113A1_ACAV_M2_M40";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_MK18";
                requiredMastery[] = {};
                replacementPrice = 4200;
                rentable = 1;
                replacementCooldownSeconds = 285;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M55 AA Truck (Quad) | factual: WEST / MACV / Cars (US Army)
            class vn_b_wheeled_m54_mg_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 132;
                purchasePrice = 25000;
                rentalPrice = 4800;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M54";
                loadoutId = "MACV_M54_M55_AA_TRUCK_QUAD";
                baseLoadout = 0;
                requiredLoadout = "MACV_M54_M54_GUN_TRUCK_MINIGUN";
                requiredMastery[] = {};
                replacementPrice = 2400;
                rentable = 0;
                replacementCooldownSeconds = 165;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M132A1 Flamethrower | factual: WEST / MACV / APCs (MACV)
            class vn_b_armor_m132_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 142;
                purchasePrice = 40000;
                rentalPrice = 9200;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M113";
                loadoutId = "MACV_M113_M132A1_FLAMETHROWER";
                baseLoadout = 0;
                requiredLoadout = "MACV_M113_M113A1_ACAV_M2_M40";
                requiredMastery[] = {"infantryKills", 35};
                replacementPrice = 4600;
                rentable = 0;
                replacementCooldownSeconds = 300;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M41A3 Walker Bulldog | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m41_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 155;
                purchasePrice = 60000;
                rentalPrice = 10000;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M41";
                loadoutId = "MACV_M41_M41A3_WALKER_BULLDOG";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 5000;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M67A2 Flame Tank | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m67_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 195;
                purchasePrice = 78000;
                rentalPrice = 13600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M67";
                loadoutId = "MACV_M67_M67A2_FLAME_TANK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 6800;
                rentable = 1;
                replacementCooldownSeconds = 360;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // M48A3 Patton Tank | factual: WEST / MACV / Tanks (Army)
            class vn_b_armor_m48_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 215;
                purchasePrice = 85000;
                rentalPrice = 15600;
                requiredPerks[] = {};
                storeCategory = "GROUND";
                familyId = "MACV_M48";
                loadoutId = "MACV_M48_M48A3_PATTON_TANK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 7800;
                rentable = 1;
                replacementCooldownSeconds = 390;
                capabilities[] = {"COMBAT"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };


            // ROTARY products.
            // Mi-2P Hoplite (Transport) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_01_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 42;
                purchasePrice = 30000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2P_HOPLITE_TRANSPORT";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 1800;
                rentable = 1;
                replacementCooldownSeconds = 210;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2US Hoplite (MG) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_03_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 62;
                purchasePrice = 30000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2US_HOPLITE_MG";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2P_HOPLITE_TRANSPORT";
                requiredMastery[] = {"insertions", 5};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 225;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2URN Viper (HE) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 78;
                purchasePrice = 30000;
                rentalPrice = 5200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2URN_VIPER_HE";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2US_HOPLITE_MG";
                requiredMastery[] = {"insertions", 10};
                replacementPrice = 2600;
                rentable = 1;
                replacementCooldownSeconds = 240;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2URN Viper (APERS) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 88;
                purchasePrice = 30000;
                rentalPrice = 5800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2URN_VIPER_APERS";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2URN_VIPER_HE";
                requiredMastery[] = {"insertions", 15};
                replacementPrice = 2900;
                rentable = 1;
                replacementCooldownSeconds = 255;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2URN Viper (HEAT) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_04_03
            {
                allowedSides[] = {"EAST"};
                minLevel = 100;
                purchasePrice = 30000;
                rentalPrice = 6600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2URN_VIPER_HEAT";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2URN_VIPER_APERS";
                requiredMastery[] = {"insertions", 20};
                replacementPrice = 3300;
                rentable = 1;
                replacementCooldownSeconds = 270;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2URP Salamander (AA) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_05_05
            {
                allowedSides[] = {"EAST"};
                minLevel = 112;
                purchasePrice = 30000;
                rentalPrice = 7400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2URP_SALAMANDER_AA";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2URN_VIPER_HEAT";
                requiredMastery[] = {"insertions", 25};
                replacementPrice = 3700;
                rentable = 1;
                replacementCooldownSeconds = 285;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // Mi-2URP Salamander (AT) | factual: EAST / PAVN / Helicopters (VPAF)
            class vn_o_air_mi2_05_01
            {
                allowedSides[] = {"EAST"};
                minLevel = 126;
                purchasePrice = 30000;
                rentalPrice = 8400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "MI2";
                loadoutId = "MI2_MI_2URP_SALAMANDER_AT";
                baseLoadout = 0;
                requiredLoadout = "MI2_MI_2URP_SALAMANDER_AA";
                requiredMastery[] = {"insertions", 30};
                replacementPrice = 4200;
                rentable = 0;
                replacementCooldownSeconds = 300;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // OH-6A Cayuse | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 35;
                purchasePrice = 15000;
                rentalPrice = 1800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "OH6";
                loadoutId = "OH6_OH_6A_CAYUSE";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 900;
                rentable = 1;
                replacementCooldownSeconds = 180;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // OH-6A Cayuse (Scout MG) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 48;
                purchasePrice = 15000;
                rentalPrice = 2600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "OH6";
                loadoutId = "OH6_OH_6A_CAYUSE_SCOUT_MG";
                baseLoadout = 0;
                requiredLoadout = "OH6_OH_6A_CAYUSE";
                requiredMastery[] = {"insertions", 5};
                replacementPrice = 1300;
                rentable = 1;
                replacementCooldownSeconds = 195;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // OH-6A Cayuse (Gunship/ APERS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 64;
                purchasePrice = 15000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "OH6";
                loadoutId = "OH6_OH_6A_CAYUSE_GUNSHIP_APERS";
                baseLoadout = 0;
                requiredLoadout = "OH6_OH_6A_CAYUSE_SCOUT_MG";
                requiredMastery[] = {"insertions", 10};
                replacementPrice = 1800;
                rentable = 1;
                replacementCooldownSeconds = 210;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // OH-6A Cayuse (Gunship/ AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_oh6a_05
            {
                allowedSides[] = {"WEST"};
                minLevel = 76;
                purchasePrice = 15000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "OH6";
                loadoutId = "OH6_OH_6A_CAYUSE_GUNSHIP_AT";
                baseLoadout = 0;
                requiredLoadout = "OH6_OH_6A_CAYUSE_GUNSHIP_APERS";
                requiredMastery[] = {"insertions", 15};
                replacementPrice = 2200;
                rentable = 0;
                replacementCooldownSeconds = 225;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-34D Seahorse (M60) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 52;
                purchasePrice = 30000;
                rentalPrice = 3600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH34";
                loadoutId = "UH34_UH_34D_SEAHORSE_M60";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 1800;
                rentable = 1;
                replacementCooldownSeconds = 210;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-34D Seahorse (M60 x2) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 66;
                purchasePrice = 30000;
                rentalPrice = 4600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH34";
                loadoutId = "UH34_UH_34D_SEAHORSE_M60_X2";
                baseLoadout = 0;
                requiredLoadout = "UH34_UH_34D_SEAHORSE_M60";
                requiredMastery[] = {"insertions", 5};
                replacementPrice = 2300;
                rentable = 1;
                replacementCooldownSeconds = 225;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-34 Stinger (CAS) | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_ch34_04_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 92;
                purchasePrice = 30000;
                rentalPrice = 7000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH34";
                loadoutId = "UH34_UH_34_STINGER_CAS";
                baseLoadout = 0;
                requiredLoadout = "UH34_UH_34D_SEAHORSE_M60_X2";
                requiredMastery[] = {"insertions", 10};
                replacementPrice = 3500;
                rentable = 0;
                replacementCooldownSeconds = 240;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1E Iroquois Slick | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_03_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 60;
                purchasePrice = 35000;
                rentalPrice = 4400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1E_IROQUOIS_SLICK";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 2200;
                rentable = 1;
                replacementCooldownSeconds = 240;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1E Iroquois Gunship | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_01_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 82;
                purchasePrice = 35000;
                rentalPrice = 5600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1E_IROQUOIS_GUNSHIP";
                baseLoadout = 0;
                requiredLoadout = "UH1_UH_1E_IROQUOIS_SLICK";
                requiredMastery[] = {"insertions", 5};
                replacementPrice = 2800;
                rentable = 1;
                replacementCooldownSeconds = 255;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1E Iroquois Heavy Gunship | factual: WEST / MACV / Helicopters (USMC)
            class vn_b_air_uh1e_02_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 98;
                purchasePrice = 35000;
                rentalPrice = 6800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1E_IROQUOIS_HEAVY_GUNSHIP";
                baseLoadout = 0;
                requiredLoadout = "UH1_UH_1E_IROQUOIS_GUNSHIP";
                requiredMastery[] = {"insertions", 10};
                replacementPrice = 3400;
                rentable = 1;
                replacementCooldownSeconds = 270;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1C Iroquois Gunship (Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_uh1c_02_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 108;
                purchasePrice = 35000;
                rentalPrice = 7800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1C_IROQUOIS_GUNSHIP_ARMY";
                baseLoadout = 0;
                requiredLoadout = "UH1_UH_1E_IROQUOIS_HEAVY_GUNSHIP";
                requiredMastery[] = {"insertions", 15};
                replacementPrice = 3900;
                rentable = 1;
                replacementCooldownSeconds = 285;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // CH-47A Chinook (Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ch47_04_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 118;
                purchasePrice = 40000;
                rentalPrice = 5000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "CH47";
                loadoutId = "CH47_CH_47A_CHINOOK_ARMY";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 2500;
                rentable = 1;
                replacementCooldownSeconds = 270;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // CH-47A Chinook (M60/ Army) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ch47_01_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 132;
                purchasePrice = 40000;
                rentalPrice = 6200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "CH47";
                loadoutId = "CH47_CH_47A_CHINOOK_M60_ARMY";
                baseLoadout = 0;
                requiredLoadout = "CH47_CH_47A_CHINOOK_ARMY";
                requiredMastery[] = {"insertions", 5};
                replacementPrice = 3100;
                rentable = 1;
                replacementCooldownSeconds = 285;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1P Iroquois Hornet | factual: WEST / MACV / Helicopters (USAF)
            class vn_b_air_uh1c_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 145;
                purchasePrice = 35000;
                rentalPrice = 8800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1P_IROQUOIS_HORNET";
                baseLoadout = 0;
                requiredLoadout = "UH1_UH_1C_IROQUOIS_GUNSHIP_ARMY";
                requiredMastery[] = {"insertions", 20};
                replacementPrice = 4400;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // UH-1D Iroquois Bushranger | factual: WEST / Australia / Helicopters (RAAF)
            class vn_b_air_uh1d_03_06
            {
                allowedSides[] = {"WEST"};
                minLevel = 158;
                purchasePrice = 35000;
                rentalPrice = 9600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "UH1";
                loadoutId = "UH1_UH_1D_IROQUOIS_BUSHRANGER";
                baseLoadout = 0;
                requiredLoadout = "UH1_UH_1P_IROQUOIS_HORNET";
                requiredMastery[] = {"insertions", 25};
                replacementPrice = 4800;
                rentable = 0;
                replacementCooldownSeconds = 315;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // ACH-47A Guns-A-Go-Go (AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ach47_03_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 172;
                purchasePrice = 40000;
                rentalPrice = 9200;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "CH47";
                loadoutId = "CH47_ACH_47A_GUNS_A_GO_GO_AT";
                baseLoadout = 0;
                requiredLoadout = "CH47_CH_47A_CHINOOK_M60_ARMY";
                requiredMastery[] = {"insertions", 10};
                replacementPrice = 4600;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // ACH-47A Guns-A-Go-Go (Cannon) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ach47_05_01
            {
                allowedSides[] = {"WEST"};
                minLevel = 188;
                purchasePrice = 40000;
                rentalPrice = 11000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "CH47";
                loadoutId = "CH47_ACH_47A_GUNS_A_GO_GO_CANNON";
                baseLoadout = 0;
                requiredLoadout = "CH47_ACH_47A_GUNS_A_GO_GO_AT";
                requiredMastery[] = {"insertions", 15};
                replacementPrice = 5500;
                rentable = 0;
                replacementCooldownSeconds = 315;
                capabilities[] = {"TRANSPORT", "COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // AH-1G Cobra (APERS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_02
            {
                allowedSides[] = {"WEST"};
                minLevel = 180;
                purchasePrice = 65000;
                rentalPrice = 9600;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "AH1G";
                loadoutId = "AH1G_AH_1G_COBRA_APERS";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 4800;
                rentable = 1;
                replacementCooldownSeconds = 300;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // AH-1G Cobra (AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_03
            {
                allowedSides[] = {"WEST"};
                minLevel = 198;
                purchasePrice = 65000;
                rentalPrice = 10800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "AH1G";
                loadoutId = "AH1G_AH_1G_COBRA_AT";
                baseLoadout = 0;
                requiredLoadout = "AH1G_AH_1G_COBRA_APERS";
                requiredMastery[] = {};
                replacementPrice = 5400;
                rentable = 1;
                replacementCooldownSeconds = 315;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // AH-1G Cobra (CAS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_04
            {
                allowedSides[] = {"WEST"};
                minLevel = 210;
                purchasePrice = 65000;
                rentalPrice = 11800;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "AH1G";
                loadoutId = "AH1G_AH_1G_COBRA_CAS";
                baseLoadout = 0;
                requiredLoadout = "AH1G_AH_1G_COBRA_AT";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 5900;
                rentable = 1;
                replacementCooldownSeconds = 330;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // AH-1G Cobra (M195/AT) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_08
            {
                allowedSides[] = {"WEST"};
                minLevel = 226;
                purchasePrice = 65000;
                rentalPrice = 13000;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "AH1G";
                loadoutId = "AH1G_AH_1G_COBRA_M195_AT";
                baseLoadout = 0;
                requiredLoadout = "AH1G_AH_1G_COBRA_CAS";
                requiredMastery[] = {};
                replacementPrice = 6500;
                rentable = 1;
                replacementCooldownSeconds = 345;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // AH-1G Cobra (M195/CAS) | factual: WEST / MACV / Helicopters (US Army)
            class vn_b_air_ah1g_09
            {
                allowedSides[] = {"WEST"};
                minLevel = 238;
                purchasePrice = 65000;
                rentalPrice = 14400;
                requiredPerks[] = {};
                storeCategory = "ROTARY";
                familyId = "AH1G";
                loadoutId = "AH1G_AH_1G_COBRA_M195_CAS";
                baseLoadout = 0;
                requiredLoadout = "AH1G_AH_1G_COBRA_M195_AT";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 7200;
                rentable = 0;
                replacementCooldownSeconds = 360;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };


            // FIXED_WING products.
            // MiG-19 S (CAP) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_cap
            {
                allowedSides[] = {"EAST"};
                minLevel = 170;
                purchasePrice = 65000;
                rentalPrice = 10000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG19";
                loadoutId = "MIG19_MIG_19_S_CAP";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 5000;
                rentable = 1;
                replacementCooldownSeconds = 360;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-19 S (CAS) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_cas
            {
                allowedSides[] = {"EAST"};
                minLevel = 182;
                purchasePrice = 65000;
                rentalPrice = 11200;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG19";
                loadoutId = "MIG19_MIG_19_S_CAS";
                baseLoadout = 0;
                requiredLoadout = "MIG19_MIG_19_S_CAP";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 5600;
                rentable = 1;
                replacementCooldownSeconds = 375;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-19 S (AT) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_at
            {
                allowedSides[] = {"EAST"};
                minLevel = 194;
                purchasePrice = 65000;
                rentalPrice = 12400;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG19";
                loadoutId = "MIG19_MIG_19_S_AT";
                baseLoadout = 0;
                requiredLoadout = "MIG19_MIG_19_S_CAS";
                requiredMastery[] = {};
                replacementPrice = 6200;
                rentable = 1;
                replacementCooldownSeconds = 390;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-19 S (BMB) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig19_bmb
            {
                allowedSides[] = {"EAST"};
                minLevel = 206;
                purchasePrice = 65000;
                rentalPrice = 13600;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG19";
                loadoutId = "MIG19_MIG_19_S_BMB";
                baseLoadout = 0;
                requiredLoadout = "MIG19_MIG_19_S_AT";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 6800;
                rentable = 0;
                replacementCooldownSeconds = 405;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-21 PFM (CAP) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_cap
            {
                allowedSides[] = {"EAST"};
                minLevel = 214;
                purchasePrice = 80000;
                rentalPrice = 12000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG21";
                loadoutId = "MIG21_MIG_21_PFM_CAP";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 6000;
                rentable = 1;
                replacementCooldownSeconds = 420;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-21 PFM (CAS) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_cas
            {
                allowedSides[] = {"EAST"};
                minLevel = 226;
                purchasePrice = 80000;
                rentalPrice = 13600;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG21";
                loadoutId = "MIG21_MIG_21_PFM_CAS";
                baseLoadout = 0;
                requiredLoadout = "MIG21_MIG_21_PFM_CAP";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 6800;
                rentable = 1;
                replacementCooldownSeconds = 435;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-21 PFM (ATGM) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_atgm
            {
                allowedSides[] = {"EAST"};
                minLevel = 240;
                purchasePrice = 80000;
                rentalPrice = 15200;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG21";
                loadoutId = "MIG21_MIG_21_PFM_ATGM";
                baseLoadout = 0;
                requiredLoadout = "MIG21_MIG_21_PFM_CAS";
                requiredMastery[] = {};
                replacementPrice = 7600;
                rentable = 1;
                replacementCooldownSeconds = 450;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // MiG-21 PFM (HBMB) | factual: EAST / PAVN / Planes (VPAF)
            class vn_o_air_mig21_hbmb
            {
                allowedSides[] = {"EAST"};
                minLevel = 258;
                purchasePrice = 80000;
                rentalPrice = 17000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "MIG21";
                loadoutId = "MIG21_MIG_21_PFM_HBMB";
                baseLoadout = 0;
                requiredLoadout = "MIG21_MIG_21_PFM_ATGM";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 8500;
                rentable = 0;
                replacementCooldownSeconds = 465;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-100D (CAP) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_cap
            {
                allowedSides[] = {"WEST"};
                minLevel = 168;
                purchasePrice = 70000;
                rentalPrice = 10400;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F100D";
                loadoutId = "F100D_F_100D_CAP";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 5200;
                rentable = 1;
                replacementCooldownSeconds = 390;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-100D (CAS) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_cas
            {
                allowedSides[] = {"WEST"};
                minLevel = 184;
                purchasePrice = 70000;
                rentalPrice = 11800;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F100D";
                loadoutId = "F100D_F_100D_CAS";
                baseLoadout = 0;
                requiredLoadout = "F100D_F_100D_CAP";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 5900;
                rentable = 1;
                replacementCooldownSeconds = 405;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-100D (AT) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_at
            {
                allowedSides[] = {"WEST"};
                minLevel = 198;
                purchasePrice = 70000;
                rentalPrice = 13200;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F100D";
                loadoutId = "F100D_F_100D_AT";
                baseLoadout = 0;
                requiredLoadout = "F100D_F_100D_CAS";
                requiredMastery[] = {};
                replacementPrice = 6600;
                rentable = 1;
                replacementCooldownSeconds = 420;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-100D (SEAD) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f100d_sead
            {
                allowedSides[] = {"WEST"};
                minLevel = 218;
                purchasePrice = 70000;
                rentalPrice = 14800;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F100D";
                loadoutId = "F100D_F_100D_SEAD";
                baseLoadout = 0;
                requiredLoadout = "F100D_F_100D_AT";
                requiredMastery[] = {};
                replacementPrice = 7400;
                rentable = 0;
                replacementCooldownSeconds = 435;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4B Phantom II (CAP) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_cap
            {
                allowedSides[] = {"WEST"};
                minLevel = 220;
                purchasePrice = 90000;
                rentalPrice = 13000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4B_PHANTOM_II_CAP";
                baseLoadout = 1;
                requiredLoadout = "";
                requiredMastery[] = {};
                replacementPrice = 6500;
                rentable = 1;
                replacementCooldownSeconds = 480;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4B Phantom II (AT) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_at
            {
                allowedSides[] = {"WEST"};
                minLevel = 232;
                purchasePrice = 90000;
                rentalPrice = 14400;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4B_PHANTOM_II_AT";
                baseLoadout = 0;
                requiredLoadout = "F4_F_4B_PHANTOM_II_CAP";
                requiredMastery[] = {};
                replacementPrice = 7200;
                rentable = 1;
                replacementCooldownSeconds = 495;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4B Phantom II (SEAD) | factual: WEST / MACV / Planes (US Navy)
            class vn_b_air_f4b_navy_sead
            {
                allowedSides[] = {"WEST"};
                minLevel = 246;
                purchasePrice = 90000;
                rentalPrice = 15600;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4B_PHANTOM_II_SEAD";
                baseLoadout = 0;
                requiredLoadout = "F4_F_4B_PHANTOM_II_AT";
                requiredMastery[] = {};
                replacementPrice = 7800;
                rentable = 1;
                replacementCooldownSeconds = 510;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4C Phantom II (CAS) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_cas
            {
                allowedSides[] = {"WEST"};
                minLevel = 228;
                purchasePrice = 90000;
                rentalPrice = 14800;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4C_PHANTOM_II_CAS";
                baseLoadout = 0;
                requiredLoadout = "F4_F_4B_PHANTOM_II_SEAD";
                requiredMastery[] = {"infantryKills", 5};
                replacementPrice = 7400;
                rentable = 1;
                replacementCooldownSeconds = 525;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4C Phantom II (GBU) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_gbu
            {
                allowedSides[] = {"WEST"};
                minLevel = 252;
                purchasePrice = 90000;
                rentalPrice = 17000;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4C_PHANTOM_II_GBU";
                baseLoadout = 0;
                requiredLoadout = "F4_F_4C_PHANTOM_II_CAS";
                requiredMastery[] = {"infantryKills", 10};
                replacementPrice = 8500;
                rentable = 1;
                replacementCooldownSeconds = 540;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

            // F-4C Phantom II (CHICO) | factual: WEST / MACV / Planes (USAF)
            class vn_b_air_f4c_chico
            {
                allowedSides[] = {"WEST"};
                minLevel = 265;
                purchasePrice = 90000;
                rentalPrice = 18400;
                requiredPerks[] = {};
                storeCategory = "FIXED_WING";
                familyId = "F4";
                loadoutId = "F4_F_4C_PHANTOM_II_CHICO";
                baseLoadout = 0;
                requiredLoadout = "F4_F_4C_PHANTOM_II_GBU";
                requiredMastery[] = {"infantryKills", 15};
                replacementPrice = 9200;
                rentable = 0;
                replacementCooldownSeconds = 555;
                capabilities[] = {"COMBAT", "CAS"};
                crossSideEligible = 0;
                capturedRequirement = "";
                visualProfile = "";
            };

        };
    };
};

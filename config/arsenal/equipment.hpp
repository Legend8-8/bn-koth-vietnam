class CfgBnKothArsenal
{
    class Loadouts
    {
        class starter_west
        {
            side = "WEST";
            source = "UNIT_CLASS_TEMPLATE";
            unitClass = "vn_b_men_sog_07";
            starter = 1;
            category = "starter";

            primaryWeapon = "vn_m1903";
            primaryMagazineCount = 4;
            primaryMagazineContainer = "vest";
            primaryAttachments[] = {};

            handgunWeapon = "vn_m1911";
            handgunMagazineCount = 1;
            handgunMagazineContainer = "vest";
            handgunAttachments[] = {};

            launcherWeapon = "";
            launcherMagazineCount = 0;
            launcherMagazineContainer = "backpack";
            launcherAttachments[] = {};

            uniform = "vn_b_uniform_aus_01_01";
            vest = "vn_b_vest_sog_04";
            backpack = "";
            headgear = "";
            facewear = "";
            binocular = "";

            cargo[] = {
                {"vn_b_item_firstaidkit", 2, "uniform"}
            };

            // Arma assigned-item order: map, GPS/terminal, radio, compass, watch, NVG.
            assignedItems[] = {
                "vn_b_item_map",
                "",
                "vn_b_item_radio_urc10",
                "vn_b_item_compass_sog",
                "vn_b_item_watch",
                ""
            };
        };

        class starter_east
        {
            side = "EAST";
            source = "UNIT_CLASS_TEMPLATE";
            unitClass = "vn_o_men_nva_04";
            starter = 1;
            category = "starter";

            primaryWeapon = "vn_k98k";
            primaryMagazineCount = 4;
            primaryMagazineContainer = "vest";
            primaryAttachments[] = {};

            handgunWeapon = "vn_pm";
            handgunMagazineCount = 1;
            handgunMagazineContainer = "vest";
            handgunAttachments[] = {};

            launcherWeapon = "";
            launcherMagazineCount = 0;
            launcherMagazineContainer = "backpack";
            launcherAttachments[] = {};

            uniform = "vn_o_uniform_nva_army_03_03";
            vest = "vn_o_vest_01";
            backpack = "";
            headgear = "";
            facewear = "";
            binocular = "";

            cargo[] = {
                {"vn_o_item_firstaidkit", 2, "uniform"}
            };

            // Arma assigned-item order: map, GPS/terminal, radio, compass, watch, NVG.
            assignedItems[] = {
                "vn_o_item_map",
                "",
                "vn_o_item_radio_m252",
                "vn_b_item_compass_sog",
                "vn_b_item_watch",
                ""
            };
        };
    };

    class Equipment
    {
        // Human-authored KOTH progression/balance metadata.
        //
        // Generated S.O.G. sourceAffiliations are factual evidence only and
        // must never be used as KOTH faction entitlement.
        //
        // Schema for KOTH progression/balance metadata entries:
        //   nativeSide = "WEST" | "EAST";
        //   minLevel = <number>;
        //   licenseKills = <number>;
        //   purchasePrice = <number>;   // optional until economy is implemented
        //   rentalPrice = <number>;     // optional until economy is implemented
        //   requiredPerks[] = {...};    // optional; progression owns perk state
        //
        // Structural variants do not receive separate progression metadata.
        // Runtime lookup resolves them to their canonical base weapon first.
        class Metadata
        {
            class Weapons
            {
                // First progression seed from the agreed design example.
                class vn_l1a1_01
                {
                    nativeSide = "WEST";
                    minLevel = 20;
                    licenseKills = 50;
                    requiredPerks[] = {};
                };
            };

            // Human-authored future KOTH balance namespaces only. They remain
            // deliberately empty until individual balance decisions are made.
            class Attachments {};
            class Wearables {};
            class Consumables {};
        };

        // Intentionally tiny, reviewable seed catalogue.
        class Items
        {
            class vn_b_men_sog_07
            {
                category = "unit_template";
                allowedSides[] = {"WEST"};
                starter = 1;
            };

            class vn_o_men_nva_04
            {
                category = "unit_template";
                allowedSides[] = {"EAST"};
                starter = 1;
            };
        };

        // Future generated factual compatibility data attaches here.
        class Compatibility
        {
            #include "generated\sog_catalogue.hpp"
        };
    };
};

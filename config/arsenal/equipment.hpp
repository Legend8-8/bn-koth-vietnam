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
        // Schema for human-authored KOTH equipment policy/progression entries:
        //   allowedSides[] = {"WEST", "EAST"}; // gameplay availability
        //   appearanceSide = "WEST" | "EAST" | ""; // visual identity
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
                // Canonical logical-weapon side policy. Structural variants
                // inherit these entries through canonical metadata lookup.
                class vn_ak_01 {allowedSides[] = {"EAST"};};
                class vn_dp28 {allowedSides[] = {"EAST"};};
                class vn_f1_smg {allowedSides[] = {"WEST"};};
                // vn_fkb1_pm remains unconfigured pending manual review.
                class vn_gau5a {allowedSides[] = {"WEST"};};
                class vn_hd {allowedSides[] = {"WEST"};};
                class vn_hp {allowedSides[] = {"WEST"};};
                class vn_izh54 {allowedSides[] = {"EAST"};};
                class vn_k50m {allowedSides[] = {"EAST"};};
                class vn_k98k {allowedSides[] = {"EAST"};};
                class vn_kbkg {allowedSides[] = {"EAST"};};
                class vn_l1a1_01
                {
                    allowedSides[] = {"WEST"};
                    minLevel = 20;
                    licenseKills = 50;
                    requiredPerks[] = {};
                };
                class vn_l2a1_01 {allowedSides[] = {"WEST"};};
                class vn_l2a3 {allowedSides[] = {"WEST"};};
                class vn_l34a1 {allowedSides[] = {"WEST"};};
                class vn_l4 {allowedSides[] = {"WEST"};};
                class vn_m10 {allowedSides[] = {"WEST"};};
                class vn_m127 {allowedSides[] = {"WEST"};};
                class vn_m14 {allowedSides[] = {"WEST"};};
                class vn_m14a1 {allowedSides[] = {"WEST"};};
                class vn_m16 {allowedSides[] = {"WEST"};};
                class vn_m16_usaf {allowedSides[] = {"WEST"};};
                class vn_m1891 {allowedSides[] = {"EAST"};};
                class vn_m1895 {allowedSides[] = {"EAST"};};
                class vn_m1897 {allowedSides[] = {"WEST"};};
                class vn_m1903 {allowedSides[] = {"WEST"};};
                class vn_m1911 {allowedSides[] = {"WEST"};};
                class vn_m1918 {allowedSides[] = {"WEST"};};
                class vn_m1928_tommy {allowedSides[] = {"WEST"};};
                class vn_m1928a1_tommy {allowedSides[] = {"WEST"};};
                class vn_m1_garand {allowedSides[] = {"WEST"};};
                class vn_m1a1_tommy {allowedSides[] = {"WEST"};};
                class vn_m1carbine {allowedSides[] = {"WEST", "EAST"};};
                class vn_m1carbine_shorty {allowedSides[] = {"WEST"};};
                class vn_m20a1b1_01 {allowedSides[] = {"WEST"};};
                class vn_m21 {allowedSides[] = {"WEST"};};
                class vn_m2carbine {allowedSides[] = {"WEST"};};
                class vn_m36 {allowedSides[] = {"EAST"};};
                class vn_m38 {allowedSides[] = {"EAST"};};
                class vn_m3a1 {allowedSides[] = {"WEST", "EAST"};};
                class vn_m3carbine {allowedSides[] = {"WEST"};};
                class vn_m40a1 {allowedSides[] = {"WEST"};};
                class vn_m45 {allowedSides[] = {"WEST"};};
                class vn_m4956 {allowedSides[] = {"EAST"};};
                class vn_m60 {allowedSides[] = {"WEST"};};
                class vn_m63a {allowedSides[] = {"WEST"};};
                class vn_m63a_cdo {allowedSides[] = {"WEST"};};
                class vn_m63a_lmg {allowedSides[] = {"WEST"};};
                class vn_m712 {allowedSides[] = {"EAST"};};
                class vn_m72 {allowedSides[] = {"WEST"};};
                class vn_m79 {allowedSides[] = {"WEST", "EAST"};};
                class vn_m9130 {allowedSides[] = {"EAST"};};
                class vn_mat49 {allowedSides[] = {"WEST"};};
                class vn_mat49_vc {allowedSides[] = {"EAST"};};
                class vn_mc10 {allowedSides[] = {"WEST"};};
                class vn_mg42 {allowedSides[] = {"EAST"};};
                class vn_mk1_udg {allowedSides[] = {"WEST"};};
                class vn_mk22 {allowedSides[] = {"WEST"};};
                class vn_mp40 {allowedSides[] = {"EAST"};};
                class vn_mpu {allowedSides[] = {"WEST"};};
                class vn_mx991_m1911 {allowedSides[] = {"WEST"};};
                class vn_p38 {allowedSides[] = {"EAST"};};
                class vn_p38s {allowedSides[] = {"WEST"};};
                class vn_pk {allowedSides[] = {"EAST"};};
                class vn_pm {allowedSides[] = {"EAST"};};
                class vn_ppk {allowedSides[] = {"EAST"};};
                class vn_pps43 {allowedSides[] = {"EAST"};};
                class vn_pps52 {allowedSides[] = {"EAST"};};
                class vn_ppsh41 {allowedSides[] = {"EAST"};};
                class vn_rpd {allowedSides[] = {"WEST", "EAST"};};
                class vn_rpg2 {allowedSides[] = {"WEST", "EAST"};};
                class vn_rpg7 {allowedSides[] = {"EAST"};};
                class vn_sa7 {allowedSides[] = {"EAST"};};
                class vn_sa7b {allowedSides[] = {"EAST"};};
                class vn_sks {allowedSides[] = {"EAST"};};
                class vn_sten {allowedSides[] = {"WEST"};};
                class vn_svd {allowedSides[] = {"EAST"};};
                class vn_tt33 {allowedSides[] = {"EAST"};};
                class vn_type56 {allowedSides[] = {"WEST", "EAST"};};
                class vn_type64 {allowedSides[] = {"EAST"};};
                // Intentional KOTH balance override: the factual catalogue
                // reports WEST provenance, while gameplay assigns this
                // integral-suppressed Chinese SMG to EAST for capability parity.
                class vn_type64_smg {allowedSides[] = {"EAST"};};
                class vn_vz54 {allowedSides[] = {"EAST"};};
                class vn_vz61 {allowedSides[] = {"EAST"};};
                class vn_welrod {allowedSides[] = {"WEST"};};
                class vn_xm16e1 {allowedSides[] = {"WEST"};};
                class vn_xm177 {allowedSides[] = {"WEST"};};
                class vn_xm177e1 {allowedSides[] = {"WEST"};};
            };

            class Attachments {};
            class Wearables
            {
                // Starter appearance seeds. Unclassified visual equipment is
                // intentionally rejected until a human assigns appearanceSide.
                class vn_b_uniform_aus_01_01
                {
                    allowedSides[] = {"WEST"};
                    appearanceSide = "WEST";
                };
                class vn_b_vest_sog_04
                {
                    allowedSides[] = {"WEST"};
                    appearanceSide = "WEST";
                };
                class vn_o_uniform_nva_army_03_03
                {
                    allowedSides[] = {"EAST"};
                    appearanceSide = "EAST";
                };
                class vn_o_vest_01
                {
                    allowedSides[] = {"EAST"};
                    appearanceSide = "EAST";
                };
            };
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

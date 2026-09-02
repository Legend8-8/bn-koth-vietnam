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

            primaryWeapon = "vn_m3a1";
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
                {"vn_b_item_firstaidkit", 2, "uniform"},
                {"vn_m61_grenade_mag", 3, "vest"},
                {"vn_m18_white_mag", 2, "vest"}
            };

            // Arma assigned-item order: map, GPS/terminal, radio, compass, watch, NVG.
            assignedItems[] = {
                "vn_b_item_map",
                "ItemGPS",
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

            primaryWeapon = "vn_pps43";
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
                {"vn_o_item_firstaidkit", 2, "uniform"},
                {"vn_rgd5_grenade_mag", 3, "vest"},
                {"vn_rdg2_mag", 2, "vest"}
            };

            // Arma assigned-item order: map, GPS/terminal, radio, compass, watch, NVG.
            assignedItems[] = {
                "vn_o_item_map",
                "ItemGPS",
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
        //   crossSideAllowed = 1; // explicit weapon-only mastery path
        //   appearanceSide = "WEST" | "EAST" | "BOTH" | ""; // visual identity
        //     BOTH is a provisional headgear-only exception; uniforms, vests
        //     and backpacks must always author WEST or EAST, never BOTH.
        //   minLevel = <number>;
        //   masteryKillsRequired = <number>; // weapons only; never appearance
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
                //
                // Mastery targets are deliberately coarse, round-number goals:
                // higher-level weapons generally require more kills, while
                // pistols/precision/specialist launchers are adjusted for kill rate
                // and high-volume support weapons are slightly more demanding.

                class vn_ak_01
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 30;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_dp28
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 45;
                    masteryKillsRequired = 120;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_f1_smg
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 20;
                    masteryKillsRequired = 60;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                // vn_fkb1_pm remains unconfigured pending manual review.
                class vn_gau5a
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 55;
                    masteryKillsRequired = 90;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_hd
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 85;
                    masteryKillsRequired = 120;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_hp
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 12;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_izh54
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 25;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_k50m
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 20;
                    masteryKillsRequired = 60;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_k98k
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_kbkg
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 38;
                    masteryKillsRequired = 90;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_l1a1_01
                {
                };

                class vn_l2a1_01
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 65;
                    masteryKillsRequired = 150;
                    purchasePrice = 3500;
                    rentalPrice = 700;
                };

                class vn_l2a3
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 22;
                    masteryKillsRequired = 60;
                    purchasePrice = 1250;
                    rentalPrice = 250;
                };

                class vn_l34a1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 70;
                    masteryKillsRequired = 90;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_l4
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 80;
                    masteryKillsRequired = 180;
                    purchasePrice = 4000;
                    rentalPrice = 800;
                };

                class vn_m10
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 8;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_m127
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 25;
                    masteryKillsRequired = 60;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_m14
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 40;
                    masteryKillsRequired = 90;
                    purchasePrice = 2000;
                    rentalPrice = 400;
                };

                class vn_m14a1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 58;
                    masteryKillsRequired = 90;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_m16
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 35;
                    masteryKillsRequired = 60;
                    purchasePrice = 1750;
                    rentalPrice = 350;
                };

                class vn_m16_usaf
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 45;
                    masteryKillsRequired = 90;
                    purchasePrice = 2000;
                    rentalPrice = 400;
                };

                class vn_m1891
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 12;
                    masteryKillsRequired = 30;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_m1895
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 12;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_m1897
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 30;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_m1903
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_m1911
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_m1918
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 40;
                    masteryKillsRequired = 120;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_m1928_tommy
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 18;
                    masteryKillsRequired = 30;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_m1928a1_tommy
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 30;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_m1_garand
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 18;
                    masteryKillsRequired = 30;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_m1a1_tommy
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 42;
                    masteryKillsRequired = 90;
                    purchasePrice = 2000;
                    rentalPrice = 400;
                };

                class vn_m1carbine
                {
                    allowedSides[] = {"WEST", "EAST"};
                    minLevel = 10;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_m1carbine_shorty
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 90;
                    masteryKillsRequired = 150;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_m20a1b1_01
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 180;
                    masteryKillsRequired = 270;
                    purchasePrice = 6500;
                    rentalPrice = 1300;
                };

                class vn_m21
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 150;
                    masteryKillsRequired = 210;
                    purchasePrice = 6000;
                    rentalPrice = 1200;
                };

                class vn_m2carbine
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 25;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_m36
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 18;
                    masteryKillsRequired = 30;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_m38
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 15;
                    masteryKillsRequired = 30;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_m3a1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_m3carbine
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 175;
                    masteryKillsRequired = 240;
                    purchasePrice = 6500;
                    rentalPrice = 1300;
                };

                class vn_m40a1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 125;
                    masteryKillsRequired = 180;
                    purchasePrice = 5000;
                    rentalPrice = 1000;
                };

                class vn_m45
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 30;
                    masteryKillsRequired = 30;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_m4956
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 35;
                    masteryKillsRequired = 60;
                    purchasePrice = 1750;
                    rentalPrice = 350;
                };

                class vn_m60
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 120;
                    masteryKillsRequired = 240;
                    purchasePrice = 5000;
                    rentalPrice = 1000;
                };

                class vn_m63a
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 65;
                    masteryKillsRequired = 120;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_m63a_cdo
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 100;
                    masteryKillsRequired = 180;
                    purchasePrice = 4000;
                    rentalPrice = 800;
                };

                class vn_m63a_lmg
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 135;
                    masteryKillsRequired = 240;
                    purchasePrice = 5500;
                    rentalPrice = 1100;
                };

                class vn_m712
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 32;
                    masteryKillsRequired = 30;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_m72
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 70;
                    masteryKillsRequired = 60;
                    purchasePrice = 3500;
                    rentalPrice = 700;
                };

                class vn_m79
                {
                    allowedSides[] = {"WEST", "EAST"};
                    minLevel = 45;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_m9130
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 32;
                    masteryKillsRequired = 30;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_mat49
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 28;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_mat49_vc
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 28;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_mc10
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 45;
                    masteryKillsRequired = 90;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_mg42
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 95;
                    masteryKillsRequired = 180;
                    purchasePrice = 4500;
                    rentalPrice = 900;
                };

                class vn_mk1_udg
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 160;
                    masteryKillsRequired = 240;
                    purchasePrice = 6000;
                    rentalPrice = 1200;
                };

                class vn_mk22
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 85;
                    masteryKillsRequired = 150;
                    purchasePrice = 3500;
                    rentalPrice = 700;
                };

                class vn_mp40
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 18;
                    masteryKillsRequired = 30;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_mpu
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 50;
                    masteryKillsRequired = 90;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_mx991_m1911
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 25;
                    masteryKillsRequired = 30;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_p38
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 25;
                    masteryKillsRequired = 30;
                    purchasePrice = 1250;
                    rentalPrice = 250;
                };

                class vn_p38s
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 6;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_pk
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 115;
                    masteryKillsRequired = 210;
                    purchasePrice = 5000;
                    rentalPrice = 1000;
                };

                class vn_pm
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_ppk
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 8;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_pps43
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 1;
                    masteryKillsRequired = 30;
                };

                class vn_pps52
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 18;
                    masteryKillsRequired = 30;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_ppsh41
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 22;
                    masteryKillsRequired = 60;
                    purchasePrice = 1250;
                    rentalPrice = 250;
                };

                class vn_rpd
                {
                    allowedSides[] = {"WEST", "EAST"};
                    minLevel = 70;
                    purchasePrice = 3500;
                    rentalPrice = 700;
                };

                class vn_rpg2
                {
                    allowedSides[] = {"WEST", "EAST"};
                    minLevel = 55;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_rpg7
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 75;
                    masteryKillsRequired = 60;
                    purchasePrice = 4000;
                    rentalPrice = 800;
                };

                class vn_sa7
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 170;
                    masteryKillsRequired = 180;
                    purchasePrice = 7000;
                    rentalPrice = 1400;
                };

                class vn_sa7b
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 210;
                    masteryKillsRequired = 210;
                    purchasePrice = 8000;
                    rentalPrice = 1600;
                };

                class vn_sks
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 20;
                    masteryKillsRequired = 60;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_sten
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 15;
                    masteryKillsRequired = 30;
                    purchasePrice = 750;
                    rentalPrice = 150;
                };

                class vn_svd
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 110;
                    masteryKillsRequired = 150;
                    purchasePrice = 4500;
                    rentalPrice = 900;
                };

                class vn_tt33
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 5;
                    masteryKillsRequired = 30;
                    purchasePrice = 500;
                    rentalPrice = 100;
                };

                class vn_type56
                {
                    allowedSides[] = {"WEST", "EAST"};
                    minLevel = 28;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_type64
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 80;
                    masteryKillsRequired = 150;
                    purchasePrice = 1250;
                    rentalPrice = 250;
                };

                // Intentional KOTH balance override: the factual catalogue
                // reports WEST provenance, while gameplay assigns this
                // integral-suppressed Chinese SMG to EAST for capability parity.
                class vn_type64_smg
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 70;
                    masteryKillsRequired = 120;
                    purchasePrice = 3000;
                    rentalPrice = 600;
                };

                class vn_vz54
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 75;
                    masteryKillsRequired = 90;
                    purchasePrice = 3500;
                    rentalPrice = 700;
                };

                class vn_vz61
                {
                    allowedSides[] = {"EAST"};
                    crossSideAllowed = 1;
                    minLevel = 35;
                    masteryKillsRequired = 60;
                    purchasePrice = 1000;
                    rentalPrice = 200;
                };

                class vn_welrod
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 95;
                    masteryKillsRequired = 120;
                    purchasePrice = 2000;
                    rentalPrice = 400;
                };

                class vn_xm16e1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 28;
                    masteryKillsRequired = 60;
                    purchasePrice = 1500;
                    rentalPrice = 300;
                };

                class vn_xm177
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 60;
                    masteryKillsRequired = 120;
                    purchasePrice = 2500;
                    rentalPrice = 500;
                };

                class vn_xm177e1
                {
                    allowedSides[] = {"WEST"};
                    crossSideAllowed = 1;
                    minLevel = 50;
                    masteryKillsRequired = 90;
                    purchasePrice = 2250;
                    rentalPrice = 450;
                };

            };
            class Attachments
            {
                class vn_b_camo_k98k {minLevel = 6;};
                class vn_b_camo_m14 {minLevel = 45;};
                class vn_b_camo_m14a1 {minLevel = 63;};
                class vn_b_camo_m1_garand {minLevel = 23;};
                class vn_b_camo_m36 {minLevel = 23;};
                class vn_b_camo_m40a1 {minLevel = 130;};
                class vn_b_camo_svd {minLevel = 130;};
                class vn_b_camo_vz54 {minLevel = 80;};
                class vn_b_carbine {minLevel = 15;};
                class vn_b_k98k {minLevel = 6;};
                class vn_b_l1a1 {minLevel = 25;};
                class vn_b_m14 {minLevel = 45;};
                class vn_b_m16 {minLevel = 35;};
                class vn_b_m1897 {minLevel = 35;};
                class vn_b_m1903 {minLevel = 6;};
                class vn_b_m1_garand {minLevel = 23;};
                class vn_b_m36 {minLevel = 23;};
                class vn_b_m38 {minLevel = 20;};
                class vn_b_m4956 {minLevel = 40;};
                class vn_b_sks {minLevel = 25;};
                class vn_b_type56 {minLevel = 33;};
                class vn_bipod_m14 {minLevel = 68;};
                class vn_bipod_m16 {minLevel = 45;};
                class vn_bipod_m1918 {minLevel = 50;};
                class vn_bipod_m63a {minLevel = 110;};
                class vn_o_1_5x_k98k {minLevel = 12;};
                class vn_o_1x_sp_m16 {minLevel = 65;};
                class vn_o_3x_l1a1 {minLevel = 35;};
                class vn_o_3x_m84 {minLevel = 30;};
                class vn_o_3x_m9130 {minLevel = 38;};
                class vn_o_3x_sks {minLevel = 35;};
                class vn_o_3x_vz54 {minLevel = 85;};
                class vn_o_4x_m16 {minLevel = 50;};
                class vn_o_4x_m4956 {minLevel = 50;};
                class vn_o_4x_svd {minLevel = 135;};
                class vn_o_8x_m1903 {minLevel = 55;};
                class vn_o_9x_m14 {minLevel = 85;};
                class vn_o_9x_m16 {minLevel = 75;};
                class vn_o_9x_m40a1 {minLevel = 145;};
                class vn_o_anpvs2_m14 {minLevel = 120;};
                class vn_o_anpvs2_m16 {minLevel = 110;};
                class vn_o_anpvs2_m40a1 {minLevel = 175;};
                class vn_o_m14_front {minLevel = 63;};
                class vn_s_hp {minLevel = 40;};
                class vn_s_m14 {minLevel = 95;};
                class vn_s_m16 {minLevel = 70;};
                class vn_s_m1895 {minLevel = 40;};
                class vn_s_m1911 {minLevel = 35;};
                class vn_s_m3a1 {minLevel = 45;};
                class vn_s_m45_camo {minLevel = 65;};
                class vn_s_mat49 {minLevel = 65;};
                class vn_s_mc10 {minLevel = 75;};
                class vn_s_mk22 {minLevel = 105;};
                class vn_s_mpu {minLevel = 80;};
                class vn_s_pm {minLevel = 35;};
                class vn_s_ppk {minLevel = 45;};
                class vn_s_sten {minLevel = 45;};
            };
            class Wearables
            {
                #include "wearables.hpp"
            };
            class Consumables
            {
                class vn_m18_white_mag {allowedSides[] = {"WEST"}; minLevel = 1;};
                class vn_m61_grenade_mag {allowedSides[] = {"WEST"}; minLevel = 1;};
                class vn_rdg2_mag {allowedSides[] = {"EAST"}; minLevel = 1;};
                class vn_rgd5_grenade_mag {allowedSides[] = {"EAST"}; minLevel = 1;};
            };
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

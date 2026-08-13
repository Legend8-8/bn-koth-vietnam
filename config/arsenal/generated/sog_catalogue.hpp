// MACHINE GENERATED FILE - DO NOT EDIT BY HAND.
// Source: data/generated/sog_catalogue.json
// Generator: python -m tools.sog_catalogue.generate_runtime_config
// This file is included under CfgBnKothArsenal > Equipment > Compatibility.

    class SourceWeapons
    {
        class vn_ak_01
        {
            className = "vn_ak_01";
            displayName = "AK";
            weaponType = "rifle";
            family = "ak";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_dp28
        {
            className = "vn_dp28";
            displayName = "DP-27";
            weaponType = "lmg";
            family = "dp28";
            baseMagazine = "vn_dp28_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_dp28_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_f1_smg
        {
            className = "vn_f1_smg";
            displayName = "F1 SMG";
            weaponType = "smg";
            family = "f1_smg";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_f1_smg_bayo
        {
            className = "vn_f1_smg_bayo";
            displayName = "F1 SMG (Bayo)";
            weaponType = "smg";
            family = "f1_smg";
            variantOf = "vn_f1_smg";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_l1a1", "vn_f1_smg"};
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
            compatibleAttachments[] = {"vn_b_l1a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_fkb1_pm
        {
            className = "vn_fkb1_pm";
            displayName = "PM (Flashlight)";
            weaponType = "handgun";
            family = "fkb1_pm";
            baseMagazine = "vn_pm_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pm_mag"};
        };
        class vn_fkb1_pm_sd
        {
            className = "vn_fkb1_pm_sd";
            displayName = "PM (S/ Flashlight)";
            weaponType = "handgun";
            family = "fkb1_pm";
            variantOf = "vn_fkb1_pm";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_fkb1_pm", "vn_s_pm"};
            baseMagazine = "vn_pm_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pm_mag"};
            compatibleAttachments[] = {"vn_s_pm"};
        };
        class vn_gau5a
        {
            className = "vn_gau5a";
            displayName = "GAU-5A/A";
            weaponType = "rifle";
            family = "gau5a";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_gau5a_mrk
        {
            className = "vn_gau5a_mrk";
            displayName = "GAU-5A/A (SP Optic)";
            weaponType = "rifle";
            family = "gau5a";
            variantOf = "vn_gau5a";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_gau5a", "vn_o_1x_sp_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_1x_sp_m16"};
        };
        class vn_hd
        {
            className = "vn_hd";
            displayName = "HD (S)";
            weaponType = "handgun";
            family = "hd";
            baseMagazine = "vn_hd_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_hd_mag"};
        };
        class vn_hp
        {
            className = "vn_hp";
            displayName = "HP automatic";
            weaponType = "handgun";
            family = "hp";
            baseMagazine = "vn_hp_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_hp_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_hp_sd
        {
            className = "vn_hp_sd";
            displayName = "HP (S)";
            weaponType = "handgun";
            family = "hp";
            variantOf = "vn_hp";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_hp", "vn_s_hp"};
            baseMagazine = "vn_hp_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_hp_mag"};
            compatibleAttachments[] = {"vn_s_hp"};
        };
        class vn_izh54
        {
            className = "vn_izh54";
            displayName = "ISh-54";
            weaponType = "shotgun";
            family = "izh54";
            baseMagazine = "vn_izh54_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_izh54_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_izh54_p
        {
            className = "vn_izh54_p";
            displayName = "ISh-54 (Sidearm)";
            weaponType = "handgun";
            family = "izh54";
            baseMagazine = "vn_izh54_mag";
            baseMagazineConfidence = "family";
            compatibleMagazines[] = {"vn_izh54_mag", "vn_izh54_so_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_izh54_shorty
        {
            className = "vn_izh54_shorty";
            displayName = "ISh-54 (Sawn-off)";
            weaponType = "shotgun";
            family = "izh54";
            baseMagazine = "vn_izh54_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_izh54_mag", "vn_izh54_so_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_k50m
        {
            className = "vn_k50m";
            displayName = "K-50M";
            weaponType = "smg";
            family = "k50m";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_ppsh41_35_mag", "vn_ppsh41_35_t_mag", "vn_ppsh41_71_mag", "vn_ppsh41_71_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_k98k
        {
            className = "vn_k98k";
            displayName = "K98K";
            weaponType = "rifle";
            family = "k98k";
            baseMagazine = "vn_k98k_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
        };
        class vn_k98k_bayo
        {
            className = "vn_k98k_bayo";
            displayName = "K98K (Bayonet)";
            weaponType = "rifle";
            family = "k98k";
            variantOf = "vn_k98k";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_k98k", "vn_k98k"};
            baseMagazine = "vn_k98k_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
            compatibleAttachments[] = {"vn_b_k98k"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_k98k_mrk
        {
            className = "vn_k98k_mrk";
            displayName = "K98K (Sniper)";
            weaponType = "marksman";
            family = "k98k";
            variantOf = "vn_k98k";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_k98k", "vn_o_1_5x_k98k"};
            baseMagazine = "vn_k98k_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
            compatibleAttachments[] = {"vn_o_1_5x_k98k"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_k98k_mrk_camo
        {
            className = "vn_k98k_mrk_camo";
            displayName = "K98K (Sniper/ camo)";
            weaponType = "marksman";
            family = "k98k";
            variantOf = "vn_k98k_mrk";
            variantTraits[] = {"bayonet", "camo"};
            derivedRequirements[] = {"vn_b_camo_k98k", "vn_k98k_mrk"};
            baseMagazine = "vn_k98k_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_k98k", "vn_o_1_5x_k98k"};
        };
        class vn_kbkg
        {
            className = "vn_kbkg";
            displayName = "KBKG";
            weaponType = "rifle";
            family = "kbkg";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_kbkg_gl
        {
            className = "vn_kbkg_gl";
            displayName = "KBKG (Rifle Grenade)";
            weaponType = "rifle";
            family = "kbkg";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_20mm_dgn_wp_mag", "vn_20mm_f1n60_frag_mag", "vn_20mm_kgn_frag_mag", "vn_20mm_pgn60_heat_mag", "vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_l1a1_01
        {
            className = "vn_l1a1_01";
            displayName = "L1A1 (Aus)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_01_bayo
        {
            className = "vn_l1a1_01_bayo";
            displayName = "L1A1 (Aus/ Bayonet)";
            weaponType = "rifle";
            family = "l1a1";
            variantOf = "vn_l1a1_01";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_l1a1", "vn_l1a1_01"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            compatibleAttachments[] = {"vn_b_l1a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_01_camo
        {
            className = "vn_l1a1_01_camo";
            displayName = "L1A1 (Aus/ Camo)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_01_gl
        {
            className = "vn_l1a1_01_gl";
            displayName = "L1A1 (Aus/ Rifle Grenade)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_22mm_m61_frag_mag", "vn_22mm_n94_heat_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_01_mrk
        {
            className = "vn_l1a1_01_mrk";
            displayName = "L1A1 (Aus/ 3x Optic)";
            weaponType = "rifle";
            family = "l1a1";
            variantOf = "vn_l1a1_01";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_l1a1_01", "vn_o_3x_l1a1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_l1a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_02
        {
            className = "vn_l1a1_02";
            displayName = "L1A1 (NZ)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_02_bayo
        {
            className = "vn_l1a1_02_bayo";
            displayName = "L1A1 (NZ/ Bayonet)";
            weaponType = "rifle";
            family = "l1a1";
            variantOf = "vn_l1a1_01";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_l1a1", "vn_l1a1_01"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            compatibleAttachments[] = {"vn_b_l1a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_02_camo
        {
            className = "vn_l1a1_02_camo";
            displayName = "L1A1 (NZ/ Camo)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02_gl
        {
            className = "vn_l1a1_02_gl";
            displayName = "L1A1 (NZ/ Rifle Grenade)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_22mm_m61_frag_mag", "vn_22mm_n94_heat_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_02_mrk
        {
            className = "vn_l1a1_02_mrk";
            displayName = "L1A1 (NZ/ 3x Optic)";
            weaponType = "rifle";
            family = "l1a1";
            variantOf = "vn_l1a1_01";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_l1a1_01", "vn_o_3x_l1a1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_l1a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_03
        {
            className = "vn_l1a1_03";
            displayName = "L1A1 (SAS)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_03_camo
        {
            className = "vn_l1a1_03_camo";
            displayName = "L1A1 (SAS/ Camo)";
            weaponType = "rifle";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l1a1_xm148
        {
            className = "vn_l1a1_xm148";
            displayName = "L1A1 (XM148)";
            weaponType = "launcher";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_xm148_camo
        {
            className = "vn_l1a1_xm148_camo";
            displayName = "L1A1 (XM148/ Camo)";
            weaponType = "launcher";
            family = "l1a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l2a1_01
        {
            className = "vn_l2a1_01";
            displayName = "L2A1 LMG";
            weaponType = "lmg";
            family = "l2a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l2a3
        {
            className = "vn_l2a3";
            displayName = "L2A3";
            weaponType = "smg";
            family = "l2a3";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l2a3_f
        {
            className = "vn_l2a3_f";
            displayName = "L2A3 (Folded)";
            weaponType = "smg";
            family = "l2a3";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l34a1
        {
            className = "vn_l34a1";
            displayName = "L34A1";
            weaponType = "smg";
            family = "l34a1";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l34a1_f
        {
            className = "vn_l34a1_f";
            displayName = "L34A1 (Folded)";
            weaponType = "smg";
            family = "l34a1";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l34a1_xm148
        {
            className = "vn_l34a1_xm148";
            displayName = "L34A1 (XM148)";
            weaponType = "smg";
            family = "l34a1";
            baseMagazine = "vn_f1_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_f1_smg_mag", "vn_f1_smg_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_l4
        {
            className = "vn_l4";
            displayName = "L4 LMG";
            weaponType = "lmg";
            family = "l4";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m10
        {
            className = "vn_m10";
            displayName = "Model 10";
            weaponType = "handgun";
            family = "m10";
            baseMagazine = "vn_m10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m10_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m10_sd
        {
            className = "vn_m10_sd";
            displayName = "Model 10 (S)";
            weaponType = "handgun";
            family = "m10";
            variantOf = "vn_m10";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m10", "vn_s_mk22"};
            baseMagazine = "vn_m10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m10_mag"};
            compatibleAttachments[] = {"vn_s_mk22"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m127
        {
            className = "vn_m127";
            displayName = "M127 Flare Launcher";
            weaponType = "rifle";
            family = "m127";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m127_mag", "vn_m128_mag", "vn_m129_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14
        {
            className = "vn_m14";
            displayName = "M14";
            weaponType = "rifle";
            family = "m14";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14_bayo
        {
            className = "vn_m14_bayo";
            displayName = "M14 (Bayonet)";
            weaponType = "rifle";
            family = "m14";
            variantOf = "vn_m14";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m14", "vn_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_b_m14"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14_camo
        {
            className = "vn_m14_camo";
            displayName = "M14 (Camo)";
            weaponType = "rifle";
            family = "m14";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14_sd
        {
            className = "vn_m14_sd";
            displayName = "M14 (S)";
            weaponType = "rifle";
            family = "m14";
            variantOf = "vn_m14";
            variantTraits[] = {"bayonet", "suppressed"};
            derivedRequirements[] = {"vn_b_camo_m14", "vn_m14", "vn_s_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m14", "vn_s_m14"};
        };
        class vn_m14a1
        {
            className = "vn_m14a1";
            displayName = "M14A1";
            weaponType = "rifle";
            family = "m14a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_bipod
        {
            className = "vn_m14a1_bipod";
            displayName = "M14A1 (Bipod)";
            weaponType = "rifle";
            family = "m14a1";
            variantOf = "vn_m14a1";
            variantTraits[] = {"bipod"};
            derivedRequirements[] = {"vn_bipod_m14", "vn_m14a1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m14"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14a1_camo
        {
            className = "vn_m14a1_camo";
            displayName = "M14A1 (Camo)";
            weaponType = "rifle";
            family = "m14a1";
            variantOf = "vn_m14a1";
            variantTraits[] = {"bayonet", "camo", "suppressed"};
            derivedRequirements[] = {"vn_b_camo_m14a1", "vn_m14a1", "vn_s_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m14a1", "vn_s_m14"};
        };
        class vn_m14a1_nvg
        {
            className = "vn_m14a1_nvg";
            displayName = "M14A1 (NV Optic)";
            weaponType = "rifle";
            family = "m14a1";
            variantOf = "vn_m14a1_camo";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_m14a1_camo", "vn_o_anpvs2_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m14a1", "vn_o_anpvs2_m14", "vn_s_m14"};
        };
        class vn_m14a1_shorty
        {
            className = "vn_m14a1_shorty";
            displayName = "M14A1 (Shorty)";
            weaponType = "rifle";
            family = "m14a1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14a1_shorty_fs
        {
            className = "vn_m14a1_shorty_fs";
            displayName = "M14A1 (Shorty/ sight)";
            weaponType = "rifle";
            family = "m14a1";
            variantOf = "vn_m14a1";
            variantTraits[] = {"front_sight", "optic", "short"};
            derivedRequirements[] = {"vn_m14a1", "vn_o_m14_front"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_o_m14_front"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m14a1_sniper
        {
            className = "vn_m14a1_sniper";
            displayName = "M14A1 (9x Optic)";
            weaponType = "marksman";
            family = "m14a1";
            variantOf = "vn_m14a1_bipod";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m14a1_bipod", "vn_o_9x_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m14", "vn_o_9x_m14"};
        };
        class vn_m16
        {
            className = "vn_m16";
            displayName = "M16A1";
            weaponType = "rifle";
            family = "m16";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m16_bayo
        {
            className = "vn_m16_bayo";
            displayName = "M16A1 (Bayonet)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m16", "vn_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_b_m16"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m16_camo
        {
            className = "vn_m16_camo";
            displayName = "M16A1 (Camo)";
            weaponType = "rifle";
            family = "m16";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_m203
        {
            className = "vn_m16_m203";
            displayName = "M16A1 (M203)";
            weaponType = "launcher";
            family = "m16";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_m203_camo
        {
            className = "vn_m16_m203_camo";
            displayName = "M16A1 (M203 Camo)";
            weaponType = "launcher";
            family = "m16";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_mrk
        {
            className = "vn_m16_mrk";
            displayName = "M16A1 (4x Optic)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m16", "vn_o_4x_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_mrk_sd
        {
            className = "vn_m16_mrk_sd";
            displayName = "M16A1 (4x Optic/S)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16_sd";
            variantTraits[] = {"optic", "suppressed"};
            derivedRequirements[] = {"vn_m16_sd", "vn_o_4x_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16", "vn_s_m16"};
        };
        class vn_m16_muzzle
        {
            className = "vn_m16_muzzle";
            displayName = "M16A1 (XM148)";
            weaponType = "launcher";
            family = "m16_muzzle";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_nvg
        {
            className = "vn_m16_nvg";
            displayName = "M16A1 (NV Optic)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_m16", "vn_o_anpvs2_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_nvg_sd
        {
            className = "vn_m16_nvg_sd";
            displayName = "M16A1 (NV Optic/S)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16_sd";
            variantTraits[] = {"night_optic", "optic", "suppressed"};
            derivedRequirements[] = {"vn_m16_sd", "vn_o_anpvs2_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16", "vn_s_m16"};
        };
        class vn_m16_sd
        {
            className = "vn_m16_sd";
            displayName = "M16A1 (S)";
            weaponType = "rifle";
            family = "m16";
            variantOf = "vn_m16";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m16", "vn_s_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_s_m16"};
        };
        class vn_m16_sniper
        {
            className = "vn_m16_sniper";
            displayName = "M16A1 (9x Optic)";
            weaponType = "marksman";
            family = "m16";
            variantOf = "vn_m16";
            variantTraits[] = {"bipod", "optic"};
            derivedRequirements[] = {"vn_bipod_m16", "vn_m16", "vn_o_9x_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_sniper_sd
        {
            className = "vn_m16_sniper_sd";
            displayName = "M16A1 (9x Optic/S)";
            weaponType = "marksman";
            family = "m16";
            variantOf = "vn_m16_sniper";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m16_sniper", "vn_s_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16", "vn_s_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m16_usaf
        {
            className = "vn_m16_usaf";
            displayName = "M16 USAF";
            weaponType = "rifle";
            family = "m16_usaf";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf_bayo
        {
            className = "vn_m16_usaf_bayo";
            displayName = "M16 USAF (Bayonet)";
            weaponType = "rifle";
            family = "m16_usaf";
            variantOf = "vn_m16_usaf";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m16", "vn_m16_usaf"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_b_m16"};
        };
        class vn_m16_usaf_mrk
        {
            className = "vn_m16_usaf_mrk";
            displayName = "M16 USAF (4x Optic)";
            weaponType = "rifle";
            family = "m16_usaf";
            variantOf = "vn_m16_usaf";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m16_usaf", "vn_o_4x_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16"};
        };
        class vn_m16_usaf_nvg
        {
            className = "vn_m16_usaf_nvg";
            displayName = "M16 USAF (NV Optic)";
            weaponType = "rifle";
            family = "m16_usaf";
            variantOf = "vn_m16_usaf";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_m16_usaf", "vn_o_anpvs2_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16"};
        };
        class vn_m16_usaf_sniper
        {
            className = "vn_m16_usaf_sniper";
            displayName = "M16 USAF (9x Optic)";
            weaponType = "marksman";
            family = "m16_usaf";
            variantOf = "vn_m16_usaf";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m16_usaf", "vn_o_9x_m16"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_9x_m16"};
        };
        class vn_m16_xm148
        {
            className = "vn_m16_xm148";
            displayName = "M16A1 (XM148)";
            weaponType = "rifle";
            family = "m16";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m1891
        {
            className = "vn_m1891";
            displayName = "M1891 Rifle";
            weaponType = "rifle";
            family = "m1891";
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m1891_bayo
        {
            className = "vn_m1891_bayo";
            displayName = "M1891 Rifle (Bayonet)";
            weaponType = "rifle";
            family = "m1891";
            variantOf = "vn_m1891";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m38", "vn_m1891"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_b_m38"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m1895
        {
            className = "vn_m1895";
            displayName = "M1895";
            weaponType = "handgun";
            family = "m1895";
            baseMagazine = "vn_m1895_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1895_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m1895_sd
        {
            className = "vn_m1895_sd";
            displayName = "M1895 (S)";
            weaponType = "handgun";
            family = "m1895";
            variantOf = "vn_m1895";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m1895", "vn_s_m1895"};
            baseMagazine = "vn_m1895_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1895_mag"};
            compatibleAttachments[] = {"vn_s_m1895"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m1897
        {
            className = "vn_m1897";
            displayName = "M1897";
            weaponType = "rifle";
            family = "m1897";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1897_buck_mag", "vn_m1897_fl_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1897_bayo
        {
            className = "vn_m1897_bayo";
            displayName = "M1897 (Bayonet)";
            weaponType = "rifle";
            family = "m1897";
            variantOf = "vn_m1897";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m1897", "vn_m1897"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1897_buck_mag", "vn_m1897_fl_mag"};
            compatibleAttachments[] = {"vn_b_m1897"};
        };
        class vn_m1903
        {
            className = "vn_m1903";
            displayName = "M1903 Rifle";
            weaponType = "rifle";
            family = "m1903";
            baseMagazine = "vn_m1903_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1903_bayo
        {
            className = "vn_m1903_bayo";
            displayName = "M1903 (Bayonet)";
            weaponType = "rifle";
            family = "m1903";
            variantOf = "vn_m1903";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m1903", "vn_m1903"};
            baseMagazine = "vn_m1903_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
            compatibleAttachments[] = {"vn_b_m1903"};
            sourceAffiliations[] = {"INDEPENDENT"};
        };
        class vn_m1903_gl
        {
            className = "vn_m1903_gl";
            displayName = "M1903 (Rifle Grenade)";
            weaponType = "rifle";
            family = "m1903";
            baseMagazine = "vn_m1903_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1903_sniper
        {
            className = "vn_m1903_sniper";
            displayName = "M1903 (8x Optic)";
            weaponType = "marksman";
            family = "m1903";
            variantOf = "vn_m1903_bayo";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m1903_bayo", "vn_o_8x_m1903"};
            baseMagazine = "vn_m1903_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
            compatibleAttachments[] = {"vn_b_m1903", "vn_o_8x_m1903"};
        };
        class vn_m1911
        {
            className = "vn_m1911";
            displayName = "M1911";
            weaponType = "handgun";
            family = "m1911";
            baseMagazine = "vn_m1911_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1911_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1911_sd
        {
            className = "vn_m1911_sd";
            displayName = "M1911 (S)";
            weaponType = "rifle";
            family = "m1911";
            variantOf = "vn_m1911";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m1911", "vn_s_m1911"};
            baseMagazine = "vn_m1911_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1911_mag"};
            compatibleAttachments[] = {"vn_s_m1911"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m1918
        {
            className = "vn_m1918";
            displayName = "M1918A2";
            weaponType = "lmg";
            family = "m1918";
            baseMagazine = "vn_m1918_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1918_mag", "vn_m1918_t_mag"};
        };
        class vn_m1918_bipod
        {
            className = "vn_m1918_bipod";
            displayName = "M1918A2 (Bipod)";
            weaponType = "lmg";
            family = "m1918";
            variantOf = "vn_m1918";
            variantTraits[] = {"bipod"};
            derivedRequirements[] = {"vn_bipod_m1918", "vn_m1918"};
            baseMagazine = "vn_m1918_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1918_mag", "vn_m1918_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m1918"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m1928_tommy
        {
            className = "vn_m1928_tommy";
            displayName = "M1928 Tommy Gun";
            weaponType = "smg";
            family = "m1928_tommy";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1928_mag", "vn_m1928_t_mag", "vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
        };
        class vn_m1928a1_tommy
        {
            className = "vn_m1928a1_tommy";
            displayName = "M1928A1 Tommy Gun";
            weaponType = "smg";
            family = "m1928a1_tommy";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1928_mag", "vn_m1928_t_mag", "vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1_garand
        {
            className = "vn_m1_garand";
            displayName = "M1 Garand";
            weaponType = "rifle";
            family = "m1_garand";
            baseMagazine = "vn_m1_garand_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1_garand_bayo
        {
            className = "vn_m1_garand_bayo";
            displayName = "M1 Garand (Bayonet)";
            weaponType = "rifle";
            family = "m1_garand";
            variantOf = "vn_m1_garand";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m1_garand", "vn_m1_garand"};
            baseMagazine = "vn_m1_garand_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
            compatibleAttachments[] = {"vn_b_m1_garand"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m1_garand_gl
        {
            className = "vn_m1_garand_gl";
            displayName = "M1 Garand (Rifle Grenade)";
            weaponType = "rifle";
            family = "m1_garand";
            baseMagazine = "vn_m1_garand_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m1_garand_mag", "vn_m1_garand_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1_garand_sniper
        {
            className = "vn_m1_garand_sniper";
            displayName = "M1 Garand (3x Optic)";
            weaponType = "marksman";
            family = "m1_garand";
            variantOf = "vn_m1_garand";
            variantTraits[] = {"bayonet", "optic"};
            derivedRequirements[] = {"vn_b_camo_m1_garand", "vn_m1_garand", "vn_o_3x_m84"};
            baseMagazine = "vn_m1_garand_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m1_garand", "vn_o_3x_m84"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1a1_tommy
        {
            className = "vn_m1a1_tommy";
            displayName = "M1A1 Tommy Gun";
            weaponType = "smg";
            family = "m1a1_tommy";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m1a1_tommy_so
        {
            className = "vn_m1a1_tommy_so";
            displayName = "M1A1 Tommy Gun (shorty)";
            weaponType = "smg";
            family = "m1a1_tommy_so";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m1carbine
        {
            className = "vn_m1carbine";
            displayName = "M1 Carbine";
            weaponType = "rifle";
            family = "m1carbine";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m1carbine_bayo
        {
            className = "vn_m1carbine_bayo";
            displayName = "M1 Carbine (Bayonet)";
            weaponType = "rifle";
            family = "m1carbine";
            variantOf = "vn_m1carbine";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_carbine", "vn_m1carbine"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            compatibleAttachments[] = {"vn_b_carbine"};
            sourceAffiliations[] = {"EAST", "WEST"};
        };
        class vn_m1carbine_gl
        {
            className = "vn_m1carbine_gl";
            displayName = "M1 Carbine (Rifle Grenade)";
            weaponType = "rifle";
            family = "m1carbine";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m1carbine_shorty
        {
            className = "vn_m1carbine_shorty";
            displayName = "M1 Carbine (Shorty)";
            weaponType = "rifle";
            family = "m1carbine";
            baseMagazine = "vn_hp_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_hp_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m1carbine_sniper
        {
            className = "vn_m1carbine_sniper";
            displayName = "M1 Carbine (2.2x optic)";
            weaponType = "marksman";
            family = "m1carbine";
            variantOf = "vn_m1carbine";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m1carbine", "vn_o_3x_m84"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_m84"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m20a1b1_01
        {
            className = "vn_m20a1b1_01";
            displayName = "M20A1B1";
            weaponType = "rifle";
            family = "m20a1b1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m20a1b1_heat_mag", "vn_m20a1b1_wp_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m21
        {
            className = "vn_m21";
            displayName = "XM21 Sniper Rifle";
            weaponType = "marksman";
            family = "m21";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_o_9x_m14"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m21_nvg
        {
            className = "vn_m21_nvg";
            displayName = "XM21 Sniper Rifle (NV Optic)";
            weaponType = "marksman";
            family = "m21";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m14"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m21_nvg_sd
        {
            className = "vn_m21_nvg_sd";
            displayName = "XM21 Sniper Rifle (NV Optic/S)";
            weaponType = "marksman";
            family = "m21";
            variantOf = "vn_m21_nvg";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m21_nvg", "vn_s_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m14", "vn_s_m14"};
        };
        class vn_m21_sd
        {
            className = "vn_m21_sd";
            displayName = "XM21 Sniper Rifle (S)";
            weaponType = "marksman";
            family = "m21";
            variantOf = "vn_m21";
            variantTraits[] = {"bayonet", "suppressed"};
            derivedRequirements[] = {"vn_b_camo_m14", "vn_m21", "vn_s_m14"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m14", "vn_o_9x_m14", "vn_s_m14"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m2carbine
        {
            className = "vn_m2carbine";
            displayName = "M2 Carbine";
            weaponType = "rifle";
            family = "m2carbine";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m2carbine_bayo
        {
            className = "vn_m2carbine_bayo";
            displayName = "M2 Carbine (Bayonet)";
            weaponType = "rifle";
            family = "m2carbine";
            variantOf = "vn_m2carbine";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_carbine", "vn_m2carbine"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            compatibleAttachments[] = {"vn_b_carbine"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m2carbine_gl
        {
            className = "vn_m2carbine_gl";
            displayName = "M2 Carbine (Rifle Grenade)";
            weaponType = "rifle";
            family = "m2carbine";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m2carbine_sniper
        {
            className = "vn_m2carbine_sniper";
            displayName = "M2 Carbine (2.2x optic)";
            weaponType = "marksman";
            family = "m2carbine";
            variantOf = "vn_m2carbine";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m2carbine", "vn_o_3x_m84"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_m84"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m36
        {
            className = "vn_m36";
            displayName = "M36";
            weaponType = "rifle";
            family = "m36";
            baseMagazine = "vn_m36_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m36_mag", "vn_m36_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_m36_bayo
        {
            className = "vn_m36_bayo";
            displayName = "M36 (Bayonet)";
            weaponType = "rifle";
            family = "m36";
            variantOf = "vn_m36";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m36", "vn_m36"};
            baseMagazine = "vn_m36_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m36_mag", "vn_m36_t_mag"};
            compatibleAttachments[] = {"vn_b_m36"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_m36_camo
        {
            className = "vn_m36_camo";
            displayName = "M36 (Camo)";
            weaponType = "rifle";
            family = "m36";
            baseMagazine = "vn_m36_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m36_mag", "vn_m36_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m36"};
        };
        class vn_m38
        {
            className = "vn_m38";
            displayName = "M38 Rifle";
            weaponType = "rifle";
            family = "m38";
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m38_bayo
        {
            className = "vn_m38_bayo";
            displayName = "M38 Rifle (Bayonet)";
            weaponType = "rifle";
            family = "m38";
            variantOf = "vn_m38";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m38", "vn_m38"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_b_m38"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m3a1
        {
            className = "vn_m3a1";
            displayName = "M3A1 Grease Gun";
            weaponType = "rifle";
            family = "m3a1";
            baseMagazine = "vn_m3a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m3a1_mag", "vn_m3a1_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m3carbine
        {
            className = "vn_m3carbine";
            displayName = "M3 Carbine (NVG)";
            weaponType = "rifle";
            family = "m3carbine";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m3sd
        {
            className = "vn_m3sd";
            displayName = "M3 Grease Gun (S)";
            weaponType = "rifle";
            family = "m3a1";
            variantOf = "vn_m3a1";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m3a1", "vn_s_m3a1"};
            baseMagazine = "vn_m3a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m3a1_mag", "vn_m3a1_t_mag"};
            compatibleAttachments[] = {"vn_s_m3a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m40a1
        {
            className = "vn_m40a1";
            displayName = "M40 Sniper Rifle";
            weaponType = "marksman";
            family = "m40a1";
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_camo
        {
            className = "vn_m40a1_camo";
            displayName = "M40 Sniper Rifle Camo";
            weaponType = "marksman";
            family = "m40a1";
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_nvg
        {
            className = "vn_m40a1_nvg";
            displayName = "M40 Sniper Rifle (NV Optic)";
            weaponType = "marksman";
            family = "m40a1";
            variantOf = "vn_m40a1";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_m40a1", "vn_o_anpvs2_m40a1"};
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m40a1"};
        };
        class vn_m40a1_nvg_sd
        {
            className = "vn_m40a1_nvg_sd";
            displayName = "M40 Sniper Rifle (NV Optic/S)";
            weaponType = "marksman";
            family = "m40a1";
            variantOf = "vn_m40a1_nvg";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m40a1_nvg", "vn_s_m14"};
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m40a1", "vn_s_m14"};
        };
        class vn_m40a1_sniper
        {
            className = "vn_m40a1_sniper";
            displayName = "M40 Sniper Rifle (9x Optic)";
            weaponType = "marksman";
            family = "m40a1";
            variantOf = "vn_m40a1";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m40a1", "vn_o_9x_m40a1"};
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
            compatibleAttachments[] = {"vn_o_9x_m40a1"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m40a1_sniper_sd
        {
            className = "vn_m40a1_sniper_sd";
            displayName = "M40 Sniper Rifle (Camo/S)";
            weaponType = "marksman";
            family = "m40a1";
            variantOf = "vn_m40a1_sniper";
            variantTraits[] = {"bayonet", "suppressed"};
            derivedRequirements[] = {"vn_b_camo_m40a1", "vn_m40a1_sniper", "vn_s_m14"};
            baseMagazine = "vn_m40a1_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_m40a1", "vn_o_9x_m40a1", "vn_s_m14"};
        };
        class vn_m45
        {
            className = "vn_m45";
            displayName = "M/45 Submachinegun";
            weaponType = "smg";
            family = "m45";
            baseMagazine = "vn_m45_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m45_mag", "vn_m45_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m45_camo
        {
            className = "vn_m45_camo";
            displayName = "M/45 Submachinegun (Camo)";
            weaponType = "smg";
            family = "m45";
            baseMagazine = "vn_m45_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m45_mag", "vn_m45_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m45_fold
        {
            className = "vn_m45_fold";
            displayName = "M/45 Submachinegun (Folded)";
            weaponType = "smg";
            family = "m45";
            baseMagazine = "vn_m45_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m45_mag", "vn_m45_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m45_sd
        {
            className = "vn_m45_sd";
            displayName = "M/45 Submachinegun (S)";
            weaponType = "smg";
            family = "m45";
            variantOf = "vn_m45";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_m45", "vn_s_m45_camo"};
            baseMagazine = "vn_m45_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m45_mag", "vn_m45_t_mag"};
            compatibleAttachments[] = {"vn_s_m45_camo"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m4956
        {
            className = "vn_m4956";
            displayName = "M49/56";
            weaponType = "rifle";
            family = "m4956";
            baseMagazine = "vn_m4956_10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m4956_bayo
        {
            className = "vn_m4956_bayo";
            displayName = "M49/56 (Bayonet)";
            weaponType = "rifle";
            family = "m4956";
            variantOf = "vn_m4956";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m4956", "vn_m4956"};
            baseMagazine = "vn_m4956_10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
            compatibleAttachments[] = {"vn_b_m4956"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m4956_gl
        {
            className = "vn_m4956_gl";
            displayName = "M49/56 (Rifle Grenade)";
            weaponType = "rifle";
            family = "m4956";
            baseMagazine = "vn_m4956_10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_he_mag", "vn_22mm_lume_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m4956_10_mag", "vn_m4956_10_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m4956_sniper
        {
            className = "vn_m4956_sniper";
            displayName = "M49/56 (3.5x Optic)";
            weaponType = "marksman";
            family = "m4956";
            variantOf = "vn_m4956";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m4956", "vn_o_4x_m4956"};
            baseMagazine = "vn_m4956_10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m4956"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m60
        {
            className = "vn_m60";
            displayName = "M60";
            weaponType = "lmg";
            family = "m60";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m60_100_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m60_shorty
        {
            className = "vn_m60_shorty";
            displayName = "M60 Shorty";
            weaponType = "lmg";
            family = "m60";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m60_100_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m60_shorty_camo
        {
            className = "vn_m60_shorty_camo";
            displayName = "M60 Shorty (Camo)";
            weaponType = "lmg";
            family = "m60";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m60_100_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m63a
        {
            className = "vn_m63a";
            displayName = "M63A";
            weaponType = "rifle";
            family = "m63a";
            baseMagazine = "vn_m63a_30_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m63a_30_mag", "vn_m63a_30_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m63a_cdo
        {
            className = "vn_m63a_cdo";
            displayName = "M63A Commando";
            weaponType = "rifle";
            family = "m63a_cdo";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m63a_150_mag", "vn_m63a_150_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m63a_cdo_bipod
        {
            className = "vn_m63a_cdo_bipod";
            displayName = "M63A Commando (Bipod)";
            weaponType = "rifle";
            family = "m63a_cdo";
            variantOf = "vn_m63a_cdo";
            variantTraits[] = {"bipod"};
            derivedRequirements[] = {"vn_bipod_m63a", "vn_m63a_cdo"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m63a_150_mag", "vn_m63a_150_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m63a"};
        };
        class vn_m63a_lmg
        {
            className = "vn_m63a_lmg";
            displayName = "M63A LMG";
            weaponType = "lmg";
            family = "m63a_lmg";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m63a_100_mag", "vn_m63a_100_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m63a_lmg_bipod
        {
            className = "vn_m63a_lmg_bipod";
            displayName = "M63A LMG (Bipod)";
            weaponType = "lmg";
            family = "m63a_lmg";
            variantOf = "vn_m63a_lmg";
            variantTraits[] = {"bipod"};
            derivedRequirements[] = {"vn_bipod_m63a", "vn_m63a_lmg"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m63a_100_mag", "vn_m63a_100_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m63a"};
        };
        class vn_m712
        {
            className = "vn_m712";
            displayName = "M712";
            weaponType = "handgun";
            family = "m712";
            baseMagazine = "vn_m712_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m712_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m72
        {
            className = "vn_m72";
            displayName = "M72 LAW";
            weaponType = "launcher";
            family = "m72";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m72_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_m79
        {
            className = "vn_m79";
            displayName = "M79 40mm GL";
            weaponType = "launcher";
            family = "m79";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m576_buck_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m79_p
        {
            className = "vn_m79_p";
            displayName = "M79 40mm GL (sawn-off)";
            weaponType = "handgun";
            family = "m79";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m576_buck_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_m9130
        {
            className = "vn_m9130";
            displayName = "M91/30 Rifle";
            weaponType = "rifle";
            family = "m9130";
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m9130_bayo
        {
            className = "vn_m9130_bayo";
            displayName = "M91/30 Rifle (Bayonet)";
            weaponType = "rifle";
            family = "m9130";
            variantOf = "vn_m9130";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m38", "vn_m9130"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_b_m38"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_m9130_sniper
        {
            className = "vn_m9130_sniper";
            displayName = "M91/30 Rifle (3.5x Optic)";
            weaponType = "marksman";
            family = "m9130";
            variantOf = "vn_m9130";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_m9130", "vn_o_3x_m9130"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_m9130"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_mat49
        {
            className = "vn_mat49";
            displayName = "MAT-49";
            weaponType = "rifle";
            family = "mat49";
            baseMagazine = "vn_mat49_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_mat49_f
        {
            className = "vn_mat49_f";
            displayName = "MAT-49 (Folded)";
            weaponType = "smg";
            family = "mat49";
            baseMagazine = "vn_mat49_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT"};
        };
        class vn_mat49_sd
        {
            className = "vn_mat49_sd";
            displayName = "MAT-49 (S)";
            weaponType = "smg";
            family = "mat49";
            variantOf = "vn_mat49";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_mat49", "vn_s_mat49"};
            baseMagazine = "vn_mat49_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
            compatibleAttachments[] = {"vn_s_mat49"};
        };
        class vn_mat49_vc
        {
            className = "vn_mat49_vc";
            displayName = "MAT-49 (VC)";
            weaponType = "smg";
            family = "mat49_vc";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_mat49_vc_mag", "vn_mat49_vc_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_mc10
        {
            className = "vn_mc10";
            displayName = "MC-10";
            weaponType = "handgun";
            family = "mc10";
            baseMagazine = "vn_mc10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mc10_mag", "vn_mc10_t_mag"};
        };
        class vn_mc10_sd
        {
            className = "vn_mc10_sd";
            displayName = "MC-10 (S)";
            weaponType = "handgun";
            family = "mc10";
            variantOf = "vn_mc10";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_mc10", "vn_s_mc10"};
            baseMagazine = "vn_mc10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mc10_mag", "vn_mc10_t_mag"};
            compatibleAttachments[] = {"vn_s_mc10"};
        };
        class vn_mg42
        {
            className = "vn_mg42";
            displayName = "MG42";
            weaponType = "lmg";
            family = "mg42";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_mg42_50_mag", "vn_mg42_50_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_mk1_udg
        {
            className = "vn_mk1_udg";
            displayName = "Mk1 UDG";
            weaponType = "rifle";
            family = "mk1_udg";
            baseMagazine = "vn_mk1_udg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mk1_udg_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_mk22
        {
            className = "vn_mk22";
            displayName = "Mk22 Mod 0";
            weaponType = "rifle";
            family = "mk22";
            baseMagazine = "vn_mk22_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mk22_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_mk22_sd
        {
            className = "vn_mk22_sd";
            displayName = "Mk22 Mod 0 (S)";
            weaponType = "handgun";
            family = "mk22";
            variantOf = "vn_mk22";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_mk22", "vn_s_mk22"};
            baseMagazine = "vn_mk22_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mk22_mag"};
            compatibleAttachments[] = {"vn_s_mk22"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_mp40
        {
            className = "vn_mp40";
            displayName = "MP40";
            weaponType = "smg";
            family = "mp40";
            baseMagazine = "vn_mp40_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mp40_mag", "vn_mp40_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_mpu
        {
            className = "vn_mpu";
            displayName = "MPU";
            weaponType = "smg";
            family = "mpu";
            baseMagazine = "vn_mpu_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mpu_mag", "vn_mpu_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_mpu_sd
        {
            className = "vn_mpu_sd";
            displayName = "MPU (S)";
            weaponType = "smg";
            family = "mpu";
            variantOf = "vn_mpu";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_mpu", "vn_s_mpu"};
            baseMagazine = "vn_mpu_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_mpu_mag", "vn_mpu_t_mag"};
            compatibleAttachments[] = {"vn_s_mpu"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_mx991_m1911
        {
            className = "vn_mx991_m1911";
            displayName = "M1911 (Flashlight)";
            weaponType = "handgun";
            family = "mx991_m1911";
            baseMagazine = "vn_m1911_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1911_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_mx991_m1911_sd
        {
            className = "vn_mx991_m1911_sd";
            displayName = "M1911 (S/ Flashlight)";
            weaponType = "handgun";
            family = "mx991_m1911";
            variantOf = "vn_mx991_m1911";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_mx991_m1911", "vn_s_m1911"};
            baseMagazine = "vn_m1911_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m1911_mag"};
            compatibleAttachments[] = {"vn_s_m1911"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_p38
        {
            className = "vn_p38";
            displayName = "P38";
            weaponType = "rifle";
            family = "p38";
            baseMagazine = "vn_p38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_p38_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_p38_sd
        {
            className = "vn_p38_sd";
            displayName = "P38 (S)";
            weaponType = "handgun";
            family = "p38";
            variantOf = "vn_p38";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_p38", "vn_s_ppk"};
            baseMagazine = "vn_p38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_p38_mag"};
            compatibleAttachments[] = {"vn_s_ppk"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_p38s
        {
            className = "vn_p38s";
            displayName = ".38 Revolver";
            weaponType = "handgun";
            family = "p38s";
            baseMagazine = "vn_m10_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m10_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_pk
        {
            className = "vn_pk";
            displayName = "PK";
            weaponType = "lmg";
            family = "pk";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_pk_100_mag"};
        };
        class vn_pm
        {
            className = "vn_pm";
            displayName = "PM";
            weaponType = "handgun";
            family = "pm";
            baseMagazine = "vn_pm_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pm_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_pm_sd
        {
            className = "vn_pm_sd";
            displayName = "PM (S)";
            weaponType = "handgun";
            family = "pm";
            variantOf = "vn_pm";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_pm", "vn_s_pm"};
            baseMagazine = "vn_pm_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pm_mag"};
            compatibleAttachments[] = {"vn_s_pm"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_ppk
        {
            className = "vn_ppk";
            displayName = "PPK";
            weaponType = "handgun";
            family = "ppk";
            baseMagazine = "vn_ppk_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_ppk_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_ppk_sd
        {
            className = "vn_ppk_sd";
            displayName = "PPK (S)";
            weaponType = "handgun";
            family = "ppk";
            variantOf = "vn_ppk";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_ppk", "vn_s_ppk"};
            baseMagazine = "vn_ppk_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_ppk_mag"};
            compatibleAttachments[] = {"vn_s_ppk"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_pps43
        {
            className = "vn_pps43";
            displayName = "PPS-43";
            weaponType = "smg";
            family = "pps43";
            baseMagazine = "vn_pps_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pps_mag", "vn_pps_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_pps52
        {
            className = "vn_pps52";
            displayName = "PPS-52";
            weaponType = "smg";
            family = "pps52";
            baseMagazine = "vn_pps_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_pps_mag", "vn_pps_t_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_ppsh41
        {
            className = "vn_ppsh41";
            displayName = "PPSh-41";
            weaponType = "smg";
            family = "ppsh41";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_ppsh41_35_mag", "vn_ppsh41_35_t_mag", "vn_ppsh41_71_mag", "vn_ppsh41_71_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_rpd
        {
            className = "vn_rpd";
            displayName = "RPD";
            weaponType = "lmg";
            family = "rpd";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_rpd_shorty
        {
            className = "vn_rpd_shorty";
            displayName = "RPD Shorty (El Cid)";
            weaponType = "lmg";
            family = "rpd";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_rpd_shorty_01
        {
            className = "vn_rpd_shorty_01";
            displayName = "RPD Shorty";
            weaponType = "lmg";
            family = "rpd_shorty";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
        };
        class vn_rpg2
        {
            className = "vn_rpg2";
            displayName = "B40";
            weaponType = "launcher";
            family = "rpg2";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_rpg2_fuze_mag", "vn_rpg2_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_rpg7
        {
            className = "vn_rpg7";
            displayName = "B41";
            weaponType = "launcher";
            family = "rpg7";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_rpg7_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_sa7
        {
            className = "vn_sa7";
            displayName = "9K32 Strela-2";
            weaponType = "launcher";
            family = "sa7";
            baseMagazine = "vn_sa7_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sa7_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_sa7b
        {
            className = "vn_sa7b";
            displayName = "9K32 Strela-2M";
            weaponType = "launcher";
            family = "sa7b";
            baseMagazine = "vn_sa7b_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sa7b_mag"};
        };
        class vn_sks
        {
            className = "vn_sks";
            displayName = "SKS Rifle";
            weaponType = "rifle";
            family = "sks";
            baseMagazine = "vn_sks_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sks_mag", "vn_sks_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_sks_bayo
        {
            className = "vn_sks_bayo";
            displayName = "SKS Rifle (Bayonet)";
            weaponType = "rifle";
            family = "sks";
            variantOf = "vn_sks";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_sks", "vn_sks"};
            baseMagazine = "vn_sks_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sks_mag", "vn_sks_t_mag"};
            compatibleAttachments[] = {"vn_b_sks"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_sks_gl
        {
            className = "vn_sks_gl";
            displayName = "SKS Rifle (22mm GL)";
            weaponType = "rifle";
            family = "sks";
            baseMagazine = "vn_sks_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m60_frag_mag", "vn_22mm_m60_heat_mag", "vn_sks_mag", "vn_sks_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_sks_sniper
        {
            className = "vn_sks_sniper";
            displayName = "SKS Rifle (3.5x Optic)";
            weaponType = "marksman";
            family = "sks";
            variantOf = "vn_sks";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_3x_sks", "vn_sks"};
            baseMagazine = "vn_sks_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sks_mag", "vn_sks_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_sks"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_sten
        {
            className = "vn_sten";
            displayName = "Sten Mk.II";
            weaponType = "rifle";
            family = "sten";
            baseMagazine = "vn_sten_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sten_mag", "vn_sten_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT"};
        };
        class vn_sten_sd
        {
            className = "vn_sten_sd";
            displayName = "Sten Mk.II (S)";
            weaponType = "rifle";
            family = "sten";
            variantOf = "vn_sten";
            variantTraits[] = {"suppressed"};
            derivedRequirements[] = {"vn_s_sten", "vn_sten"};
            baseMagazine = "vn_sten_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_sten_mag", "vn_sten_t_mag"};
            compatibleAttachments[] = {"vn_s_sten"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_svd
        {
            className = "vn_svd";
            displayName = "SVD";
            weaponType = "marksman";
            family = "svd";
            baseMagazine = "vn_svd_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_svd_mag", "vn_svd_t_mag"};
        };
        class vn_svd_sniper
        {
            className = "vn_svd_sniper";
            displayName = "SVD (Sniper)";
            weaponType = "marksman";
            family = "svd";
            variantOf = "vn_svd";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_4x_svd", "vn_svd"};
            baseMagazine = "vn_svd_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_svd_mag", "vn_svd_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_svd"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_svd_sniper_camo
        {
            className = "vn_svd_sniper_camo";
            displayName = "SVD (Sniper/ camo)";
            weaponType = "marksman";
            family = "svd";
            variantOf = "vn_svd";
            variantTraits[] = {"bayonet", "camo", "optic"};
            derivedRequirements[] = {"vn_b_camo_svd", "vn_o_4x_svd", "vn_svd"};
            baseMagazine = "vn_svd_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_svd_mag", "vn_svd_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_svd", "vn_o_4x_svd"};
        };
        class vn_tt33
        {
            className = "vn_tt33";
            displayName = "TT-33";
            weaponType = "handgun";
            family = "tt33";
            baseMagazine = "vn_tt33_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_tt33_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_type56
        {
            className = "vn_type56";
            displayName = "Type 56 Assault Rifle";
            weaponType = "rifle";
            family = "type56";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_type56_bayo
        {
            className = "vn_type56_bayo";
            displayName = "Type 56 Assault Rifle (Bayo)";
            weaponType = "rifle";
            family = "type56";
            variantOf = "vn_type56";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_type56", "vn_type56"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
            compatibleAttachments[] = {"vn_b_type56"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT"};
        };
        class vn_type64
        {
            className = "vn_type64";
            displayName = "Type 64";
            weaponType = "handgun";
            family = "type64";
            baseMagazine = "vn_type64_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_type64_mag"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_type64_f_smg
        {
            className = "vn_type64_f_smg";
            displayName = "Type 64 SMG (Folded)";
            weaponType = "smg";
            family = "type64_f_smg";
            baseMagazine = "vn_type64_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_type64_smg_mag", "vn_type64_smg_t_mag"};
        };
        class vn_type64_smg
        {
            className = "vn_type64_smg";
            displayName = "Type 64 SMG";
            weaponType = "smg";
            family = "type64_smg";
            baseMagazine = "vn_type64_smg_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_type64_smg_mag", "vn_type64_smg_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_vz54
        {
            className = "vn_vz54";
            displayName = "VZ54 Rifle";
            weaponType = "rifle";
            family = "vz54";
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_vz54_sniper
        {
            className = "vn_vz54_sniper";
            displayName = "VZ54 Rifle (2.5x Optic)";
            weaponType = "marksman";
            family = "vz54";
            variantOf = "vn_vz54";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_3x_vz54", "vn_vz54"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_o_3x_vz54"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_vz54_sniper_camo
        {
            className = "vn_vz54_sniper_camo";
            displayName = "VZ54 Rifle (2.5x Optic and camo)";
            weaponType = "marksman";
            family = "vz54";
            variantOf = "vn_vz54_sniper";
            variantTraits[] = {"bayonet", "camo"};
            derivedRequirements[] = {"vn_b_camo_vz54", "vn_vz54_sniper"};
            baseMagazine = "vn_m38_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_m38_mag", "vn_m38_t_mag"};
            compatibleAttachments[] = {"vn_b_camo_vz54", "vn_o_3x_vz54"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_vz61
        {
            className = "vn_vz61";
            displayName = "VZ.61";
            weaponType = "handgun";
            family = "vz61";
            baseMagazine = "vn_vz61_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_vz61_mag", "vn_vz61_t_mag"};
        };
        class vn_vz61_p
        {
            className = "vn_vz61_p";
            displayName = "VZ.61 (Sidearm)";
            weaponType = "handgun";
            family = "vz61";
            baseMagazine = "vn_vz61_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_vz61_mag", "vn_vz61_t_mag"};
        };
        class vn_welrod
        {
            className = "vn_welrod";
            displayName = "Welrod (S)";
            weaponType = "handgun";
            family = "welrod";
            baseMagazine = "vn_welrod_mag";
            baseMagazineConfidence = "high";
            compatibleMagazines[] = {"vn_welrod_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm16e1
        {
            className = "vn_xm16e1";
            displayName = "XM16E1";
            weaponType = "rifle";
            family = "xm16e1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_xm16e1_bayo
        {
            className = "vn_xm16e1_bayo";
            displayName = "XM16E1 (Bayonet)";
            weaponType = "rifle";
            family = "xm16e1";
            variantOf = "vn_xm16e1";
            variantTraits[] = {"bayonet"};
            derivedRequirements[] = {"vn_b_m16", "vn_xm16e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_b_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm16e1_mrk
        {
            className = "vn_xm16e1_mrk";
            displayName = "XM16E1 (4x Optic)";
            weaponType = "rifle";
            family = "xm16e1";
            variantOf = "vn_xm16e1";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_4x_m16", "vn_xm16e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16"};
        };
        class vn_xm16e1_nvg
        {
            className = "vn_xm16e1_nvg";
            displayName = "XM16E1 (NV Optic)";
            weaponType = "rifle";
            family = "xm16e1";
            variantOf = "vn_xm16e1";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_o_anpvs2_m16", "vn_xm16e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm16e1_sniper
        {
            className = "vn_xm16e1_sniper";
            displayName = "XM16E1 (9x Optic)";
            weaponType = "marksman";
            family = "xm16e1";
            variantOf = "vn_xm16e1";
            variantTraits[] = {"bipod", "optic"};
            derivedRequirements[] = {"vn_bipod_m16", "vn_o_9x_m16", "vn_xm16e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm16e1_xm148
        {
            className = "vn_xm16e1_xm148";
            displayName = "XM16E1 (XM148)";
            weaponType = "rifle";
            family = "xm16e1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177
        {
            className = "vn_xm177";
            displayName = "XM177E2";
            weaponType = "rifle";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_camo
        {
            className = "vn_xm177_camo";
            displayName = "XM177E2 (Camo)";
            weaponType = "rifle";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_fg
        {
            className = "vn_xm177_fg";
            displayName = "XM177E2 (Foregrip)";
            weaponType = "rifle";
            family = "xm177_fg";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_m203
        {
            className = "vn_xm177_m203";
            displayName = "XM177E2 (M203)";
            weaponType = "launcher";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_m203_camo
        {
            className = "vn_xm177_m203_camo";
            displayName = "XM177E2 (M203/ Camo)";
            weaponType = "launcher";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_mrk
        {
            className = "vn_xm177_mrk";
            displayName = "XM177E2 (4x Optic)";
            weaponType = "rifle";
            family = "xm177";
            variantOf = "vn_xm177";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_4x_m16", "vn_xm177"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16"};
        };
        class vn_xm177_muzzle
        {
            className = "vn_xm177_muzzle";
            displayName = "XM177E2 (XM148)";
            weaponType = "launcher";
            family = "xm177_muzzle";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_nvg
        {
            className = "vn_xm177_nvg";
            displayName = "XM177E2 (NV Optic)";
            weaponType = "rifle";
            family = "xm177";
            variantOf = "vn_xm177";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_o_anpvs2_m16", "vn_xm177"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm177_short
        {
            className = "vn_xm177_short";
            displayName = "XM177E2 (Short)";
            weaponType = "rifle";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_xm177_sniper
        {
            className = "vn_xm177_sniper";
            displayName = "XM177E2 (9x Optic)";
            weaponType = "marksman";
            family = "xm177";
            variantOf = "vn_xm177";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_9x_m16", "vn_xm177"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_9x_m16"};
        };
        class vn_xm177_stock
        {
            className = "vn_xm177_stock";
            displayName = "XM177E2 (Stock)";
            weaponType = "rifle";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_stock_camo
        {
            className = "vn_xm177_stock_camo";
            displayName = "XM177E2 (Stock/ Camo)";
            weaponType = "rifle";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_xm148
        {
            className = "vn_xm177_xm148";
            displayName = "XM177E2 (XM148)";
            weaponType = "launcher";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177_xm148_camo
        {
            className = "vn_xm177_xm148_camo";
            displayName = "XM177E2 (XM148/ Camo)";
            weaponType = "launcher";
            family = "xm177";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177e1
        {
            className = "vn_xm177e1";
            displayName = "XM177E1";
            weaponType = "rifle";
            family = "xm177e1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177e1_camo
        {
            className = "vn_xm177e1_camo";
            displayName = "XM177E1 (Camo)";
            weaponType = "rifle";
            family = "xm177e1";
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_xm177e1_mrk
        {
            className = "vn_xm177e1_mrk";
            displayName = "XM177E1 (4x Optic)";
            weaponType = "rifle";
            family = "xm177e1";
            variantOf = "vn_xm177e1";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_4x_m16", "vn_xm177e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_4x_m16"};
        };
        class vn_xm177e1_nvg
        {
            className = "vn_xm177e1_nvg";
            displayName = "XM177E1 (NV Optic)";
            weaponType = "rifle";
            family = "xm177e1";
            variantOf = "vn_xm177e1";
            variantTraits[] = {"night_optic", "optic"};
            derivedRequirements[] = {"vn_o_anpvs2_m16", "vn_xm177e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm177e1_sniper
        {
            className = "vn_xm177e1_sniper";
            displayName = "XM177E1 (4x Optic)";
            weaponType = "marksman";
            family = "xm177e1";
            variantOf = "vn_xm177e1";
            variantTraits[] = {"optic"};
            derivedRequirements[] = {"vn_o_9x_m16", "vn_xm177e1"};
            baseMagazineConfidence = "ambiguous";
            compatibleMagazines[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
            compatibleAttachments[] = {"vn_o_9x_m16"};
        };
    };

    class SourceMagazines
    {
        class vn_20mm_dgn_wp_mag
        {
            className = "vn_20mm_dgn_wp_mag";
            displayName = "DGN 20mm WP";
            category = "grenade_20mm";
            ammoClass = "vn_22mm_m19_wp_ammo";
            traits[] = {"grenade_20mm", "wp"};
            compatibleWeapons[] = {"vn_kbkg_gl"};
        };
        class vn_20mm_f1n60_frag_mag
        {
            className = "vn_20mm_f1n60_frag_mag";
            displayName = "F1N60 20mm FRAG";
            category = "grenade_20mm";
            ammoClass = "vn_20mm_f1n60_frag_ammo";
            traits[] = {"grenade_20mm"};
            compatibleWeapons[] = {"vn_kbkg_gl"};
        };
        class vn_20mm_kgn_frag_mag
        {
            className = "vn_20mm_kgn_frag_mag";
            displayName = "KGN 20mm FRAG";
            category = "grenade_20mm";
            ammoClass = "vn_20mm_kgn_frag_ammo";
            traits[] = {"grenade_20mm"};
            compatibleWeapons[] = {"vn_kbkg_gl"};
        };
        class vn_20mm_pgn60_heat_mag
        {
            className = "vn_20mm_pgn60_heat_mag";
            displayName = "PGN60 20mm HEAT";
            category = "grenade_20mm";
            ammoClass = "vn_20mm_pgn60_heat_ammo";
            traits[] = {"grenade_20mm", "heat"};
            compatibleWeapons[] = {"vn_kbkg_gl"};
        };
        class vn_22mm_cs_mag
        {
            className = "vn_22mm_cs_mag";
            displayName = "22mm CS";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_cs_ammo";
            traits[] = {"cs", "grenade_22mm"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl", "vn_m4956_gl", "vn_sks_gl"};
        };
        class vn_22mm_he_mag
        {
            className = "vn_22mm_he_mag";
            displayName = "22mm FRAG";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_he_ammo";
            traits[] = {"grenade_22mm"};
            compatibleWeapons[] = {"vn_m4956_gl"};
        };
        class vn_22mm_lume_mag
        {
            className = "vn_22mm_lume_mag";
            displayName = "22mm LUME";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_lume_ammo";
            traits[] = {"flare", "grenade_22mm"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl", "vn_m4956_gl", "vn_sks_gl"};
        };
        class vn_22mm_m17_frag_mag
        {
            className = "vn_22mm_m17_frag_mag";
            displayName = "M17 22mm FRAG";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m17_frag_ammo";
            traits[] = {"grenade_22mm"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl"};
        };
        class vn_22mm_m19_wp_mag
        {
            className = "vn_22mm_m19_wp_mag";
            displayName = "M19 22mm WP";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m19_wp_ammo";
            traits[] = {"grenade_22mm", "wp"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl", "vn_m4956_gl", "vn_sks_gl"};
        };
        class vn_22mm_m1a2_frag_mag
        {
            className = "vn_22mm_m1a2_frag_mag";
            displayName = "M1A2 22mm FRAG";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m1a2_frag_ammo";
            traits[] = {"grenade_22mm"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl"};
        };
        class vn_22mm_m22_smoke_mag
        {
            className = "vn_22mm_m22_smoke_mag";
            displayName = "M22 22mm SMOKE";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m22_smoke_ammo";
            traits[] = {"grenade_22mm", "smoke"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl", "vn_m4956_gl", "vn_sks_gl"};
        };
        class vn_22mm_m60_frag_mag
        {
            className = "vn_22mm_m60_frag_mag";
            displayName = "M60 22mm FRAG";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m60_frag_ammo";
            traits[] = {"grenade_22mm"};
            compatibleWeapons[] = {"vn_sks_gl"};
        };
        class vn_22mm_m60_heat_mag
        {
            className = "vn_22mm_m60_heat_mag";
            displayName = "M60 22mm HEAT";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m60_heat_ammo";
            traits[] = {"grenade_22mm", "heat"};
            compatibleWeapons[] = {"vn_sks_gl"};
        };
        class vn_22mm_m61_frag_mag
        {
            className = "vn_22mm_m61_frag_mag";
            displayName = "M61 22mm FRAG";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m61_frag_ammo";
            traits[] = {"grenade_22mm"};
            compatibleWeapons[] = {"vn_l1a1_01_gl", "vn_l1a1_02_gl"};
        };
        class vn_22mm_m9_heat_mag
        {
            className = "vn_22mm_m9_heat_mag";
            displayName = "M9 22mm HEAT";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_m9_heat_ammo";
            traits[] = {"grenade_22mm", "heat"};
            compatibleWeapons[] = {"vn_m1903_gl", "vn_m1_garand_gl", "vn_m1carbine_gl", "vn_m2carbine_gl", "vn_m4956_gl"};
        };
        class vn_22mm_n94_heat_mag
        {
            className = "vn_22mm_n94_heat_mag";
            displayName = "N94 22mm HEAT";
            category = "grenade_22mm";
            ammoClass = "vn_22mm_n94_heat_ammo";
            traits[] = {"grenade_22mm", "heat"};
            compatibleWeapons[] = {"vn_l1a1_01_gl", "vn_l1a1_02_gl"};
        };
        class vn_40mm_m381_he_mag
        {
            className = "vn_40mm_m381_he_mag";
            displayName = "M381 40mm HE";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m381_he_ammo";
            traits[] = {"grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m397_ab_mag
        {
            className = "vn_40mm_m397_ab_mag";
            displayName = "M397 40mm Airburst";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m397_ab_ammo";
            traits[] = {"airburst", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m406_he_mag
        {
            className = "vn_40mm_m406_he_mag";
            displayName = "M406 40mm HE";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m406_he_ammo";
            traits[] = {"grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m433_hedp_mag
        {
            className = "vn_40mm_m433_hedp_mag";
            displayName = "M433 40mm HEDP";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m433_hedp_ammo";
            traits[] = {"grenade_40mm", "hedp"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m576_buck_mag
        {
            className = "vn_40mm_m576_buck_mag";
            displayName = "M576 40mm Buckshot";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m576_buck_ammo";
            traits[] = {"buckshot", "grenade_40mm"};
            compatibleWeapons[] = {"vn_m79", "vn_m79_p"};
        };
        class vn_40mm_m583_flare_w_mag
        {
            className = "vn_40mm_m583_flare_w_mag";
            displayName = "M583 40mm Flare W";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m583_flare_w_ammo";
            traits[] = {"flare", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m651_cs_mag
        {
            className = "vn_40mm_m651_cs_mag";
            displayName = "M651 40mm CS Gas";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m651_cs_ammo";
            traits[] = {"cs", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m661_flare_g_mag
        {
            className = "vn_40mm_m661_flare_g_mag";
            displayName = "M661 40mm Flare G";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m661_flare_g_ammo";
            traits[] = {"flare", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m662_flare_r_mag
        {
            className = "vn_40mm_m662_flare_r_mag";
            displayName = "M662 40mm Flare R";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m662_flare_r_ammo";
            traits[] = {"flare", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m680_smoke_w_mag
        {
            className = "vn_40mm_m680_smoke_w_mag";
            displayName = "M680 40mm Smoke W";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m680_smoke_w_ammo";
            traits[] = {"grenade_40mm", "smoke"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m682_smoke_r_mag
        {
            className = "vn_40mm_m682_smoke_r_mag";
            displayName = "M682 40mm Smoke R";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m682_smoke_r_ammo";
            traits[] = {"grenade_40mm", "smoke"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m695_flare_y_mag
        {
            className = "vn_40mm_m695_flare_y_mag";
            displayName = "M695 40mm Flare Y";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m695_flare_y_ammo";
            traits[] = {"flare", "grenade_40mm"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m715_smoke_g_mag
        {
            className = "vn_40mm_m715_smoke_g_mag";
            displayName = "M715 40mm Smoke G";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m715_smoke_g_ammo";
            traits[] = {"grenade_40mm", "smoke"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m716_smoke_y_mag
        {
            className = "vn_40mm_m716_smoke_y_mag";
            displayName = "M716 40mm Smoke Y";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m716_smoke_y_ammo";
            traits[] = {"grenade_40mm", "smoke"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_40mm_m717_smoke_p_mag
        {
            className = "vn_40mm_m717_smoke_p_mag";
            displayName = "M717 40mm Smoke P";
            category = "grenade_40mm";
            ammoClass = "vn_40mm_m717_smoke_p_ammo";
            traits[] = {"grenade_40mm", "smoke"};
            compatibleWeapons[] = {"vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l34a1_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_xm148", "vn_m79", "vn_m79_p", "vn_xm16e1_xm148", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo"};
        };
        class vn_b_item_bandage_01
        {
            className = "vn_b_item_bandage_01";
            displayName = "Bandage";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_b_item_bugjuice_01
        {
            className = "vn_b_item_bugjuice_01";
            displayName = "Bug Juice";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_b_item_cigs_01
        {
            className = "vn_b_item_cigs_01";
            displayName = "Cigarettes";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_b_item_gunoil_01
        {
            className = "vn_b_item_gunoil_01";
            displayName = "Gun Oil";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_b_item_lighter_01
        {
            className = "vn_b_item_lighter_01";
            displayName = "Lighter";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_b_item_rations_01
        {
            className = "vn_b_item_rations_01";
            displayName = "Rations";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_carbine_15_mag
        {
            className = "vn_carbine_15_mag";
            displayName = "15Rnd. M1/M2 Carbine Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x33";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1carbine", "vn_m1carbine_bayo", "vn_m1carbine_gl", "vn_m1carbine_sniper", "vn_m2carbine", "vn_m2carbine_bayo", "vn_m2carbine_gl", "vn_m2carbine_sniper", "vn_m3carbine"};
        };
        class vn_carbine_15_t_mag
        {
            className = "vn_carbine_15_t_mag";
            displayName = "15Rnd. M1/M2 Carbine Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x33";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1carbine", "vn_m1carbine_bayo", "vn_m1carbine_gl", "vn_m1carbine_sniper", "vn_m2carbine", "vn_m2carbine_bayo", "vn_m2carbine_gl", "vn_m2carbine_sniper", "vn_m3carbine"};
        };
        class vn_carbine_30_mag
        {
            className = "vn_carbine_30_mag";
            displayName = "30Rnd. M1/M2 Carbine Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x33";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1carbine", "vn_m1carbine_bayo", "vn_m1carbine_gl", "vn_m1carbine_sniper", "vn_m2carbine", "vn_m2carbine_bayo", "vn_m2carbine_gl", "vn_m2carbine_sniper", "vn_m3carbine"};
        };
        class vn_carbine_30_t_mag
        {
            className = "vn_carbine_30_t_mag";
            displayName = "30Rnd. M1/M2 Carbine Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x33";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1carbine", "vn_m1carbine_bayo", "vn_m1carbine_gl", "vn_m1carbine_sniper", "vn_m2carbine", "vn_m2carbine_bayo", "vn_m2carbine_gl", "vn_m2carbine_sniper", "vn_m3carbine"};
        };
        class vn_chicom_grenade_mag
        {
            className = "vn_chicom_grenade_mag";
            displayName = "Grenade Chicom (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_chicom_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_dp28_mag
        {
            className = "vn_dp28_mag";
            displayName = "47Rnd. DP-27 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x54";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_dp28"};
        };
        class vn_f1_grenade_mag
        {
            className = "vn_f1_grenade_mag";
            displayName = "Grenade F-1 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_f1_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_f1_smg_mag
        {
            className = "vn_f1_smg_mag";
            displayName = "34Rnd. F1/L2A3/L34A1 Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_f1_smg", "vn_f1_smg_bayo", "vn_l2a3", "vn_l2a3_f", "vn_l34a1", "vn_l34a1_f", "vn_l34a1_xm148"};
        };
        class vn_f1_smg_t_mag
        {
            className = "vn_f1_smg_t_mag";
            displayName = "34Rnd. F1/L2A3/L34A1 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_f1_smg", "vn_f1_smg_bayo", "vn_l2a3", "vn_l2a3_f", "vn_l34a1", "vn_l34a1_f", "vn_l34a1_xm148"};
        };
        class vn_gun_m61a1_640_mag
        {
            className = "vn_gun_m61a1_640_mag";
            displayName = "M61A1 20mm";
            category = "rifle_mag";
            ammoClass = "vn_20x110_x6";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m61a1"};
        };
        class vn_hd_mag
        {
            className = "vn_hd_mag";
            displayName = "10Rnd. HD Mag";
            category = "pistol_mag";
            ammoClass = "vn_560x15";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_hd"};
        };
        class vn_hp_mag
        {
            className = "vn_hp_mag";
            displayName = "13Rnd. HP/ M1 Shorty Mag";
            category = "pistol_mag";
            ammoClass = "vn_9x19";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_hp", "vn_hp_sd", "vn_m1carbine_shorty"};
        };
        class vn_izh54_mag
        {
            className = "vn_izh54_mag";
            displayName = "2Rnd. ISh-54 Reload (Buckshot)";
            category = "shotgun_mag";
            ammoClass = "vn_12g_buck_ns";
            traits[] = {"buckshot", "shotgun_mag"};
            compatibleWeapons[] = {"vn_izh54", "vn_izh54_p", "vn_izh54_shorty"};
        };
        class vn_izh54_so_mag
        {
            className = "vn_izh54_so_mag";
            displayName = "2Rnd. ISh-54 Sawn-off (Buckshot)";
            category = "shotgun_mag";
            ammoClass = "vn_12g_buck_so";
            traits[] = {"buckshot", "shotgun_mag"};
            compatibleWeapons[] = {"vn_izh54_p", "vn_izh54_shorty"};
        };
        class vn_k98k_mag
        {
            className = "vn_k98k_mag";
            displayName = "5Rnd. K98K Clip";
            category = "rifle_mag";
            ammoClass = "vn_792x57";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_k98k", "vn_k98k_bayo", "vn_k98k_mrk", "vn_k98k_mrk_camo"};
        };
        class vn_k98k_t_mag
        {
            className = "vn_k98k_t_mag";
            displayName = "5Rnd. K98K Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_792x57";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_k98k", "vn_k98k_bayo", "vn_k98k_mrk", "vn_k98k_mrk_camo"};
        };
        class vn_kbkg_mag
        {
            className = "vn_kbkg_mag";
            displayName = "10Rnd. KBKG Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_ak_01", "vn_kbkg", "vn_kbkg_gl", "vn_type56", "vn_type56_bayo"};
        };
        class vn_kbkg_t_mag
        {
            className = "vn_kbkg_t_mag";
            displayName = "10Rnd. KBKG Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_ak_01", "vn_kbkg", "vn_kbkg_gl", "vn_type56", "vn_type56_bayo"};
        };
        class vn_l1a1_10_mag
        {
            className = "vn_l1a1_10_mag";
            displayName = "10Rnd. L1A1/L2A1/L4 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_10_t_mag
        {
            className = "vn_l1a1_10_t_mag";
            displayName = "10Rnd. L1A1/L2A1/L4 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_20_mag
        {
            className = "vn_l1a1_20_mag";
            displayName = "20Rnd. L1A1/L2A1/L4 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_20_t_mag
        {
            className = "vn_l1a1_20_t_mag";
            displayName = "20Rnd. L1A1/L2A1/L4 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_30_02_mag
        {
            className = "vn_l1a1_30_02_mag";
            displayName = "30Rnd. L2A1/L1A1/L4 Mag Straight";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_30_02_t_mag
        {
            className = "vn_l1a1_30_02_t_mag";
            displayName = "30Rnd. L2A1/L1A1/L4 Mag Straight (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_30_mag
        {
            className = "vn_l1a1_30_mag";
            displayName = "30Rnd. L2A1 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_l1a1_30_t_mag
        {
            className = "vn_l1a1_30_t_mag";
            displayName = "30Rnd. L2A1/L1A1/L4 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_l1a1_01", "vn_l1a1_01_bayo", "vn_l1a1_01_camo", "vn_l1a1_01_gl", "vn_l1a1_01_mrk", "vn_l1a1_02", "vn_l1a1_02_bayo", "vn_l1a1_02_camo", "vn_l1a1_02_gl", "vn_l1a1_02_mrk", "vn_l1a1_03", "vn_l1a1_03_camo", "vn_l1a1_xm148", "vn_l1a1_xm148_camo", "vn_l2a1_01", "vn_l4"};
        };
        class vn_m10_mag
        {
            className = "vn_m10_mag";
            displayName = "6Rnd. .38 revolver";
            category = "pistol_mag";
            ammoClass = "vn_9x29";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_m10", "vn_m10_sd", "vn_p38s"};
        };
        class vn_m127_mag
        {
            className = "vn_m127_mag";
            displayName = "M127 Flare Launcher";
            category = "throwable_flare";
            ammoClass = "vn_m127_rocket_ammo";
            traits[] = {"flare", "throwable_flare"};
            compatibleWeapons[] = {"vn_m127"};
        };
        class vn_m128_mag
        {
            className = "vn_m128_mag";
            displayName = "M128 Flare Launcher (Green)";
            category = "throwable_flare";
            ammoClass = "vn_m128_rocket_ammo";
            traits[] = {"flare", "throwable_flare"};
            compatibleWeapons[] = {"vn_m127", "vn_rocket_m128_launcher"};
        };
        class vn_m129_mag
        {
            className = "vn_m129_mag";
            displayName = "M129 Flare Launcher (Red)";
            category = "throwable_flare";
            ammoClass = "vn_m129_rocket_ammo";
            traits[] = {"flare", "throwable_flare"};
            compatibleWeapons[] = {"vn_m127"};
        };
        class vn_m14_10_mag
        {
            className = "vn_m14_10_mag";
            displayName = "10Rnd. M14 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m14", "vn_m14_bayo", "vn_m14_camo", "vn_m14_sd", "vn_m14a1", "vn_m14a1_bipod", "vn_m14a1_camo", "vn_m14a1_nvg", "vn_m14a1_shorty", "vn_m14a1_shorty_fs", "vn_m14a1_sniper", "vn_m21", "vn_m21_nvg", "vn_m21_nvg_sd", "vn_m21_sd"};
        };
        class vn_m14_10_t_mag
        {
            className = "vn_m14_10_t_mag";
            displayName = "10Rnd. M14 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m14", "vn_m14_bayo", "vn_m14_camo", "vn_m14_sd", "vn_m14a1", "vn_m14a1_bipod", "vn_m14a1_camo", "vn_m14a1_nvg", "vn_m14a1_shorty", "vn_m14a1_shorty_fs", "vn_m14a1_sniper", "vn_m21", "vn_m21_nvg", "vn_m21_nvg_sd", "vn_m21_sd"};
        };
        class vn_m14_early_grenade_mag
        {
            className = "vn_m14_early_grenade_mag";
            displayName = "Grenade M14-A (Incendiary)";
            category = "throwable_grenade";
            ammoClass = "vn_m14_p_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_m14_grenade_mag
        {
            className = "vn_m14_grenade_mag";
            displayName = "Grenade M14 (Incendiary)";
            category = "throwable_grenade";
            ammoClass = "vn_m14_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_m14_mag
        {
            className = "vn_m14_mag";
            displayName = "20Rnd. M14 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m14", "vn_m14_bayo", "vn_m14_camo", "vn_m14_sd", "vn_m14a1", "vn_m14a1_bipod", "vn_m14a1_camo", "vn_m14a1_nvg", "vn_m14a1_shorty", "vn_m14a1_shorty_fs", "vn_m14a1_sniper", "vn_m21", "vn_m21_nvg", "vn_m21_nvg_sd", "vn_m21_sd"};
        };
        class vn_m14_t_mag
        {
            className = "vn_m14_t_mag";
            displayName = "20Rnd. M14 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m14", "vn_m14_bayo", "vn_m14_camo", "vn_m14_sd", "vn_m14a1", "vn_m14a1_bipod", "vn_m14a1_camo", "vn_m14a1_nvg", "vn_m14a1_shorty", "vn_m14a1_shorty_fs", "vn_m14a1_sniper", "vn_m21", "vn_m21_nvg", "vn_m21_nvg_sd", "vn_m21_sd"};
        };
        class vn_m16_20_mag
        {
            className = "vn_m16_20_mag";
            displayName = "20Rnd. M16 Mag";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_20_t_mag
        {
            className = "vn_m16_20_t_mag";
            displayName = "20Rnd. M16 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_30_mag
        {
            className = "vn_m16_30_mag";
            displayName = "30Rnd. M16 Mag";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_30_t_mag
        {
            className = "vn_m16_30_t_mag";
            displayName = "30Rnd. M16 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_40_mag
        {
            className = "vn_m16_40_mag";
            displayName = "20Rnd. M16 Mag (Dual)";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"dual", "rifle_mag"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_40_t_mag
        {
            className = "vn_m16_40_t_mag";
            displayName = "20Rnd. M16 Mag (Tracer/ Dual)";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"dual", "rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_gau5a", "vn_gau5a_mrk", "vn_m16", "vn_m16_bayo", "vn_m16_camo", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_muzzle", "vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf", "vn_m16_usaf_bayo", "vn_m16_usaf_mrk", "vn_m16_usaf_nvg", "vn_m16_usaf_sniper", "vn_m16_xm148", "vn_revive_weapon", "vn_xm16e1", "vn_xm16e1_bayo", "vn_xm16e1_mrk", "vn_xm16e1_nvg", "vn_xm16e1_sniper", "vn_xm16e1_xm148", "vn_xm177", "vn_xm177_camo", "vn_xm177_fg", "vn_xm177_m203", "vn_xm177_m203_camo", "vn_xm177_mrk", "vn_xm177_muzzle", "vn_xm177_nvg", "vn_xm177_short", "vn_xm177_sniper", "vn_xm177_stock", "vn_xm177_stock_camo", "vn_xm177_xm148", "vn_xm177_xm148_camo", "vn_xm177e1", "vn_xm177e1_camo", "vn_xm177e1_mrk", "vn_xm177e1_nvg", "vn_xm177e1_sniper"};
        };
        class vn_m16_mag_base
        {
            className = "vn_m16_mag_base";
            displayName = "20Rnd. M16 Mag";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag"};
        };
        class vn_m1895_mag
        {
            className = "vn_m1895_mag";
            displayName = "7Rnd. M1895 Reload";
            category = "pistol_mag";
            ammoClass = "vn_762x38";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_m1895", "vn_m1895_sd"};
        };
        class vn_m1897_buck_mag
        {
            className = "vn_m1897_buck_mag";
            displayName = "6Rnd. M1897 Reload (Buckshot)";
            category = "shotgun_mag";
            ammoClass = "vn_12g_buck";
            traits[] = {"buckshot", "shotgun_mag"};
            compatibleWeapons[] = {"vn_m1897", "vn_m1897_bayo"};
        };
        class vn_m1897_fl_mag
        {
            className = "vn_m1897_fl_mag";
            displayName = "6Rnd. M1897 Reload (Flechette)";
            category = "shotgun_mag";
            ammoClass = "vn_12g_fl";
            traits[] = {"flechette", "shotgun_mag"};
            compatibleWeapons[] = {"vn_m1897", "vn_m1897_bayo"};
        };
        class vn_m18_green_mag
        {
            className = "vn_m18_green_mag";
            displayName = "Grenade Smoke (Green)";
            category = "throwable_smoke";
            ammoClass = "vn_m18_green_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_m18_purple_mag
        {
            className = "vn_m18_purple_mag";
            displayName = "Grenade Smoke (Purple)";
            category = "throwable_smoke";
            ammoClass = "vn_m18_purple_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_m18_red_mag
        {
            className = "vn_m18_red_mag";
            displayName = "Grenade Smoke (Red)";
            category = "throwable_smoke";
            ammoClass = "vn_m18_red_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_m18_white_mag
        {
            className = "vn_m18_white_mag";
            displayName = "Grenade Smoke (White)";
            category = "throwable_smoke";
            ammoClass = "vn_m18_white_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_m18_yellow_mag
        {
            className = "vn_m18_yellow_mag";
            displayName = "Grenade Smoke (Yellow)";
            category = "throwable_smoke";
            ammoClass = "vn_m18_yellow_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_m1903_mag
        {
            className = "vn_m1903_mag";
            displayName = "5Rnd. M1903 Clip";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1903", "vn_m1903_bayo", "vn_m1903_gl", "vn_m1903_sniper"};
        };
        class vn_m1903_t_mag
        {
            className = "vn_m1903_t_mag";
            displayName = "5Rnd. M1903 Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1903", "vn_m1903_bayo", "vn_m1903_gl", "vn_m1903_sniper"};
        };
        class vn_m1911_mag
        {
            className = "vn_m1911_mag";
            displayName = "7Rnd. M1911 Mag";
            category = "pistol_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_m1911", "vn_m1911_sd", "vn_mx991_m1911", "vn_mx991_m1911_sd"};
        };
        class vn_m1918_mag
        {
            className = "vn_m1918_mag";
            displayName = "20Rnd. M1918 Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1918", "vn_m1918_bipod"};
        };
        class vn_m1918_t_mag
        {
            className = "vn_m1918_t_mag";
            displayName = "20Rnd. M1918 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1918", "vn_m1918_bipod"};
        };
        class vn_m1928_mag
        {
            className = "vn_m1928_mag";
            displayName = "50Rnd. M1928 Mag";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy"};
        };
        class vn_m1928_t_mag
        {
            className = "vn_m1928_t_mag";
            displayName = "50Rnd. M1928 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy"};
        };
        class vn_m1_garand_mag
        {
            className = "vn_m1_garand_mag";
            displayName = "8Rnd. M1 Garand Clip";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1_garand", "vn_m1_garand_bayo", "vn_m1_garand_gl", "vn_m1_garand_sniper"};
        };
        class vn_m1_garand_t_mag
        {
            className = "vn_m1_garand_t_mag";
            displayName = "8Rnd. M1 Garand Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x63";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1_garand", "vn_m1_garand_bayo", "vn_m1_garand_gl", "vn_m1_garand_sniper"};
        };
        class vn_m1a1_20_mag
        {
            className = "vn_m1a1_20_mag";
            displayName = "20Rnd. M1A1 Mag";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy", "vn_m1a1_tommy", "vn_m1a1_tommy_so"};
        };
        class vn_m1a1_20_t_mag
        {
            className = "vn_m1a1_20_t_mag";
            displayName = "20Rnd. M1A1 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy", "vn_m1a1_tommy", "vn_m1a1_tommy_so"};
        };
        class vn_m1a1_30_mag
        {
            className = "vn_m1a1_30_mag";
            displayName = "30Rnd. M1A1 Mag";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy", "vn_m1a1_tommy", "vn_m1a1_tommy_so"};
        };
        class vn_m1a1_30_t_mag
        {
            className = "vn_m1a1_30_t_mag";
            displayName = "30Rnd. M1A1 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1928_tommy", "vn_m1928a1_tommy", "vn_m1a1_tommy", "vn_m1a1_tommy_so"};
        };
        class vn_m20a1b1_heat_mag
        {
            className = "vn_m20a1b1_heat_mag";
            displayName = "Rocket M28A2 HEAT";
            category = "launcher_round";
            ammoClass = "vn_m20a1b1_heat_ammo";
            traits[] = {"heat", "launcher_round"};
            compatibleWeapons[] = {"vn_m20a1b1_01"};
        };
        class vn_m20a1b1_wp_mag
        {
            className = "vn_m20a1b1_wp_mag";
            displayName = "Rocket M30 WP";
            category = "launcher_round";
            ammoClass = "vn_m20a1b1_wp_ammo";
            traits[] = {"launcher_round", "wp"};
            compatibleWeapons[] = {"vn_m20a1b1_01"};
        };
        class vn_m34_grenade_mag
        {
            className = "vn_m34_grenade_mag";
            displayName = "Grenade M34 (WP)";
            category = "throwable_grenade";
            ammoClass = "vn_m34_grenade_ammo";
            traits[] = {"throwable_grenade", "wp"};
        };
        class vn_m36_mag
        {
            className = "vn_m36_mag";
            displayName = "5Rnd. M36 Clip";
            category = "rifle_mag";
            ammoClass = "vn_75x54";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m36", "vn_m36_bayo", "vn_m36_camo"};
        };
        class vn_m36_t_mag
        {
            className = "vn_m36_t_mag";
            displayName = "5Rnd. M36 Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_75x54";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m36", "vn_m36_bayo", "vn_m36_camo"};
        };
        class vn_m38_mag
        {
            className = "vn_m38_mag";
            displayName = "5Rnd. M38 Clip";
            category = "rifle_mag";
            ammoClass = "vn_762x54";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m1891", "vn_m1891_bayo", "vn_m38", "vn_m38_bayo", "vn_m9130", "vn_m9130_bayo", "vn_m9130_sniper", "vn_vz54", "vn_vz54_sniper", "vn_vz54_sniper_camo"};
        };
        class vn_m38_t_mag
        {
            className = "vn_m38_t_mag";
            displayName = "5Rnd. M38 Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x54";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m1891", "vn_m1891_bayo", "vn_m38", "vn_m38_bayo", "vn_m9130", "vn_m9130_bayo", "vn_m9130_sniper", "vn_vz54", "vn_vz54_sniper", "vn_vz54_sniper_camo"};
        };
        class vn_m3a1_mag
        {
            className = "vn_m3a1_mag";
            displayName = "30Rnd. M3A1 Mag";
            category = "smg_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_m3a1", "vn_m3sd"};
        };
        class vn_m3a1_t_mag
        {
            className = "vn_m3a1_t_mag";
            displayName = "30Rnd. M3A1 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_1143x23";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_m3a1", "vn_m3sd"};
        };
        class vn_m40a1_mag
        {
            className = "vn_m40a1_mag";
            displayName = "5Rnd. M40 Reload";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m40a1", "vn_m40a1_camo", "vn_m40a1_nvg", "vn_m40a1_nvg_sd", "vn_m40a1_sniper", "vn_m40a1_sniper_sd"};
        };
        class vn_m40a1_t_mag
        {
            className = "vn_m40a1_t_mag";
            displayName = "5Rnd. M40 Reload (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x51";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m40a1", "vn_m40a1_camo", "vn_m40a1_nvg", "vn_m40a1_nvg_sd", "vn_m40a1_sniper", "vn_m40a1_sniper_sd"};
        };
        class vn_m45_mag
        {
            className = "vn_m45_mag";
            displayName = "36Rnd. M/45 Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_m45", "vn_m45_camo", "vn_m45_fold", "vn_m45_sd"};
        };
        class vn_m45_t_mag
        {
            className = "vn_m45_t_mag";
            displayName = "36Rnd. M/45 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_m45", "vn_m45_camo", "vn_m45_fold", "vn_m45_sd"};
        };
        class vn_m4956_10_mag
        {
            className = "vn_m4956_10_mag";
            displayName = "10Rnd. M49/56 Carbine Mag";
            category = "rifle_mag";
            ammoClass = "vn_75x54";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m4956", "vn_m4956_bayo", "vn_m4956_gl", "vn_m4956_sniper"};
        };
        class vn_m4956_10_t_mag
        {
            className = "vn_m4956_10_t_mag";
            displayName = "10Rnd. M49/56 Carbine Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_75x54";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m4956", "vn_m4956_bayo", "vn_m4956_gl", "vn_m4956_sniper"};
        };
        class vn_m60_100_mag
        {
            className = "vn_m60_100_mag";
            displayName = "100Rnd. M60 Belt";
            category = "lmg_mag";
            ammoClass = "vn_762x51";
            traits[] = {"belt", "lmg_mag"};
            compatibleWeapons[] = {"vn_m60", "vn_m60_shorty", "vn_m60_shorty_camo"};
        };
        class vn_m61_grenade_mag
        {
            className = "vn_m61_grenade_mag";
            displayName = "Grenade M61 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_m61_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_m63a_100_mag
        {
            className = "vn_m63a_100_mag";
            displayName = "100Rnd. M63A Box";
            category = "lmg_mag";
            ammoClass = "vn_556x45";
            traits[] = {"box", "lmg_mag"};
            compatibleWeapons[] = {"vn_m63a_lmg", "vn_m63a_lmg_bipod"};
        };
        class vn_m63a_100_t_mag
        {
            className = "vn_m63a_100_t_mag";
            displayName = "100Rnd. M63A Box (Tracer)";
            category = "lmg_mag";
            ammoClass = "vn_556x45";
            traits[] = {"box", "lmg_mag", "tracer"};
            compatibleWeapons[] = {"vn_m63a_lmg", "vn_m63a_lmg_bipod"};
        };
        class vn_m63a_150_mag
        {
            className = "vn_m63a_150_mag";
            displayName = "150Rnd. M63A Drum";
            category = "lmg_mag";
            ammoClass = "vn_556x45";
            traits[] = {"drum", "lmg_mag"};
            compatibleWeapons[] = {"vn_m63a_cdo", "vn_m63a_cdo_bipod"};
        };
        class vn_m63a_150_t_mag
        {
            className = "vn_m63a_150_t_mag";
            displayName = "150Rnd. M63A Drum (Tracer)";
            category = "lmg_mag";
            ammoClass = "vn_556x45";
            traits[] = {"drum", "lmg_mag", "tracer"};
            compatibleWeapons[] = {"vn_m63a_cdo", "vn_m63a_cdo_bipod"};
        };
        class vn_m63a_30_mag
        {
            className = "vn_m63a_30_mag";
            displayName = "30Rnd. M63A Mag";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_m63a"};
        };
        class vn_m63a_30_t_mag
        {
            className = "vn_m63a_30_t_mag";
            displayName = "30Rnd. M63A Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_556x45";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_m63a"};
        };
        class vn_m67_grenade_mag
        {
            className = "vn_m67_grenade_mag";
            displayName = "Grenade M67 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_m67_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_m712_mag
        {
            className = "vn_m712_mag";
            displayName = "20Rnd. M712 Mag";
            category = "pistol_mag";
            ammoClass = "vn_762x25";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_m712"};
        };
        class vn_m72_fakemag
        {
            className = "vn_m72_fakemag";
            displayName = "Rocket M72 HEAT";
            category = "launcher_round";
            ammoClass = "vn_m72_fakeammo";
            traits[] = {"heat", "launcher_round"};
        };
        class vn_m72_mag
        {
            className = "vn_m72_mag";
            displayName = "Rocket M72 HEAT";
            category = "launcher_round";
            ammoClass = "vn_m72_rocket_ammo";
            traits[] = {"heat", "launcher_round"};
            compatibleWeapons[] = {"vn_m72"};
        };
        class vn_m7_grenade_mag
        {
            className = "vn_m7_grenade_mag";
            displayName = "Grenade M7A3 (CS Gas)";
            category = "throwable_grenade";
            ammoClass = "vn_m7_grenade_ammo";
            traits[] = {"cs", "throwable_grenade"};
        };
        class vn_mat49_mag
        {
            className = "vn_mat49_mag";
            displayName = "32Rnd. MAT-49 Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_mat49", "vn_mat49_f", "vn_mat49_sd"};
        };
        class vn_mat49_t_mag
        {
            className = "vn_mat49_t_mag";
            displayName = "32Rnd. MAT-49 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_mat49", "vn_mat49_f", "vn_mat49_sd"};
        };
        class vn_mat49_vc_mag
        {
            className = "vn_mat49_vc_mag";
            displayName = "32Rnd. MAT-49 Mag (VC)";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_mat49_vc"};
        };
        class vn_mat49_vc_t_mag
        {
            className = "vn_mat49_vc_t_mag";
            displayName = "32Rnd. MAT-49 Mag (VC/ Tracer)";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_mat49_vc"};
        };
        class vn_mc10_mag
        {
            className = "vn_mc10_mag";
            displayName = "32Rnd. MC-10 SMG Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_mc10", "vn_mc10_sd"};
        };
        class vn_mc10_t_mag
        {
            className = "vn_mc10_t_mag";
            displayName = "32Rnd. MC-10 SMG Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_mc10", "vn_mc10_sd"};
        };
        class vn_mg42_50_mag
        {
            className = "vn_mg42_50_mag";
            displayName = "50Rnd. MG42 Drum";
            category = "lmg_mag";
            ammoClass = "vn_792x57";
            traits[] = {"drum", "lmg_mag"};
            compatibleWeapons[] = {"vn_mg42"};
        };
        class vn_mg42_50_t_mag
        {
            className = "vn_mg42_50_t_mag";
            displayName = "50Rnd. MG42 Drum (Tracer)";
            category = "lmg_mag";
            ammoClass = "vn_792x57";
            traits[] = {"drum", "lmg_mag", "tracer"};
            compatibleWeapons[] = {"vn_mg42"};
        };
        class vn_mine_ammobox_range_mag
        {
            className = "vn_mine_ammobox_range_mag";
            displayName = "Mine Ammobox (booby-trapped)";
            category = "explosive";
            ammoClass = "vn_mine_ammobox_range_ammo";
            traits[] = {"box", "explosive"};
        };
        class vn_mine_bangalore_mag
        {
            className = "vn_mine_bangalore_mag";
            displayName = "Mine Bangalore (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_bangalore_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_bike_mag
        {
            className = "vn_mine_bike_mag";
            displayName = "Mine Bicycle (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_bike_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_bike_range_mag
        {
            className = "vn_mine_bike_range_mag";
            displayName = "Mine Bicycle (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_bike_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_cartridge_mag
        {
            className = "vn_mine_cartridge_mag";
            displayName = "Mine Cartridge (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_cartridge_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_chicom_no8_mag
        {
            className = "vn_mine_chicom_no8_mag";
            displayName = "Mine No 8 (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_chicom_no8_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_dh10_mag
        {
            className = "vn_mine_dh10_mag";
            displayName = "Mine DH10 (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_dh10_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_dh10_range_mag
        {
            className = "vn_mine_dh10_range_mag";
            displayName = "Mine DH10 (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_dh10_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_gboard_range_mag
        {
            className = "vn_mine_gboard_range_mag";
            displayName = "Trap RGD5 4m (AP)";
            category = "explosive";
            ammoClass = "vn_mine_gboard_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_jerrycan_mag
        {
            className = "vn_mine_jerrycan_mag";
            displayName = "Mine Jerry Can (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_jerrycan_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_jerrycan_range_mag
        {
            className = "vn_mine_jerrycan_range_mag";
            displayName = "Mine Jerry Can (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_jerrycan_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_lighter_mag
        {
            className = "vn_mine_lighter_mag";
            displayName = "Mine Lighter (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_lighter_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_limpet_01_mag
        {
            className = "vn_mine_limpet_01_mag";
            displayName = "Mine Limpet US (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_limpet_01_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_limpet_02_mag
        {
            className = "vn_mine_limpet_02_mag";
            displayName = "Mine Limpet Russian (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_limpet_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m112_remote_mag
        {
            className = "vn_mine_m112_remote_mag";
            displayName = "M112 Breaching charge";
            category = "rifle_mag";
            ammoClass = "vn_mine_m112_remote_ammo";
            traits[] = {"rifle_mag"};
        };
        class vn_mine_m14_mag
        {
            className = "vn_mine_m14_mag";
            displayName = "Mine M14 Toe-popper";
            category = "explosive";
            ammoClass = "vn_mine_m14_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m15_mag
        {
            className = "vn_mine_m15_mag";
            displayName = "Mine M15 Anti-Tank";
            category = "explosive";
            ammoClass = "vn_mine_m15_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m16_mag
        {
            className = "vn_mine_m16_mag";
            displayName = "Mine M16 Bounding";
            category = "explosive";
            ammoClass = "vn_mine_m16_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m18_fuze10_mag
        {
            className = "vn_mine_m18_fuze10_mag";
            displayName = "Mine M18 Claymore (10s Fuze)";
            category = "explosive";
            ammoClass = "vn_mine_m18_fuze10_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m18_mag
        {
            className = "vn_mine_m18_mag";
            displayName = "Mine M18 Claymore (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_m18_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m18_range_mag
        {
            className = "vn_mine_m18_range_mag";
            displayName = "Mine M18 Claymore (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_m18_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m18_wp_fuze10_mag
        {
            className = "vn_mine_m18_wp_fuze10_mag";
            displayName = "Mine M18/WP Claymore (10s Fuze)";
            category = "explosive";
            ammoClass = "vn_mine_m18_wp_fuze10_ammo";
            traits[] = {"explosive", "wp"};
        };
        class vn_mine_m18_wp_mag
        {
            className = "vn_mine_m18_wp_mag";
            displayName = "Mine M18/WP Claymore (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_m18_wp_ammo";
            traits[] = {"explosive", "wp"};
        };
        class vn_mine_m18_wp_range_mag
        {
            className = "vn_mine_m18_wp_range_mag";
            displayName = "Mine M18/WP Claymore (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_m18_wp_range_ammo";
            traits[] = {"explosive", "wp"};
        };
        class vn_mine_m18_x3_mag
        {
            className = "vn_mine_m18_x3_mag";
            displayName = "Mine M18 Claymore x3 (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_m18_x3_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_m18_x3_range_mag
        {
            className = "vn_mine_m18_x3_range_mag";
            displayName = "Mine M18 Claymore x3 (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_m18_x3_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_mortar_range_mag
        {
            className = "vn_mine_mortar_range_mag";
            displayName = "Mine Mortar (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_mortar_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_pot_mag
        {
            className = "vn_mine_pot_mag";
            displayName = "Mine Pot (Remote)";
            category = "explosive";
            ammoClass = "vn_mine_pot_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_pot_range_mag
        {
            className = "vn_mine_pot_range_mag";
            displayName = "Mine Pot (Proximity)";
            category = "explosive";
            ammoClass = "vn_mine_pot_range_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_punji_01_mag
        {
            className = "vn_mine_punji_01_mag";
            displayName = "Trap punji (Large)";
            category = "explosive";
            ammoClass = "vn_mine_punji_01_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_punji_02_mag
        {
            className = "vn_mine_punji_02_mag";
            displayName = "Trap punji (Small)";
            category = "explosive";
            ammoClass = "vn_mine_punji_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_punji_03_mag
        {
            className = "vn_mine_punji_03_mag";
            displayName = "Trap punji (Whip)";
            category = "explosive";
            ammoClass = "vn_mine_punji_03_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_punji_04_mag
        {
            className = "vn_mine_punji_04_mag";
            displayName = "Trap punji (Doorway)";
            category = "explosive";
            ammoClass = "vn_mine_punji_04_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_punji_05_mag
        {
            className = "vn_mine_punji_05_mag";
            displayName = "Trap punji (Side Whip Tripwire)";
            category = "explosive";
            ammoClass = "vn_mine_punji_05_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_satchel_remote_02_mag
        {
            className = "vn_mine_satchel_remote_02_mag";
            displayName = "Satchel charge";
            category = "explosive";
            ammoClass = "vn_mine_satchel_remote_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_satchelcharge_02_mag
        {
            className = "vn_mine_satchelcharge_02_mag";
            displayName = "Satchel charge (Sapper)";
            category = "explosive";
            ammoClass = "vn_mine_satchelcharge_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tm57_mag
        {
            className = "vn_mine_tm57_mag";
            displayName = "Mine TM-57 Anti-Tank";
            category = "explosive";
            ammoClass = "vn_mine_tm57_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_arty_mag
        {
            className = "vn_mine_tripwire_arty_mag";
            displayName = "Trap IED 4m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_arty_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_f1_02_mag
        {
            className = "vn_mine_tripwire_f1_02_mag";
            displayName = "Trap F-1 2m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_f1_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_f1_04_mag
        {
            className = "vn_mine_tripwire_f1_04_mag";
            displayName = "Trap F-1 4m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_f1_04_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_m16_02_mag
        {
            className = "vn_mine_tripwire_m16_02_mag";
            displayName = "Mine M16 2m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_m16_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_m16_04_mag
        {
            className = "vn_mine_tripwire_m16_04_mag";
            displayName = "Mine M16 4m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_m16_04_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_m49_02_mag
        {
            className = "vn_mine_tripwire_m49_02_mag";
            displayName = "Mine M49A1 2m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_m49_02_ammo";
            traits[] = {"explosive"};
        };
        class vn_mine_tripwire_m49_04_mag
        {
            className = "vn_mine_tripwire_m49_04_mag";
            displayName = "Mine M49A1 4m tripwire";
            category = "explosive";
            ammoClass = "vn_mine_tripwire_m49_04_ammo";
            traits[] = {"explosive"};
        };
        class vn_mk1_udg_mag
        {
            className = "vn_mk1_udg_mag";
            displayName = "6Rnd. Mk1 UDG Mag";
            category = "rifle_mag";
            ammoClass = "vn_mk1_udg_ammo";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_mk1_udg"};
        };
        class vn_mk22_mag
        {
            className = "vn_mk22_mag";
            displayName = "14Rnd. Mk22 Mag";
            category = "pistol_mag";
            ammoClass = "vn_9x19";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_mk22", "vn_mk22_sd"};
        };
        class vn_molotov_grenade_mag
        {
            className = "vn_molotov_grenade_mag";
            displayName = "Grenade (Molotov Cocktail)";
            category = "throwable_grenade";
            ammoClass = "vn_molotov_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_mp40_mag
        {
            className = "vn_mp40_mag";
            displayName = "32Rnd. MP40 Mag";
            category = "rifle_mag";
            ammoClass = "vn_9x19";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_mp40"};
        };
        class vn_mp40_t_mag
        {
            className = "vn_mp40_t_mag";
            displayName = "32Rnd. MP40 Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_9x19";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_mp40"};
        };
        class vn_mpu_mag
        {
            className = "vn_mpu_mag";
            displayName = "32Rnd. MPU SMG Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_mpu", "vn_mpu_sd"};
        };
        class vn_mpu_t_mag
        {
            className = "vn_mpu_t_mag";
            displayName = "32Rnd. MPU SMG Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_mpu", "vn_mpu_sd"};
        };
        class vn_p38_mag
        {
            className = "vn_p38_mag";
            displayName = "8Rnd. P38 Mag";
            category = "pistol_mag";
            ammoClass = "vn_9x19";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_p38", "vn_p38_sd"};
        };
        class vn_pk_100_mag
        {
            className = "vn_pk_100_mag";
            displayName = "100Rnd. PK Belt";
            category = "lmg_mag";
            ammoClass = "vn_762x54";
            traits[] = {"belt", "lmg_mag"};
            compatibleWeapons[] = {"vn_pk"};
        };
        class vn_pm_mag
        {
            className = "vn_pm_mag";
            displayName = "8Rnd. PM Mag";
            category = "pistol_mag";
            ammoClass = "vn_9x18";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_fkb1_pm", "vn_fkb1_pm_sd", "vn_pm", "vn_pm_sd"};
        };
        class vn_ppk_mag
        {
            className = "vn_ppk_mag";
            displayName = "7Rnd. PPK Mag";
            category = "pistol_mag";
            ammoClass = "vn_9x17";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_ppk", "vn_ppk_sd"};
        };
        class vn_pps_mag
        {
            className = "vn_pps_mag";
            displayName = "35Rnd. PPS Mag";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_pps43", "vn_pps52"};
        };
        class vn_pps_t_mag
        {
            className = "vn_pps_t_mag";
            displayName = "35Rnd. PPS Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_pps43", "vn_pps52"};
        };
        class vn_ppsh41_35_mag
        {
            className = "vn_ppsh41_35_mag";
            displayName = "35Rnd. PPSh-41 Mag";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_k50m", "vn_ppsh41"};
        };
        class vn_ppsh41_35_t_mag
        {
            className = "vn_ppsh41_35_t_mag";
            displayName = "35Rnd. PPSh-41 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_k50m", "vn_ppsh41"};
        };
        class vn_ppsh41_71_mag
        {
            className = "vn_ppsh41_71_mag";
            displayName = "71Rnd. PPSh-41 Mag";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_k50m", "vn_ppsh41"};
        };
        class vn_ppsh41_71_t_mag
        {
            className = "vn_ppsh41_71_t_mag";
            displayName = "71Rnd. PPSh-41 Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_762x25";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_k50m", "vn_ppsh41"};
        };
        class vn_prop_drink_01
        {
            className = "vn_prop_drink_01";
            displayName = "Canteen 0.75L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_02
        {
            className = "vn_prop_drink_02";
            displayName = "Canteen 1L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_03
        {
            className = "vn_prop_drink_03";
            displayName = "Canteen 0.76L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_04
        {
            className = "vn_prop_drink_04";
            displayName = "Canteen 1.1L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_05
        {
            className = "vn_prop_drink_05";
            displayName = "Bottle 0.5L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_06
        {
            className = "vn_prop_drink_06";
            displayName = "Canteen 2L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_07_01
        {
            className = "vn_prop_drink_07_01";
            displayName = "Tilts Hot Sauce";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_07_02
        {
            className = "vn_prop_drink_07_02";
            displayName = "Hoangs Muoc Mam";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_07_03
        {
            className = "vn_prop_drink_07_03";
            displayName = "Napalm Sauce";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_08_01
        {
            className = "vn_prop_drink_08_01";
            displayName = "Savage Bia";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_09_01
        {
            className = "vn_prop_drink_09_01";
            displayName = "Whiskey";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_drink_10
        {
            className = "vn_prop_drink_10";
            displayName = "Water pack 2L";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_box_01_01
        {
            className = "vn_prop_food_box_01_01";
            displayName = "Ration box (LRP Ration Box)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_01_02
        {
            className = "vn_prop_food_box_01_02";
            displayName = "Ration box (PIR Ration Box)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_01_03
        {
            className = "vn_prop_food_box_01_03";
            displayName = "Ration box (MCI Ration Box)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_01
        {
            className = "vn_prop_food_box_02_01";
            displayName = "Ration box (Ham and Eggs Chopped)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_02
        {
            className = "vn_prop_food_box_02_02";
            displayName = "Ration box (Ham Fried)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_03
        {
            className = "vn_prop_food_box_02_03";
            displayName = "Ration box (Beans w/ Frankfurter Chunks)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_04
        {
            className = "vn_prop_food_box_02_04";
            displayName = "Ration box (Spaghetti w/ Ground Meat)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_05
        {
            className = "vn_prop_food_box_02_05";
            displayName = "Ration box (Turkey Loaf)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_06
        {
            className = "vn_prop_food_box_02_06";
            displayName = "Ration box (Pork Steak)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_07
        {
            className = "vn_prop_food_box_02_07";
            displayName = "Ration box (Beef w/ Spiced Sauce)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_box_02_08
        {
            className = "vn_prop_food_box_02_08";
            displayName = "Ration box (Chicken Boned)";
            category = "lmg_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"box", "lmg_mag"};
        };
        class vn_prop_food_can_01_01
        {
            className = "vn_prop_food_can_01_01";
            displayName = "Ration can (Beefsteak)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_02
        {
            className = "vn_prop_food_can_01_02";
            displayName = "Ration can (Spiced Sauce)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_03
        {
            className = "vn_prop_food_can_01_03";
            displayName = "Ration can (Turkey Loaf)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_04
        {
            className = "vn_prop_food_can_01_04";
            displayName = "Ration can (Ham, Fried)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_05
        {
            className = "vn_prop_food_can_01_05";
            displayName = "Ration can (Ham and Eggs Chopped)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_06
        {
            className = "vn_prop_food_can_01_06";
            displayName = "Ration can (Tuna)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_07
        {
            className = "vn_prop_food_can_01_07";
            displayName = "Ration can (Chicken and Noodles)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_08
        {
            className = "vn_prop_food_can_01_08";
            displayName = "Ration can (Chicken Boned)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_09
        {
            className = "vn_prop_food_can_01_09";
            displayName = "Ration can (Pork Slices with Juices)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_10
        {
            className = "vn_prop_food_can_01_10";
            displayName = "Ration can (B-1A Crackers and Candy)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_11
        {
            className = "vn_prop_food_can_01_11";
            displayName = "Ration can (B-2 Crackers and Cheese Spread)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_12
        {
            className = "vn_prop_food_can_01_12";
            displayName = "Ration can (Pound Cake)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_13
        {
            className = "vn_prop_food_can_01_13";
            displayName = "Ration can (Pecan Cake Roll)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_14
        {
            className = "vn_prop_food_can_01_14";
            displayName = "Ration can (Chocolate Nut Roll)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_15
        {
            className = "vn_prop_food_can_01_15";
            displayName = "Ration can (Fruitcake)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_01_16
        {
            className = "vn_prop_food_can_01_16";
            displayName = "Ration can (White Bread)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_01
        {
            className = "vn_prop_food_can_02_01";
            displayName = "Ration can (Beans, Meatballs, Tomato Sauce)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_02
        {
            className = "vn_prop_food_can_02_02";
            displayName = "Ration can (Ham and Lima Beans)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_03
        {
            className = "vn_prop_food_can_02_03";
            displayName = "Ration can (Beans, Frankfurter, Tomato Sauce)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_04
        {
            className = "vn_prop_food_can_02_04";
            displayName = "Ration can (Spaghetti, Ground Meat)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_05
        {
            className = "vn_prop_food_can_02_05";
            displayName = "Ration can (B-3 Cookies, Jam, Cocoa Powder)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_06
        {
            className = "vn_prop_food_can_02_06";
            displayName = "Ration can (Apricots)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_07
        {
            className = "vn_prop_food_can_02_07";
            displayName = "Ration can (Peaches)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_02_08
        {
            className = "vn_prop_food_can_02_08";
            displayName = "Ration can (Pears)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_03_01
        {
            className = "vn_prop_food_can_03_01";
            displayName = "Ration can (Peanut Butter)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_03_02
        {
            className = "vn_prop_food_can_03_02";
            displayName = "Ration can (Jam, Seedless Blackberry)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_03_03
        {
            className = "vn_prop_food_can_03_03";
            displayName = "Ration can (Pineapple Jam)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_can_03_04
        {
            className = "vn_prop_food_can_03_04";
            displayName = "Ration can (Cheese Spread)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_01
        {
            className = "vn_prop_food_fresh_01";
            displayName = "Orange 0.2Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_02
        {
            className = "vn_prop_food_fresh_02";
            displayName = "Pumpkin 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_03
        {
            className = "vn_prop_food_fresh_03";
            displayName = "Chicken 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_04
        {
            className = "vn_prop_food_fresh_04";
            displayName = "Shrimp 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_05
        {
            className = "vn_prop_food_fresh_05";
            displayName = "Fish 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_06
        {
            className = "vn_prop_food_fresh_06";
            displayName = "Pork 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_07
        {
            className = "vn_prop_food_fresh_07";
            displayName = "Snake 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_08
        {
            className = "vn_prop_food_fresh_08";
            displayName = "Tiger 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_09
        {
            className = "vn_prop_food_fresh_09";
            displayName = "Elephant 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_fresh_10
        {
            className = "vn_prop_food_fresh_10";
            displayName = "Rau Ma 3Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_01
        {
            className = "vn_prop_food_lrrp_01_01";
            displayName = "LRRP ration (Beef Hash)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_02
        {
            className = "vn_prop_food_lrrp_01_02";
            displayName = "LRRP ration (Chili Con Carne)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_03
        {
            className = "vn_prop_food_lrrp_01_03";
            displayName = "LRRP ration (Spaghetti w/ Meat Sauce)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_04
        {
            className = "vn_prop_food_lrrp_01_04";
            displayName = "LRRP ration (Beef and Rice)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_05
        {
            className = "vn_prop_food_lrrp_01_05";
            displayName = "LRRP ration (Chicken Stew)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_06
        {
            className = "vn_prop_food_lrrp_01_06";
            displayName = "LRRP ration (Pork w/ Escalloped Potatoes)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_07
        {
            className = "vn_prop_food_lrrp_01_07";
            displayName = "LRRP ration (Beef Stew)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_lrrp_01_08
        {
            className = "vn_prop_food_lrrp_01_08";
            displayName = "LRRP ration (Chicken and Rice)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01
        {
            className = "vn_prop_food_meal_01";
            displayName = "Rations 0.75Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_01
        {
            className = "vn_prop_food_meal_01_01";
            displayName = "Meal (Fox Hole Dinner for Two)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_02
        {
            className = "vn_prop_food_meal_01_02";
            displayName = "Meal (Soup Du Jour)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_03
        {
            className = "vn_prop_food_meal_01_03";
            displayName = "Meal (Breast of Chicken Under Bullets)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_04
        {
            className = "vn_prop_food_meal_01_04";
            displayName = "Meal (Battlefield Fufu)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_05
        {
            className = "vn_prop_food_meal_01_05";
            displayName = "Meal (Ham with Spiced Apricots)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_06
        {
            className = "vn_prop_food_meal_01_06";
            displayName = "Meal (Pork Mandarin)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_07
        {
            className = "vn_prop_food_meal_01_07";
            displayName = "Meal (Tin Can Casserole)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_08
        {
            className = "vn_prop_food_meal_01_08";
            displayName = "Meal (Creamed Turkey on Toast)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_09
        {
            className = "vn_prop_food_meal_01_09";
            displayName = "Meal (Fish with Front line Stuffing)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_10
        {
            className = "vn_prop_food_meal_01_10";
            displayName = "Meal (Combat Zone Burgoo)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_11
        {
            className = "vn_prop_food_meal_01_11";
            displayName = "Meal (Patrol Chicken Soup)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_12
        {
            className = "vn_prop_food_meal_01_12";
            displayName = "Meal (Guard Relief Eggs Benedict)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_13
        {
            className = "vn_prop_food_meal_01_13";
            displayName = "Meal (Beefsteak En Croute)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_14
        {
            className = "vn_prop_food_meal_01_14";
            displayName = "Meal (Curried Meat Balls Over Rice)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_15
        {
            className = "vn_prop_food_meal_01_15";
            displayName = "Meal (Cease Fire Casserole)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_16
        {
            className = "vn_prop_food_meal_01_16";
            displayName = "Meal (Rice Paddy Shrimp)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_17
        {
            className = "vn_prop_food_meal_01_17";
            displayName = "Meal (Battlefield Birthday Cake)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_01_18
        {
            className = "vn_prop_food_meal_01_18";
            displayName = "Meal (Pecan Cake Roll, Peanut Butter Sauce)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_01
        {
            className = "vn_prop_food_meal_02_01";
            displayName = "Meal (Con ho)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_02
        {
            className = "vn_prop_food_meal_02_02";
            displayName = "Meal (Con voi)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_03
        {
            className = "vn_prop_food_meal_02_03";
            displayName = "Meal (Con ran)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_04
        {
            className = "vn_prop_food_meal_02_04";
            displayName = "Meal (Cha ca la vong)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_05
        {
            className = "vn_prop_food_meal_02_05";
            displayName = "Meal (Con tom)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_meal_02_06
        {
            className = "vn_prop_food_meal_02_06";
            displayName = "Meal (Pho ga)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_pir_01_01
        {
            className = "vn_prop_food_pir_01_01";
            displayName = "PIR ration (Beef)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_pir_01_02
        {
            className = "vn_prop_food_pir_01_02";
            displayName = "PIR ration (Fish and Squid)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_pir_01_03
        {
            className = "vn_prop_food_pir_01_03";
            displayName = "PIR ration (Shrimp and Mushroom)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_pir_01_04
        {
            className = "vn_prop_food_pir_01_04";
            displayName = "PIR ration (Mutton)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_pir_01_05
        {
            className = "vn_prop_food_pir_01_05";
            displayName = "PIR ration (Sausage)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_sack_01
        {
            className = "vn_prop_food_sack_01";
            displayName = "Rice 1Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_food_sack_02
        {
            className = "vn_prop_food_sack_02";
            displayName = "Rice 4Kg";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_fort_mag
        {
            className = "vn_prop_fort_mag";
            displayName = "Sandbag 01";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_med_antibiotics
        {
            className = "vn_prop_med_antibiotics";
            displayName = "Meds (Anti-biotics)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"cs", "rifle_mag"};
        };
        class vn_prop_med_antimalaria
        {
            className = "vn_prop_med_antimalaria";
            displayName = "Meds (Anti-malaria)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_med_antivenom
        {
            className = "vn_prop_med_antivenom";
            displayName = "Meds (Anti-venom)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_med_dysentery
        {
            className = "vn_prop_med_dysentery";
            displayName = "Meds (Dysentery)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_med_painkillers
        {
            className = "vn_prop_med_painkillers";
            displayName = "Meds (Pain-killers)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_prop_med_wormpowder
        {
            className = "vn_prop_med_wormpowder";
            displayName = "Meds (Worm-powder)";
            category = "rifle_mag";
            ammoClass = "FakeAmmo";
            traits[] = {"rifle_mag"};
        };
        class vn_rdg2_mag
        {
            className = "vn_rdg2_mag";
            displayName = "Grenade RDG-2 Smoke (White)";
            category = "throwable_smoke";
            ammoClass = "vn_rdg2_ammo";
            traits[] = {"smoke", "throwable_smoke"};
        };
        class vn_rg42_grenade_mag
        {
            className = "vn_rg42_grenade_mag";
            displayName = "Grenade RG-42 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_rg42_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_rgd33_grenade_mag
        {
            className = "vn_rgd33_grenade_mag";
            displayName = "Grenade RGD-33 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_rgd33_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_rgd5_grenade_mag
        {
            className = "vn_rgd5_grenade_mag";
            displayName = "Grenade RGD-5 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_rgd5_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_rkg3_grenade_mag
        {
            className = "vn_rkg3_grenade_mag";
            displayName = "Grenade RKG-3 (HEAT)";
            category = "throwable_grenade";
            ammoClass = "vn_rkg3_grenade_ammo";
            traits[] = {"heat", "throwable_grenade"};
        };
        class vn_rpd_100_mag
        {
            className = "vn_rpd_100_mag";
            displayName = "100Rnd. RPD Belt";
            category = "lmg_mag";
            ammoClass = "vn_762x39";
            traits[] = {"belt", "lmg_mag"};
            compatibleWeapons[] = {"vn_rpd", "vn_rpd_shorty", "vn_rpd_shorty_01"};
        };
        class vn_rpd_125_mag
        {
            className = "vn_rpd_125_mag";
            displayName = "125Rnd. RPD Belt";
            category = "lmg_mag";
            ammoClass = "vn_762x39";
            traits[] = {"belt", "lmg_mag"};
            compatibleWeapons[] = {"vn_rpd", "vn_rpd_shorty", "vn_rpd_shorty_01"};
        };
        class vn_rpg2_fuze_mag
        {
            className = "vn_rpg2_fuze_mag";
            displayName = "Rocket PG-2 Fuze";
            category = "launcher_round";
            ammoClass = "vn_rpg2_fuze_rocket_ammo";
            traits[] = {"launcher_round"};
            compatibleWeapons[] = {"vn_rpg2"};
        };
        class vn_rpg2_mag
        {
            className = "vn_rpg2_mag";
            displayName = "Rocket PG-2 HEAT";
            category = "launcher_round";
            ammoClass = "vn_rpg2_rocket_ammo";
            traits[] = {"heat", "launcher_round"};
            compatibleWeapons[] = {"vn_rpg2"};
        };
        class vn_rpg7_mag
        {
            className = "vn_rpg7_mag";
            displayName = "Rocket PG-7V HEAT";
            category = "launcher_round";
            ammoClass = "vn_rpg7_rocket_ammo";
            traits[] = {"heat", "launcher_round"};
            compatibleWeapons[] = {"vn_rpg7"};
        };
        class vn_sa2_camo_mag_x1
        {
            className = "vn_sa2_camo_mag_x1";
            displayName = "S-75 (SA-2)";
            category = "rifle_mag";
            ammoClass = "vn_sa2_camo_ammo";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_sa2_launcher"};
        };
        class vn_sa2_camo_mag_x4
        {
            className = "vn_sa2_camo_mag_x4";
            displayName = "S-75 (SA-2) x4";
            category = "rifle_mag";
            ammoClass = "vn_sa2_camo_ammo";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_sa2_launcher"};
        };
        class vn_sa2_mag_x1
        {
            className = "vn_sa2_mag_x1";
            displayName = "S-75 (SA-2)";
            category = "rifle_mag";
            ammoClass = "vn_sa2_ammo";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_sa2_launcher"};
        };
        class vn_sa2_mag_x4
        {
            className = "vn_sa2_mag_x4";
            displayName = "S-75 (SA-2) x4";
            category = "rifle_mag";
            ammoClass = "vn_sa2_ammo";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_sa2_launcher"};
        };
        class vn_sa7_mag
        {
            className = "vn_sa7_mag";
            displayName = "9K32 Strela-2 Missile";
            category = "launcher_round";
            ammoClass = "vn_sa7_rocket_ammo";
            traits[] = {"launcher_round"};
            compatibleWeapons[] = {"vn_sa7"};
        };
        class vn_sa7b_mag
        {
            className = "vn_sa7b_mag";
            displayName = "9K32 Strela-2M Missile";
            category = "launcher_round";
            ammoClass = "vn_sa7b_rocket_ammo";
            traits[] = {"launcher_round"};
            compatibleWeapons[] = {"vn_sa7b"};
        };
        class vn_satchelcharge_02_throw_mag
        {
            className = "vn_satchelcharge_02_throw_mag";
            displayName = "Satchel charge (Thrown)";
            category = "explosive";
            ammoClass = "vn_satchelcharge_02_throw_ammo";
            traits[] = {"explosive"};
        };
        class vn_sks_mag
        {
            className = "vn_sks_mag";
            displayName = "10Rnd. SKS Clip";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_sks", "vn_sks_bayo", "vn_sks_gl", "vn_sks_sniper"};
        };
        class vn_sks_t_mag
        {
            className = "vn_sks_t_mag";
            displayName = "10Rnd. SKS Clip (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_sks", "vn_sks_bayo", "vn_sks_gl", "vn_sks_sniper"};
        };
        class vn_sten_mag
        {
            className = "vn_sten_mag";
            displayName = "32Rnd. Sten Mk.II Mag";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_sten", "vn_sten_sd"};
        };
        class vn_sten_t_mag
        {
            className = "vn_sten_t_mag";
            displayName = "32Rnd. Sten Mk.II Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_9x19";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_sten", "vn_sten_sd"};
        };
        class vn_svd_mag
        {
            className = "vn_svd_mag";
            displayName = "10Rnd. SVD Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x54";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_svd", "vn_svd_sniper", "vn_svd_sniper_camo"};
        };
        class vn_svd_t_mag
        {
            className = "vn_svd_t_mag";
            displayName = "10Rnd. SVD Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x54";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_svd", "vn_svd_sniper", "vn_svd_sniper_camo"};
        };
        class vn_t67_grenade_mag
        {
            className = "vn_t67_grenade_mag";
            displayName = "Grenade Type67 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_t67_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_tt33_mag
        {
            className = "vn_tt33_mag";
            displayName = "8Rnd. TT-33 Mag";
            category = "pistol_mag";
            ammoClass = "vn_762x25";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_tt33"};
        };
        class vn_type56_mag
        {
            className = "vn_type56_mag";
            displayName = "30Rnd. Type 56/AK Mag";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag"};
            compatibleWeapons[] = {"vn_ak_01", "vn_kbkg", "vn_kbkg_gl", "vn_type56", "vn_type56_bayo"};
        };
        class vn_type56_t_mag
        {
            className = "vn_type56_t_mag";
            displayName = "30Rnd. Type 56/AK Mag (Tracer)";
            category = "rifle_mag";
            ammoClass = "vn_762x39";
            traits[] = {"rifle_mag", "tracer"};
            compatibleWeapons[] = {"vn_ak_01", "vn_kbkg", "vn_kbkg_gl", "vn_type56", "vn_type56_bayo"};
        };
        class vn_type64_mag
        {
            className = "vn_type64_mag";
            displayName = "9Rnd. Type 64 Mag";
            category = "pistol_mag";
            ammoClass = "vn_765x17";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_type64"};
        };
        class vn_type64_smg_mag
        {
            className = "vn_type64_smg_mag";
            displayName = "30Rnd. Type 64 SMG Mag";
            category = "smg_mag";
            ammoClass = "vn_765x17_t64";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_type64_f_smg", "vn_type64_smg"};
        };
        class vn_type64_smg_t_mag
        {
            className = "vn_type64_smg_t_mag";
            displayName = "30Rnd. Type 64 SMG Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_765x17_t64";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_type64_f_smg", "vn_type64_smg"};
        };
        class vn_v40_grenade_mag
        {
            className = "vn_v40_grenade_mag";
            displayName = "Grenade V40 (Frag)";
            category = "throwable_grenade";
            ammoClass = "vn_v40_grenade_ammo";
            traits[] = {"throwable_grenade"};
        };
        class vn_vz61_mag
        {
            className = "vn_vz61_mag";
            displayName = "20Rnd. VZ.61 SMG Mag";
            category = "smg_mag";
            ammoClass = "vn_765x17";
            traits[] = {"smg_mag"};
            compatibleWeapons[] = {"vn_vz61", "vn_vz61_p"};
        };
        class vn_vz61_t_mag
        {
            className = "vn_vz61_t_mag";
            displayName = "20Rnd. VZ.61 SMG Mag (Tracer)";
            category = "smg_mag";
            ammoClass = "vn_765x17";
            traits[] = {"smg_mag", "tracer"};
            compatibleWeapons[] = {"vn_vz61", "vn_vz61_p"};
        };
        class vn_welrod_mag
        {
            className = "vn_welrod_mag";
            displayName = "8Rnd. Welrod mag";
            category = "pistol_mag";
            ammoClass = "vn_765x17";
            traits[] = {"pistol_mag"};
            compatibleWeapons[] = {"vn_welrod"};
        };
    };

    class SourceItems
    {
        class vn_anpvs2_binoc
        {
            className = "vn_anpvs2_binoc";
            displayName = "Starlight ANPVS2 (NV)";
            itemType = "binocular";
            traits[] = {"binocular"};
        };
        class vn_b_camo_k98k
        {
            className = "vn_b_camo_k98k";
            displayName = "Camo wrap [K98K]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_k98k_mrk_camo"};
        };
        class vn_b_camo_m14
        {
            className = "vn_b_camo_m14";
            displayName = "Camo wrap [M14]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_m14_sd", "vn_m21_sd"};
        };
        class vn_b_camo_m14a1
        {
            className = "vn_b_camo_m14a1";
            displayName = "Camo wrap [M14A1]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_m14a1_camo", "vn_m14a1_nvg"};
        };
        class vn_b_camo_m1903
        {
            className = "vn_b_camo_m1903";
            displayName = "Camo wrap [M1903]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
        };
        class vn_b_camo_m1_garand
        {
            className = "vn_b_camo_m1_garand";
            displayName = "Camo wrap [M1 Garand]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_m1_garand_sniper"};
        };
        class vn_b_camo_m36
        {
            className = "vn_b_camo_m36";
            displayName = "Camo wrap [M36]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_m36_camo"};
        };
        class vn_b_camo_m40a1
        {
            className = "vn_b_camo_m40a1";
            displayName = "Camo wrap [M40]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_m40a1_sniper_sd"};
        };
        class vn_b_camo_m9130
        {
            className = "vn_b_camo_m9130";
            displayName = "Camo wrap [M9130]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
        };
        class vn_b_camo_svd
        {
            className = "vn_b_camo_svd";
            displayName = "Camo wrap [SVD]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_svd_sniper_camo"};
        };
        class vn_b_camo_vz54
        {
            className = "vn_b_camo_vz54";
            displayName = "Camo wrap [VZ54]";
            itemType = "bayonet";
            traits[] = {"bayonet", "camo"};
            compatibleWeapons[] = {"vn_vz54_sniper_camo"};
        };
        class vn_b_carbine
        {
            className = "vn_b_carbine";
            displayName = "Bayonet M4 [M1/ M2]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m1carbine_bayo", "vn_m2carbine_bayo"};
        };
        class vn_b_item_compass
        {
            className = "vn_b_item_compass";
            displayName = "Compass (US)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_b_item_compass_sog
        {
            className = "vn_b_item_compass_sog";
            displayName = "Compass (SOG)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_b_item_firstaidkit
        {
            className = "vn_b_item_firstaidkit";
            displayName = "First Aid Kit (US)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_b_item_map
        {
            className = "vn_b_item_map";
            displayName = "Map (US)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_b_item_medikit_01
        {
            className = "vn_b_item_medikit_01";
            displayName = "Medikit";
            itemType = "bayonet";
            traits[] = {"bayonet"};
        };
        class vn_b_item_radio_urc10
        {
            className = "vn_b_item_radio_urc10";
            displayName = "Radio (URC-10)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"INDEPENDENT", "WEST"};
        };
        class vn_b_item_toolkit
        {
            className = "vn_b_item_toolkit";
            displayName = "Toolkit";
            itemType = "bayonet";
            traits[] = {"bayonet"};
        };
        class vn_b_item_toolkit_weightless
        {
            className = "vn_b_item_toolkit_weightless";
            displayName = "Toolkit";
            itemType = "bayonet";
            traits[] = {"bayonet"};
        };
        class vn_b_item_trapkit
        {
            className = "vn_b_item_trapkit";
            displayName = "Trap Kit";
            itemType = "bayonet";
            traits[] = {"bayonet"};
        };
        class vn_b_item_watch
        {
            className = "vn_b_item_watch";
            displayName = "Watch (Savage)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_b_item_wiretap
        {
            className = "vn_b_item_wiretap";
            displayName = "Wire-tap set (414)";
            itemType = "bayonet";
            traits[] = {"bayonet"};
        };
        class vn_b_k98k
        {
            className = "vn_b_k98k";
            displayName = "Bayonet [K98K]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_k98k_bayo"};
        };
        class vn_b_l1a1
        {
            className = "vn_b_l1a1";
            displayName = "Bayonet L1A1 [L1A1/ F1]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_f1_smg_bayo", "vn_l1a1_01_bayo", "vn_l1a1_02_bayo"};
        };
        class vn_b_m14
        {
            className = "vn_b_m14";
            displayName = "Bayonet M6 [M14]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m14_bayo"};
        };
        class vn_b_m16
        {
            className = "vn_b_m16";
            displayName = "Bayonet M7 [M16]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m16_bayo", "vn_m16_usaf_bayo", "vn_xm16e1_bayo"};
        };
        class vn_b_m1897
        {
            className = "vn_b_m1897";
            displayName = "Bayonet M1917 [M1897]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m1897_bayo"};
        };
        class vn_b_m1903
        {
            className = "vn_b_m1903";
            displayName = "Bayonet [M1903]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m1903_bayo", "vn_m1903_sniper"};
        };
        class vn_b_m1_garand
        {
            className = "vn_b_m1_garand";
            displayName = "Bayonet M5 [M1 Garand]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m1_garand_bayo"};
        };
        class vn_b_m36
        {
            className = "vn_b_m36";
            displayName = "Bayonet Spike [M36]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m36_bayo"};
        };
        class vn_b_m38
        {
            className = "vn_b_m38";
            displayName = "Bayonet Spike [M38/ M91/30/ M1892]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m1891_bayo", "vn_m38_bayo", "vn_m9130_bayo"};
        };
        class vn_b_m4956
        {
            className = "vn_b_m4956";
            displayName = "Bayonet Model 58 [M49/56]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_m4956_bayo"};
        };
        class vn_b_sks
        {
            className = "vn_b_sks";
            displayName = "Bayonet Spike [M38]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_sks_bayo"};
        };
        class vn_b_type56
        {
            className = "vn_b_type56";
            displayName = "Bayonet Spike [Type56]";
            itemType = "bayonet";
            traits[] = {"bayonet"};
            compatibleWeapons[] = {"vn_type56_bayo"};
        };
        class vn_bipod_m14
        {
            className = "vn_bipod_m14";
            displayName = "Bipod [M14]";
            itemType = "bipod";
            traits[] = {"bipod"};
            compatibleWeapons[] = {"vn_m14a1_bipod", "vn_m14a1_sniper"};
        };
        class vn_bipod_m16
        {
            className = "vn_bipod_m16";
            displayName = "Bipod [M16]";
            itemType = "bipod";
            traits[] = {"bipod"};
            compatibleWeapons[] = {"vn_m16_sniper", "vn_m16_sniper_sd", "vn_xm16e1_sniper"};
        };
        class vn_bipod_m1918
        {
            className = "vn_bipod_m1918";
            displayName = "Bipod [M1918]";
            itemType = "bipod";
            traits[] = {"bipod"};
            compatibleWeapons[] = {"vn_m1918_bipod"};
        };
        class vn_bipod_m63a
        {
            className = "vn_bipod_m63a";
            displayName = "Bipod [M63A]";
            itemType = "bipod";
            traits[] = {"bipod"};
            compatibleWeapons[] = {"vn_m63a_cdo_bipod", "vn_m63a_lmg_bipod"};
        };
        class vn_camera_01
        {
            className = "vn_camera_01";
            displayName = "SOG 35mm Camera";
            itemType = "item";
            traits[] = {"item"};
        };
        class vn_m19_binocs_grey
        {
            className = "vn_m19_binocs_grey";
            displayName = "Binocular M19 Grey (7x50)";
            itemType = "binocular";
            traits[] = {"binocular"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_m19_binocs_grn
        {
            className = "vn_m19_binocs_grn";
            displayName = "Binocular M19 Green (7x50)";
            itemType = "binocular";
            traits[] = {"binocular"};
            sourceAffiliations[] = {"EAST", "INDEPENDENT", "WEST"};
        };
        class vn_mk21_binocs
        {
            className = "vn_mk21_binocs";
            displayName = "Binocular Mk21 (7x50)";
            itemType = "binocular";
            traits[] = {"binocular"};
            sourceAffiliations[] = {"WEST"};
        };
        class vn_o_1_5x_k98k
        {
            className = "vn_o_1_5x_k98k";
            displayName = "Optic [K98K 1.5x]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_k98k_mrk", "vn_k98k_mrk_camo"};
        };
        class vn_o_1x_sp_m16
        {
            className = "vn_o_1x_sp_m16";
            displayName = "Optic (M16 SP)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_gau5a_mrk"};
        };
        class vn_o_3x_l1a1
        {
            className = "vn_o_3x_l1a1";
            displayName = "Optic (L1A1 3x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_l1a1_01_mrk", "vn_l1a1_02_mrk"};
        };
        class vn_o_3x_m84
        {
            className = "vn_o_3x_m84";
            displayName = "Scope (M1/2 Carbine 2.2x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m1_garand_sniper", "vn_m1carbine_sniper", "vn_m2carbine_sniper"};
        };
        class vn_o_3x_m9130
        {
            className = "vn_o_3x_m9130";
            displayName = "Optic (M91/30 3.5x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m9130_sniper"};
        };
        class vn_o_3x_sks
        {
            className = "vn_o_3x_sks";
            displayName = "Optic (SKS 3.5x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_sks_sniper"};
        };
        class vn_o_3x_vz54
        {
            className = "vn_o_3x_vz54";
            displayName = "Optic (VZ54 2.5x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_vz54_sniper", "vn_vz54_sniper_camo"};
        };
        class vn_o_4x_m16
        {
            className = "vn_o_4x_m16";
            displayName = "Optic (M16 4x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m16_mrk", "vn_m16_mrk_sd", "vn_m16_usaf_mrk", "vn_xm16e1_mrk", "vn_xm177_mrk", "vn_xm177e1_mrk"};
        };
        class vn_o_4x_m4956
        {
            className = "vn_o_4x_m4956";
            displayName = "Scope (M49/56 3.5x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m4956_sniper"};
        };
        class vn_o_4x_svd
        {
            className = "vn_o_4x_svd";
            displayName = "Optic [SVD 4x]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_svd_sniper", "vn_svd_sniper_camo"};
        };
        class vn_o_8x_m1903
        {
            className = "vn_o_8x_m1903";
            displayName = "Optic [M1903 8x]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m1903_sniper"};
        };
        class vn_o_9x_m14
        {
            className = "vn_o_9x_m14";
            displayName = "Optic (M14 3-9x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m14a1_sniper", "vn_m21", "vn_m21_sd"};
        };
        class vn_o_9x_m16
        {
            className = "vn_o_9x_m16";
            displayName = "Optic (M16 3-9x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m16_sniper", "vn_m16_sniper_sd", "vn_m16_usaf_sniper", "vn_xm16e1_sniper", "vn_xm177_sniper", "vn_xm177e1_sniper"};
        };
        class vn_o_9x_m40a1
        {
            className = "vn_o_9x_m40a1";
            displayName = "Optic (M40 3-9x)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m40a1_sniper", "vn_m40a1_sniper_sd"};
        };
        class vn_o_9x_m40a1_camo
        {
            className = "vn_o_9x_m40a1_camo";
            displayName = "Optic (M40 3-9x camo)";
            itemType = "optic";
            traits[] = {"camo", "optic"};
        };
        class vn_o_anpvs2_m14
        {
            className = "vn_o_anpvs2_m14";
            displayName = "Scope (AN-PVS2 Starlight) [M14]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m14a1_nvg", "vn_m21_nvg", "vn_m21_nvg_sd"};
        };
        class vn_o_anpvs2_m16
        {
            className = "vn_o_anpvs2_m16";
            displayName = "Scope (AN-PVS2 Starlight) [XM177/M16]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m16_nvg", "vn_m16_nvg_sd", "vn_m16_usaf_nvg", "vn_xm16e1_nvg", "vn_xm177_nvg", "vn_xm177e1_nvg"};
        };
        class vn_o_anpvs2_m40a1
        {
            className = "vn_o_anpvs2_m40a1";
            displayName = "Scope (AN-PVS2 Starlight) [M40]";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m40a1_nvg", "vn_m40a1_nvg_sd"};
        };
        class vn_o_item_firstaidkit
        {
            className = "vn_o_item_firstaidkit";
            displayName = "First Aid Kit (PAVN)";
            itemType = "optic";
            traits[] = {"optic"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_o_item_map
        {
            className = "vn_o_item_map";
            displayName = "Map (PAVN)";
            itemType = "optic";
            traits[] = {"optic"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_o_item_radio_m252
        {
            className = "vn_o_item_radio_m252";
            displayName = "Field Telephone (M252)";
            itemType = "optic";
            traits[] = {"optic"};
            sourceAffiliations[] = {"EAST"};
        };
        class vn_o_m14_front
        {
            className = "vn_o_m14_front";
            displayName = "Optic (M14 Front Sight)";
            itemType = "optic";
            traits[] = {"optic"};
            compatibleWeapons[] = {"vn_m14a1_shorty_fs"};
        };
        class vn_s_hp
        {
            className = "vn_s_hp";
            displayName = "Suppressor 9mm [HP]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_hp_sd"};
        };
        class vn_s_m14
        {
            className = "vn_s_m14";
            displayName = "Suppressor [M14/M40]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m14_sd", "vn_m14a1_camo", "vn_m14a1_nvg", "vn_m21_nvg_sd", "vn_m21_sd", "vn_m40a1_nvg_sd", "vn_m40a1_sniper_sd"};
        };
        class vn_s_m16
        {
            className = "vn_s_m16";
            displayName = "Suppressor [M16]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m16_mrk_sd", "vn_m16_nvg_sd", "vn_m16_sd", "vn_m16_sniper_sd"};
        };
        class vn_s_m1895
        {
            className = "vn_s_m1895";
            displayName = "Suppressor [M1895]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m1895_sd"};
        };
        class vn_s_m1911
        {
            className = "vn_s_m1911";
            displayName = "Suppressor [M1911]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m1911_sd", "vn_mx991_m1911_sd"};
        };
        class vn_s_m3a1
        {
            className = "vn_s_m3a1";
            displayName = "Suppressor [M3]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m3sd"};
        };
        class vn_s_m45
        {
            className = "vn_s_m45";
            displayName = "Suppressor [M/45]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
        };
        class vn_s_m45_camo
        {
            className = "vn_s_m45_camo";
            displayName = "Suppressor [M/45 Camo]";
            itemType = "suppressor";
            traits[] = {"camo", "suppressor"};
            compatibleWeapons[] = {"vn_m45_sd"};
        };
        class vn_s_mat49
        {
            className = "vn_s_mat49";
            displayName = "Suppressor [MAT-49]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_mat49_sd"};
        };
        class vn_s_mc10
        {
            className = "vn_s_mc10";
            displayName = "Suppressor [MC-10]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_mc10_sd"};
        };
        class vn_s_mk22
        {
            className = "vn_s_mk22";
            displayName = "Suppressor [Mk22]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_m10_sd", "vn_mk22_sd"};
        };
        class vn_s_mpu
        {
            className = "vn_s_mpu";
            displayName = "Suppressor [MPU]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_mpu_sd"};
        };
        class vn_s_pm
        {
            className = "vn_s_pm";
            displayName = "Suppressor [PM]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_fkb1_pm_sd", "vn_pm_sd"};
        };
        class vn_s_ppk
        {
            className = "vn_s_ppk";
            displayName = "Suppressor 9mm [PPK/ P38]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_p38_sd", "vn_ppk_sd"};
        };
        class vn_s_sten
        {
            className = "vn_s_sten";
            displayName = "Suppressor [Sten Mk.II]";
            itemType = "suppressor";
            traits[] = {"suppressor"};
            compatibleWeapons[] = {"vn_sten_sd"};
        };
    };

    class WeaponMagazines
    {
        class vn_ak_01
        {
            values[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_dp28
        {
            values[] = {"vn_dp28_mag"};
        };
        class vn_f1_smg
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_f1_smg_bayo
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_fkb1_pm
        {
            values[] = {"vn_pm_mag"};
        };
        class vn_fkb1_pm_sd
        {
            values[] = {"vn_pm_mag"};
        };
        class vn_gau5a
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_gau5a_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_hd
        {
            values[] = {"vn_hd_mag"};
        };
        class vn_hp
        {
            values[] = {"vn_hp_mag"};
        };
        class vn_hp_sd
        {
            values[] = {"vn_hp_mag"};
        };
        class vn_izh54
        {
            values[] = {"vn_izh54_mag"};
        };
        class vn_izh54_p
        {
            values[] = {"vn_izh54_mag", "vn_izh54_so_mag"};
        };
        class vn_izh54_shorty
        {
            values[] = {"vn_izh54_mag", "vn_izh54_so_mag"};
        };
        class vn_k50m
        {
            values[] = {"vn_ppsh41_35_mag", "vn_ppsh41_35_t_mag", "vn_ppsh41_71_mag", "vn_ppsh41_71_t_mag"};
        };
        class vn_k98k
        {
            values[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
        };
        class vn_k98k_bayo
        {
            values[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
        };
        class vn_k98k_mrk
        {
            values[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
        };
        class vn_k98k_mrk_camo
        {
            values[] = {"vn_k98k_mag", "vn_k98k_t_mag"};
        };
        class vn_kbkg
        {
            values[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_kbkg_gl
        {
            values[] = {"vn_20mm_dgn_wp_mag", "vn_20mm_f1n60_frag_mag", "vn_20mm_kgn_frag_mag", "vn_20mm_pgn60_heat_mag", "vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_l1a1_01
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_01_bayo
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_01_camo
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_01_gl
        {
            values[] = {"vn_22mm_m61_frag_mag", "vn_22mm_n94_heat_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_01_mrk
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02_bayo
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02_camo
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02_gl
        {
            values[] = {"vn_22mm_m61_frag_mag", "vn_22mm_n94_heat_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_02_mrk
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_03
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_03_camo
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_xm148
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l1a1_xm148_camo
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l2a1_01
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_l2a3
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l2a3_f
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l34a1
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l34a1_f
        {
            values[] = {"vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l34a1_xm148
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_f1_smg_mag", "vn_f1_smg_t_mag"};
        };
        class vn_l4
        {
            values[] = {"vn_l1a1_10_mag", "vn_l1a1_10_t_mag", "vn_l1a1_20_mag", "vn_l1a1_20_t_mag", "vn_l1a1_30_02_mag", "vn_l1a1_30_02_t_mag", "vn_l1a1_30_mag", "vn_l1a1_30_t_mag"};
        };
        class vn_m10
        {
            values[] = {"vn_m10_mag"};
        };
        class vn_m10_sd
        {
            values[] = {"vn_m10_mag"};
        };
        class vn_m127
        {
            values[] = {"vn_m127_mag", "vn_m128_mag", "vn_m129_mag"};
        };
        class vn_m14
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14_bayo
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14_camo
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14_sd
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_bipod
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_camo
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_nvg
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_shorty
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_shorty_fs
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m14a1_sniper
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m16
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_bayo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_camo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_m203
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_m203_camo
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_mrk_sd
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_muzzle
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_nvg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_nvg_sd
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_sd
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_sniper
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_sniper_sd
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf_bayo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf_nvg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_usaf_sniper
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m16_xm148
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_m1891
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m1891_bayo
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m1895
        {
            values[] = {"vn_m1895_mag"};
        };
        class vn_m1895_sd
        {
            values[] = {"vn_m1895_mag"};
        };
        class vn_m1897
        {
            values[] = {"vn_m1897_buck_mag", "vn_m1897_fl_mag"};
        };
        class vn_m1897_bayo
        {
            values[] = {"vn_m1897_buck_mag", "vn_m1897_fl_mag"};
        };
        class vn_m1903
        {
            values[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1903_bayo
        {
            values[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1903_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1903_sniper
        {
            values[] = {"vn_m1903_mag", "vn_m1903_t_mag"};
        };
        class vn_m1911
        {
            values[] = {"vn_m1911_mag"};
        };
        class vn_m1911_sd
        {
            values[] = {"vn_m1911_mag"};
        };
        class vn_m1918
        {
            values[] = {"vn_m1918_mag", "vn_m1918_t_mag"};
        };
        class vn_m1918_bipod
        {
            values[] = {"vn_m1918_mag", "vn_m1918_t_mag"};
        };
        class vn_m1928_tommy
        {
            values[] = {"vn_m1928_mag", "vn_m1928_t_mag", "vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
        };
        class vn_m1928a1_tommy
        {
            values[] = {"vn_m1928_mag", "vn_m1928_t_mag", "vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
        };
        class vn_m1_garand
        {
            values[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
        };
        class vn_m1_garand_bayo
        {
            values[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
        };
        class vn_m1_garand_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m1_garand_mag", "vn_m1_garand_t_mag"};
        };
        class vn_m1_garand_sniper
        {
            values[] = {"vn_m1_garand_mag", "vn_m1_garand_t_mag"};
        };
        class vn_m1a1_tommy
        {
            values[] = {"vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
        };
        class vn_m1a1_tommy_so
        {
            values[] = {"vn_m1a1_20_mag", "vn_m1a1_20_t_mag", "vn_m1a1_30_mag", "vn_m1a1_30_t_mag"};
        };
        class vn_m1carbine
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m1carbine_bayo
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m1carbine_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m1carbine_shorty
        {
            values[] = {"vn_hp_mag"};
        };
        class vn_m1carbine_sniper
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m20a1b1_01
        {
            values[] = {"vn_m20a1b1_heat_mag", "vn_m20a1b1_wp_mag"};
        };
        class vn_m21
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m21_nvg
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m21_nvg_sd
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m21_sd
        {
            values[] = {"vn_m14_10_mag", "vn_m14_10_t_mag", "vn_m14_mag", "vn_m14_t_mag"};
        };
        class vn_m2carbine
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m2carbine_bayo
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m2carbine_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m17_frag_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m1a2_frag_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m2carbine_sniper
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m36
        {
            values[] = {"vn_m36_mag", "vn_m36_t_mag"};
        };
        class vn_m36_bayo
        {
            values[] = {"vn_m36_mag", "vn_m36_t_mag"};
        };
        class vn_m36_camo
        {
            values[] = {"vn_m36_mag", "vn_m36_t_mag"};
        };
        class vn_m38
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m38_bayo
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m3a1
        {
            values[] = {"vn_m3a1_mag", "vn_m3a1_t_mag"};
        };
        class vn_m3carbine
        {
            values[] = {"vn_carbine_15_mag", "vn_carbine_15_t_mag", "vn_carbine_30_mag", "vn_carbine_30_t_mag"};
        };
        class vn_m3sd
        {
            values[] = {"vn_m3a1_mag", "vn_m3a1_t_mag"};
        };
        class vn_m40a1
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_camo
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_nvg
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_nvg_sd
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_sniper
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m40a1_sniper_sd
        {
            values[] = {"vn_m40a1_mag", "vn_m40a1_t_mag"};
        };
        class vn_m45
        {
            values[] = {"vn_m45_mag", "vn_m45_t_mag"};
        };
        class vn_m45_camo
        {
            values[] = {"vn_m45_mag", "vn_m45_t_mag"};
        };
        class vn_m45_fold
        {
            values[] = {"vn_m45_mag", "vn_m45_t_mag"};
        };
        class vn_m45_sd
        {
            values[] = {"vn_m45_mag", "vn_m45_t_mag"};
        };
        class vn_m4956
        {
            values[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
        };
        class vn_m4956_bayo
        {
            values[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
        };
        class vn_m4956_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_he_mag", "vn_22mm_lume_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m9_heat_mag", "vn_m4956_10_mag", "vn_m4956_10_t_mag"};
        };
        class vn_m4956_sniper
        {
            values[] = {"vn_m4956_10_mag", "vn_m4956_10_t_mag"};
        };
        class vn_m60
        {
            values[] = {"vn_m60_100_mag"};
        };
        class vn_m60_shorty
        {
            values[] = {"vn_m60_100_mag"};
        };
        class vn_m60_shorty_camo
        {
            values[] = {"vn_m60_100_mag"};
        };
        class vn_m63a
        {
            values[] = {"vn_m63a_30_mag", "vn_m63a_30_t_mag"};
        };
        class vn_m63a_cdo
        {
            values[] = {"vn_m63a_150_mag", "vn_m63a_150_t_mag"};
        };
        class vn_m63a_cdo_bipod
        {
            values[] = {"vn_m63a_150_mag", "vn_m63a_150_t_mag"};
        };
        class vn_m63a_lmg
        {
            values[] = {"vn_m63a_100_mag", "vn_m63a_100_t_mag"};
        };
        class vn_m63a_lmg_bipod
        {
            values[] = {"vn_m63a_100_mag", "vn_m63a_100_t_mag"};
        };
        class vn_m712
        {
            values[] = {"vn_m712_mag"};
        };
        class vn_m72
        {
            values[] = {"vn_m72_mag"};
        };
        class vn_m79
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m576_buck_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag"};
        };
        class vn_m79_p
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m576_buck_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag"};
        };
        class vn_m9130
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m9130_bayo
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_m9130_sniper
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_mat49
        {
            values[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
        };
        class vn_mat49_f
        {
            values[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
        };
        class vn_mat49_sd
        {
            values[] = {"vn_mat49_mag", "vn_mat49_t_mag"};
        };
        class vn_mat49_vc
        {
            values[] = {"vn_mat49_vc_mag", "vn_mat49_vc_t_mag"};
        };
        class vn_mc10
        {
            values[] = {"vn_mc10_mag", "vn_mc10_t_mag"};
        };
        class vn_mc10_sd
        {
            values[] = {"vn_mc10_mag", "vn_mc10_t_mag"};
        };
        class vn_mg42
        {
            values[] = {"vn_mg42_50_mag", "vn_mg42_50_t_mag"};
        };
        class vn_mk1_udg
        {
            values[] = {"vn_mk1_udg_mag"};
        };
        class vn_mk22
        {
            values[] = {"vn_mk22_mag"};
        };
        class vn_mk22_sd
        {
            values[] = {"vn_mk22_mag"};
        };
        class vn_mp40
        {
            values[] = {"vn_mp40_mag", "vn_mp40_t_mag"};
        };
        class vn_mpu
        {
            values[] = {"vn_mpu_mag", "vn_mpu_t_mag"};
        };
        class vn_mpu_sd
        {
            values[] = {"vn_mpu_mag", "vn_mpu_t_mag"};
        };
        class vn_mx991_m1911
        {
            values[] = {"vn_m1911_mag"};
        };
        class vn_mx991_m1911_sd
        {
            values[] = {"vn_m1911_mag"};
        };
        class vn_p38
        {
            values[] = {"vn_p38_mag"};
        };
        class vn_p38_sd
        {
            values[] = {"vn_p38_mag"};
        };
        class vn_p38s
        {
            values[] = {"vn_m10_mag"};
        };
        class vn_pk
        {
            values[] = {"vn_pk_100_mag"};
        };
        class vn_pm
        {
            values[] = {"vn_pm_mag"};
        };
        class vn_pm_sd
        {
            values[] = {"vn_pm_mag"};
        };
        class vn_ppk
        {
            values[] = {"vn_ppk_mag"};
        };
        class vn_ppk_sd
        {
            values[] = {"vn_ppk_mag"};
        };
        class vn_pps43
        {
            values[] = {"vn_pps_mag", "vn_pps_t_mag"};
        };
        class vn_pps52
        {
            values[] = {"vn_pps_mag", "vn_pps_t_mag"};
        };
        class vn_ppsh41
        {
            values[] = {"vn_ppsh41_35_mag", "vn_ppsh41_35_t_mag", "vn_ppsh41_71_mag", "vn_ppsh41_71_t_mag"};
        };
        class vn_rpd
        {
            values[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
        };
        class vn_rpd_shorty
        {
            values[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
        };
        class vn_rpd_shorty_01
        {
            values[] = {"vn_rpd_100_mag", "vn_rpd_125_mag"};
        };
        class vn_rpg2
        {
            values[] = {"vn_rpg2_fuze_mag", "vn_rpg2_mag"};
        };
        class vn_rpg7
        {
            values[] = {"vn_rpg7_mag"};
        };
        class vn_sa7
        {
            values[] = {"vn_sa7_mag"};
        };
        class vn_sa7b
        {
            values[] = {"vn_sa7b_mag"};
        };
        class vn_sks
        {
            values[] = {"vn_sks_mag", "vn_sks_t_mag"};
        };
        class vn_sks_bayo
        {
            values[] = {"vn_sks_mag", "vn_sks_t_mag"};
        };
        class vn_sks_gl
        {
            values[] = {"vn_22mm_cs_mag", "vn_22mm_lume_mag", "vn_22mm_m19_wp_mag", "vn_22mm_m22_smoke_mag", "vn_22mm_m60_frag_mag", "vn_22mm_m60_heat_mag", "vn_sks_mag", "vn_sks_t_mag"};
        };
        class vn_sks_sniper
        {
            values[] = {"vn_sks_mag", "vn_sks_t_mag"};
        };
        class vn_sten
        {
            values[] = {"vn_sten_mag", "vn_sten_t_mag"};
        };
        class vn_sten_sd
        {
            values[] = {"vn_sten_mag", "vn_sten_t_mag"};
        };
        class vn_svd
        {
            values[] = {"vn_svd_mag", "vn_svd_t_mag"};
        };
        class vn_svd_sniper
        {
            values[] = {"vn_svd_mag", "vn_svd_t_mag"};
        };
        class vn_svd_sniper_camo
        {
            values[] = {"vn_svd_mag", "vn_svd_t_mag"};
        };
        class vn_tt33
        {
            values[] = {"vn_tt33_mag"};
        };
        class vn_type56
        {
            values[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_type56_bayo
        {
            values[] = {"vn_kbkg_mag", "vn_kbkg_t_mag", "vn_type56_mag", "vn_type56_t_mag"};
        };
        class vn_type64
        {
            values[] = {"vn_type64_mag"};
        };
        class vn_type64_f_smg
        {
            values[] = {"vn_type64_smg_mag", "vn_type64_smg_t_mag"};
        };
        class vn_type64_smg
        {
            values[] = {"vn_type64_smg_mag", "vn_type64_smg_t_mag"};
        };
        class vn_vz54
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_vz54_sniper
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_vz54_sniper_camo
        {
            values[] = {"vn_m38_mag", "vn_m38_t_mag"};
        };
        class vn_vz61
        {
            values[] = {"vn_vz61_mag", "vn_vz61_t_mag"};
        };
        class vn_vz61_p
        {
            values[] = {"vn_vz61_mag", "vn_vz61_t_mag"};
        };
        class vn_welrod
        {
            values[] = {"vn_welrod_mag"};
        };
        class vn_xm16e1
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm16e1_bayo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm16e1_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm16e1_nvg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm16e1_sniper
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm16e1_xm148
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_camo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_fg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_m203
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_m203_camo
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_muzzle
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_nvg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_short
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_sniper
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_stock
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_stock_camo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_xm148
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177_xm148_camo
        {
            values[] = {"vn_40mm_m381_he_mag", "vn_40mm_m397_ab_mag", "vn_40mm_m406_he_mag", "vn_40mm_m433_hedp_mag", "vn_40mm_m583_flare_w_mag", "vn_40mm_m651_cs_mag", "vn_40mm_m661_flare_g_mag", "vn_40mm_m662_flare_r_mag", "vn_40mm_m680_smoke_w_mag", "vn_40mm_m682_smoke_r_mag", "vn_40mm_m695_flare_y_mag", "vn_40mm_m715_smoke_g_mag", "vn_40mm_m716_smoke_y_mag", "vn_40mm_m717_smoke_p_mag", "vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177e1
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177e1_camo
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177e1_mrk
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177e1_nvg
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
        class vn_xm177e1_sniper
        {
            values[] = {"vn_m16_20_mag", "vn_m16_20_t_mag", "vn_m16_30_mag", "vn_m16_30_t_mag", "vn_m16_40_mag", "vn_m16_40_t_mag"};
        };
    };

    class WeaponAttachments
    {
        class vn_ak_01
        {
        };
        class vn_dp28
        {
        };
        class vn_f1_smg
        {
        };
        class vn_f1_smg_bayo
        {
            values[] = {"vn_b_l1a1"};
        };
        class vn_fkb1_pm
        {
        };
        class vn_fkb1_pm_sd
        {
            values[] = {"vn_s_pm"};
        };
        class vn_gau5a
        {
        };
        class vn_gau5a_mrk
        {
            values[] = {"vn_o_1x_sp_m16"};
        };
        class vn_hd
        {
        };
        class vn_hp
        {
        };
        class vn_hp_sd
        {
            values[] = {"vn_s_hp"};
        };
        class vn_izh54
        {
        };
        class vn_izh54_p
        {
        };
        class vn_izh54_shorty
        {
        };
        class vn_k50m
        {
        };
        class vn_k98k
        {
        };
        class vn_k98k_bayo
        {
            values[] = {"vn_b_k98k"};
        };
        class vn_k98k_mrk
        {
            values[] = {"vn_o_1_5x_k98k"};
        };
        class vn_k98k_mrk_camo
        {
            values[] = {"vn_b_camo_k98k", "vn_o_1_5x_k98k"};
        };
        class vn_kbkg
        {
        };
        class vn_kbkg_gl
        {
        };
        class vn_l1a1_01
        {
        };
        class vn_l1a1_01_bayo
        {
            values[] = {"vn_b_l1a1"};
        };
        class vn_l1a1_01_camo
        {
        };
        class vn_l1a1_01_gl
        {
        };
        class vn_l1a1_01_mrk
        {
            values[] = {"vn_o_3x_l1a1"};
        };
        class vn_l1a1_02
        {
        };
        class vn_l1a1_02_bayo
        {
            values[] = {"vn_b_l1a1"};
        };
        class vn_l1a1_02_camo
        {
        };
        class vn_l1a1_02_gl
        {
        };
        class vn_l1a1_02_mrk
        {
            values[] = {"vn_o_3x_l1a1"};
        };
        class vn_l1a1_03
        {
        };
        class vn_l1a1_03_camo
        {
        };
        class vn_l1a1_xm148
        {
        };
        class vn_l1a1_xm148_camo
        {
        };
        class vn_l2a1_01
        {
        };
        class vn_l2a3
        {
        };
        class vn_l2a3_f
        {
        };
        class vn_l34a1
        {
        };
        class vn_l34a1_f
        {
        };
        class vn_l34a1_xm148
        {
        };
        class vn_l4
        {
        };
        class vn_m10
        {
        };
        class vn_m10_sd
        {
            values[] = {"vn_s_mk22"};
        };
        class vn_m127
        {
        };
        class vn_m14
        {
        };
        class vn_m14_bayo
        {
            values[] = {"vn_b_m14"};
        };
        class vn_m14_camo
        {
        };
        class vn_m14_sd
        {
            values[] = {"vn_b_camo_m14", "vn_s_m14"};
        };
        class vn_m14a1
        {
        };
        class vn_m14a1_bipod
        {
            values[] = {"vn_bipod_m14"};
        };
        class vn_m14a1_camo
        {
            values[] = {"vn_b_camo_m14a1", "vn_s_m14"};
        };
        class vn_m14a1_nvg
        {
            values[] = {"vn_b_camo_m14a1", "vn_o_anpvs2_m14", "vn_s_m14"};
        };
        class vn_m14a1_shorty
        {
        };
        class vn_m14a1_shorty_fs
        {
            values[] = {"vn_o_m14_front"};
        };
        class vn_m14a1_sniper
        {
            values[] = {"vn_bipod_m14", "vn_o_9x_m14"};
        };
        class vn_m16
        {
        };
        class vn_m16_bayo
        {
            values[] = {"vn_b_m16"};
        };
        class vn_m16_camo
        {
        };
        class vn_m16_m203
        {
        };
        class vn_m16_m203_camo
        {
        };
        class vn_m16_mrk
        {
            values[] = {"vn_o_4x_m16"};
        };
        class vn_m16_mrk_sd
        {
            values[] = {"vn_o_4x_m16", "vn_s_m16"};
        };
        class vn_m16_muzzle
        {
        };
        class vn_m16_nvg
        {
            values[] = {"vn_o_anpvs2_m16"};
        };
        class vn_m16_nvg_sd
        {
            values[] = {"vn_o_anpvs2_m16", "vn_s_m16"};
        };
        class vn_m16_sd
        {
            values[] = {"vn_s_m16"};
        };
        class vn_m16_sniper
        {
            values[] = {"vn_bipod_m16", "vn_o_9x_m16"};
        };
        class vn_m16_sniper_sd
        {
            values[] = {"vn_bipod_m16", "vn_o_9x_m16", "vn_s_m16"};
        };
        class vn_m16_usaf
        {
        };
        class vn_m16_usaf_bayo
        {
            values[] = {"vn_b_m16"};
        };
        class vn_m16_usaf_mrk
        {
            values[] = {"vn_o_4x_m16"};
        };
        class vn_m16_usaf_nvg
        {
            values[] = {"vn_o_anpvs2_m16"};
        };
        class vn_m16_usaf_sniper
        {
            values[] = {"vn_o_9x_m16"};
        };
        class vn_m16_xm148
        {
        };
        class vn_m1891
        {
        };
        class vn_m1891_bayo
        {
            values[] = {"vn_b_m38"};
        };
        class vn_m1895
        {
        };
        class vn_m1895_sd
        {
            values[] = {"vn_s_m1895"};
        };
        class vn_m1897
        {
        };
        class vn_m1897_bayo
        {
            values[] = {"vn_b_m1897"};
        };
        class vn_m1903
        {
        };
        class vn_m1903_bayo
        {
            values[] = {"vn_b_m1903"};
        };
        class vn_m1903_gl
        {
        };
        class vn_m1903_sniper
        {
            values[] = {"vn_b_m1903", "vn_o_8x_m1903"};
        };
        class vn_m1911
        {
        };
        class vn_m1911_sd
        {
            values[] = {"vn_s_m1911"};
        };
        class vn_m1918
        {
        };
        class vn_m1918_bipod
        {
            values[] = {"vn_bipod_m1918"};
        };
        class vn_m1928_tommy
        {
        };
        class vn_m1928a1_tommy
        {
        };
        class vn_m1_garand
        {
        };
        class vn_m1_garand_bayo
        {
            values[] = {"vn_b_m1_garand"};
        };
        class vn_m1_garand_gl
        {
        };
        class vn_m1_garand_sniper
        {
            values[] = {"vn_b_camo_m1_garand", "vn_o_3x_m84"};
        };
        class vn_m1a1_tommy
        {
        };
        class vn_m1a1_tommy_so
        {
        };
        class vn_m1carbine
        {
        };
        class vn_m1carbine_bayo
        {
            values[] = {"vn_b_carbine"};
        };
        class vn_m1carbine_gl
        {
        };
        class vn_m1carbine_shorty
        {
        };
        class vn_m1carbine_sniper
        {
            values[] = {"vn_o_3x_m84"};
        };
        class vn_m20a1b1_01
        {
        };
        class vn_m21
        {
            values[] = {"vn_o_9x_m14"};
        };
        class vn_m21_nvg
        {
            values[] = {"vn_o_anpvs2_m14"};
        };
        class vn_m21_nvg_sd
        {
            values[] = {"vn_o_anpvs2_m14", "vn_s_m14"};
        };
        class vn_m21_sd
        {
            values[] = {"vn_b_camo_m14", "vn_o_9x_m14", "vn_s_m14"};
        };
        class vn_m2carbine
        {
        };
        class vn_m2carbine_bayo
        {
            values[] = {"vn_b_carbine"};
        };
        class vn_m2carbine_gl
        {
        };
        class vn_m2carbine_sniper
        {
            values[] = {"vn_o_3x_m84"};
        };
        class vn_m36
        {
        };
        class vn_m36_bayo
        {
            values[] = {"vn_b_m36"};
        };
        class vn_m36_camo
        {
            values[] = {"vn_b_camo_m36"};
        };
        class vn_m38
        {
        };
        class vn_m38_bayo
        {
            values[] = {"vn_b_m38"};
        };
        class vn_m3a1
        {
        };
        class vn_m3carbine
        {
        };
        class vn_m3sd
        {
            values[] = {"vn_s_m3a1"};
        };
        class vn_m40a1
        {
        };
        class vn_m40a1_camo
        {
        };
        class vn_m40a1_nvg
        {
            values[] = {"vn_o_anpvs2_m40a1"};
        };
        class vn_m40a1_nvg_sd
        {
            values[] = {"vn_o_anpvs2_m40a1", "vn_s_m14"};
        };
        class vn_m40a1_sniper
        {
            values[] = {"vn_o_9x_m40a1"};
        };
        class vn_m40a1_sniper_sd
        {
            values[] = {"vn_b_camo_m40a1", "vn_o_9x_m40a1", "vn_s_m14"};
        };
        class vn_m45
        {
        };
        class vn_m45_camo
        {
        };
        class vn_m45_fold
        {
        };
        class vn_m45_sd
        {
            values[] = {"vn_s_m45_camo"};
        };
        class vn_m4956
        {
        };
        class vn_m4956_bayo
        {
            values[] = {"vn_b_m4956"};
        };
        class vn_m4956_gl
        {
        };
        class vn_m4956_sniper
        {
            values[] = {"vn_o_4x_m4956"};
        };
        class vn_m60
        {
        };
        class vn_m60_shorty
        {
        };
        class vn_m60_shorty_camo
        {
        };
        class vn_m63a
        {
        };
        class vn_m63a_cdo
        {
        };
        class vn_m63a_cdo_bipod
        {
            values[] = {"vn_bipod_m63a"};
        };
        class vn_m63a_lmg
        {
        };
        class vn_m63a_lmg_bipod
        {
            values[] = {"vn_bipod_m63a"};
        };
        class vn_m712
        {
        };
        class vn_m72
        {
        };
        class vn_m79
        {
        };
        class vn_m79_p
        {
        };
        class vn_m9130
        {
        };
        class vn_m9130_bayo
        {
            values[] = {"vn_b_m38"};
        };
        class vn_m9130_sniper
        {
            values[] = {"vn_o_3x_m9130"};
        };
        class vn_mat49
        {
        };
        class vn_mat49_f
        {
        };
        class vn_mat49_sd
        {
            values[] = {"vn_s_mat49"};
        };
        class vn_mat49_vc
        {
        };
        class vn_mc10
        {
        };
        class vn_mc10_sd
        {
            values[] = {"vn_s_mc10"};
        };
        class vn_mg42
        {
        };
        class vn_mk1_udg
        {
        };
        class vn_mk22
        {
        };
        class vn_mk22_sd
        {
            values[] = {"vn_s_mk22"};
        };
        class vn_mp40
        {
        };
        class vn_mpu
        {
        };
        class vn_mpu_sd
        {
            values[] = {"vn_s_mpu"};
        };
        class vn_mx991_m1911
        {
        };
        class vn_mx991_m1911_sd
        {
            values[] = {"vn_s_m1911"};
        };
        class vn_p38
        {
        };
        class vn_p38_sd
        {
            values[] = {"vn_s_ppk"};
        };
        class vn_p38s
        {
        };
        class vn_pk
        {
        };
        class vn_pm
        {
        };
        class vn_pm_sd
        {
            values[] = {"vn_s_pm"};
        };
        class vn_ppk
        {
        };
        class vn_ppk_sd
        {
            values[] = {"vn_s_ppk"};
        };
        class vn_pps43
        {
        };
        class vn_pps52
        {
        };
        class vn_ppsh41
        {
        };
        class vn_rpd
        {
        };
        class vn_rpd_shorty
        {
        };
        class vn_rpd_shorty_01
        {
        };
        class vn_rpg2
        {
        };
        class vn_rpg7
        {
        };
        class vn_sa7
        {
        };
        class vn_sa7b
        {
        };
        class vn_sks
        {
        };
        class vn_sks_bayo
        {
            values[] = {"vn_b_sks"};
        };
        class vn_sks_gl
        {
        };
        class vn_sks_sniper
        {
            values[] = {"vn_o_3x_sks"};
        };
        class vn_sten
        {
        };
        class vn_sten_sd
        {
            values[] = {"vn_s_sten"};
        };
        class vn_svd
        {
        };
        class vn_svd_sniper
        {
            values[] = {"vn_o_4x_svd"};
        };
        class vn_svd_sniper_camo
        {
            values[] = {"vn_b_camo_svd", "vn_o_4x_svd"};
        };
        class vn_tt33
        {
        };
        class vn_type56
        {
        };
        class vn_type56_bayo
        {
            values[] = {"vn_b_type56"};
        };
        class vn_type64
        {
        };
        class vn_type64_f_smg
        {
        };
        class vn_type64_smg
        {
        };
        class vn_vz54
        {
        };
        class vn_vz54_sniper
        {
            values[] = {"vn_o_3x_vz54"};
        };
        class vn_vz54_sniper_camo
        {
            values[] = {"vn_b_camo_vz54", "vn_o_3x_vz54"};
        };
        class vn_vz61
        {
        };
        class vn_vz61_p
        {
        };
        class vn_welrod
        {
        };
        class vn_xm16e1
        {
        };
        class vn_xm16e1_bayo
        {
            values[] = {"vn_b_m16"};
        };
        class vn_xm16e1_mrk
        {
            values[] = {"vn_o_4x_m16"};
        };
        class vn_xm16e1_nvg
        {
            values[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm16e1_sniper
        {
            values[] = {"vn_bipod_m16", "vn_o_9x_m16"};
        };
        class vn_xm16e1_xm148
        {
        };
        class vn_xm177
        {
        };
        class vn_xm177_camo
        {
        };
        class vn_xm177_fg
        {
        };
        class vn_xm177_m203
        {
        };
        class vn_xm177_m203_camo
        {
        };
        class vn_xm177_mrk
        {
            values[] = {"vn_o_4x_m16"};
        };
        class vn_xm177_muzzle
        {
        };
        class vn_xm177_nvg
        {
            values[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm177_short
        {
        };
        class vn_xm177_sniper
        {
            values[] = {"vn_o_9x_m16"};
        };
        class vn_xm177_stock
        {
        };
        class vn_xm177_stock_camo
        {
        };
        class vn_xm177_xm148
        {
        };
        class vn_xm177_xm148_camo
        {
        };
        class vn_xm177e1
        {
        };
        class vn_xm177e1_camo
        {
        };
        class vn_xm177e1_mrk
        {
            values[] = {"vn_o_4x_m16"};
        };
        class vn_xm177e1_nvg
        {
            values[] = {"vn_o_anpvs2_m16"};
        };
        class vn_xm177e1_sniper
        {
            values[] = {"vn_o_9x_m16"};
        };
    };

    class WeaponVariants
    {
        class vn_f1_smg_bayo
        {
            base = "vn_f1_smg";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_l1a1", "vn_f1_smg"};
        };
        class vn_fkb1_pm_sd
        {
            base = "vn_fkb1_pm";
            traits[] = {"suppressed"};
            requirements[] = {"vn_fkb1_pm", "vn_s_pm"};
        };
        class vn_gau5a_mrk
        {
            base = "vn_gau5a";
            traits[] = {"optic"};
            requirements[] = {"vn_gau5a", "vn_o_1x_sp_m16"};
        };
        class vn_hp_sd
        {
            base = "vn_hp";
            traits[] = {"suppressed"};
            requirements[] = {"vn_hp", "vn_s_hp"};
        };
        class vn_k98k_bayo
        {
            base = "vn_k98k";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_k98k", "vn_k98k"};
        };
        class vn_k98k_mrk
        {
            base = "vn_k98k";
            traits[] = {"optic"};
            requirements[] = {"vn_k98k", "vn_o_1_5x_k98k"};
        };
        class vn_k98k_mrk_camo
        {
            base = "vn_k98k_mrk";
            traits[] = {"bayonet", "camo"};
            requirements[] = {"vn_b_camo_k98k", "vn_k98k_mrk"};
        };
        class vn_l1a1_01_bayo
        {
            base = "vn_l1a1_01";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_l1a1", "vn_l1a1_01"};
        };
        class vn_l1a1_01_mrk
        {
            base = "vn_l1a1_01";
            traits[] = {"optic"};
            requirements[] = {"vn_l1a1_01", "vn_o_3x_l1a1"};
        };
        class vn_l1a1_02_bayo
        {
            base = "vn_l1a1_01";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_l1a1", "vn_l1a1_01"};
        };
        class vn_l1a1_02_mrk
        {
            base = "vn_l1a1_01";
            traits[] = {"optic"};
            requirements[] = {"vn_l1a1_01", "vn_o_3x_l1a1"};
        };
        class vn_m10_sd
        {
            base = "vn_m10";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m10", "vn_s_mk22"};
        };
        class vn_m14_bayo
        {
            base = "vn_m14";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m14", "vn_m14"};
        };
        class vn_m14_sd
        {
            base = "vn_m14";
            traits[] = {"bayonet", "suppressed"};
            requirements[] = {"vn_b_camo_m14", "vn_m14", "vn_s_m14"};
        };
        class vn_m14a1_bipod
        {
            base = "vn_m14a1";
            traits[] = {"bipod"};
            requirements[] = {"vn_bipod_m14", "vn_m14a1"};
        };
        class vn_m14a1_camo
        {
            base = "vn_m14a1";
            traits[] = {"bayonet", "camo", "suppressed"};
            requirements[] = {"vn_b_camo_m14a1", "vn_m14a1", "vn_s_m14"};
        };
        class vn_m14a1_nvg
        {
            base = "vn_m14a1_camo";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_m14a1_camo", "vn_o_anpvs2_m14"};
        };
        class vn_m14a1_shorty_fs
        {
            base = "vn_m14a1";
            traits[] = {"front_sight", "optic", "short"};
            requirements[] = {"vn_m14a1", "vn_o_m14_front"};
        };
        class vn_m14a1_sniper
        {
            base = "vn_m14a1_bipod";
            traits[] = {"optic"};
            requirements[] = {"vn_m14a1_bipod", "vn_o_9x_m14"};
        };
        class vn_m16_bayo
        {
            base = "vn_m16";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m16", "vn_m16"};
        };
        class vn_m16_mrk
        {
            base = "vn_m16";
            traits[] = {"optic"};
            requirements[] = {"vn_m16", "vn_o_4x_m16"};
        };
        class vn_m16_mrk_sd
        {
            base = "vn_m16_sd";
            traits[] = {"optic", "suppressed"};
            requirements[] = {"vn_m16_sd", "vn_o_4x_m16"};
        };
        class vn_m16_nvg
        {
            base = "vn_m16";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_m16", "vn_o_anpvs2_m16"};
        };
        class vn_m16_nvg_sd
        {
            base = "vn_m16_sd";
            traits[] = {"night_optic", "optic", "suppressed"};
            requirements[] = {"vn_m16_sd", "vn_o_anpvs2_m16"};
        };
        class vn_m16_sd
        {
            base = "vn_m16";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m16", "vn_s_m16"};
        };
        class vn_m16_sniper
        {
            base = "vn_m16";
            traits[] = {"bipod", "optic"};
            requirements[] = {"vn_bipod_m16", "vn_m16", "vn_o_9x_m16"};
        };
        class vn_m16_sniper_sd
        {
            base = "vn_m16_sniper";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m16_sniper", "vn_s_m16"};
        };
        class vn_m16_usaf_bayo
        {
            base = "vn_m16_usaf";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m16", "vn_m16_usaf"};
        };
        class vn_m16_usaf_mrk
        {
            base = "vn_m16_usaf";
            traits[] = {"optic"};
            requirements[] = {"vn_m16_usaf", "vn_o_4x_m16"};
        };
        class vn_m16_usaf_nvg
        {
            base = "vn_m16_usaf";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_m16_usaf", "vn_o_anpvs2_m16"};
        };
        class vn_m16_usaf_sniper
        {
            base = "vn_m16_usaf";
            traits[] = {"optic"};
            requirements[] = {"vn_m16_usaf", "vn_o_9x_m16"};
        };
        class vn_m1891_bayo
        {
            base = "vn_m1891";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m38", "vn_m1891"};
        };
        class vn_m1895_sd
        {
            base = "vn_m1895";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m1895", "vn_s_m1895"};
        };
        class vn_m1897_bayo
        {
            base = "vn_m1897";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m1897", "vn_m1897"};
        };
        class vn_m1903_bayo
        {
            base = "vn_m1903";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m1903", "vn_m1903"};
        };
        class vn_m1903_sniper
        {
            base = "vn_m1903_bayo";
            traits[] = {"optic"};
            requirements[] = {"vn_m1903_bayo", "vn_o_8x_m1903"};
        };
        class vn_m1911_sd
        {
            base = "vn_m1911";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m1911", "vn_s_m1911"};
        };
        class vn_m1918_bipod
        {
            base = "vn_m1918";
            traits[] = {"bipod"};
            requirements[] = {"vn_bipod_m1918", "vn_m1918"};
        };
        class vn_m1_garand_bayo
        {
            base = "vn_m1_garand";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m1_garand", "vn_m1_garand"};
        };
        class vn_m1_garand_sniper
        {
            base = "vn_m1_garand";
            traits[] = {"bayonet", "optic"};
            requirements[] = {"vn_b_camo_m1_garand", "vn_m1_garand", "vn_o_3x_m84"};
        };
        class vn_m1carbine_bayo
        {
            base = "vn_m1carbine";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_carbine", "vn_m1carbine"};
        };
        class vn_m1carbine_sniper
        {
            base = "vn_m1carbine";
            traits[] = {"optic"};
            requirements[] = {"vn_m1carbine", "vn_o_3x_m84"};
        };
        class vn_m21_nvg_sd
        {
            base = "vn_m21_nvg";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m21_nvg", "vn_s_m14"};
        };
        class vn_m21_sd
        {
            base = "vn_m21";
            traits[] = {"bayonet", "suppressed"};
            requirements[] = {"vn_b_camo_m14", "vn_m21", "vn_s_m14"};
        };
        class vn_m2carbine_bayo
        {
            base = "vn_m2carbine";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_carbine", "vn_m2carbine"};
        };
        class vn_m2carbine_sniper
        {
            base = "vn_m2carbine";
            traits[] = {"optic"};
            requirements[] = {"vn_m2carbine", "vn_o_3x_m84"};
        };
        class vn_m36_bayo
        {
            base = "vn_m36";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m36", "vn_m36"};
        };
        class vn_m38_bayo
        {
            base = "vn_m38";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m38", "vn_m38"};
        };
        class vn_m3sd
        {
            base = "vn_m3a1";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m3a1", "vn_s_m3a1"};
        };
        class vn_m40a1_nvg
        {
            base = "vn_m40a1";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_m40a1", "vn_o_anpvs2_m40a1"};
        };
        class vn_m40a1_nvg_sd
        {
            base = "vn_m40a1_nvg";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m40a1_nvg", "vn_s_m14"};
        };
        class vn_m40a1_sniper
        {
            base = "vn_m40a1";
            traits[] = {"optic"};
            requirements[] = {"vn_m40a1", "vn_o_9x_m40a1"};
        };
        class vn_m40a1_sniper_sd
        {
            base = "vn_m40a1_sniper";
            traits[] = {"bayonet", "suppressed"};
            requirements[] = {"vn_b_camo_m40a1", "vn_m40a1_sniper", "vn_s_m14"};
        };
        class vn_m45_sd
        {
            base = "vn_m45";
            traits[] = {"suppressed"};
            requirements[] = {"vn_m45", "vn_s_m45_camo"};
        };
        class vn_m4956_bayo
        {
            base = "vn_m4956";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m4956", "vn_m4956"};
        };
        class vn_m4956_sniper
        {
            base = "vn_m4956";
            traits[] = {"optic"};
            requirements[] = {"vn_m4956", "vn_o_4x_m4956"};
        };
        class vn_m63a_cdo_bipod
        {
            base = "vn_m63a_cdo";
            traits[] = {"bipod"};
            requirements[] = {"vn_bipod_m63a", "vn_m63a_cdo"};
        };
        class vn_m63a_lmg_bipod
        {
            base = "vn_m63a_lmg";
            traits[] = {"bipod"};
            requirements[] = {"vn_bipod_m63a", "vn_m63a_lmg"};
        };
        class vn_m9130_bayo
        {
            base = "vn_m9130";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m38", "vn_m9130"};
        };
        class vn_m9130_sniper
        {
            base = "vn_m9130";
            traits[] = {"optic"};
            requirements[] = {"vn_m9130", "vn_o_3x_m9130"};
        };
        class vn_mat49_sd
        {
            base = "vn_mat49";
            traits[] = {"suppressed"};
            requirements[] = {"vn_mat49", "vn_s_mat49"};
        };
        class vn_mc10_sd
        {
            base = "vn_mc10";
            traits[] = {"suppressed"};
            requirements[] = {"vn_mc10", "vn_s_mc10"};
        };
        class vn_mk22_sd
        {
            base = "vn_mk22";
            traits[] = {"suppressed"};
            requirements[] = {"vn_mk22", "vn_s_mk22"};
        };
        class vn_mpu_sd
        {
            base = "vn_mpu";
            traits[] = {"suppressed"};
            requirements[] = {"vn_mpu", "vn_s_mpu"};
        };
        class vn_mx991_m1911_sd
        {
            base = "vn_mx991_m1911";
            traits[] = {"suppressed"};
            requirements[] = {"vn_mx991_m1911", "vn_s_m1911"};
        };
        class vn_p38_sd
        {
            base = "vn_p38";
            traits[] = {"suppressed"};
            requirements[] = {"vn_p38", "vn_s_ppk"};
        };
        class vn_pm_sd
        {
            base = "vn_pm";
            traits[] = {"suppressed"};
            requirements[] = {"vn_pm", "vn_s_pm"};
        };
        class vn_ppk_sd
        {
            base = "vn_ppk";
            traits[] = {"suppressed"};
            requirements[] = {"vn_ppk", "vn_s_ppk"};
        };
        class vn_sks_bayo
        {
            base = "vn_sks";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_sks", "vn_sks"};
        };
        class vn_sks_sniper
        {
            base = "vn_sks";
            traits[] = {"optic"};
            requirements[] = {"vn_o_3x_sks", "vn_sks"};
        };
        class vn_sten_sd
        {
            base = "vn_sten";
            traits[] = {"suppressed"};
            requirements[] = {"vn_s_sten", "vn_sten"};
        };
        class vn_svd_sniper
        {
            base = "vn_svd";
            traits[] = {"optic"};
            requirements[] = {"vn_o_4x_svd", "vn_svd"};
        };
        class vn_svd_sniper_camo
        {
            base = "vn_svd";
            traits[] = {"bayonet", "camo", "optic"};
            requirements[] = {"vn_b_camo_svd", "vn_o_4x_svd", "vn_svd"};
        };
        class vn_type56_bayo
        {
            base = "vn_type56";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_type56", "vn_type56"};
        };
        class vn_vz54_sniper
        {
            base = "vn_vz54";
            traits[] = {"optic"};
            requirements[] = {"vn_o_3x_vz54", "vn_vz54"};
        };
        class vn_vz54_sniper_camo
        {
            base = "vn_vz54_sniper";
            traits[] = {"bayonet", "camo"};
            requirements[] = {"vn_b_camo_vz54", "vn_vz54_sniper"};
        };
        class vn_xm16e1_bayo
        {
            base = "vn_xm16e1";
            traits[] = {"bayonet"};
            requirements[] = {"vn_b_m16", "vn_xm16e1"};
        };
        class vn_xm16e1_mrk
        {
            base = "vn_xm16e1";
            traits[] = {"optic"};
            requirements[] = {"vn_o_4x_m16", "vn_xm16e1"};
        };
        class vn_xm16e1_nvg
        {
            base = "vn_xm16e1";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_o_anpvs2_m16", "vn_xm16e1"};
        };
        class vn_xm16e1_sniper
        {
            base = "vn_xm16e1";
            traits[] = {"bipod", "optic"};
            requirements[] = {"vn_bipod_m16", "vn_o_9x_m16", "vn_xm16e1"};
        };
        class vn_xm177_mrk
        {
            base = "vn_xm177";
            traits[] = {"optic"};
            requirements[] = {"vn_o_4x_m16", "vn_xm177"};
        };
        class vn_xm177_nvg
        {
            base = "vn_xm177";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_o_anpvs2_m16", "vn_xm177"};
        };
        class vn_xm177_sniper
        {
            base = "vn_xm177";
            traits[] = {"optic"};
            requirements[] = {"vn_o_9x_m16", "vn_xm177"};
        };
        class vn_xm177e1_mrk
        {
            base = "vn_xm177e1";
            traits[] = {"optic"};
            requirements[] = {"vn_o_4x_m16", "vn_xm177e1"};
        };
        class vn_xm177e1_nvg
        {
            base = "vn_xm177e1";
            traits[] = {"night_optic", "optic"};
            requirements[] = {"vn_o_anpvs2_m16", "vn_xm177e1"};
        };
        class vn_xm177e1_sniper
        {
            base = "vn_xm177e1";
            traits[] = {"optic"};
            requirements[] = {"vn_o_9x_m16", "vn_xm177e1"};
        };
    };

    class WeaponVariantByBaseAndAttachments
    {
        class vn_ak_01
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_ak_01";
            };
        };
        class vn_dp28
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_dp28";
            };
        };
        class vn_f1_smg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_f1_smg";
            };
            class k_vn_b_l1a1
            {
                structuralAttachments[] = {"vn_b_l1a1"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_f1_smg_bayo";
            };
        };
        class vn_fkb1_pm
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_fkb1_pm";
            };
            class k_vn_s_pm
            {
                structuralAttachments[] = {"vn_s_pm"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_fkb1_pm_sd";
            };
        };
        class vn_gau5a
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_gau5a";
            };
            class k_vn_o_1x_sp_m16
            {
                structuralAttachments[] = {"vn_o_1x_sp_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_gau5a_mrk";
            };
        };
        class vn_hd
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_hd";
            };
        };
        class vn_hp
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_hp";
            };
            class k_vn_s_hp
            {
                structuralAttachments[] = {"vn_s_hp"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_hp_sd";
            };
        };
        class vn_izh54
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_izh54";
            };
        };
        class vn_izh54_p
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_izh54_p";
            };
        };
        class vn_izh54_shorty
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_izh54_shorty";
            };
        };
        class vn_k50m
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_k50m";
            };
        };
        class vn_k98k
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_k98k";
            };
            class k_vn_b_camo_k98k__vn_o_1_5x_k98k
            {
                structuralAttachments[] = {"vn_b_camo_k98k", "vn_o_1_5x_k98k"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_k98k_mrk_camo";
            };
            class k_vn_b_k98k
            {
                structuralAttachments[] = {"vn_b_k98k"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_k98k_bayo";
            };
            class k_vn_o_1_5x_k98k
            {
                structuralAttachments[] = {"vn_o_1_5x_k98k"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_k98k_mrk";
            };
        };
        class vn_kbkg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_kbkg";
            };
        };
        class vn_kbkg_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_kbkg_gl";
            };
        };
        class vn_l1a1_01
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_01";
            };
            class k_vn_b_l1a1
            {
                structuralAttachments[] = {"vn_b_l1a1"};
                ambiguous = 1;
                resolvedWeaponClass = "";
                candidates[] = {"vn_l1a1_01_bayo", "vn_l1a1_02_bayo"};
            };
            class k_vn_o_3x_l1a1
            {
                structuralAttachments[] = {"vn_o_3x_l1a1"};
                ambiguous = 1;
                resolvedWeaponClass = "";
                candidates[] = {"vn_l1a1_01_mrk", "vn_l1a1_02_mrk"};
            };
        };
        class vn_l1a1_01_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_01_camo";
            };
        };
        class vn_l1a1_01_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_01_gl";
            };
        };
        class vn_l1a1_02
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_02";
            };
        };
        class vn_l1a1_02_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_02_camo";
            };
        };
        class vn_l1a1_02_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_02_gl";
            };
        };
        class vn_l1a1_03
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_03";
            };
        };
        class vn_l1a1_03_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_03_camo";
            };
        };
        class vn_l1a1_xm148
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_xm148";
            };
        };
        class vn_l1a1_xm148_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l1a1_xm148_camo";
            };
        };
        class vn_l2a1_01
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l2a1_01";
            };
        };
        class vn_l2a3
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l2a3";
            };
        };
        class vn_l2a3_f
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l2a3_f";
            };
        };
        class vn_l34a1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l34a1";
            };
        };
        class vn_l34a1_f
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l34a1_f";
            };
        };
        class vn_l34a1_xm148
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l34a1_xm148";
            };
        };
        class vn_l4
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_l4";
            };
        };
        class vn_m10
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m10";
            };
            class k_vn_s_mk22
            {
                structuralAttachments[] = {"vn_s_mk22"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m10_sd";
            };
        };
        class vn_m127
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m127";
            };
        };
        class vn_m14
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14";
            };
            class k_vn_b_camo_m14__vn_s_m14
            {
                structuralAttachments[] = {"vn_b_camo_m14", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14_sd";
            };
            class k_vn_b_m14
            {
                structuralAttachments[] = {"vn_b_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14_bayo";
            };
        };
        class vn_m14_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14_camo";
            };
        };
        class vn_m14a1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1";
            };
            class k_vn_b_camo_m14a1__vn_o_anpvs2_m14__vn_s_m14
            {
                structuralAttachments[] = {"vn_b_camo_m14a1", "vn_o_anpvs2_m14", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_nvg";
            };
            class k_vn_b_camo_m14a1__vn_s_m14
            {
                structuralAttachments[] = {"vn_b_camo_m14a1", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_camo";
            };
            class k_vn_bipod_m14
            {
                structuralAttachments[] = {"vn_bipod_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_bipod";
            };
            class k_vn_bipod_m14__vn_o_9x_m14
            {
                structuralAttachments[] = {"vn_bipod_m14", "vn_o_9x_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_sniper";
            };
            class k_vn_o_m14_front
            {
                structuralAttachments[] = {"vn_o_m14_front"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_shorty_fs";
            };
        };
        class vn_m14a1_shorty
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m14a1_shorty";
            };
        };
        class vn_m16
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16";
            };
            class k_vn_b_m16
            {
                structuralAttachments[] = {"vn_b_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_bayo";
            };
            class k_vn_bipod_m16__vn_o_9x_m16
            {
                structuralAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_sniper";
            };
            class k_vn_bipod_m16__vn_o_9x_m16__vn_s_m16
            {
                structuralAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16", "vn_s_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_sniper_sd";
            };
            class k_vn_o_4x_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_mrk";
            };
            class k_vn_o_4x_m16__vn_s_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16", "vn_s_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_mrk_sd";
            };
            class k_vn_o_anpvs2_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_nvg";
            };
            class k_vn_o_anpvs2_m16__vn_s_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16", "vn_s_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_nvg_sd";
            };
            class k_vn_s_m16
            {
                structuralAttachments[] = {"vn_s_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_sd";
            };
        };
        class vn_m16_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_camo";
            };
        };
        class vn_m16_m203
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_m203";
            };
        };
        class vn_m16_m203_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_m203_camo";
            };
        };
        class vn_m16_muzzle
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_muzzle";
            };
        };
        class vn_m16_usaf
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_usaf";
            };
            class k_vn_b_m16
            {
                structuralAttachments[] = {"vn_b_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_usaf_bayo";
            };
            class k_vn_o_4x_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_usaf_mrk";
            };
            class k_vn_o_9x_m16
            {
                structuralAttachments[] = {"vn_o_9x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_usaf_sniper";
            };
            class k_vn_o_anpvs2_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_usaf_nvg";
            };
        };
        class vn_m16_xm148
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m16_xm148";
            };
        };
        class vn_m1891
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1891";
            };
            class k_vn_b_m38
            {
                structuralAttachments[] = {"vn_b_m38"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1891_bayo";
            };
        };
        class vn_m1895
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1895";
            };
            class k_vn_s_m1895
            {
                structuralAttachments[] = {"vn_s_m1895"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1895_sd";
            };
        };
        class vn_m1897
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1897";
            };
            class k_vn_b_m1897
            {
                structuralAttachments[] = {"vn_b_m1897"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1897_bayo";
            };
        };
        class vn_m1903
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1903";
            };
            class k_vn_b_m1903
            {
                structuralAttachments[] = {"vn_b_m1903"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1903_bayo";
            };
            class k_vn_b_m1903__vn_o_8x_m1903
            {
                structuralAttachments[] = {"vn_b_m1903", "vn_o_8x_m1903"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1903_sniper";
            };
        };
        class vn_m1903_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1903_gl";
            };
        };
        class vn_m1911
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1911";
            };
            class k_vn_s_m1911
            {
                structuralAttachments[] = {"vn_s_m1911"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1911_sd";
            };
        };
        class vn_m1918
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1918";
            };
            class k_vn_bipod_m1918
            {
                structuralAttachments[] = {"vn_bipod_m1918"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1918_bipod";
            };
        };
        class vn_m1928_tommy
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1928_tommy";
            };
        };
        class vn_m1928a1_tommy
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1928a1_tommy";
            };
        };
        class vn_m1_garand
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1_garand";
            };
            class k_vn_b_camo_m1_garand__vn_o_3x_m84
            {
                structuralAttachments[] = {"vn_b_camo_m1_garand", "vn_o_3x_m84"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1_garand_sniper";
            };
            class k_vn_b_m1_garand
            {
                structuralAttachments[] = {"vn_b_m1_garand"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1_garand_bayo";
            };
        };
        class vn_m1_garand_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1_garand_gl";
            };
        };
        class vn_m1a1_tommy
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1a1_tommy";
            };
        };
        class vn_m1a1_tommy_so
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1a1_tommy_so";
            };
        };
        class vn_m1carbine
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1carbine";
            };
            class k_vn_b_carbine
            {
                structuralAttachments[] = {"vn_b_carbine"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1carbine_bayo";
            };
            class k_vn_o_3x_m84
            {
                structuralAttachments[] = {"vn_o_3x_m84"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1carbine_sniper";
            };
        };
        class vn_m1carbine_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1carbine_gl";
            };
        };
        class vn_m1carbine_shorty
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m1carbine_shorty";
            };
        };
        class vn_m20a1b1_01
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m20a1b1_01";
            };
        };
        class vn_m21
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m21";
            };
            class k_vn_b_camo_m14__vn_s_m14
            {
                structuralAttachments[] = {"vn_b_camo_m14", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m21_sd";
            };
        };
        class vn_m21_nvg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m21_nvg";
            };
            class k_vn_s_m14
            {
                structuralAttachments[] = {"vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m21_nvg_sd";
            };
        };
        class vn_m2carbine
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m2carbine";
            };
            class k_vn_b_carbine
            {
                structuralAttachments[] = {"vn_b_carbine"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m2carbine_bayo";
            };
            class k_vn_o_3x_m84
            {
                structuralAttachments[] = {"vn_o_3x_m84"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m2carbine_sniper";
            };
        };
        class vn_m2carbine_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m2carbine_gl";
            };
        };
        class vn_m36
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m36";
            };
            class k_vn_b_m36
            {
                structuralAttachments[] = {"vn_b_m36"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m36_bayo";
            };
        };
        class vn_m36_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m36_camo";
            };
        };
        class vn_m38
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m38";
            };
            class k_vn_b_m38
            {
                structuralAttachments[] = {"vn_b_m38"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m38_bayo";
            };
        };
        class vn_m3a1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m3a1";
            };
            class k_vn_s_m3a1
            {
                structuralAttachments[] = {"vn_s_m3a1"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m3sd";
            };
        };
        class vn_m3carbine
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m3carbine";
            };
        };
        class vn_m40a1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1";
            };
            class k_vn_b_camo_m40a1__vn_o_9x_m40a1__vn_s_m14
            {
                structuralAttachments[] = {"vn_b_camo_m40a1", "vn_o_9x_m40a1", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1_sniper_sd";
            };
            class k_vn_o_9x_m40a1
            {
                structuralAttachments[] = {"vn_o_9x_m40a1"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1_sniper";
            };
            class k_vn_o_anpvs2_m40a1
            {
                structuralAttachments[] = {"vn_o_anpvs2_m40a1"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1_nvg";
            };
            class k_vn_o_anpvs2_m40a1__vn_s_m14
            {
                structuralAttachments[] = {"vn_o_anpvs2_m40a1", "vn_s_m14"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1_nvg_sd";
            };
        };
        class vn_m40a1_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m40a1_camo";
            };
        };
        class vn_m45
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m45";
            };
            class k_vn_s_m45_camo
            {
                structuralAttachments[] = {"vn_s_m45_camo"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m45_sd";
            };
        };
        class vn_m45_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m45_camo";
            };
        };
        class vn_m45_fold
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m45_fold";
            };
        };
        class vn_m4956
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m4956";
            };
            class k_vn_b_m4956
            {
                structuralAttachments[] = {"vn_b_m4956"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m4956_bayo";
            };
            class k_vn_o_4x_m4956
            {
                structuralAttachments[] = {"vn_o_4x_m4956"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m4956_sniper";
            };
        };
        class vn_m4956_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m4956_gl";
            };
        };
        class vn_m60
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m60";
            };
        };
        class vn_m60_shorty
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m60_shorty";
            };
        };
        class vn_m60_shorty_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m60_shorty_camo";
            };
        };
        class vn_m63a
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m63a";
            };
        };
        class vn_m63a_cdo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m63a_cdo";
            };
            class k_vn_bipod_m63a
            {
                structuralAttachments[] = {"vn_bipod_m63a"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m63a_cdo_bipod";
            };
        };
        class vn_m63a_lmg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m63a_lmg";
            };
            class k_vn_bipod_m63a
            {
                structuralAttachments[] = {"vn_bipod_m63a"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m63a_lmg_bipod";
            };
        };
        class vn_m712
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m712";
            };
        };
        class vn_m72
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m72";
            };
        };
        class vn_m79
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m79";
            };
        };
        class vn_m79_p
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m79_p";
            };
        };
        class vn_m9130
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m9130";
            };
            class k_vn_b_m38
            {
                structuralAttachments[] = {"vn_b_m38"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m9130_bayo";
            };
            class k_vn_o_3x_m9130
            {
                structuralAttachments[] = {"vn_o_3x_m9130"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_m9130_sniper";
            };
        };
        class vn_mat49
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mat49";
            };
            class k_vn_s_mat49
            {
                structuralAttachments[] = {"vn_s_mat49"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mat49_sd";
            };
        };
        class vn_mat49_f
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mat49_f";
            };
        };
        class vn_mat49_vc
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mat49_vc";
            };
        };
        class vn_mc10
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mc10";
            };
            class k_vn_s_mc10
            {
                structuralAttachments[] = {"vn_s_mc10"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mc10_sd";
            };
        };
        class vn_mg42
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mg42";
            };
        };
        class vn_mk1_udg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mk1_udg";
            };
        };
        class vn_mk22
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mk22";
            };
            class k_vn_s_mk22
            {
                structuralAttachments[] = {"vn_s_mk22"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mk22_sd";
            };
        };
        class vn_mp40
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mp40";
            };
        };
        class vn_mpu
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mpu";
            };
            class k_vn_s_mpu
            {
                structuralAttachments[] = {"vn_s_mpu"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mpu_sd";
            };
        };
        class vn_mx991_m1911
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mx991_m1911";
            };
            class k_vn_s_m1911
            {
                structuralAttachments[] = {"vn_s_m1911"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_mx991_m1911_sd";
            };
        };
        class vn_p38
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_p38";
            };
            class k_vn_s_ppk
            {
                structuralAttachments[] = {"vn_s_ppk"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_p38_sd";
            };
        };
        class vn_p38s
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_p38s";
            };
        };
        class vn_pk
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_pk";
            };
        };
        class vn_pm
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_pm";
            };
            class k_vn_s_pm
            {
                structuralAttachments[] = {"vn_s_pm"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_pm_sd";
            };
        };
        class vn_ppk
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_ppk";
            };
            class k_vn_s_ppk
            {
                structuralAttachments[] = {"vn_s_ppk"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_ppk_sd";
            };
        };
        class vn_pps43
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_pps43";
            };
        };
        class vn_pps52
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_pps52";
            };
        };
        class vn_ppsh41
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_ppsh41";
            };
        };
        class vn_rpd
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_rpd";
            };
        };
        class vn_rpd_shorty
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_rpd_shorty";
            };
        };
        class vn_rpd_shorty_01
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_rpd_shorty_01";
            };
        };
        class vn_rpg2
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_rpg2";
            };
        };
        class vn_rpg7
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_rpg7";
            };
        };
        class vn_sa7
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sa7";
            };
        };
        class vn_sa7b
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sa7b";
            };
        };
        class vn_sks
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sks";
            };
            class k_vn_b_sks
            {
                structuralAttachments[] = {"vn_b_sks"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sks_bayo";
            };
            class k_vn_o_3x_sks
            {
                structuralAttachments[] = {"vn_o_3x_sks"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sks_sniper";
            };
        };
        class vn_sks_gl
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sks_gl";
            };
        };
        class vn_sten
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sten";
            };
            class k_vn_s_sten
            {
                structuralAttachments[] = {"vn_s_sten"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_sten_sd";
            };
        };
        class vn_svd
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_svd";
            };
            class k_vn_b_camo_svd__vn_o_4x_svd
            {
                structuralAttachments[] = {"vn_b_camo_svd", "vn_o_4x_svd"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_svd_sniper_camo";
            };
            class k_vn_o_4x_svd
            {
                structuralAttachments[] = {"vn_o_4x_svd"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_svd_sniper";
            };
        };
        class vn_tt33
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_tt33";
            };
        };
        class vn_type56
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_type56";
            };
            class k_vn_b_type56
            {
                structuralAttachments[] = {"vn_b_type56"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_type56_bayo";
            };
        };
        class vn_type64
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_type64";
            };
        };
        class vn_type64_f_smg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_type64_f_smg";
            };
        };
        class vn_type64_smg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_type64_smg";
            };
        };
        class vn_vz54
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_vz54";
            };
            class k_vn_b_camo_vz54__vn_o_3x_vz54
            {
                structuralAttachments[] = {"vn_b_camo_vz54", "vn_o_3x_vz54"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_vz54_sniper_camo";
            };
            class k_vn_o_3x_vz54
            {
                structuralAttachments[] = {"vn_o_3x_vz54"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_vz54_sniper";
            };
        };
        class vn_vz61
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_vz61";
            };
        };
        class vn_vz61_p
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_vz61_p";
            };
        };
        class vn_welrod
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_welrod";
            };
        };
        class vn_xm16e1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1";
            };
            class k_vn_b_m16
            {
                structuralAttachments[] = {"vn_b_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1_bayo";
            };
            class k_vn_bipod_m16__vn_o_9x_m16
            {
                structuralAttachments[] = {"vn_bipod_m16", "vn_o_9x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1_sniper";
            };
            class k_vn_o_4x_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1_mrk";
            };
            class k_vn_o_anpvs2_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1_nvg";
            };
        };
        class vn_xm16e1_xm148
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm16e1_xm148";
            };
        };
        class vn_xm177
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177";
            };
            class k_vn_o_4x_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_mrk";
            };
            class k_vn_o_9x_m16
            {
                structuralAttachments[] = {"vn_o_9x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_sniper";
            };
            class k_vn_o_anpvs2_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_nvg";
            };
        };
        class vn_xm177_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_camo";
            };
        };
        class vn_xm177_fg
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_fg";
            };
        };
        class vn_xm177_m203
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_m203";
            };
        };
        class vn_xm177_m203_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_m203_camo";
            };
        };
        class vn_xm177_muzzle
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_muzzle";
            };
        };
        class vn_xm177_short
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_short";
            };
        };
        class vn_xm177_stock
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_stock";
            };
        };
        class vn_xm177_stock_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_stock_camo";
            };
        };
        class vn_xm177_xm148
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_xm148";
            };
        };
        class vn_xm177_xm148_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177_xm148_camo";
            };
        };
        class vn_xm177e1
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177e1";
            };
            class k_vn_o_4x_m16
            {
                structuralAttachments[] = {"vn_o_4x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177e1_mrk";
            };
            class k_vn_o_9x_m16
            {
                structuralAttachments[] = {"vn_o_9x_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177e1_sniper";
            };
            class k_vn_o_anpvs2_m16
            {
                structuralAttachments[] = {"vn_o_anpvs2_m16"};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177e1_nvg";
            };
        };
        class vn_xm177e1_camo
        {
            class k_none
            {
                structuralAttachments[] = {};
                ambiguous = 0;
                resolvedWeaponClass = "vn_xm177e1_camo";
            };
        };
    };

    class WeaponVariantTransformingAttachments
    {
        class vn_ak_01
        {
            values[] = {};
        };
        class vn_dp28
        {
            values[] = {};
        };
        class vn_f1_smg
        {
            values[] = {"vn_b_l1a1"};
        };
        class vn_fkb1_pm
        {
            values[] = {"vn_s_pm"};
        };
        class vn_gau5a
        {
            values[] = {"vn_o_1x_sp_m16"};
        };
        class vn_hd
        {
            values[] = {};
        };
        class vn_hp
        {
            values[] = {"vn_s_hp"};
        };
        class vn_izh54
        {
            values[] = {};
        };
        class vn_izh54_p
        {
            values[] = {};
        };
        class vn_izh54_shorty
        {
            values[] = {};
        };
        class vn_k50m
        {
            values[] = {};
        };
        class vn_k98k
        {
            values[] = {"vn_b_camo_k98k", "vn_b_k98k", "vn_o_1_5x_k98k"};
        };
        class vn_kbkg
        {
            values[] = {};
        };
        class vn_kbkg_gl
        {
            values[] = {};
        };
        class vn_l1a1_01
        {
            values[] = {"vn_b_l1a1", "vn_o_3x_l1a1"};
        };
        class vn_l1a1_01_camo
        {
            values[] = {};
        };
        class vn_l1a1_01_gl
        {
            values[] = {};
        };
        class vn_l1a1_02
        {
            values[] = {};
        };
        class vn_l1a1_02_camo
        {
            values[] = {};
        };
        class vn_l1a1_02_gl
        {
            values[] = {};
        };
        class vn_l1a1_03
        {
            values[] = {};
        };
        class vn_l1a1_03_camo
        {
            values[] = {};
        };
        class vn_l1a1_xm148
        {
            values[] = {};
        };
        class vn_l1a1_xm148_camo
        {
            values[] = {};
        };
        class vn_l2a1_01
        {
            values[] = {};
        };
        class vn_l2a3
        {
            values[] = {};
        };
        class vn_l2a3_f
        {
            values[] = {};
        };
        class vn_l34a1
        {
            values[] = {};
        };
        class vn_l34a1_f
        {
            values[] = {};
        };
        class vn_l34a1_xm148
        {
            values[] = {};
        };
        class vn_l4
        {
            values[] = {};
        };
        class vn_m10
        {
            values[] = {"vn_s_mk22"};
        };
        class vn_m127
        {
            values[] = {};
        };
        class vn_m14
        {
            values[] = {"vn_b_camo_m14", "vn_b_m14", "vn_s_m14"};
        };
        class vn_m14_camo
        {
            values[] = {};
        };
        class vn_m14a1
        {
            values[] = {"vn_b_camo_m14a1", "vn_bipod_m14", "vn_o_9x_m14", "vn_o_anpvs2_m14", "vn_o_m14_front", "vn_s_m14"};
        };
        class vn_m14a1_shorty
        {
            values[] = {};
        };
        class vn_m16
        {
            values[] = {"vn_b_m16", "vn_bipod_m16", "vn_o_4x_m16", "vn_o_9x_m16", "vn_o_anpvs2_m16", "vn_s_m16"};
        };
        class vn_m16_camo
        {
            values[] = {};
        };
        class vn_m16_m203
        {
            values[] = {};
        };
        class vn_m16_m203_camo
        {
            values[] = {};
        };
        class vn_m16_muzzle
        {
            values[] = {};
        };
        class vn_m16_usaf
        {
            values[] = {"vn_b_m16", "vn_o_4x_m16", "vn_o_9x_m16", "vn_o_anpvs2_m16"};
        };
        class vn_m16_xm148
        {
            values[] = {};
        };
        class vn_m1891
        {
            values[] = {"vn_b_m38"};
        };
        class vn_m1895
        {
            values[] = {"vn_s_m1895"};
        };
        class vn_m1897
        {
            values[] = {"vn_b_m1897"};
        };
        class vn_m1903
        {
            values[] = {"vn_b_m1903", "vn_o_8x_m1903"};
        };
        class vn_m1903_gl
        {
            values[] = {};
        };
        class vn_m1911
        {
            values[] = {"vn_s_m1911"};
        };
        class vn_m1918
        {
            values[] = {"vn_bipod_m1918"};
        };
        class vn_m1928_tommy
        {
            values[] = {};
        };
        class vn_m1928a1_tommy
        {
            values[] = {};
        };
        class vn_m1_garand
        {
            values[] = {"vn_b_camo_m1_garand", "vn_b_m1_garand", "vn_o_3x_m84"};
        };
        class vn_m1_garand_gl
        {
            values[] = {};
        };
        class vn_m1a1_tommy
        {
            values[] = {};
        };
        class vn_m1a1_tommy_so
        {
            values[] = {};
        };
        class vn_m1carbine
        {
            values[] = {"vn_b_carbine", "vn_o_3x_m84"};
        };
        class vn_m1carbine_gl
        {
            values[] = {};
        };
        class vn_m1carbine_shorty
        {
            values[] = {};
        };
        class vn_m20a1b1_01
        {
            values[] = {};
        };
        class vn_m21
        {
            values[] = {"vn_b_camo_m14", "vn_s_m14"};
        };
        class vn_m21_nvg
        {
            values[] = {"vn_s_m14"};
        };
        class vn_m2carbine
        {
            values[] = {"vn_b_carbine", "vn_o_3x_m84"};
        };
        class vn_m2carbine_gl
        {
            values[] = {};
        };
        class vn_m36
        {
            values[] = {"vn_b_m36"};
        };
        class vn_m36_camo
        {
            values[] = {};
        };
        class vn_m38
        {
            values[] = {"vn_b_m38"};
        };
        class vn_m3a1
        {
            values[] = {"vn_s_m3a1"};
        };
        class vn_m3carbine
        {
            values[] = {};
        };
        class vn_m40a1
        {
            values[] = {"vn_b_camo_m40a1", "vn_o_9x_m40a1", "vn_o_anpvs2_m40a1", "vn_s_m14"};
        };
        class vn_m40a1_camo
        {
            values[] = {};
        };
        class vn_m45
        {
            values[] = {"vn_s_m45_camo"};
        };
        class vn_m45_camo
        {
            values[] = {};
        };
        class vn_m45_fold
        {
            values[] = {};
        };
        class vn_m4956
        {
            values[] = {"vn_b_m4956", "vn_o_4x_m4956"};
        };
        class vn_m4956_gl
        {
            values[] = {};
        };
        class vn_m60
        {
            values[] = {};
        };
        class vn_m60_shorty
        {
            values[] = {};
        };
        class vn_m60_shorty_camo
        {
            values[] = {};
        };
        class vn_m63a
        {
            values[] = {};
        };
        class vn_m63a_cdo
        {
            values[] = {"vn_bipod_m63a"};
        };
        class vn_m63a_lmg
        {
            values[] = {"vn_bipod_m63a"};
        };
        class vn_m712
        {
            values[] = {};
        };
        class vn_m72
        {
            values[] = {};
        };
        class vn_m79
        {
            values[] = {};
        };
        class vn_m79_p
        {
            values[] = {};
        };
        class vn_m9130
        {
            values[] = {"vn_b_m38", "vn_o_3x_m9130"};
        };
        class vn_mat49
        {
            values[] = {"vn_s_mat49"};
        };
        class vn_mat49_f
        {
            values[] = {};
        };
        class vn_mat49_vc
        {
            values[] = {};
        };
        class vn_mc10
        {
            values[] = {"vn_s_mc10"};
        };
        class vn_mg42
        {
            values[] = {};
        };
        class vn_mk1_udg
        {
            values[] = {};
        };
        class vn_mk22
        {
            values[] = {"vn_s_mk22"};
        };
        class vn_mp40
        {
            values[] = {};
        };
        class vn_mpu
        {
            values[] = {"vn_s_mpu"};
        };
        class vn_mx991_m1911
        {
            values[] = {"vn_s_m1911"};
        };
        class vn_p38
        {
            values[] = {"vn_s_ppk"};
        };
        class vn_p38s
        {
            values[] = {};
        };
        class vn_pk
        {
            values[] = {};
        };
        class vn_pm
        {
            values[] = {"vn_s_pm"};
        };
        class vn_ppk
        {
            values[] = {"vn_s_ppk"};
        };
        class vn_pps43
        {
            values[] = {};
        };
        class vn_pps52
        {
            values[] = {};
        };
        class vn_ppsh41
        {
            values[] = {};
        };
        class vn_rpd
        {
            values[] = {};
        };
        class vn_rpd_shorty
        {
            values[] = {};
        };
        class vn_rpd_shorty_01
        {
            values[] = {};
        };
        class vn_rpg2
        {
            values[] = {};
        };
        class vn_rpg7
        {
            values[] = {};
        };
        class vn_sa7
        {
            values[] = {};
        };
        class vn_sa7b
        {
            values[] = {};
        };
        class vn_sks
        {
            values[] = {"vn_b_sks", "vn_o_3x_sks"};
        };
        class vn_sks_gl
        {
            values[] = {};
        };
        class vn_sten
        {
            values[] = {"vn_s_sten"};
        };
        class vn_svd
        {
            values[] = {"vn_b_camo_svd", "vn_o_4x_svd"};
        };
        class vn_tt33
        {
            values[] = {};
        };
        class vn_type56
        {
            values[] = {"vn_b_type56"};
        };
        class vn_type64
        {
            values[] = {};
        };
        class vn_type64_f_smg
        {
            values[] = {};
        };
        class vn_type64_smg
        {
            values[] = {};
        };
        class vn_vz54
        {
            values[] = {"vn_b_camo_vz54", "vn_o_3x_vz54"};
        };
        class vn_vz61
        {
            values[] = {};
        };
        class vn_vz61_p
        {
            values[] = {};
        };
        class vn_welrod
        {
            values[] = {};
        };
        class vn_xm16e1
        {
            values[] = {"vn_b_m16", "vn_bipod_m16", "vn_o_4x_m16", "vn_o_9x_m16", "vn_o_anpvs2_m16"};
        };
        class vn_xm16e1_xm148
        {
            values[] = {};
        };
        class vn_xm177
        {
            values[] = {"vn_o_4x_m16", "vn_o_9x_m16", "vn_o_anpvs2_m16"};
        };
        class vn_xm177_camo
        {
            values[] = {};
        };
        class vn_xm177_fg
        {
            values[] = {};
        };
        class vn_xm177_m203
        {
            values[] = {};
        };
        class vn_xm177_m203_camo
        {
            values[] = {};
        };
        class vn_xm177_muzzle
        {
            values[] = {};
        };
        class vn_xm177_short
        {
            values[] = {};
        };
        class vn_xm177_stock
        {
            values[] = {};
        };
        class vn_xm177_stock_camo
        {
            values[] = {};
        };
        class vn_xm177_xm148
        {
            values[] = {};
        };
        class vn_xm177_xm148_camo
        {
            values[] = {};
        };
        class vn_xm177e1
        {
            values[] = {"vn_o_4x_m16", "vn_o_9x_m16", "vn_o_anpvs2_m16"};
        };
        class vn_xm177e1_camo
        {
            values[] = {};
        };
    };

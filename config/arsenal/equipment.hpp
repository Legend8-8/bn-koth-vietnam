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
        };

        class starter_east
        {
            side = "EAST";
            source = "UNIT_CLASS_TEMPLATE";
            unitClass = "vn_o_men_nva_04";
            starter = 1;
            category = "starter";
        };
    };

    class Equipment
    {
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
            class WeaponMagazines {};
            class WeaponAttachments {};
            class WeaponVariants {};
        };
    };
};

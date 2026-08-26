#include "\a3\ui_f\hpp\definedikcodes.inc"

class CfgBnKothBuild
{
    enabled = 1;
    defaultKeyDik = DIK_N;
    maxObjectsPerPlayer = 15;
    maxObjectsPerSide = 80;
    placeDistanceMin = 2;
    placeDistanceMax = 12;
    allowDeleteOwn = 1;
    clearOnRoundReset = 1;
    placementPolicy = 0;

    class Objects
    {
        class TrenchStair
        {
            classname = "Land_vn_b_trench_stair_01";
            displayName = "Trench (Stair)";
            category = "Fortifications";
            cost = 0;
        };

        class TrenchStairEarth
        {
            classname = "Land_vn_b_trench_stair_02";
            displayName = "Trench (Stair/Earth)";
            category = "Fortifications";
            cost = 0;
        };

        class TrenchCorner
        {
            classname = "Land_vn_b_trench_corner_01";
            displayName = "Trench (Corner)";
            category = "Fortifications";
            cost = 0;
        };

        class TrenchRevetmentTall3m
        {
            classname = "Land_vn_b_trench_revetment_tall_03";
            displayName = "Trench Revetment (3m)";
            category = "Fortifications";
            cost = 0;
        };

        class SandbagCorner
        {
            classname = "Land_vn_bagfence_corner_f";
            displayName = "Sandbag Wall (Corner)";
            category = "Fortifications";
            cost = 0;
        };

        class SandbagEnd
        {
            classname = "Land_vn_bagfence_end_f";
            displayName = "Sandbag Wall (End)";
            category = "Fortifications";
            cost = 0;
        };

        class SandbagLong
        {
            classname = "Land_vn_bagfence_long_f";
            displayName = "Sandbag Wall (Long)";
            category = "Fortifications";
            cost = 0;
        };

        class SandbagRound
        {
            classname = "Land_vn_bagfence_round_f";
            displayName = "Sandbag Wall (Round)";
            category = "Fortifications";
            cost = 0;
        };

        class SandbagShort
        {
            classname = "Land_vn_bagfence_short_f";
            displayName = "Sandbag Wall (Short)";
            category = "Fortifications";
            cost = 0;
        };
    };
};

class CfgBnKothRanks
{
    // Presentation-only grade colours applied to Arma 3 built-in neutral
    // rank insignia textures. Rank thresholds remain account-level metadata.
    class Grades
    {
        class BRONZE { color[] = {0.72, 0.42, 0.18, 1}; };
        class SILVER { color[] = {0.72, 0.76, 0.80, 1}; };
        class GOLD   { color[] = {0.94, 0.72, 0.20, 1}; };
    };

    class Ranks
    {
        // Levels below the first threshold are recruits and show no insignia.
        class BronzePrivate    { minLevel = 10;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa";    grade = "BRONZE"; };
        class BronzeCorporal   { minLevel = 23;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\corporal_gs.paa";   grade = "BRONZE"; };
        class BronzeSergeant   { minLevel = 36;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";   grade = "BRONZE"; };
        class BronzeLieutenant { minLevel = 49;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa"; grade = "BRONZE"; };
        class BronzeCaptain    { minLevel = 62;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\captain_gs.paa";    grade = "BRONZE"; };
        class BronzeMajor      { minLevel = 75;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\major_gs.paa";      grade = "BRONZE"; };
        class BronzeColonel    { minLevel = 88;  icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";    grade = "BRONZE"; };
        class SilverPrivate    { minLevel = 101; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa";    grade = "SILVER"; };
        class SilverCorporal   { minLevel = 114; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\corporal_gs.paa";   grade = "SILVER"; };
        class SilverSergeant   { minLevel = 127; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";   grade = "SILVER"; };
        class SilverLieutenant { minLevel = 140; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa"; grade = "SILVER"; };
        class SilverCaptain    { minLevel = 153; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\captain_gs.paa";    grade = "SILVER"; };
        class SilverMajor      { minLevel = 166; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\major_gs.paa";      grade = "SILVER"; };
        class SilverColonel    { minLevel = 179; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";    grade = "SILVER"; };
        class GoldPrivate      { minLevel = 192; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa";    grade = "GOLD"; };
        class GoldCorporal     { minLevel = 205; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\corporal_gs.paa";   grade = "GOLD"; };
        class GoldSergeant     { minLevel = 218; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa";   grade = "GOLD"; };
        class GoldLieutenant   { minLevel = 231; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa"; grade = "GOLD"; };
        class GoldCaptain      { minLevel = 244; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\captain_gs.paa";    grade = "GOLD"; };
        class GoldMajor        { minLevel = 257; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\major_gs.paa";      grade = "GOLD"; };
        class GoldColonel      { minLevel = 270; icon = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";    grade = "GOLD"; };
    };
};

#include "\a3\ui_f\hpp\definedikcodes.inc"

class CfgBnKothEscMenuKeybinds
{
    class traversal
    {
        defaultKey = DIK_SPACE;
        shift = "true";
        ctrl = "false";
        alt = "false";
        down = 0;
        function = "bn_koth_fnc_traversal_request";
        displayName = "Advanced Climb (Vanilla/SOG)";
        access = 1;
    };

    class earplugs_toggle
    {
        defaultKey = DIK_F1;
        shift = "false";
        ctrl = "false";
        alt = "false";
        down = 0;
        function = "bn_koth_fnc_escMenu_earplugs_toggle";
        displayName = "Toggle Earplugs";
        access = 1;
    };

    class enemySpotting_mark
    {
        defaultKey = DIK_T;
        shift = "false";
        ctrl = "false";
        alt = "false";
        down = 1;
        function = "bn_koth_fnc_enemySpotting_requestSpot";
        displayName = "Spot Enemy";
        access = 1;
    };

    class group_menu
    {
        defaultKey = DIK_U;
        shift = "false";
        ctrl = "false";
        alt = "false";
        down = 1;
        function = "bn_koth_fnc_groupMenu_open";
        displayName = "Group Menu";
        access = 1;
    };
};

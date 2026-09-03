#include "idcs.hpp"

class BN_KOTH_RscEscMenuKeybindings
{
    idd = BN_KOTH_IDD_ESC_MENU_KEYBINDS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call bn_koth_fnc_escMenu_keybindings_onLoad;";
    onUnload = "_this call bn_koth_fnc_escMenu_keybindings_onUnload;";

    class controlsBackground
    {
        class Bg: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.18;
            w = safeZoneW * 0.40;
            h = safeZoneH * 0.64;
            colorBackground[] = {0.02, 0.02, 0.02, 0.96};
        };

        class Title: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_ESC_KEYBINDS_TITLE;
            text = "GAMEMODE KEYBINDINGS";
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.20;
            w = safeZoneW * 0.38;
            h = safeZoneH * 0.035;
            sizeEx = "0.030 * safeZoneH";
            colorText[] = {0.96, 0.90, 0.72, 1};
        };
    };

    class controls
    {
        class KeybindList: BN_KOTH_RscListNBox
        {
            idc = BN_KOTH_IDC_ESC_KEYBINDS_LIST;
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.25;
            w = safeZoneW * 0.38;
            h = safeZoneH * 0.48;
            columns[] = {0, 0.68};
            soundSelect[] = {"", 0.1, 1};
            soundExpand[] = {"", 0.1, 1};
            soundCollapse[] = {"", 0.1, 1};
        };

        class Reset: BN_KOTH_RscButton
        {
            idc = BN_KOTH_IDC_ESC_KEYBINDS_RESET;
            text = "RESET";
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.75;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            onButtonClick = "_this call bn_koth_fnc_escMenu_keybinds_reset;";
        };

        class Confirm: BN_KOTH_RscButton
        {
            idc = 1;
            text = "OK";
            x = safeZoneX + safeZoneW * 0.57;
            y = safeZoneY + safeZoneH * 0.75;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            action = "closeDialog 1;";
        };

        class Cancel: BN_KOTH_RscButton
        {
            idc = 2;
            text = "CANCEL";
            x = safeZoneX + safeZoneW * 0.44;
            y = safeZoneY + safeZoneH * 0.75;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            action = "closeDialog 2;";
        };
    };
};

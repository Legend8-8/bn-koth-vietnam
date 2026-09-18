#include "idcs.hpp"

#define BN_KOTH_ESC_MENU_ROW_GAP (safeZoneH * 0.055)
#define BN_KOTH_ESC_MENU_ROW_LABEL_Y(rowIndex) ((rowIndex) * BN_KOTH_ESC_MENU_ROW_GAP)
#define BN_KOTH_ESC_MENU_ROW_SLIDER_Y(rowIndex) (BN_KOTH_ESC_MENU_ROW_LABEL_Y(rowIndex) + (safeZoneH * 0.03))
#define BN_KOTH_ESC_MENU_LABEL_X 0
#define BN_KOTH_ESC_MENU_VALUE_X (safeZoneW * 0.24)
#define BN_KOTH_ESC_MENU_TOGGLE_X (safeZoneW * 0.23)
#define BN_KOTH_ESC_MENU_SLIDER_W (safeZoneW * 0.34)
#define BN_KOTH_ESC_MENU_SLIDER_X 0
#define BN_KOTH_ESC_MENU_TOGGLE_H (safeZoneH * 0.024)

class BN_KOTH_RscEscMenuOptions
{
    idd = BN_KOTH_IDD_ESC_MENU_OPTIONS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call bn_koth_fnc_escMenu_options_onLoad; [(_this select 0) displayCtrl 9101] call bn_koth_fnc_announcements_configureControl;";
    onUnload = "_this call bn_koth_fnc_escMenu_options_onUnload;";

    class controlsBackground
    {
        class Bg: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.24;
            w = safeZoneW * 0.40;
            h = safeZoneH * 0.58;
            colorBackground[] = {0.02, 0.02, 0.02, 0.96};
        };

        class Title: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_ESC_OPTIONS_TITLE;
            text = "GAMEMODE OPTIONS";
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.26;
            w = safeZoneW * 0.22;
            h = safeZoneH * 0.035;
            sizeEx = "0.030 * safeZoneH";
            colorText[] = {0.96, 0.90, 0.72, 1};
        };
    };

    class controls
    {
        class OptionsGroup: BN_KOTH_RscControlsGroup
        {
            idc = 8724;
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.33;
            w = safeZoneW * 0.36;
            h = safeZoneH * 0.48;

            class controls
            {
                class GroundLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_LABEL;
                    text = "Earplug Volume (On Ground)";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(0);
                    w = safeZoneW * 0.23;
                    h = safeZoneH * 0.035;
                };

                class GroundValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE;
                    text = "50%";
                    x = BN_KOTH_ESC_MENU_VALUE_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(0);
                    w = safeZoneW * 0.11;
                    h = safeZoneH * 0.035;
                    style = 1;
                };

                class GroundSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_ROW_SLIDER_Y(0);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = safeZoneH * 0.03;
                };

                class VehicleLabel: GroundLabel
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_LABEL;
                    text = "Earplug Volume (In Vehicle)";
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(1);
                };

                class VehicleValue: GroundValue
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(1);
                };

                class VehicleSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_ROW_SLIDER_Y(1);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = safeZoneH * 0.03;
                };

                class Player3DLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_LABEL;
                    text = "Player 3D Icons";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(2);
                    w = safeZoneW * 0.22;
                    h = safeZoneH * 0.035;
                };

                class Player3DValue: BN_KOTH_RscButton
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE;
                    text = "ON";
                    x = BN_KOTH_ESC_MENU_TOGGLE_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(2);
                    w = safeZoneW * 0.08;
                    h = BN_KOTH_ESC_MENU_TOGGLE_H;
                    style = 2;
                    colorBackground[] = {0.08, 0.08, 0.08, 0.85};
                    colorBackgroundActive[] = {0.15, 0.15, 0.15, 1};
                    colorFocused[] = {0.15, 0.15, 0.15, 1};
                };

                class Player3DAlphaLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_LABEL;
                    text = "Player 3D Icons Alpha";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(3);
                    w = safeZoneW * 0.25;
                    h = safeZoneH * 0.035;
                };

                class Player3DAlphaValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE;
                    text = "100%";
                    x = BN_KOTH_ESC_MENU_VALUE_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(3);
                    w = safeZoneW * 0.11;
                    h = safeZoneH * 0.035;
                    style = 1;
                };

                class Player3DAlphaSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_ROW_SLIDER_Y(3);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = safeZoneH * 0.03;
                };

                class CenterMapLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_CENTERMAP_LABEL;
                    text = "Center Map On Open";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(4);
                    w = safeZoneW * 0.23;
                    h = safeZoneH * 0.035;
                };

                class CenterMapValue: BN_KOTH_RscButton
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_CENTERMAP_VALUE;
                    text = "ON";
                    x = BN_KOTH_ESC_MENU_TOGGLE_X;
                    y = BN_KOTH_ESC_MENU_ROW_LABEL_Y(4);
                    w = safeZoneW * 0.08;
                    h = BN_KOTH_ESC_MENU_TOGGLE_H;
                    style = 2;
                    colorBackground[] = {0.08, 0.08, 0.08, 0.85};
                    colorBackgroundActive[] = {0.15, 0.15, 0.15, 1};
                    colorFocused[] = {0.15, 0.15, 0.15, 1};
                };
            };
        };

        class Reset: BN_KOTH_RscButton
        {
            idc = 3;
            text = "RESET";
            x = safeZoneX + safeZoneW * 0.31;
            y = safeZoneY + safeZoneH * 0.88;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            onButtonClick = "_this call bn_koth_fnc_escMenu_options_reset;";
        };

        class Confirm: BN_KOTH_RscButton
        {
            idc = 1;
            text = "OK";
            x = safeZoneX + safeZoneW * 0.57;
            y = safeZoneY + safeZoneH * 0.88;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            action = "closeDialog 1;";
        };

        class Cancel: BN_KOTH_RscButton
        {
            idc = 2;
            text = "CANCEL";
            x = safeZoneX + safeZoneW * 0.44;
            y = safeZoneY + safeZoneH * 0.88;
            w = safeZoneW * 0.12;
            h = safeZoneH * 0.04;
            action = "closeDialog 2;";
        };

        class Announcement: BN_KOTH_AnnouncementNotice
        {
            x = safeZoneX + safeZoneW * 0.545;
            y = safeZoneY + safeZoneH * 0.252;
            w = safeZoneW * 0.145;
            h = safeZoneH * 0.050;
            size = "0.020 * safeZoneH";
        };
    };
};

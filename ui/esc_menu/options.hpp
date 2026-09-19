#include "idcs.hpp"

#define BN_KOTH_ESC_MENU_PANEL_X (safeZoneX + safeZoneW * 0.30)
#define BN_KOTH_ESC_MENU_PANEL_Y (safeZoneY + safeZoneH * 0.21)
#define BN_KOTH_ESC_MENU_PANEL_W (safeZoneW * 0.40)
#define BN_KOTH_ESC_MENU_PANEL_H (safeZoneH * 0.58)
#define BN_KOTH_ESC_MENU_INNER_X (safeZoneX + safeZoneW * 0.31)
#define BN_KOTH_ESC_MENU_INNER_W (safeZoneW * 0.38)
#define BN_KOTH_ESC_MENU_TITLE_Y (BN_KOTH_ESC_MENU_PANEL_Y + safeZoneH * 0.02)
#define BN_KOTH_ESC_MENU_OPTIONS_Y (BN_KOTH_ESC_MENU_PANEL_Y + safeZoneH * 0.09)
#define BN_KOTH_ESC_MENU_OPTIONS_H (safeZoneH * 0.40)
#define BN_KOTH_ESC_MENU_ACTION_Y (BN_KOTH_ESC_MENU_PANEL_Y + safeZoneH * 0.52)
#define BN_KOTH_ESC_MENU_ACTION_W (safeZoneW * 0.12)
#define BN_KOTH_ESC_MENU_ACTION_GAP (safeZoneW * 0.01)
#define BN_KOTH_ESC_MENU_LABEL_X 0
#define BN_KOTH_ESC_MENU_LABEL_W (safeZoneW * 0.23)
#define BN_KOTH_ESC_MENU_LABEL_H (safeZoneH * 0.025)
#define BN_KOTH_ESC_MENU_VALUE_X (safeZoneW * 0.24)
#define BN_KOTH_ESC_MENU_VALUE_W (safeZoneW * 0.11)
#define BN_KOTH_ESC_MENU_SLIDER_W (safeZoneW * 0.35)
#define BN_KOTH_ESC_MENU_SLIDER_X 0
#define BN_KOTH_ESC_MENU_SLIDER_H (safeZoneH * 0.025)
#define BN_KOTH_ESC_MENU_CONTROL_GAP (safeZoneH * 0.002)
#define BN_KOTH_ESC_MENU_OPTION_GAP (safeZoneH * 0.003)
#define BN_KOTH_ESC_MENU_SLIDER_OPTION_H (BN_KOTH_ESC_MENU_LABEL_H + BN_KOTH_ESC_MENU_CONTROL_GAP + BN_KOTH_ESC_MENU_SLIDER_H + BN_KOTH_ESC_MENU_OPTION_GAP)
#define BN_KOTH_ESC_MENU_TOGGLE_OPTION_H (BN_KOTH_ESC_MENU_LABEL_H + BN_KOTH_ESC_MENU_OPTION_GAP)
#define BN_KOTH_ESC_MENU_NEXT_OPTION_Y(previousY, previousHeight) ((previousY) + (previousHeight))
#define BN_KOTH_ESC_MENU_SLIDER_Y(optionY) ((optionY) + BN_KOTH_ESC_MENU_LABEL_H + BN_KOTH_ESC_MENU_CONTROL_GAP)
#define BN_KOTH_ESC_MENU_GROUND_Y 0
#define BN_KOTH_ESC_MENU_VEHICLE_Y BN_KOTH_ESC_MENU_NEXT_OPTION_Y(BN_KOTH_ESC_MENU_GROUND_Y, BN_KOTH_ESC_MENU_SLIDER_OPTION_H)
#define BN_KOTH_ESC_MENU_PLAYER3D_Y BN_KOTH_ESC_MENU_NEXT_OPTION_Y(BN_KOTH_ESC_MENU_VEHICLE_Y, BN_KOTH_ESC_MENU_SLIDER_OPTION_H)
#define BN_KOTH_ESC_MENU_PLAYER3D_ALPHA_Y BN_KOTH_ESC_MENU_NEXT_OPTION_Y(BN_KOTH_ESC_MENU_PLAYER3D_Y, BN_KOTH_ESC_MENU_TOGGLE_OPTION_H)

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
            x = BN_KOTH_ESC_MENU_PANEL_X;
            y = BN_KOTH_ESC_MENU_PANEL_Y;
            w = BN_KOTH_ESC_MENU_PANEL_W;
            h = BN_KOTH_ESC_MENU_PANEL_H;
            colorBackground[] = {0.02, 0.02, 0.02, 0.96};
        };

        class Title: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_ESC_OPTIONS_TITLE;
            text = "GAMEMODE OPTIONS";
            x = BN_KOTH_ESC_MENU_INNER_X;
            y = BN_KOTH_ESC_MENU_TITLE_Y;
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
            x = BN_KOTH_ESC_MENU_INNER_X;
            y = BN_KOTH_ESC_MENU_OPTIONS_Y;
            w = BN_KOTH_ESC_MENU_INNER_W;
            h = BN_KOTH_ESC_MENU_OPTIONS_H;

            class controls
            {
                class GroundLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_LABEL;
                    text = "Earplug Volume (On Ground)";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_GROUND_Y;
                    w = BN_KOTH_ESC_MENU_LABEL_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
                };

                class GroundValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE;
                    text = "50%";
                    x = BN_KOTH_ESC_MENU_VALUE_X;
                    y = BN_KOTH_ESC_MENU_GROUND_Y;
                    w = BN_KOTH_ESC_MENU_VALUE_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
                    style = 1;
                };

                class GroundSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_SLIDER_Y(BN_KOTH_ESC_MENU_GROUND_Y);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = BN_KOTH_ESC_MENU_SLIDER_H;
                };

                class VehicleLabel: GroundLabel
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_LABEL;
                    text = "Earplug Volume (In Vehicle)";
                    y = BN_KOTH_ESC_MENU_VEHICLE_Y;
                };

                class VehicleValue: GroundValue
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE;
                    y = BN_KOTH_ESC_MENU_VEHICLE_Y;
                };

                class VehicleSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_SLIDER_Y(BN_KOTH_ESC_MENU_VEHICLE_Y);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = BN_KOTH_ESC_MENU_SLIDER_H;
                };

                class Player3DLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_LABEL;
                    text = "Player 3D Icons";
                    x = BN_KOTH_ESC_MENU_LABEL_X;
                    y = BN_KOTH_ESC_MENU_PLAYER3D_Y;
                    w = BN_KOTH_ESC_MENU_LABEL_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
                };

                class Player3DValue: BN_KOTH_RscButton
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE;
                    text = "ON";
                    x = BN_KOTH_ESC_MENU_VALUE_X;
                    y = BN_KOTH_ESC_MENU_PLAYER3D_Y;
                    w = BN_KOTH_ESC_MENU_VALUE_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
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
                    y = BN_KOTH_ESC_MENU_PLAYER3D_ALPHA_Y;
                    w = BN_KOTH_ESC_MENU_LABEL_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
                };

                class Player3DAlphaValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE;
                    text = "100%";
                    x = BN_KOTH_ESC_MENU_VALUE_X;
                    y = BN_KOTH_ESC_MENU_PLAYER3D_ALPHA_Y;
                    w = BN_KOTH_ESC_MENU_VALUE_W;
                    h = BN_KOTH_ESC_MENU_LABEL_H;
                    style = 1;
                };

                class Player3DAlphaSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_SLIDER;
                    x = BN_KOTH_ESC_MENU_SLIDER_X;
                    y = BN_KOTH_ESC_MENU_SLIDER_Y(BN_KOTH_ESC_MENU_PLAYER3D_ALPHA_Y);
                    w = BN_KOTH_ESC_MENU_SLIDER_W;
                    h = BN_KOTH_ESC_MENU_SLIDER_H;
                };

            };
        };

        class Reset: BN_KOTH_RscButton
        {
            idc = 3;
            text = "RESET";
            x = BN_KOTH_ESC_MENU_INNER_X;
            y = BN_KOTH_ESC_MENU_ACTION_Y;
            w = BN_KOTH_ESC_MENU_ACTION_W;
            h = safeZoneH * 0.04;
            onButtonClick = "_this call bn_koth_fnc_escMenu_options_reset;";
        };

        class Confirm: BN_KOTH_RscButton
        {
            idc = 1;
            text = "OK";
            x = BN_KOTH_ESC_MENU_INNER_X + 2 * (BN_KOTH_ESC_MENU_ACTION_W + BN_KOTH_ESC_MENU_ACTION_GAP);
            y = BN_KOTH_ESC_MENU_ACTION_Y;
            w = BN_KOTH_ESC_MENU_ACTION_W;
            h = safeZoneH * 0.04;
            action = "closeDialog 1;";
        };

        class Cancel: BN_KOTH_RscButton
        {
            idc = 2;
            text = "CANCEL";
            x = BN_KOTH_ESC_MENU_INNER_X + BN_KOTH_ESC_MENU_ACTION_W + BN_KOTH_ESC_MENU_ACTION_GAP;
            y = BN_KOTH_ESC_MENU_ACTION_Y;
            w = BN_KOTH_ESC_MENU_ACTION_W;
            h = safeZoneH * 0.04;
            action = "closeDialog 2;";
        };

        class Announcement: BN_KOTH_AnnouncementNotice
        {
            x = BN_KOTH_ESC_MENU_INNER_X + safeZoneW * 0.235;
            y = BN_KOTH_ESC_MENU_PANEL_Y + safeZoneH * 0.012;
            w = safeZoneW * 0.145;
            h = safeZoneH * 0.050;
            size = "0.020 * safeZoneH";
        };
    };
};

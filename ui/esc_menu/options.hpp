#include "idcs.hpp"

class BN_KOTH_RscEscMenuOptions
{
    idd = BN_KOTH_IDD_ESC_MENU_OPTIONS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call bn_koth_fnc_escMenu_options_onLoad;";
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
            w = safeZoneW * 0.38;
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
            x = safeZoneX + safeZoneW * 0.305;
            y = safeZoneY + safeZoneH * 0.35;
            w = safeZoneW * 0.37;
            h = safeZoneH * 0.44;

            class controls
            {
                class GroundLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_LABEL;
                    text = "Earplug Volume (On Ground)";
                    x = 0;
                    y = 0;
                    w = safeZoneW * 0.23;
                    h = safeZoneH * 0.035;
                };

                class GroundValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_VALUE;
                    text = "50%";
                    x = safeZoneW * 0.24;
                    y = 0;
                    w = safeZoneW * 0.11;
                    h = safeZoneH * 0.035;
                    style = 1;
                };

                class GroundSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_GROUND_SLIDER;
                    x = 0;
                    y = safeZoneH * 0.05;
                    w = safeZoneW * 0.38;
                    h = safeZoneH * 0.03;
                };

                class VehicleLabel: GroundLabel
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_LABEL;
                    text = "Earplug Volume (In Vehicle)";
                    y = safeZoneH * 0.14;
                };

                class VehicleValue: GroundValue
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_VALUE;
                    y = safeZoneH * 0.14;
                };

                class VehicleSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_VEHICLE_SLIDER;
                    x = 0;
                    y = safeZoneH * 0.19;
                    w = safeZoneW * 0.38;
                    h = safeZoneH * 0.03;
                };

                class Player3DLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_LABEL;
                    text = "Player 3D Icons";
                    x = 0;
                    y = safeZoneH * 0.28;
                    w = safeZoneW * 0.22;
                    h = safeZoneH * 0.035;
                };

                class Player3DValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_VALUE;
                    text = "ON";
                    x = 0.23;
                    y = safeZoneH * 0.28;
                    w = safeZoneW * 0.08;
                    h = safeZoneH * 0.035;
                    style = 1;
                };

                class Player3DCheckbox: BN_KOTH_RscCheckBox
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_CHECKBOX;
                    x = 0.31;
                    y = safeZoneH * 0.287;
                    w = safeZoneW * 0.02;
                    h = safeZoneH * 0.02;
                    checked = 1;
                };

                class Player3DAlphaLabel: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_LABEL;
                    text = "Player 3D Icons Alpha";
                    x = 0;
                    y = safeZoneH * 0.36;
                    w = safeZoneW * 0.25;
                    h = safeZoneH * 0.035;
                };

                class Player3DAlphaValue: BN_KOTH_RscText
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_VALUE;
                    text = "100%";
                    x = safeZoneW * 0.24;
                    y = safeZoneH * 0.36;
                    w = safeZoneW * 0.11;
                    h = safeZoneH * 0.035;
                    style = 1;
                };

                class Player3DAlphaSlider: BN_KOTH_RscSlider
                {
                    idc = BN_KOTH_IDC_ESC_OPTIONS_PLAYER3D_ALPHA_SLIDER;
                    x = 0;
                    y = safeZoneH * 0.41;
                    w = safeZoneW * 0.38;
                    h = safeZoneH * 0.03;
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
            action = "closeDialog 3;";
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
    };
};

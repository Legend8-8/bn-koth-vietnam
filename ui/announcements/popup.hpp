#include "idcs.hpp"

class BN_KOTH_RscAnnouncementPopup
{
    idd = BN_KOTH_IDD_ANNOUNCEMENT_POPUP;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call bn_koth_fnc_announcements_popupOnLoad;";
    onUnload = "uiNamespace setVariable ['BN_KOTH_announcementPopupDisplay', displayNull];";

    class controlsBackground
    {
        class Screen: BN_KOTH_RscText
        {
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0, 0, 0, 0.72};
        };

        class Panel: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.25;
            y = safeZoneY + safeZoneH * 0.20;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.60;
            colorBackground[] = {0.035, 0.035, 0.03, 0.98};
        };

        class Header: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.25;
            y = safeZoneY + safeZoneH * 0.20;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.085;
            colorBackground[] = {0.20, 0.065, 0.045, 0.98};
        };

        class Accent: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.25;
            y = safeZoneY + safeZoneH * 0.282;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.003;
            colorBackground[] = {0.88, 0.58, 0.20, 1};
        };
    };

    class controls
    {
        class Title: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_ANNOUNCEMENT_POPUP_TITLE;
            text = "";
            style = 2;
            font = "PuristaSemiBold";
            x = safeZoneX + safeZoneW * 0.275;
            y = safeZoneY + safeZoneH * 0.218;
            w = safeZoneW * 0.45;
            h = safeZoneH * 0.050;
            sizeEx = "0.040 * safeZoneH";
            colorText[] = {1, 0.90, 0.70, 1};
        };

        class Body: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_ANNOUNCEMENT_POPUP_BODY;
            text = "";
            x = safeZoneX + safeZoneW * 0.285;
            y = safeZoneY + safeZoneH * 0.315;
            w = safeZoneW * 0.43;
            h = safeZoneH * 0.36;
            size = "0.023 * safeZoneH";

            class Attributes
            {
                font = "RobotoCondensed";
                color = "#EEECE6";
                align = "left";
                valign = "top";
                shadow = 0;
            };
        };

        class Close: BN_KOTH_RscButton
        {
            idc = BN_KOTH_IDC_ANNOUNCEMENT_POPUP_CLOSE;
            text = "CLOSE";
            x = safeZoneX + safeZoneW * 0.40;
            y = safeZoneY + safeZoneH * 0.715;
            w = safeZoneW * 0.20;
            h = safeZoneH * 0.050;
            font = "PuristaSemiBold";
            sizeEx = "0.024 * safeZoneH";
            colorBackground[] = {0.34, 0.11, 0.07, 0.96};
            colorBackgroundActive[] = {0.50, 0.16, 0.09, 1};
            colorFocused[] = {0.50, 0.16, 0.09, 1};
            onButtonClick = "(ctrlParent (_this select 0)) closeDisplay 2;";
        };
    };
};

#include "idcs.hpp"

class BN_KOTH_RscTransition
{
    idd = -1;
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "uiNamespace setVariable ['BN_KOTH_transitionDisplay', _this select 0];";
    onUnload = "uiNamespace setVariable ['BN_KOTH_transitionDisplay', displayNull];";

    class controls
    {
        class Background: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_TRANSITION_BACKGROUND;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            colorBackground[] = {0, 0, 0, 1};
        };

        class Accent: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_TRANSITION_ACCENT;
            x = safeZoneX + safeZoneW * 0.19;
            y = safeZoneY + safeZoneH * 0.22;
            w = safeZoneW * 0.002;
            h = safeZoneH * 0.50;
            colorBackground[] = {0.72, 0.55, 0.20, 0.92};
        };

        class TypewriterText: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_TRANSITION_TEXT;
            style = 16;
            font = "EtelkaMonospaceProBold";
            x = safeZoneX + safeZoneW * 0.215;
            y = safeZoneY + safeZoneH * 0.22;
            w = safeZoneW * 0.57;
            h = safeZoneH * 0.50;
            sizeEx = "0.026 * safeZoneH";
            lineSpacing = 1.15;
            colorText[] = {0.88, 0.86, 0.76, 1};
        };

        class Footer: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_TRANSITION_FOOTER;
            text = "BRO-NATION KOTH";
            font = "EtelkaMonospaceProBold";
            style = 1;
            x = safeZoneX + safeZoneW * 0.55;
            y = safeZoneY + safeZoneH * 0.75;
            w = safeZoneW * 0.235;
            h = safeZoneH * 0.035;
            sizeEx = "0.016 * safeZoneH";
            colorText[] = {0.55, 0.52, 0.43, 0.88};
        };

    };
};

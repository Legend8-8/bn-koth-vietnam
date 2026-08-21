#include "idcs.hpp"

#define BN_KOTH_HUD_W (safeZoneW * 0.19)
#define BN_KOTH_HUD_H (safeZoneH * 0.07)

#define BN_KOTH_HUD_X (safeZoneX + safeZoneW - BN_KOTH_HUD_W - safeZoneW * 0.012)
#define BN_KOTH_HUD_Y (safeZoneY + safeZoneH - BN_KOTH_HUD_H - safeZoneH * 0.025)

class BN_KOTH_RscHud
{
    idd = -1;
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "uiNamespace setVariable ['BN_KOTH_hudDisplay', _this select 0]; uiNamespace setVariable ['BN_KOTH_hudStaticKey', []]; uiNamespace setVariable ['BN_KOTH_hudSafeZonePreviousProtected', false]; uiNamespace setVariable ['BN_KOTH_hudSafeZoneExitUntil', -1]; [] call bn_koth_fnc_ui_refreshHud;";
    onUnload = "uiNamespace setVariable ['BN_KOTH_hudDisplay', displayNull]; uiNamespace setVariable ['BN_KOTH_hudSafeZonePreviousProtected', false]; uiNamespace setVariable ['BN_KOTH_hudSafeZoneExitUntil', -1];";

    class controls
    {
        class HudBackground: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_BACKGROUND;
            text = "";
            x = BN_KOTH_HUD_X;
            y = BN_KOTH_HUD_Y;
            w = BN_KOTH_HUD_W;
            h = BN_KOTH_HUD_H;
            colorBackground[] = {0.03, 0.03, 0.03, 0.72};
        };

        class WestScore: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_WEST_SCORE;
            text = "WEST 0";
            style = 0;
            font = "PuristaSemiBold";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.05;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.06;
            w = BN_KOTH_HUD_W * 0.30;
            h = BN_KOTH_HUD_H * 0.28;
            sizeEx = "0.015 * safeZoneH";
            colorText[] = {0.45, 0.77, 1, 1};
            colorBackground[] = {0, 0, 0, 0};
        };

        class HudStatus: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_STATUS;
            text = "NEUTRAL";
            style = 2;
            font = "PuristaSemiBold";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.30;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.06;
            w = BN_KOTH_HUD_W * 0.40;
            h = BN_KOTH_HUD_H * 0.28;
            sizeEx = "0.014 * safeZoneH";
            colorText[] = {0.88, 0.86, 0.80, 0.95};
            colorBackground[] = {0, 0, 0, 0};
        };

        class EastScore: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_EAST_SCORE;
            text = "0 EAST";
            style = 1;
            font = "PuristaSemiBold";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.65;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.06;
            w = BN_KOTH_HUD_W * 0.30;
            h = BN_KOTH_HUD_H * 0.28;
            sizeEx = "0.015 * safeZoneH";
            colorText[] = {1, 0.48, 0.48, 1};
            colorBackground[] = {0, 0, 0, 0};
        };

        class HudRoundLead: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_ROUND_LEAD;
            text = "ROUND: TIED";
            style = 2;
            font = "PuristaSemiBold";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.05;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.34;
            w = BN_KOTH_HUD_W * 0.90;
            h = BN_KOTH_HUD_H * 0.24;
            sizeEx = "0.011 * safeZoneH";
            colorText[] = {0.88, 0.86, 0.80, 0.95};
            colorBackground[] = {0, 0, 0, 0};
        };

        class HudProgressBg: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_PROGRESS_BG;
            text = "";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.05;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.68;
            w = BN_KOTH_HUD_W * 0.90;
            h = BN_KOTH_HUD_H * 0.15;
            colorBackground[] = {0.08, 0.08, 0.08, 0.92};
        };

        class HudProgressFill: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_PROGRESS_FILL;
            text = "";
            x = BN_KOTH_HUD_X + BN_KOTH_HUD_W * 0.05;
            y = BN_KOTH_HUD_Y + BN_KOTH_HUD_H * 0.68;
            w = 0;
            h = BN_KOTH_HUD_H * 0.15;
            colorBackground[] = {0.45, 0.77, 1, 0.95};
        };

        class HudSafeZone: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_SAFE_ZONE;
            text = "";
            style = 2;
            font = "PuristaSemiBold";
            x = safeZoneX;
            y = safeZoneY + safeZoneH * 0.02;
            w = safeZoneW;
            h = safeZoneH * 0.055;
            sizeEx = "0.03 * safeZoneH";
            colorText[] = {0.10, 1, 0.20, 1};
            colorBackground[] = {0.02, 0.02, 0.02, 0.82};
        };

        class HudEnemySafeZone: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_HUD_ENEMY_SAFE_ZONE;
            text = "";
            style = 2;
            font = "PuristaSemiBold";
            x = safeZoneX;
            y = safeZoneY + safeZoneH * 0.02;
            w = safeZoneW;
            h = safeZoneH * 0.055;
            sizeEx = "0.03 * safeZoneH";
            colorText[] = {1, 0.10, 0.10, 1};
            colorBackground[] = {0.02, 0.02, 0.02, 0.82};
        };
    };
};

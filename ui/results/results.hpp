#include "idcs.hpp"

class BN_KOTH_RscResults
{
    idd = -1;
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    movingEnable = 0;
    enableSimulation = 1;

    onLoad = "uiNamespace setVariable ['BN_KOTH_resultsDisplay', _this select 0];";
    onUnload = "uiNamespace setVariable ['BN_KOTH_resultsDisplay', displayNull];";

    class controls
    {
        class Background: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_BACKGROUND;
            x = safeZoneXAbs;
            y = safeZoneY;
            w = safeZoneWAbs;
            h = safeZoneH;
            colorBackground[] = {0, 0, 0, 1};
        };

        class Frame: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_FRAME;
            style = 64;
            x = safeZoneX + safeZoneW * 0.13;
            y = safeZoneY + safeZoneH * 0.13;
            w = safeZoneW * 0.74;
            h = safeZoneH * 0.72;
            colorText[] = {0.42, 0.38, 0.27, 0.85};
            fade = 1;
        };

        class Accent: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_ACCENT;
            x = safeZoneX + safeZoneW * 0.13;
            y = safeZoneY + safeZoneH * 0.13;
            w = safeZoneW * 0.003;
            h = safeZoneH * 0.72;
            colorBackground[] = {0.72, 0.55, 0.20, 0.95};
            fade = 1;
        };

        class Title: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_TITLE;
            text = "AFTER ACTION REPORT";
            font = "RobotoCondensedBold";
            style = 2;
            x = safeZoneX + safeZoneW * 0.20;
            y = safeZoneY + safeZoneH * 0.17;
            w = safeZoneW * 0.60;
            h = safeZoneH * 0.05;
            sizeEx = "0.036 * safeZoneH";
            colorText[] = {0.88, 0.86, 0.76, 1};
            fade = 1;
        };

        class Outcome: Title
        {
            idc = BN_KOTH_IDC_RESULTS_OUTCOME;
            text = "ROUND COMPLETE";
            y = safeZoneY + safeZoneH * 0.235;
            h = safeZoneH * 0.065;
            sizeEx = "0.052 * safeZoneH";
            colorText[] = {0.92, 0.70, 0.25, 1};
        };

        class ScoreLabel: Title
        {
            idc = BN_KOTH_IDC_RESULTS_SCORE_LABEL;
            text = "FINAL SCORE";
            y = safeZoneY + safeZoneH * 0.305;
            h = safeZoneH * 0.03;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.55, 0.52, 0.43, 1};
        };

        class Score: Title
        {
            idc = BN_KOTH_IDC_RESULTS_SCORE;
            text = "WEST 0  -  0 EAST";
            y = safeZoneY + safeZoneH * 0.342;
            h = safeZoneH * 0.05;
            sizeEx = "0.032 * safeZoneH";
        };

        class LeaderCardBase: BN_KOTH_RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.17;
            y = safeZoneY + safeZoneH * 0.44;
            w = safeZoneW * 0.205;
            h = safeZoneH * 0.22;
            colorBackground[] = {0, 0, 0, 0};
            fade = 1;
        };

        class Leader1Card: LeaderCardBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_1_CARD;
            colorBackground[] = {0.055, 0.055, 0.048, 0.98};
        };

        class Leader2Card: LeaderCardBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_2_CARD;
            x = safeZoneX + safeZoneW * 0.3975;
            colorBackground[] = {0.055, 0.055, 0.048, 0.98};
        };

        class Leader3Card: LeaderCardBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_3_CARD;
            x = safeZoneX + safeZoneW * 0.625;
            colorBackground[] = {0.055, 0.055, 0.048, 0.98};
        };

        class LeaderLabelBase: BN_KOTH_RscText
        {
            idc = -1;
            font = "RobotoCondensedBold";
            style = 2;
            x = safeZoneX + safeZoneW * 0.18;
            y = safeZoneY + safeZoneH * 0.47;
            w = safeZoneW * 0.185;
            h = safeZoneH * 0.028;
            sizeEx = "0.019 * safeZoneH";
            colorText[] = {0.72, 0.55, 0.20, 1};
            fade = 1;
        };

        class Leader1Label: LeaderLabelBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_1_LABEL;
            text = "MOST DEADLY";
        };

        class Leader2Label: LeaderLabelBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_2_LABEL;
            text = "OBJECTIVE";
            x = safeZoneX + safeZoneW * 0.4075;
        };

        class Leader3Label: LeaderLabelBase
        {
            idc = BN_KOTH_IDC_RESULTS_LEADER_3_LABEL;
            text = "BEST STREAK";
            x = safeZoneX + safeZoneW * 0.635;
        };

        class LeaderNameBase: LeaderLabelBase
        {
            idc = -1;
            font = "RobotoCondensed";
            y = safeZoneY + safeZoneH * 0.525;
            h = safeZoneH * 0.04;
            sizeEx = "0.027 * safeZoneH";
            colorText[] = {0.92, 0.91, 0.86, 1};
        };

        class Leader1Name: LeaderNameBase {idc = BN_KOTH_IDC_RESULTS_LEADER_1_NAME;};
        class Leader2Name: LeaderNameBase {idc = BN_KOTH_IDC_RESULTS_LEADER_2_NAME; x = safeZoneX + safeZoneW * 0.4075;};
        class Leader3Name: LeaderNameBase {idc = BN_KOTH_IDC_RESULTS_LEADER_3_NAME; x = safeZoneX + safeZoneW * 0.635;};

        class LeaderValueBase: LeaderLabelBase
        {
            idc = -1;
            y = safeZoneY + safeZoneH * 0.585;
            h = safeZoneH * 0.035;
            sizeEx = "0.022 * safeZoneH";
            colorText[] = {0.62, 0.60, 0.54, 1};
        };

        class Leader1Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_1_VALUE;};
        class Leader2Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_2_VALUE; x = safeZoneX + safeZoneW * 0.4075;};
        class Leader3Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_3_VALUE; x = safeZoneX + safeZoneW * 0.635;};

        class Status: Title
        {
            idc = BN_KOTH_IDC_RESULTS_STATUS;
            text = "RETURNING TO OPERATIONS...";
            y = safeZoneY + safeZoneH * 0.715;
            h = safeZoneH * 0.032;
            sizeEx = "0.019 * safeZoneH";
            colorText[] = {0.72, 0.55, 0.20, 1};
        };

        class Footer: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_FOOTER;
            text = "BRO-NATION KOTH  /  OPERATIONAL DEBRIEF";
            font = "EtelkaMonospaceProBold";
            style = 2;
            x = safeZoneX + safeZoneW * 0.25;
            y = safeZoneY + safeZoneH * 0.79;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.025;
            sizeEx = "0.014 * safeZoneH";
            colorText[] = {0.45, 0.43, 0.37, 0.9};
            fade = 1;
        };
    };
};

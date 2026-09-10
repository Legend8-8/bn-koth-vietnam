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
            y = safeZoneY + safeZoneH * 0.08;
            w = safeZoneW * 0.74;
            h = safeZoneH * 0.84;
            colorText[] = {0.42, 0.38, 0.27, 0.85};
            fade = 1;
        };

        class Accent: BN_KOTH_RscText
        {
            idc = BN_KOTH_IDC_RESULTS_ACCENT;
            x = safeZoneX + safeZoneW * 0.13;
            y = safeZoneY + safeZoneH * 0.08;
            w = safeZoneW * 0.003;
            h = safeZoneH * 0.84;
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
            y = safeZoneY + safeZoneH * 0.10;
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
            y = safeZoneY + safeZoneH * 0.155;
            h = safeZoneH * 0.065;
            sizeEx = "0.052 * safeZoneH";
            colorText[] = {0.92, 0.70, 0.25, 1};
        };

        class ScoreLabel: Title
        {
            idc = BN_KOTH_IDC_RESULTS_SCORE_LABEL;
            text = "FINAL SCORE";
            y = safeZoneY + safeZoneH * 0.220;
            h = safeZoneH * 0.03;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.55, 0.52, 0.43, 1};
        };

        class Score: Title
        {
            idc = BN_KOTH_IDC_RESULTS_SCORE;
            text = "WEST 0  -  0 EAST";
            y = safeZoneY + safeZoneH * 0.248;
            h = safeZoneH * 0.05;
            sizeEx = "0.032 * safeZoneH";
        };

        class Personal: Title
        {
            idc = BN_KOTH_IDC_RESULTS_PERSONAL;
            text = "YOU  0 KILLS  /  0 DEATHS  /  0 ASSISTS  /  0 OBJ";
            y = safeZoneY + safeZoneH * 0.302;
            h = safeZoneH * 0.025;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.82, 0.80, 0.72, 1};
        };

        class Rewards: Personal
        {
            idc = BN_KOTH_IDC_RESULTS_REWARDS;
            text = "ROUND REWARDS  +0 XP  /  $+0";
            y = safeZoneY + safeZoneH * 0.327;
            colorText[] = {0.62, 0.60, 0.54, 1};
        };

        class Duration: Personal
        {
            idc = BN_KOTH_IDC_RESULTS_DURATION;
            text = "DURATION  00:00";
            x = safeZoneX + safeZoneW * 0.69;
            y = safeZoneY + safeZoneH * 0.302;
            w = safeZoneW * 0.14;
            style = 1;
            colorText[] = {0.45, 0.43, 0.37, 1};
        };

        class LeaderCardBase: BN_KOTH_RscText
        {
            idc = -1;
            x = safeZoneX + safeZoneW * 0.17;
            y = safeZoneY + safeZoneH * 0.365;
            w = safeZoneW * 0.205;
            h = safeZoneH * 0.13;
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
            y = safeZoneY + safeZoneH * 0.378;
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
            y = safeZoneY + safeZoneH * 0.414;
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
            y = safeZoneY + safeZoneH * 0.458;
            h = safeZoneH * 0.035;
            sizeEx = "0.022 * safeZoneH";
            colorText[] = {0.62, 0.60, 0.54, 1};
        };

        class Leader1Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_1_VALUE;};
        class Leader2Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_2_VALUE; x = safeZoneX + safeZoneW * 0.4075;};
        class Leader3Value: LeaderValueBase {idc = BN_KOTH_IDC_RESULTS_LEADER_3_VALUE; x = safeZoneX + safeZoneW * 0.635;};

        class ScoreboardLabel: Title
        {
            idc = BN_KOTH_IDC_RESULTS_SCOREBOARD_LABEL;
            text = "MATCH SCOREBOARD  /  TEAM > OBJECTIVE > KILLS > NAME";
            x = safeZoneX + safeZoneW * 0.17;
            y = safeZoneY + safeZoneH * 0.512;
            w = safeZoneW * 0.66;
            h = safeZoneH * 0.026;
            style = 0;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.72, 0.55, 0.20, 1};
        };

        class Scoreboard: BN_KOTH_RscListNBox
        {
            idc = BN_KOTH_IDC_RESULTS_SCOREBOARD;
            x = safeZoneX + safeZoneW * 0.17;
            y = safeZoneY + safeZoneH * 0.542;
            w = safeZoneW * 0.66;
            h = safeZoneH * 0.285;
            columns[] = {0.01, 0.34, 0.42, 0.48, 0.54, 0.61, 0.68, 0.76, 0.84, 0.92};
            sizeEx = "0.016 * safeZoneH";
            rowHeight = "0.026 * safeZoneH";
            colorBackground[] = {0.025, 0.025, 0.022, 0.96};
            colorSelectBackground[] = {0.12, 0.11, 0.08, 0.96};
            colorSelectBackground2[] = {0.12, 0.11, 0.08, 0.96};
            autoScrollSpeed = 0.02;
            autoScrollDelay = 2;
            autoScrollRewind = 1;
            fade = 1;
        };

        class Status: Title
        {
            idc = BN_KOTH_IDC_RESULTS_STATUS;
            text = "RETURNING TO OPERATIONS...";
            y = safeZoneY + safeZoneH * 0.842;
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
            y = safeZoneY + safeZoneH * 0.882;
            w = safeZoneW * 0.50;
            h = safeZoneH * 0.025;
            sizeEx = "0.014 * safeZoneH";
            colorText[] = {0.45, 0.43, 0.37, 0.9};
            fade = 1;
        };
    };
};

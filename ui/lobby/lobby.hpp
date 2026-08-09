#include "idcs.hpp"
#include "controls.hpp"

#define BN_KOTH_UI_X (safeZoneX + safeZoneW * 0.02)
#define BN_KOTH_UI_Y (safeZoneY + safeZoneH * 0.03)
#define BN_KOTH_UI_W (safeZoneW * 0.96)
#define BN_KOTH_UI_H (safeZoneH * 0.94)

#define BN_KOTH_TOPBAR_H (BN_KOTH_UI_H * 0.095)
#define BN_KOTH_STRIP_H (BN_KOTH_UI_H * 0.045)
#define BN_KOTH_MAIN_H (BN_KOTH_UI_H * 0.62)
#define BN_KOTH_TOP_GAP (safeZoneH * 0.008)
#define BN_KOTH_MAIN_Y (BN_KOTH_UI_Y + BN_KOTH_TOPBAR_H + BN_KOTH_TOP_GAP + BN_KOTH_STRIP_H + safeZoneH * 0.012)
#define BN_KOTH_BOTTOM_Y (BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H + safeZoneH * 0.015)
#define BN_KOTH_BOTTOM_H (BN_KOTH_UI_Y + BN_KOTH_UI_H - BN_KOTH_BOTTOM_Y)

#define BN_KOTH_GAP (safeZoneW * 0.008)
#define BN_KOTH_PANEL_BORDER (safeZoneW * 0.0013)
#define BN_KOTH_WEST_W (BN_KOTH_UI_W * 0.33)
#define BN_KOTH_CENTER_W (BN_KOTH_UI_W * 0.15)
#define BN_KOTH_EAST_W (BN_KOTH_UI_W * 0.33)
#define BN_KOTH_VOTE_W (BN_KOTH_UI_W - BN_KOTH_WEST_W - BN_KOTH_CENTER_W - BN_KOTH_EAST_W - BN_KOTH_GAP * 3)

#define BN_KOTH_WEST_X BN_KOTH_UI_X
#define BN_KOTH_CENTER_X (BN_KOTH_WEST_X + BN_KOTH_WEST_W + BN_KOTH_GAP)
#define BN_KOTH_EAST_X (BN_KOTH_CENTER_X + BN_KOTH_CENTER_W + BN_KOTH_GAP)
#define BN_KOTH_VOTE_X (BN_KOTH_EAST_X + BN_KOTH_EAST_W + BN_KOTH_GAP)

class BN_KOTH_RscLobby
{
    idd = BN_KOTH_IDD_LOBBY;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['BN_KOTH_lobbyDisplay', _this select 0]; [] call bn_koth_fnc_ui_refreshLobby;";
    onUnload = "uiNamespace setVariable ['BN_KOTH_lobbyDisplay', displayNull];";

    class controlsBackground
    {
        class BgScreen: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_SCREEN;
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0.01, 0.01, 0.01, 0.88};
        };

        class BgHeaderLeft: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_HEADER;
            x = BN_KOTH_UI_X;
            y = BN_KOTH_UI_Y;
            w = BN_KOTH_UI_W * 0.29;
            h = BN_KOTH_TOPBAR_H;
            colorBackground[] = {0.09, 0.09, 0.08, 0.68};
        };

        class BgHeaderCenter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.295;
            y = BN_KOTH_UI_Y;
            w = BN_KOTH_UI_W * 0.39;
            h = BN_KOTH_TOPBAR_H;
            colorBackground[] = {0.08, 0.08, 0.07, 0.78};
        };

        class BgHeaderRight: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.69;
            y = BN_KOTH_UI_Y;
            w = BN_KOTH_UI_W * 0.31;
            h = BN_KOTH_TOPBAR_H;
            colorBackground[] = {0.08, 0.08, 0.07, 0.68};
        };

        class BgInfoStrip: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X;
            y = BN_KOTH_UI_Y + BN_KOTH_TOPBAR_H + BN_KOTH_TOP_GAP;
            w = BN_KOTH_UI_W;
            h = BN_KOTH_STRIP_H;
            colorBackground[] = {0.08, 0.08, 0.07, 0.58};
        };

        class BgWest: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_WEST;
            x = BN_KOTH_WEST_X;
            y = BN_KOTH_MAIN_Y;
            w = BN_KOTH_WEST_W;
            h = BN_KOTH_MAIN_H;
            colorBackground[] = {0.12, 0.27, 0.41, 0.72};
        };

        class BgWestInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_WEST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.03, 0.03, 0.03, 0.84};
        };

        class BgWestArt: BN_KOTH_Lobby_Picture
        {
            x = BN_KOTH_WEST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.38;
            text = "";
        };

        class BgWestArtTint: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_WEST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.38;
            colorBackground[] = {0.02, 0.09, 0.14, 0.64};
        };

        class BgWestRoster: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_WEST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.38;
            w = BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.46;
            colorBackground[] = {0.02, 0.04, 0.06, 0.76};
        };

        class BgWestFooter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_WEST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.84;
            w = BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.16 - BN_KOTH_PANEL_BORDER;
            colorBackground[] = {0.03, 0.05, 0.08, 0.82};
        };

        class BgCenter: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_CENTER;
            x = BN_KOTH_CENTER_X;
            y = BN_KOTH_MAIN_Y;
            w = BN_KOTH_CENTER_W;
            h = BN_KOTH_MAIN_H;
            colorBackground[] = {0.23, 0.21, 0.16, 0.56};
        };

        class BgCenterInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CENTER_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_CENTER_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.07, 0.07, 0.06, 0.90};
        };

        class BgEast: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_EAST;
            x = BN_KOTH_EAST_X;
            y = BN_KOTH_MAIN_Y;
            w = BN_KOTH_EAST_W;
            h = BN_KOTH_MAIN_H;
            colorBackground[] = {0.39, 0.12, 0.10, 0.72};
        };

        class BgEastInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_EAST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_EAST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.03, 0.03, 0.03, 0.84};
        };

        class BgEastArt: BN_KOTH_Lobby_Picture
        {
            x = BN_KOTH_EAST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_EAST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.38;
            text = "";
        };

        class BgEastArtTint: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_EAST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_EAST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.38;
            colorBackground[] = {0.14, 0.03, 0.03, 0.64};
        };

        class BgEastRoster: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_EAST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.38;
            w = BN_KOTH_EAST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.46;
            colorBackground[] = {0.07, 0.03, 0.03, 0.76};
        };

        class BgEastFooter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_EAST_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.84;
            w = BN_KOTH_EAST_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H * 0.16 - BN_KOTH_PANEL_BORDER;
            colorBackground[] = {0.08, 0.03, 0.03, 0.82};
        };

        class BgVote: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_VOTE;
            x = BN_KOTH_VOTE_X;
            y = BN_KOTH_MAIN_Y;
            w = BN_KOTH_VOTE_W;
            h = BN_KOTH_MAIN_H;
            colorBackground[] = {0.29, 0.22, 0.09, 0.52};
        };

        class BgVoteInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_VOTE_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_MAIN_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.05, 0.05, 0.04, 0.92};
        };

        class BgVoteInstruction: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + safeZoneW * 0.006;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.062;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.012;
            h = safeZoneH * 0.065;
            colorBackground[] = {0.11, 0.11, 0.10, 0.86};
        };

        class BgVotePreviousBox: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + safeZoneW * 0.006;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.15;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.012;
            h = safeZoneH * 0.064;
            colorBackground[] = {0.09, 0.09, 0.08, 0.90};
        };

        class BgVoteThumb1: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.255;
            w = BN_KOTH_VOTE_W * 0.22;
            h = safeZoneH * 0.052;
            colorBackground[] = {0.14, 0.14, 0.12, 0.72};
        };

        class BgVoteThumb2: BgVoteThumb1
        {
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.335;
        };

        class BgVoteThumb3: BgVoteThumb1
        {
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.415;
        };

        class BgVoteFooter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + safeZoneW * 0.006;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H - safeZoneH * 0.12;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.012;
            h = safeZoneH * 0.102;
            colorBackground[] = {0.10, 0.08, 0.05, 0.86};
        };

        class BgBottom: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_BOTTOM;
            x = BN_KOTH_UI_X;
            y = BN_KOTH_BOTTOM_Y;
            w = BN_KOTH_UI_W;
            h = BN_KOTH_BOTTOM_H;
            colorBackground[] = {0.10, 0.10, 0.09, 0.64};
        };

        class BgBottomInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_BOTTOM_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_UI_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_BOTTOM_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.04, 0.04, 0.04, 0.82};
        };

        class BgBottomHero: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BOTTOM_PLACEHOLDER;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.54;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.41;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.036;
            colorBackground[] = {0.08, 0.08, 0.08, 0.88};
        };

        class BgBottomHeroTint: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.54;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.41;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.036;
            colorBackground[] = {0.03, 0.03, 0.03, 0.58};
        };
    };

    class controls
    {
        class HeaderLogo: BN_KOTH_Lobby_Emblem
        {
            text = "images\ui\lobby\bn_avatar.paa";
            x = BN_KOTH_UI_X + safeZoneW * 0.008;
            y = BN_KOTH_UI_Y + safeZoneH * 0.01;
            w = safeZoneW * 0.06;
            h = BN_KOTH_TOPBAR_H - safeZoneH * 0.02;
        };

        class HeaderBrand: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_HEADER_BRAND;
            text = "<t color='#E6E0D4' size='0.88'>BRO-NATION</t><br/><t color='#F2EEE6' size='1.46'>KOTH <t color='#C85D39'>VIETNAM</t></t>";
            x = BN_KOTH_UI_X + safeZoneW * 0.065;
            y = BN_KOTH_UI_Y + safeZoneH * 0.012;
            w = BN_KOTH_UI_W * 0.20;
            h = safeZoneH * 0.058;
        };

        class HeaderTagline: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_TAGLINE;
            text = "ALIS AQUILAE";
            x = BN_KOTH_UI_X + safeZoneW * 0.066;
            y = BN_KOTH_UI_Y + safeZoneH * 0.062;
            w = BN_KOTH_UI_W * 0.18;
            h = safeZoneH * 0.02;
            colorText[] = {0.84, 0.71, 0.33, 1};
        };

        class HeaderStatus: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_HEADER_STATUS;
            text = "LOBBY";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.33;
            y = BN_KOTH_UI_Y + safeZoneH * 0.015;
            w = BN_KOTH_UI_W * 0.31;
            h = safeZoneH * 0.04;
            sizeEx = "0.043 * safeZoneH";
        };

        class HeaderSubstatus: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_HEADER_SUBSTATUS;
            text = "WAITING FOR PLAYERS TO JOIN";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.325;
            y = BN_KOTH_UI_Y + safeZoneH * 0.055;
            w = BN_KOTH_UI_W * 0.32;
            h = safeZoneH * 0.028;
            colorText[] = {0.88, 0.71, 0.23, 1};
        };

        class HeaderPlayers: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_HEADER_PLAYERS;
            text = "0 / 64 PLAYERS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.71;
            y = BN_KOTH_UI_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.15;
            h = safeZoneH * 0.026;
            colorText[] = {0.95, 0.94, 0.90, 0.94};
        };

        class HeaderRightTitle: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_RIGHT_TITLE;
            text = "ROUND STATUS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.86;
            y = BN_KOTH_UI_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.11;
            h = safeZoneH * 0.018;
            colorText[] = {0.78, 0.76, 0.70, 0.72};
        };

        class HeaderRightValue: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_HEADER_RIGHT_VALUE;
            text = "WAITING FOR TEAMS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.84;
            y = BN_KOTH_UI_Y + safeZoneH * 0.047;
            w = BN_KOTH_UI_W * 0.14;
            h = safeZoneH * 0.022;
            colorText[] = {0.95, 0.94, 0.90, 0.90};
        };

        class HeaderInfoIcon: BN_KOTH_Lobby_SectionLabel
        {
            text = "i";
            style = 2;
            x = BN_KOTH_UI_X + safeZoneW * 0.01;
            y = BN_KOTH_UI_Y + BN_KOTH_TOPBAR_H + BN_KOTH_TOP_GAP + safeZoneH * 0.009;
            w = safeZoneW * 0.016;
            h = safeZoneH * 0.024;
            colorText[] = {0.82, 0.80, 0.72, 0.88};
        };

        class HeaderInfo: BN_KOTH_Lobby_Body
        {
            idc = BN_KOTH_IDC_HEADER_INFO;
            text = "Capture and hold the objective to earn score. First team to reach the score limit wins the round.";
            x = BN_KOTH_UI_X + safeZoneW * 0.028;
            y = BN_KOTH_UI_Y + BN_KOTH_TOPBAR_H + BN_KOTH_TOP_GAP + safeZoneH * 0.007;
            w = BN_KOTH_UI_W - safeZoneW * 0.04;
            h = safeZoneH * 0.028;
            colorText[] = {0.90, 0.90, 0.88, 0.88};
        };

        class WestTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_WEST_TITLE;
            text = "WEST";
            x = BN_KOTH_WEST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.018;
            w = BN_KOTH_WEST_W * 0.60;
            h = safeZoneH * 0.04;
            sizeEx = "0.048 * safeZoneH";
            colorText[] = {0.40, 0.75, 1, 1};
        };

        class WestSubtitle: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_WEST_SUBTITLE;
            text = "United States Forces";
            x = BN_KOTH_WEST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.061;
            w = BN_KOTH_WEST_W * 0.85;
            h = safeZoneH * 0.025;
            colorText[] = {0.90, 0.93, 0.96, 0.86};
        };

        class WestCountLabel: BN_KOTH_Lobby_SectionLabel
        {
            text = "PLAYERS";
            x = BN_KOTH_WEST_X + safeZoneW * 0.083;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.142;
            w = safeZoneW * 0.05;
            h = safeZoneH * 0.016;
            colorText[] = {0.82, 0.88, 0.94, 0.72};
        };

        class WestCount: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_WEST_COUNT;
            text = "0 / 32";
            x = BN_KOTH_WEST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.105;
            w = safeZoneW * 0.11;
            h = safeZoneH * 0.042;
            sizeEx = "0.043 * safeZoneH";
            colorText[] = {0.88, 0.94, 1, 1};
        };

        class WestPlayersLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_WEST_PLAYERS_LABEL;
            text = "PLAYERS";
            x = BN_KOTH_WEST_X + safeZoneW * 0.02;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.41;
            w = BN_KOTH_WEST_W * 0.45;
            h = safeZoneH * 0.02;
            colorText[] = {0.82, 0.88, 0.94, 0.72};
        };

        class WestStatusLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_WEST_STATUS_LABEL;
            text = "STATUS";
            style = 1;
            x = BN_KOTH_WEST_X + BN_KOTH_WEST_W - safeZoneW * 0.095;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.41;
            w = safeZoneW * 0.06;
            h = safeZoneH * 0.02;
            colorText[] = {0.82, 0.88, 0.94, 0.72};
        };

        class WestRoster: BN_KOTH_Lobby_Roster
        {
            idc = BN_KOTH_IDC_WEST_ROSTER;
            x = BN_KOTH_WEST_X + safeZoneW * 0.018;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.446;
            w = BN_KOTH_WEST_W - safeZoneW * 0.036;
            h = BN_KOTH_MAIN_H * 0.34;
        };

        class WestJoin: BN_KOTH_Lobby_Button
        {
            idc = BN_KOTH_IDC_WEST_JOIN;
            text = "JOIN WEST TEAM";
            x = BN_KOTH_WEST_X + safeZoneW * 0.018;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.855;
            w = BN_KOTH_WEST_W - safeZoneW * 0.036;
            h = safeZoneH * 0.058;
            colorBackground[] = {0.10, 0.34, 0.63, 0.92};
            colorBackgroundActive[] = {0.15, 0.44, 0.78, 1};
            action = "['WEST'] call bn_koth_fnc_teams_requestSelection;";
        };

        class WestHint: BN_KOTH_Lobby_FinePrint
        {
            idc = BN_KOTH_IDC_WEST_HINT;
            text = "Teams are balanced for a better experience.";
            x = BN_KOTH_WEST_X + safeZoneW * 0.02;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.95;
            w = BN_KOTH_WEST_W - safeZoneW * 0.04;
            h = safeZoneH * 0.016;
            style = 2;
            colorText[] = {0.82, 0.84, 0.88, 0.68};
        };

        class CenterEmblem: BN_KOTH_Lobby_Emblem
        {
            idc = BN_KOTH_IDC_CENTER_EMBLEM;
            text = "images\ui\lobby\bn_avatar.paa";
            x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.02;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.13;
        };

        class CenterTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_CENTER_TITLE;
            text = "SPECTATOR / LOBBY";
            style = 2;
            x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.157;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.036;
            sizeEx = "0.031 * safeZoneH";
            colorText[] = {0.92, 0.92, 0.92, 1};
        };

        class CenterBrand: BN_KOTH_Lobby_SectionLabel
        {
            text = "BRO-NATION";
            style = 2;
            x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.198;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.018;
            colorText[] = {0.85, 0.73, 0.34, 0.88};
        };

        class CenterSubtitle: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_CENTER_SUBTITLE;
            text = "Wait here, spectate, or join a team to participate.";
            style = 2;
            x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.228;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.04;
        };

        class CenterMotto: BN_KOTH_Lobby_SectionLabel
        {
            text = "ALIS AQUILAE";
            style = 2;
            x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.273;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.018;
            colorText[] = {0.84, 0.71, 0.33, 0.86};
        };

        class CenterInfo: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_CENTER_INFO;
            x = BN_KOTH_CENTER_X + safeZoneW * 0.015;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.318;
            w = BN_KOTH_CENTER_W - safeZoneW * 0.03;
            h = BN_KOTH_MAIN_H - safeZoneH * 0.34;
            text = "<t align='center' size='1.0'>Waiting for mission state...</t>";
        };

        class EastTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_EAST_TITLE;
            text = "EAST";
            x = BN_KOTH_EAST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.018;
            w = BN_KOTH_EAST_W * 0.60;
            h = safeZoneH * 0.04;
            sizeEx = "0.048 * safeZoneH";
            colorText[] = {1, 0.45, 0.45, 1};
        };

        class EastSubtitle: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_EAST_SUBTITLE;
            text = "North Vietnamese Army";
            x = BN_KOTH_EAST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.061;
            w = BN_KOTH_EAST_W * 0.85;
            h = safeZoneH * 0.025;
            colorText[] = {0.96, 0.90, 0.90, 0.86};
        };

        class EastCountLabel: BN_KOTH_Lobby_SectionLabel
        {
            text = "PLAYERS";
            x = BN_KOTH_EAST_X + safeZoneW * 0.083;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.142;
            w = safeZoneW * 0.05;
            h = safeZoneH * 0.016;
            colorText[] = {0.94, 0.82, 0.82, 0.72};
        };

        class EastCount: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_EAST_COUNT;
            text = "0 / 32";
            x = BN_KOTH_EAST_X + safeZoneW * 0.08;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.105;
            w = safeZoneW * 0.11;
            h = safeZoneH * 0.042;
            sizeEx = "0.043 * safeZoneH";
            colorText[] = {1, 0.92, 0.92, 1};
        };

        class EastPlayersLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_EAST_PLAYERS_LABEL;
            text = "PLAYERS";
            x = BN_KOTH_EAST_X + safeZoneW * 0.02;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.41;
            w = BN_KOTH_EAST_W * 0.45;
            h = safeZoneH * 0.02;
            colorText[] = {0.94, 0.82, 0.82, 0.72};
        };

        class EastStatusLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_EAST_STATUS_LABEL;
            text = "STATUS";
            style = 1;
            x = BN_KOTH_EAST_X + BN_KOTH_EAST_W - safeZoneW * 0.095;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.41;
            w = safeZoneW * 0.06;
            h = safeZoneH * 0.02;
            colorText[] = {0.94, 0.82, 0.82, 0.72};
        };

        class EastRoster: BN_KOTH_Lobby_Roster
        {
            idc = BN_KOTH_IDC_EAST_ROSTER;
            x = BN_KOTH_EAST_X + safeZoneW * 0.018;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.446;
            w = BN_KOTH_EAST_W - safeZoneW * 0.036;
            h = BN_KOTH_MAIN_H * 0.34;
        };

        class EastJoin: BN_KOTH_Lobby_Button
        {
            idc = BN_KOTH_IDC_EAST_JOIN;
            text = "JOIN EAST TEAM";
            x = BN_KOTH_EAST_X + safeZoneW * 0.018;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.855;
            w = BN_KOTH_EAST_W - safeZoneW * 0.036;
            h = safeZoneH * 0.058;
            colorBackground[] = {0.62, 0.16, 0.14, 0.92};
            colorBackgroundActive[] = {0.78, 0.22, 0.18, 1};
            action = "['EAST'] call bn_koth_fnc_teams_requestSelection;";
        };

        class EastHint: BN_KOTH_Lobby_FinePrint
        {
            idc = BN_KOTH_IDC_EAST_HINT;
            text = "Switch teams anytime before deployment.";
            x = BN_KOTH_EAST_X + safeZoneW * 0.02;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.95;
            w = BN_KOTH_EAST_W - safeZoneW * 0.04;
            h = safeZoneH * 0.016;
            style = 2;
            colorText[] = {0.90, 0.82, 0.82, 0.68};
        };

        class VoteTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_VOTE_TITLE;
            text = "NEXT: MAP VOTE";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.006;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.016;
            w = BN_KOTH_VOTE_W * 0.70;
            h = safeZoneH * 0.04;
            sizeEx = "0.023 * safeZoneH";
            colorText[] = {0.92, 0.76, 0.25, 1};
        };

        class VoteTimer: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_VOTE_TIMER;
            text = "VOTE TIMER --:--";
            style = 1;
            x = BN_KOTH_VOTE_X + BN_KOTH_VOTE_W * 0.73;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.022;
            w = BN_KOTH_VOTE_W * 0.21;
            h = safeZoneH * 0.025;
            colorText[] = {0.96, 0.82, 0.32, 1};
        };

        class VoteInstructionTitle: BN_KOTH_Lobby_SectionLabel
        {
            text = "OBJECTIVE VOTE";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.074;
            w = BN_KOTH_VOTE_W * 0.40;
            h = safeZoneH * 0.016;
            colorText[] = {0.86, 0.82, 0.70, 0.72};
        };

        class VotePrevious: BN_KOTH_Lobby_Label
        {
            idc = BN_KOTH_IDC_VOTE_PREVIOUS;
            text = "PREVIOUS AO";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.162;
            w = BN_KOTH_VOTE_W * 0.42;
            h = safeZoneH * 0.026;
            colorText[] = {0.76, 0.75, 0.70, 0.72};
        };

        class VotePreviousValue: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_VOTE_PREVIOUS_VALUE;
            text = "NONE";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.185;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.026;
            colorText[] = {0.96, 0.94, 0.88, 0.94};
        };

        class VoteLocationsLabel: BN_KOTH_Lobby_SectionLabel
        {
            text = "POSSIBLE LOCATIONS";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.225;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.02;
            colorText[] = {0.86, 0.82, 0.70, 0.72};
        };

        class VoteCandidate1: BN_KOTH_Lobby_VoteButton
        {
            idc = BN_KOTH_IDC_VOTE_CANDIDATE_1;
            text = "CANDIDATE";
            x = BN_KOTH_VOTE_X + BN_KOTH_VOTE_W * 0.26;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.25;
            w = BN_KOTH_VOTE_W * 0.46;
            h = safeZoneH * 0.064;
            action = "[0] call bn_koth_fnc_round_requestVote;";
        };

        class VoteTotal1: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_1;
            text = "0";
            x = BN_KOTH_VOTE_X + BN_KOTH_VOTE_W * 0.75;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.266;
            w = BN_KOTH_VOTE_W * 0.18;
            h = safeZoneH * 0.03;
            colorText[] = {0.95, 0.94, 0.90, 1};
        };

        class VoteCandidate2: VoteCandidate1
        {
            idc = BN_KOTH_IDC_VOTE_CANDIDATE_2;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.33;
            action = "[1] call bn_koth_fnc_round_requestVote;";
        };

        class VoteTotal2: VoteTotal1
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_2;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.346;
        };

        class VoteCandidate3: VoteCandidate1
        {
            idc = BN_KOTH_IDC_VOTE_CANDIDATE_3;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.41;
            action = "[2] call bn_koth_fnc_round_requestVote;";
        };

        class VoteTotal3: VoteTotal1
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_3;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.426;
        };

        class VoteHelp: BN_KOTH_Lobby_Body
        {
            idc = BN_KOTH_IDC_VOTE_HELP;
            text = "Vote for the next objective location.";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H - safeZoneH * 0.084;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.058;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.88, 0.86, 0.82, 0.86};
        };

        class BottomTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_BOTTOM_TITLE;
            x = BN_KOTH_UI_X + safeZoneW * 0.01;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.012;
            w = BN_KOTH_UI_W * 0.30;
            h = safeZoneH * 0.034;
            sizeEx = "0.022 * safeZoneH";
            text = "MODE INFO";
        };

        class BottomDescription: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_BOTTOM_DESCRIPTION;
            x = BN_KOTH_UI_X + safeZoneW * 0.01;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.044;
            w = BN_KOTH_UI_W * 0.48;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.052;
            text = "<t size='0.95'>Two teams fight to capture and hold the objective.</t>";
        };

        class BottomPlaceholderLabel: BN_KOTH_Lobby_FinePrint
        {
            idc = BN_KOTH_IDC_BOTTOM_PLACEHOLDER_LABEL;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.56;
            y = BN_KOTH_BOTTOM_Y + BN_KOTH_BOTTOM_H * 0.62;
            w = BN_KOTH_UI_W * 0.35;
            h = safeZoneH * 0.038;
            style = 1;
            text = "BRO-NATION\nALIS AQUILAE";
            colorText[] = {0.86, 0.79, 0.57, 0.70};
        };
    };
};

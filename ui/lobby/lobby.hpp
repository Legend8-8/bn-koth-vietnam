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
// Native Arma chat draws slightly left of and above the bottom panel, so the reserved frame extends to match it.
#define BN_KOTH_CHAT_X (BN_KOTH_UI_X - safeZoneW * 0.005)
#define BN_KOTH_CHAT_Y (BN_KOTH_BOTTOM_Y - safeZoneH * 0.014)
#define BN_KOTH_CHAT_W (BN_KOTH_UI_W * 0.285 + safeZoneW * 0.005)
#define BN_KOTH_CHAT_H (safeZoneH * 0.115)
#define BN_KOTH_BOTTOM_CONTENT_X (BN_KOTH_UI_X + BN_KOTH_UI_W * 0.295)
#define BN_KOTH_BOTTOM_FRAME_Y BN_KOTH_CHAT_Y
#define BN_KOTH_BOTTOM_FRAME_H (BN_KOTH_UI_Y + BN_KOTH_UI_H - BN_KOTH_BOTTOM_FRAME_Y)

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
    onLoad = "private _display = _this select 0; uiNamespace setVariable ['BN_KOTH_lobbyDisplay', _display]; _display displayAddEventHandler ['KeyDown', '_this call bn_koth_fnc_ui_handleLobbyKeyDown']; [] call bn_koth_fnc_ui_refreshLobby; private _discordButton = _display displayCtrl 8304; if !(isNull _discordButton) then {_discordButton ctrlSetURL 'https://discord.gg/bro-nation'; _discordButton ctrlSetURLOverlayMode 0;};";
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
            x = BN_KOTH_CHAT_X;
            y = BN_KOTH_UI_Y;
            w = (BN_KOTH_UI_X + BN_KOTH_UI_W * 0.29) - BN_KOTH_CHAT_X;
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

        class BgHeaderXpTrack: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_HEADER_XP_TRACK;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.912;
            y = BN_KOTH_UI_Y + safeZoneH * 0.069;
            w = BN_KOTH_UI_W * 0.075;
            h = safeZoneH * 0.004;
            colorBackground[] = {0.16, 0.15, 0.12, 0.95};
        };

        class BgHeaderXpFill: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_HEADER_XP_FILL;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.872;
            y = BN_KOTH_UI_Y + safeZoneH * 0.069;
            w = 0;
            h = safeZoneH * 0.004;
            colorBackground[] = {0.76, 0.58, 0.20, 1};
        };

        class BgInfoStrip: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X;
            y = BN_KOTH_UI_Y + BN_KOTH_TOPBAR_H + BN_KOTH_TOP_GAP;
            w = (BN_KOTH_UI_X + BN_KOTH_UI_W) - BN_KOTH_CHAT_X;
            h = BN_KOTH_STRIP_H;
            colorBackground[] = {0.08, 0.08, 0.07, 0.58};
        };

        class BgWest: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_WEST;
            x = BN_KOTH_CHAT_X;
            y = BN_KOTH_MAIN_Y;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W) - BN_KOTH_CHAT_X;
            h = BN_KOTH_MAIN_H;
            colorBackground[] = {0.12, 0.27, 0.41, 0.72};
        };

        class BgWestInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
            h = BN_KOTH_MAIN_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.03, 0.03, 0.03, 0.84};
        };

        class BgWestArt: BN_KOTH_Lobby_Picture
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
            h = BN_KOTH_MAIN_H * 0.38;
            text = "images\ui\lobby\west_panel.jpg";
        };

        class BgWestArtTint: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_PANEL_BORDER;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
            h = BN_KOTH_MAIN_H * 0.38;
            colorBackground[] = {0.02, 0.09, 0.14, 0.64};
        };

        class BgWestRoster: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.38;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
            h = BN_KOTH_MAIN_H * 0.46;
            colorBackground[] = {0.02, 0.04, 0.06, 0.76};
        };

        class BgWestFooter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.84;
            w = (BN_KOTH_WEST_X + BN_KOTH_WEST_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
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
            text = "images\ui\lobby\east_panel.jpg";
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

        class BgVoteFooter: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_VOTE_X + safeZoneW * 0.006;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H - safeZoneH * 0.090;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.012;
            h = safeZoneH * 0.070;
            colorBackground[] = {0.10, 0.08, 0.05, 0.86};
        };

        class BgBottom: BN_KOTH_Lobby_Background
        {
            idc = BN_KOTH_IDC_BG_BOTTOM;
            x = BN_KOTH_CHAT_X;
            y = BN_KOTH_BOTTOM_FRAME_Y;
            w = (BN_KOTH_UI_X + BN_KOTH_UI_W) - BN_KOTH_CHAT_X;
            h = BN_KOTH_BOTTOM_FRAME_H;
            colorBackground[] = {0.10, 0.10, 0.09, 0.64};
        };

        class BgBottomInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_BOTTOM_FRAME_Y + BN_KOTH_PANEL_BORDER;
            w = (BN_KOTH_UI_X + BN_KOTH_UI_W - BN_KOTH_PANEL_BORDER) - (BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER);
            h = BN_KOTH_BOTTOM_FRAME_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.04, 0.04, 0.04, 0.82};
        };

        class BgBottomChat: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X;
            y = BN_KOTH_CHAT_Y;
            w = BN_KOTH_CHAT_W;
            h = BN_KOTH_CHAT_H;
            colorBackground[] = {0.29, 0.22, 0.09, 0.52};
        };

        class BgBottomChatInset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_CHAT_Y + BN_KOTH_PANEL_BORDER;
            w = BN_KOTH_CHAT_W - BN_KOTH_PANEL_BORDER * 2;
            h = BN_KOTH_CHAT_H - BN_KOTH_PANEL_BORDER * 2;
            colorBackground[] = {0.03, 0.03, 0.03, 0.90};
        };

        class BgBottomLeader1: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.630;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.037;
            w = BN_KOTH_UI_W * 0.108;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.052;
            colorBackground[] = {0.38, 0.31, 0.15, 0.78};
        };

        class BgBottomLeader1Inset: BN_KOTH_Lobby_Background
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.6315;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.039;
            w = BN_KOTH_UI_W * 0.105;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.056;
            colorBackground[] = {0.055, 0.055, 0.05, 0.96};
        };

        class BgBottomLeader2: BgBottomLeader1
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.745;
        };

        class BgBottomLeader2Inset: BgBottomLeader1Inset
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.7465;
        };

        class BgBottomLeader3: BgBottomLeader1
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.860;
        };

        class BgBottomLeader3Inset: BgBottomLeader1Inset
        {
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.8615;
        };
    };

    class controls
    {
		class HeaderBrand: BN_KOTH_RscStructuredText
		{
			idc = BN_KOTH_IDC_HEADER_BRAND;
			text = "<t font='PuristaSemiBold' color='#E6E0D4' size='0.88'>BRO-NATION</t><br/><t font='PuristaSemiBold' color='#F2EEE6' size='1.46'>KOTH <t color='#C85D39'>VIETNAM</t></t>";
			x = BN_KOTH_UI_X + safeZoneW * 0.012;
			y = BN_KOTH_UI_Y + safeZoneH * 0.012;
			w = BN_KOTH_UI_W * 0.26;
			h = safeZoneH * 0.058;
		};

		class HeaderTagline: BN_KOTH_Lobby_SectionLabel
		{
			idc = BN_KOTH_IDC_HEADER_TAGLINE;
			text = "ALIS AQUILAE";
			x = BN_KOTH_UI_X + safeZoneW * 0.013;
			y = BN_KOTH_UI_Y + safeZoneH * 0.062;
			w = BN_KOTH_UI_W * 0.25;
			h = safeZoneH * 0.02;
			colorText[] = {0.84, 0.71, 0.33, 1};
		};

		class HeaderStatus: BN_KOTH_Lobby_Title
		{
			idc = BN_KOTH_IDC_HEADER_STATUS;
			font = "PuristaSemiBold";
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

class HeaderPlayersLabel: BN_KOTH_Lobby_SectionLabel
{
    idc = BN_KOTH_IDC_HEADER_PLAYERS_LABEL;
    text = "PLAYERS";
    style = 2;

    x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.705;
    y = BN_KOTH_UI_Y + safeZoneH * 0.018;
    w = BN_KOTH_UI_W * 0.12;
    h = safeZoneH * 0.018;

    colorText[] = {0.78, 0.76, 0.70, 0.72};
};

class HeaderPlayers: BN_KOTH_Lobby_Subtitle
{
    idc = BN_KOTH_IDC_HEADER_PLAYERS;
    text = "0 / 100";
    style = 2;

    x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.705;
    y = BN_KOTH_UI_Y + safeZoneH * 0.047;
    w = BN_KOTH_UI_W * 0.12;
    h = safeZoneH * 0.022;

    sizeEx = "0.024 * safeZoneH";
    colorText[] = {0.95, 0.94, 0.90, 0.94};
};

        class HeaderRightTitle: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_RIGHT_TITLE;
            text = "ROUND STATUS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.785;
            y = BN_KOTH_UI_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.095;
            h = safeZoneH * 0.018;
            colorText[] = {0.78, 0.76, 0.70, 0.72};
        };

        class HeaderRightValue: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_HEADER_RIGHT_VALUE;
            text = "WAITING FOR TEAMS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.780;
            y = BN_KOTH_UI_Y + safeZoneH * 0.047;
            w = BN_KOTH_UI_W * 0.105;
            h = safeZoneH * 0.022;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.95, 0.94, 0.90, 0.90};
        };

        class HeaderRankBadge: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_HEADER_RANK_BADGE;
            text = "1";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.887;
            y = BN_KOTH_UI_Y + safeZoneH * 0.018;
            w = BN_KOTH_UI_W * 0.022;
            h = safeZoneH * 0.044;
            sizeEx = "0.028 * safeZoneH";
            colorText[] = {0.89, 0.70, 0.24, 1};
            colorBackground[] = {0.12, 0.11, 0.08, 0.92};
        };

        class HeaderPlayerName: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_PLAYER_NAME;
            text = "PLAYER";
            style = 0;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.912;
            y = BN_KOTH_UI_Y + safeZoneH * 0.009;
            w = BN_KOTH_UI_W * 0.075;
            h = safeZoneH * 0.018;
            sizeEx = "0.015 * safeZoneH";
            colorText[] = {0.92, 0.90, 0.84, 0.98};
        };

        class HeaderPlayerLevel: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_HEADER_PLAYER_LEVEL;
            text = "LEVEL 1";
            style = 0;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.912;
            y = BN_KOTH_UI_Y + safeZoneH * 0.029;
            w = BN_KOTH_UI_W * 0.045;
            h = safeZoneH * 0.020;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.89, 0.70, 0.24, 1};
        };

        class HeaderXp: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_XP;
            text = "0 / 100 XP";
            style = 0;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.912;
            y = BN_KOTH_UI_Y + safeZoneH * 0.049;
            w = BN_KOTH_UI_W * 0.075;
            h = safeZoneH * 0.016;
            sizeEx = "0.013 * safeZoneH";
            colorText[] = {0.74, 0.72, 0.66, 0.96};
        };

        class HeaderCash: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_HEADER_CASH;
            text = "$0";
            style = 1;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.957;
            y = BN_KOTH_UI_Y + safeZoneH * 0.029;
            w = BN_KOTH_UI_W * 0.030;
            h = safeZoneH * 0.016;
            sizeEx = "0.016 * safeZoneH";
            colorText[] = {0.82, 0.79, 0.54, 1};
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

		class WestEmblem: BN_KOTH_Lobby_Emblem
		{
			idc = -1;
			x = BN_KOTH_WEST_X + BN_KOTH_WEST_W * 0.035;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.028;
			w = safeZoneH * 0.130;
			h = safeZoneH * 0.130;
			text = "images\ui\lobby\west_emblem.paa";
		};

		class WestTitle: BN_KOTH_Lobby_Title
		{
			idc = BN_KOTH_IDC_WEST_TITLE;
			text = "WEST";
			style = 2;
			font = "PuristaSemiBold";
			x = BN_KOTH_WEST_X + BN_KOTH_WEST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.020;
			w = BN_KOTH_WEST_W * 0.52;
			h = safeZoneH * 0.045;
			sizeEx = "0.050 * safeZoneH";
			colorText[] = {0.40, 0.75, 1, 1};
		};

		class WestSubtitle: BN_KOTH_Lobby_Subtitle
		{
			idc = BN_KOTH_IDC_WEST_SUBTITLE;
			text = "UNITED STATES FORCES";
			style = 2;
			x = BN_KOTH_WEST_X + BN_KOTH_WEST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.067;
			w = BN_KOTH_WEST_W * 0.52;
			h = safeZoneH * 0.026;
			colorText[] = {0.90, 0.93, 0.96, 0.90};
		};

		class WestCount: BN_KOTH_Lobby_Value
		{
			idc = BN_KOTH_IDC_WEST_COUNT;
			text = "0 / --";
			style = 2;
			x = BN_KOTH_WEST_X + BN_KOTH_WEST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.105;
			w = BN_KOTH_WEST_W * 0.52;
			h = safeZoneH * 0.045;
			sizeEx = "0.043 * safeZoneH";
			colorText[] = {0.88, 0.94, 1, 1};
		};

		class WestCountLabel: BN_KOTH_Lobby_SectionLabel
		{
			text = "PLAYERS";
			style = 2;
			x = BN_KOTH_WEST_X + BN_KOTH_WEST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.150;
			w = BN_KOTH_WEST_W * 0.52;
			h = safeZoneH * 0.018;
			colorText[] = {0.82, 0.88, 0.94, 0.78};
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
            action = "private _uid = getPlayerUID player; private _assignedSide = sideUnknown; private _assignments = missionNamespace getVariable ['BN_KOTH_playerTeamAssignments', createHashMap]; if (_assignments isEqualType createHashMap && {_uid isNotEqualTo ''}) then {_assignedSide = _assignments getOrDefault [_uid, sideUnknown];}; if (_assignedSide isEqualTo west) then {['LOBBY'] call bn_koth_fnc_teams_requestSelection;} else {['WEST'] call bn_koth_fnc_teams_requestSelection;};";
        };

		class WestHint: BN_KOTH_Lobby_FinePrint
		{
			idc = BN_KOTH_IDC_WEST_HINT;
			text = "Teams are balanced for a better experience.";
			x = BN_KOTH_WEST_X + safeZoneW * 0.02;
			y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.956;
			w = BN_KOTH_WEST_W - safeZoneW * 0.04;
			h = safeZoneH * 0.018;
			style = 2;
			sizeEx = "0.017 * safeZoneH";
			colorText[] = {0.82, 0.84, 0.88, 0.72};
		};

		class CenterEmblem: BN_KOTH_Lobby_Emblem
		{
			idc = BN_KOTH_IDC_CENTER_EMBLEM;
			text = "images\ui\lobby\bn_avatar.paa";
			x = BN_KOTH_CENTER_X + (BN_KOTH_CENTER_W - safeZoneH * 0.140) / 2;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.012;
			w = safeZoneH * 0.140;
			h = safeZoneH * 0.140;
		};

		class CenterTitle: BN_KOTH_Lobby_Title
		{
			idc = BN_KOTH_IDC_CENTER_TITLE;
			text = "SPECTATOR / LOBBY";
			style = 2;
			font = "PuristaSemiBold";
			x = BN_KOTH_CENTER_X;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.160;
			w = BN_KOTH_CENTER_W;
			h = safeZoneH * 0.040;
			sizeEx = "0.030 * safeZoneH";
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
			text = "Wait here or join a team.";
			style = 2;
			x = BN_KOTH_CENTER_X + safeZoneW * 0.008;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.228;
			w = BN_KOTH_CENTER_W - safeZoneW * 0.016;
			h = safeZoneH * 0.04;
			sizeEx = "0.018 * safeZoneH";
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
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    show = 0;
};

        class CenterScoreTitle: BN_KOTH_Lobby_SectionLabel
{
    idc = BN_KOTH_IDC_CENTER_SCORE_TITLE;
    text = "ROUND SCORE";
    style = 2;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.010;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.325;
    w = BN_KOTH_CENTER_W - safeZoneW * 0.020;
    h = safeZoneH * 0.024;

    sizeEx = "0.019 * safeZoneH";
    colorText[] = {0.88, 0.84, 0.72, 0.92};
};

class CenterWestLabel: BN_KOTH_Lobby_SectionLabel
{
    text = "WEST";
    style = 0;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.370;
    w = BN_KOTH_CENTER_W * 0.34;
    h = safeZoneH * 0.020;

    colorText[] = {0.40, 0.75, 1, 0.90};
};

class CenterWestScore: BN_KOTH_Lobby_Value
{
    idc = BN_KOTH_IDC_CENTER_WEST_SCORE;
    text = "42";
    style = 1;

    x = BN_KOTH_CENTER_X + BN_KOTH_CENTER_W * 0.58;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.360;
    w = BN_KOTH_CENTER_W * 0.28;
    h = safeZoneH * 0.034;

    sizeEx = "0.030 * safeZoneH";
    colorText[] = {0.40, 0.75, 1, 1};
};

class CenterWestBarBg: BN_KOTH_Lobby_Background
{
    idc = BN_KOTH_IDC_CENTER_WEST_BAR_BG;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.405;
    w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
    h = safeZoneH * 0.018;

    colorBackground[] = {0.03, 0.05, 0.07, 0.94};
};

class CenterWestBar: BN_KOTH_Lobby_Background
{
    idc = BN_KOTH_IDC_CENTER_WEST_BAR;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.405;
    w = (BN_KOTH_CENTER_W - safeZoneW * 0.024) * 0.42;
    h = safeZoneH * 0.018;

    colorBackground[] = {0.10, 0.34, 0.63, 0.96};
};

class CenterEastLabel: BN_KOTH_Lobby_SectionLabel
{
    text = "EAST";
    style = 0;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.450;
    w = BN_KOTH_CENTER_W * 0.34;
    h = safeZoneH * 0.020;

    colorText[] = {1, 0.45, 0.45, 0.90};
};

class CenterEastScore: BN_KOTH_Lobby_Value
{
    idc = BN_KOTH_IDC_CENTER_EAST_SCORE;
    text = "37";
    style = 1;

    x = BN_KOTH_CENTER_X + BN_KOTH_CENTER_W * 0.58;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.440;
    w = BN_KOTH_CENTER_W * 0.28;
    h = safeZoneH * 0.034;

    sizeEx = "0.030 * safeZoneH";
    colorText[] = {1, 0.45, 0.45, 1};
};

class CenterEastBarBg: BN_KOTH_Lobby_Background
{
    idc = BN_KOTH_IDC_CENTER_EAST_BAR_BG;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.485;
    w = BN_KOTH_CENTER_W - safeZoneW * 0.024;
    h = safeZoneH * 0.018;

    colorBackground[] = {0.07, 0.03, 0.03, 0.94};
};

class CenterEastBar: BN_KOTH_Lobby_Background
{
    idc = BN_KOTH_IDC_CENTER_EAST_BAR;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.012;
    y = BN_KOTH_MAIN_Y + safeZoneH * 0.485;
    w = (BN_KOTH_CENTER_W - safeZoneW * 0.024) * 0.37;
    h = safeZoneH * 0.018;

    colorBackground[] = {0.62, 0.16, 0.14, 0.96};
};

class CenterScoreLimit: BN_KOTH_Lobby_FinePrint
{
    idc = BN_KOTH_IDC_CENTER_SCORE_LIMIT;
    text = "FIRST TO 100";
    style = 2;

    x = BN_KOTH_CENTER_X + safeZoneW * 0.010;
    y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.956;
    w = BN_KOTH_CENTER_W - safeZoneW * 0.020;
    h = safeZoneH * 0.018;

    sizeEx = "0.015 * safeZoneH";
    colorText[] = {0.82, 0.80, 0.72, 0.74};
};

		class EastEmblem: BN_KOTH_Lobby_Emblem
		{
			idc = -1;
			x = BN_KOTH_EAST_X + BN_KOTH_EAST_W * 0.035;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.028;
			w = safeZoneH * 0.130;
			h = safeZoneH * 0.130;
			text = "images\ui\lobby\east_emblem.paa";
		};

		class EastTitle: BN_KOTH_Lobby_Title
		{
			idc = BN_KOTH_IDC_EAST_TITLE;
			text = "EAST";
			style = 2;
			font = "PuristaSemiBold";
			x = BN_KOTH_EAST_X + BN_KOTH_EAST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.020;
			w = BN_KOTH_EAST_W * 0.52;
			h = safeZoneH * 0.045;
			sizeEx = "0.050 * safeZoneH";
			colorText[] = {1, 0.45, 0.45, 1};
		};

		class EastSubtitle: BN_KOTH_Lobby_Subtitle
		{
			idc = BN_KOTH_IDC_EAST_SUBTITLE;
			text = "NORTH VIETNAMESE ARMY";
			style = 2;
			x = BN_KOTH_EAST_X + BN_KOTH_EAST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.067;
			w = BN_KOTH_EAST_W * 0.52;
			h = safeZoneH * 0.026;
			colorText[] = {0.96, 0.90, 0.90, 0.90};
		};

		class EastCount: BN_KOTH_Lobby_Value
		{
			idc = BN_KOTH_IDC_EAST_COUNT;
			text = "0 / --";
			style = 2;
			x = BN_KOTH_EAST_X + BN_KOTH_EAST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.105;
			w = BN_KOTH_EAST_W * 0.52;
			h = safeZoneH * 0.045;
			sizeEx = "0.043 * safeZoneH";
			colorText[] = {1, 0.92, 0.92, 1};
		};

		class EastCountLabel: BN_KOTH_Lobby_SectionLabel
		{
			text = "PLAYERS";
			style = 2;
			x = BN_KOTH_EAST_X + BN_KOTH_EAST_W * 0.30;
			y = BN_KOTH_MAIN_Y + safeZoneH * 0.150;
			w = BN_KOTH_EAST_W * 0.52;
			h = safeZoneH * 0.018;
			colorText[] = {0.94, 0.82, 0.82, 0.78};
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
            action = "private _uid = getPlayerUID player; private _assignedSide = sideUnknown; private _assignments = missionNamespace getVariable ['BN_KOTH_playerTeamAssignments', createHashMap]; if (_assignments isEqualType createHashMap && {_uid isNotEqualTo ''}) then {_assignedSide = _assignments getOrDefault [_uid, sideUnknown];}; if (_assignedSide isEqualTo east) then {['LOBBY'] call bn_koth_fnc_teams_requestSelection;} else {['EAST'] call bn_koth_fnc_teams_requestSelection;};";
        };

		class EastHint: BN_KOTH_Lobby_FinePrint
		{
			idc = BN_KOTH_IDC_EAST_HINT;
			text = "Switch teams anytime before deployment.";
			x = BN_KOTH_EAST_X + safeZoneW * 0.02;
			y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H * 0.956;
			w = BN_KOTH_EAST_W - safeZoneW * 0.04;
			h = safeZoneH * 0.018;
			style = 2;
			sizeEx = "0.017 * safeZoneH";
			colorText[] = {0.90, 0.82, 0.82, 0.72};
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
            x = BN_KOTH_VOTE_X + BN_KOTH_VOTE_W * 0.54;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.022;
            w = BN_KOTH_VOTE_W * 0.40;
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
            x = BN_KOTH_VOTE_X + safeZoneW * 0.010;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.250;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.020;
            h = safeZoneH * 0.072;
            action = "[0] call bn_koth_fnc_round_requestVote;";
            sizeEx = "0.020 * safeZoneH";
        };
class VoteTotal1: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_1;
            text = "0";
            style = 1;
            x = BN_KOTH_VOTE_X + BN_KOTH_VOTE_W * 0.83;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.260;
            w = BN_KOTH_VOTE_W * 0.105;
            h = safeZoneH * 0.030;
            colorText[] = {0.95, 0.94, 0.90, 1};
        };

        class VoteDesc1: BN_KOTH_Lobby_FinePrint
        {
            idc = BN_KOTH_IDC_VOTE_DESC_1;
            text = "";
            style = 16;
            lineSpacing = 1;
            x = BN_KOTH_VOTE_X + safeZoneW * 0.010;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.296;
            w = BN_KOTH_VOTE_W * 0.73;
            h = safeZoneH * 0.030;
            sizeEx = "0.0135 * safeZoneH";
            colorText[] = {0.82, 0.8, 0.76, 0.88};
        };

        class VoteCandidate2: VoteCandidate1
        {
            idc = BN_KOTH_IDC_VOTE_CANDIDATE_2;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.334;
            action = "[1] call bn_koth_fnc_round_requestVote;";
        };
class VoteTotal2: VoteTotal1
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_2;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.344;
        };

        class VoteDesc2: VoteDesc1
        {
            idc = BN_KOTH_IDC_VOTE_DESC_2;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.380;
        };

        class VoteCandidate3: VoteCandidate1
        {
            idc = BN_KOTH_IDC_VOTE_CANDIDATE_3;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.418;
            action = "[2] call bn_koth_fnc_round_requestVote;";
        };
class VoteTotal3: VoteTotal1
        {
            idc = BN_KOTH_IDC_VOTE_TOTAL_3;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.428;
        };

        class VoteDesc3: VoteDesc1
        {
            idc = BN_KOTH_IDC_VOTE_DESC_3;
            y = BN_KOTH_MAIN_Y + safeZoneH * 0.464;
        };

        class VoteHelp: BN_KOTH_Lobby_Body
        {
            idc = BN_KOTH_IDC_VOTE_HELP;
            text = "Vote for the next objective location.";
            x = BN_KOTH_VOTE_X + safeZoneW * 0.012;
            y = BN_KOTH_MAIN_Y + BN_KOTH_MAIN_H - safeZoneH * 0.075;
            w = BN_KOTH_VOTE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.040;
            sizeEx = "0.016 * safeZoneH";
            colorText[] = {0.88, 0.86, 0.82, 0.86};
        };


        class BottomChatLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = -1;
            text = "-- CHAT --";
            style = 2;
            x = BN_KOTH_CHAT_X + BN_KOTH_PANEL_BORDER;
            y = BN_KOTH_CHAT_Y + BN_KOTH_CHAT_H - safeZoneH * 0.020;
            w = BN_KOTH_CHAT_W - BN_KOTH_PANEL_BORDER * 2;
            h = safeZoneH * 0.016;
            sizeEx = "0.013 * safeZoneH";
            colorText[] = {0.68, 0.64, 0.52, 0.70};
        };

        class BottomTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_BOTTOM_TITLE;
            x = BN_KOTH_BOTTOM_CONTENT_X;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.006;
            w = BN_KOTH_UI_W * 0.230;
            h = safeZoneH * 0.038;
            sizeEx = "0.026 * safeZoneH";
            text = "MODE INFO";
        };

        class BottomDescription: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_BOTTOM_DESCRIPTION;
            x = BN_KOTH_BOTTOM_CONTENT_X;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.040;
            w = BN_KOTH_UI_W * 0.230;
            h = BN_KOTH_BOTTOM_H - safeZoneH * 0.048;
            size = "0.021 * safeZoneH";
            text = "<t size='0.95'>Two teams fight to capture and hold the objective.</t>";
        };

        class BottomLeadersTitle: BN_KOTH_Lobby_Title
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADERS_TITLE;
            text = "LIVE LEADERS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.630;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.002;
            w = BN_KOTH_UI_W * 0.338;
            h = safeZoneH * 0.032;
            sizeEx = "0.024 * safeZoneH";
            colorText[] = {0.88, 0.84, 0.72, 0.92};
        };

        class BottomLeader1Label: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_1_LABEL;
            text = "MOST DEADLY";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.635;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.050;
            w = BN_KOTH_UI_W * 0.098;
            h = safeZoneH * 0.020;
            sizeEx = "0.015 * safeZoneH";
            colorText[] = {0.86, 0.70, 0.42, 0.92};
        };

        class BottomLeader1Name: BN_KOTH_Lobby_Subtitle
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_1_NAME;
            text = "Mongo";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.635;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.075;
            w = BN_KOTH_UI_W * 0.098;
            h = safeZoneH * 0.032;
            sizeEx = "0.026 * safeZoneH";
            colorText[] = {0.96, 0.95, 0.92, 1};
        };

        class BottomLeader1Value: BN_KOTH_Lobby_Value
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_1_VALUE;
            text = "18 KILLS";
            style = 2;
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.635;
            y = BN_KOTH_BOTTOM_Y + safeZoneH * 0.112;
            w = BN_KOTH_UI_W * 0.098;
            h = safeZoneH * 0.026;
            sizeEx = "0.020 * safeZoneH";
            colorText[] = {0.88, 0.82, 0.70, 0.94};
        };

        class BottomLeader2Label: BottomLeader1Label
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_2_LABEL;
            text = "OBJECTIVE LEADER";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.750;
        };
        class BottomLeader2Name: BottomLeader1Name
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_2_NAME;
            text = "Tyler";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.750;
        };
        class BottomLeader2Value: BottomLeader1Value
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_2_VALUE;
            text = "624 PTS";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.750;
        };

        class BottomLeader3Label: BottomLeader1Label
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_3_LABEL;
            text = "BEST STREAK";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.865;
        };
        class BottomLeader3Name: BottomLeader1Name
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_3_NAME;
            text = "Legend";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.865;
        };
        class BottomLeader3Value: BottomLeader1Value
        {
            idc = BN_KOTH_IDC_BOTTOM_LEADER_3_VALUE;
            text = "7 KILLS";
            x = BN_KOTH_UI_X + BN_KOTH_UI_W * 0.865;
        };

        class BottomDiscordLabel: BN_KOTH_Lobby_SectionLabel
        {
            idc = BN_KOTH_IDC_BOTTOM_DISCORD_LABEL;
            text = "BRO-NATION COMMUNITY";
            style = 2;
            x = BN_KOTH_CHAT_X + BN_KOTH_CHAT_W * 0.18;
            y = BN_KOTH_CHAT_Y + BN_KOTH_CHAT_H + safeZoneH * 0.007;
            w = BN_KOTH_CHAT_W * 0.64;
            h = safeZoneH * 0.018;
            sizeEx = "0.014 * safeZoneH";
            colorText[] = {0.78, 0.76, 0.70, 0.72};
        };

        class BottomDiscordButton: BN_KOTH_RscButton
        {
            idc = BN_KOTH_IDC_BOTTOM_DISCORD_BUTTON;
            text = "JOIN DISCORD";
            x = BN_KOTH_CHAT_X + BN_KOTH_CHAT_W * 0.25;
            y = BN_KOTH_CHAT_Y + BN_KOTH_CHAT_H + safeZoneH * 0.028;
            w = BN_KOTH_CHAT_W * 0.50;
            h = safeZoneH * 0.036;
            sizeEx = "0.018 * safeZoneH";
            colorBackground[] = {0.38, 0.31, 0.15, 0.88};
            colorBackgroundActive[] = {0.52, 0.40, 0.16, 1};
            colorBackgroundDisabled[] = {0.12, 0.12, 0.11, 0.65};
            colorText[] = {0.96, 0.94, 0.86, 1};
            colorFocused[] = {0.52, 0.40, 0.16, 1};
            url = "https://discord.gg/haNcSAEhKS";
            tooltip = "Join the Bro-Nation Discord community";
            overlayMode = 0;
        };
    };
};

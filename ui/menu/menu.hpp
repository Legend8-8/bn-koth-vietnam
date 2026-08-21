#include "idcs.hpp"
#include "controls.hpp"

#define BN_KOTH_MENU_X (safeZoneX + safeZoneW * 0.02)
#define BN_KOTH_MENU_Y (safeZoneY + safeZoneH * 0.03)
#define BN_KOTH_MENU_W (safeZoneW * 0.96)
#define BN_KOTH_MENU_H (safeZoneH * 0.94)

#define BN_KOTH_MENU_HEADER_H (BN_KOTH_MENU_H * 0.095)
#define BN_KOTH_MENU_MAIN_Y (BN_KOTH_MENU_Y + BN_KOTH_MENU_HEADER_H + safeZoneH * 0.012)
#define BN_KOTH_MENU_MAIN_H (BN_KOTH_MENU_H * 0.78)
#define BN_KOTH_MENU_BOTTOM_Y (BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H + safeZoneH * 0.012)
#define BN_KOTH_MENU_BOTTOM_H (BN_KOTH_MENU_Y + BN_KOTH_MENU_H - BN_KOTH_MENU_BOTTOM_Y)

#define BN_KOTH_MENU_GAP (safeZoneW * 0.01)
#define BN_KOTH_MENU_LEFT_W (BN_KOTH_MENU_W * 0.34)
#define BN_KOTH_MENU_CENTER_W (BN_KOTH_MENU_W * 0.28)
#define BN_KOTH_MENU_RIGHT_W (BN_KOTH_MENU_W - BN_KOTH_MENU_LEFT_W - BN_KOTH_MENU_CENTER_W - BN_KOTH_MENU_GAP * 2)

#define BN_KOTH_MENU_LEFT_X BN_KOTH_MENU_X
#define BN_KOTH_MENU_CENTER_X (BN_KOTH_MENU_LEFT_X + BN_KOTH_MENU_LEFT_W + BN_KOTH_MENU_GAP)
#define BN_KOTH_MENU_RIGHT_X (BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W + BN_KOTH_MENU_GAP)
#define BN_KOTH_MENU_BROWSER_X BN_KOTH_MENU_CENTER_X
#define BN_KOTH_MENU_BROWSER_W (BN_KOTH_MENU_CENTER_W + BN_KOTH_MENU_GAP + BN_KOTH_MENU_RIGHT_W)
#define BN_KOTH_MENU_BROWSER_CARD_GAP (safeZoneW * 0.010)
#define BN_KOTH_MENU_BROWSER_CARD_W ((BN_KOTH_MENU_BROWSER_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 3) / 2)
#define BN_KOTH_MENU_BROWSER_CARD_H (safeZoneH * 0.275)
#define BN_KOTH_MENU_LOADOUT_ROW_Y (safeZoneH * 0.078)
#define BN_KOTH_MENU_LOADOUT_ROW_STEP (safeZoneH * 0.072)
#define BN_KOTH_MENU_LOADOUT_ROW_H (safeZoneH * 0.069)

class BN_KOTH_RscMenu
{
    idd = BN_KOTH_IDD_MENU;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "private _display = _this select 0; uiNamespace setVariable ['BN_KOTH_menuDisplay', _display]; _display displayAddEventHandler ['KeyDown', 'if ((_this select 1) isEqualTo 1) exitWith {[] call bn_koth_fnc_menu_close; true}; false']; ['LOADOUT'] call bn_koth_fnc_menu_refresh;";
    onUnload = "[] call bn_koth_fnc_menu_stopPlayerPreview; uiNamespace setVariable ['BN_KOTH_menuDisplay', displayNull]; uiNamespace setVariable ['BN_KOTH_menuArsenalEnabled', false]; uiNamespace setVariable ['BN_KOTH_menuIntendedLoadout', []]; uiNamespace setVariable ['BN_KOTH_menuActivePage', 'LOADOUT']; uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', -1]; uiNamespace setVariable ['BN_KOTH_menuPrimaryEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingPrimary', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuHandgunEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingHandgun', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuLauncherEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingLauncher', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuUniformEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingUniform', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuVestEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingVest', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuBackpackEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingBackpack', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuHeadgearEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingHeadgear', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuFacewearEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingFacewear', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuBinocularEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingBinocular', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuAssignedEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingAssigned', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuAttachmentEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingAttachment', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuCargoEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingCargo', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuConfigureContext', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuConfigureDrafts', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', 0];";

    class controlsBackground
    {
        class BgScreen: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_SCREEN;
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0.01, 0.01, 0.01, 0.95};
        };

        class BgHeader: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_HEADER;
            x = BN_KOTH_MENU_X;
            y = BN_KOTH_MENU_Y;
            w = BN_KOTH_MENU_W;
            h = BN_KOTH_MENU_HEADER_H;
            colorBackground[] = {0.08, 0.08, 0.07, 0.78};
        };

        class BgProgression: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_PROGRESSION;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.72;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.008;
            w = BN_KOTH_MENU_W * 0.26;
            h = safeZoneH * 0.070;
            colorBackground[] = {0.035, 0.035, 0.03, 0.94};
        };

        class BgXpTrack: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_XP_TRACK;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.735;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.064;
            w = BN_KOTH_MENU_W * 0.225;
            h = safeZoneH * 0.005;
            colorBackground[] = {0.16, 0.15, 0.12, 0.95};
        };

        class BgXpFill: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_XP_FILL;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.735;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.064;
            w = 0;
            h = safeZoneH * 0.005;
            colorBackground[] = {0.76, 0.58, 0.20, 1};
        };

        class BgLeft: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_LEFT;
            x = BN_KOTH_MENU_LEFT_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_LEFT_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.04, 0.04, 0.04, 0.94};
        };

        class BgCenter: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_CENTER;
            x = BN_KOTH_MENU_CENTER_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_CENTER_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.03, 0.03, 0.03, 0.98};
        };

        class BgRight: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_RIGHT;
            x = BN_KOTH_MENU_RIGHT_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_RIGHT_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.04, 0.04, 0.03, 0.94};
        };

        // Browser/Configure-only continuous surface. Runtime routing hides it
        // on the retained Loadout and legacy selector views.
        class BgBrowserWorkspace: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_BROWSER_WORKSPACE;
            x = BN_KOTH_MENU_BROWSER_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_BROWSER_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.03, 0.03, 0.03, 0.98};
        };

        class BgBottom: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_BOTTOM;
            x = BN_KOTH_MENU_X;
            y = BN_KOTH_MENU_BOTTOM_Y;
            w = BN_KOTH_MENU_W;
            h = BN_KOTH_MENU_BOTTOM_H;
            colorBackground[] = {0.07, 0.07, 0.06, 0.78};
        };

    };

    class controls
    {
        class HeaderBrand: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_MENU_HEADER_BRAND;
            text = "<t font='PuristaSemiBold' color='#E6E0D4' size='0.84'>BRO-NATION</t><br/><t font='PuristaSemiBold' color='#F2EEE6' size='1.42'>KOTH <t color='#C85D39'>VIETNAM</t></t>";
            x = BN_KOTH_MENU_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.011;
            w = BN_KOTH_MENU_W * 0.32;
            h = safeZoneH * 0.06;
        };

        class HeaderServer: BN_KOTH_Menu_Label
        {
            idc = BN_KOTH_IDC_MENU_HEADER_SERVER;
            text = "SERVER";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.37;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.018;
            w = BN_KOTH_MENU_W * 0.14;
            h = safeZoneH * 0.02;
        };

        class HeaderTitle: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_HEADER_TITLE;
            text = "ARSENAL";
            style = 2;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.42;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.014;
            w = BN_KOTH_MENU_W * 0.20;
            h = safeZoneH * 0.04;
            sizeEx = "0.05 * safeZoneH";
            colorText[] = {0.94, 0.92, 0.86, 0.98};
        };

        class HeaderSubtitle: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_HEADER_SUBTITLE;
            text = "CUSTOMIZE YOUR SOLDIER AND LOADOUT";
            style = 2;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.35;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.056;
            w = BN_KOTH_MENU_W * 0.36;
            h = safeZoneH * 0.024;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.86, 0.84, 0.78, 0.82};
        };

        class HeaderPlayer: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_HEADER_PLAYER;
            text = "PLAYER";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.735;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.013;
            w = BN_KOTH_MENU_W * 0.145;
            h = safeZoneH * 0.024;
            sizeEx = "0.023 * safeZoneH";
            colorText[] = {0.92, 0.90, 0.84, 0.98};
        };

        class HeaderLevel: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_HEADER_LEVEL;
            text = "LEVEL 1";
            style = 1;
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.875;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.013;
            w = BN_KOTH_MENU_W * 0.085;
            h = safeZoneH * 0.024;
            sizeEx = "0.020 * safeZoneH";
            colorText[] = {0.89, 0.70, 0.24, 1};
        };

        class HeaderXp: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_HEADER_XP;
            text = "0 / 100 XP";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W * 0.735;
            y = BN_KOTH_MENU_Y + safeZoneH * 0.039;
            w = BN_KOTH_MENU_W * 0.225;
            h = safeZoneH * 0.020;
            sizeEx = "0.016 * safeZoneH";
            colorText[] = {0.72, 0.70, 0.64, 0.98};
        };

        class OperatorTitle: BN_KOTH_Menu_Label
        {
            idc = BN_KOTH_IDC_MENU_OPERATOR_TITLE;
            text = "OPERATOR";
            x = BN_KOTH_MENU_LEFT_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.016;
            w = BN_KOTH_MENU_LEFT_W * 0.5;
            h = safeZoneH * 0.02;
        };

        class OperatorName: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_OPERATOR_NAME;
            text = "PLAYER";
            x = BN_KOTH_MENU_LEFT_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.046;
            w = BN_KOTH_MENU_LEFT_W * 0.9;
            h = safeZoneH * 0.04;
            sizeEx = "0.042 * safeZoneH";
        };

        class OperatorTeam: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_OPERATOR_TEAM;
            text = "TEAM";
            x = BN_KOTH_MENU_LEFT_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.084;
            w = BN_KOTH_MENU_LEFT_W * 0.9;
            h = safeZoneH * 0.024;
            colorText[] = {0.89, 0.70, 0.24, 0.98};
        };

        class OperatorRoleLabel: BN_KOTH_Menu_Label
        {
            idc = BN_KOTH_IDC_MENU_OPERATOR_ROLE_LABEL;
            text = "CLASS";
            x = BN_KOTH_MENU_LEFT_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.130;
            w = BN_KOTH_MENU_LEFT_W * 0.35;
            h = safeZoneH * 0.02;
        };

        class OperatorRoleValue: BN_KOTH_Menu_Value
        {
            idc = BN_KOTH_IDC_MENU_OPERATOR_ROLE_VALUE;
            text = "RIFLEMAN";
            x = BN_KOTH_MENU_LEFT_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.154;
            w = BN_KOTH_MENU_LEFT_W * 0.9;
            h = safeZoneH * 0.028;
        };

        class PrimaryPreview: BN_KOTH_RscPicture
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
            style = 2096;
            text = "";
            x = BN_KOTH_MENU_LEFT_X + BN_KOTH_MENU_LEFT_W * 0.08;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.215;
            w = BN_KOTH_MENU_LEFT_W * 0.84;
            h = safeZoneH * 0.30;
            colorText[] = {1, 1, 1, 0.98};
        };

        class PlayerPreview: BN_KOTH_RscPicture
        {
            idc = BN_KOTH_IDC_MENU_PLAYER_PREVIEW;
            style = 48;
            text = "";
            x = BN_KOTH_MENU_LEFT_X + BN_KOTH_MENU_LEFT_W * 0.06;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.205;
            w = BN_KOTH_MENU_LEFT_W * 0.88;
            h = safeZoneH * 0.50;
            colorText[] = {1, 1, 1, 1};
        };

        class SectionTitle: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_SECTION_TITLE;
            text = "LOADOUT";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.016;
            w = BN_KOTH_MENU_CENTER_W * 0.9;
            h = safeZoneH * 0.04;
            sizeEx = "0.038 * safeZoneH";
        };

        class SectionNotice: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_NOTICE;
            text = "FEATURE COMING SOON";
            style = 0;
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.058;
            w = BN_KOTH_MENU_CENTER_W * 0.94;
            h = safeZoneH * 0.024;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.88, 0.70, 0.24, 0.98};
        };

        class SlotPrimary: BN_KOTH_Menu_Value
        {
            idc = BN_KOTH_IDC_MENU_SLOT_PRIMARY;
            text = "PRIMARY";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.084;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.028;
        };

        class LoadoutBgPrimary: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_BG_PRIMARY;
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.025;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y;
            w = BN_KOTH_MENU_CENTER_W * 0.95;
            h = BN_KOTH_MENU_LOADOUT_ROW_H;
            colorBackground[] = {0.075, 0.078, 0.066, 0.96};
        };
        class LoadoutBgHandgun: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP;};
        class LoadoutBgLauncher: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 2;};
        class LoadoutBgUniform: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 3;};
        class LoadoutBgVest: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_VEST; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 4;};
        class LoadoutBgHeadgear: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_HEADGEAR; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 5;};
        class LoadoutBgBackpack: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 6;};
        class LoadoutBgEquipment: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 7;};

        class SlotPrimaryButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.025;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y;
            w = BN_KOTH_MENU_CENTER_W * 0.95;
            h = BN_KOTH_MENU_LOADOUT_ROW_H;
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0.22, 0.17, 0.08, 0.30};
            colorFocused[] = {0.22, 0.17, 0.08, 0.30};
            colorBackgroundDisabled[] = {0, 0, 0, 0};
            colorBorder[] = {0, 0, 0, 0};
            action = "uiNamespace setVariable ['BN_KOTH_menuBrowserSlot', 'primary']; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', 0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotHandgun: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_HANDGUN;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.124;
            text = "HANDGUN";
        };

        class SlotHandgunButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_HANDGUN_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP;
            action = "uiNamespace setVariable ['BN_KOTH_menuBrowserSlot', 'handgun']; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', 0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotLauncher: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_LAUNCHER;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.164;
            text = "LAUNCHER";
        };

        class SlotLauncherButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_LAUNCHER_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 2;
            action = "['LOADOUT_LAUNCHER'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotUniform: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_UNIFORM;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.214;
            text = "UNIFORM";
        };

        class SlotUniformButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_UNIFORM_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 3;
            action = "['LOADOUT_UNIFORM'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotVest: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_VEST;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.254;
            text = "VEST";
        };

        class SlotVestButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_VEST_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 4;
            action = "['LOADOUT_VEST'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotHeadgear: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_HEADGEAR;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.294;
            text = "HEADGEAR";
        };

        class SlotHeadgearButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_HEADGEAR_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 5;
            action = "['LOADOUT_HEADGEAR'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotBackpack: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_BACKPACK;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.334;
            text = "BACKPACK";
        };

        class SlotBackpackButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_BACKPACK_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 6;
            action = "['LOADOUT_BACKPACK'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotFacewear: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_FACEWEAR;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.374;
            text = "FACEWEAR";
        };

        class SlotFacewearButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_FACEWEAR_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.372;
            action = "['LOADOUT_FACEWEAR'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotBinocular: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_BINOCULAR;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.414;
            text = "BINOCULAR";
        };

        class SlotBinocularButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_BINOCULAR_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.412;
            action = "['LOADOUT_BINOCULAR'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotEquipment: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_EQUIPMENT;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.454;
            text = "EQUIPMENT";
        };

        class SlotEquipmentButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_EQUIPMENT_BUTTON;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 7;
            action = "['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotCargoButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_CARGO_BUTTON;
            text = "CARGO / ITEMS";
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.492;
            action = "uiNamespace setVariable ['BN_KOTH_menuSelectorReturnPage','LOADOUT']; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };

        // Main LOADOUT page: contained item art and two-line row text.
        class LoadoutPicPrimary: BN_KOTH_RscPicture
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_PRIMARY;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.49;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + safeZoneH * 0.006;
            w = BN_KOTH_MENU_CENTER_W * 0.35;
            h = safeZoneH * 0.057;
            colorText[] = {1, 1, 1, 0.96};
            enable = 0;
        };
        class LoadoutPicHandgun: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP + safeZoneH * 0.006;};
        class LoadoutPicLauncher: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 2 + safeZoneH * 0.006;};
        class LoadoutPicUniform: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_UNIFORM; style = 2096; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 3 + safeZoneH * 0.006;};
        class LoadoutPicVest: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_VEST; style = 2096; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 4 + safeZoneH * 0.006;};
        class LoadoutPicHeadgear: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_HEADGEAR; style = 2096; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 5 + safeZoneH * 0.006;};
        class LoadoutPicBackpack: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_BACKPACK; style = 2096; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 6 + safeZoneH * 0.006;};
        class LoadoutPicEquipment: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 7 + safeZoneH * 0.006;};

        class LoadoutRowTextPrimary: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_PRIMARY;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.055;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + safeZoneH * 0.010;
            w = BN_KOTH_MENU_CENTER_W * 0.43;
            h = safeZoneH * 0.052;
            enable = 0;
        };
        class LoadoutRowTextHandgun: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP + safeZoneH * 0.010;};
        class LoadoutRowTextLauncher: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 2 + safeZoneH * 0.010;};
        class LoadoutRowTextUniform: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 3 + safeZoneH * 0.010;};
        class LoadoutRowTextVest: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_VEST; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 4 + safeZoneH * 0.010;};
        class LoadoutRowTextHeadgear: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_HEADGEAR; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 5 + safeZoneH * 0.010;};
        class LoadoutRowTextBackpack: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 6 + safeZoneH * 0.010;};
        class LoadoutRowTextEquipment: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_LOADOUT_ROW_Y + BN_KOTH_MENU_LOADOUT_ROW_STEP * 7 + safeZoneH * 0.010;};

        class SectionFooter: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_FOOTER_TEXT;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.025;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.052;
            w = BN_KOTH_MENU_CENTER_W * 0.95;
            h = safeZoneH * 0.038;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.84, 0.82, 0.78, 0.74};
            colorBackground[] = {0.10, 0.10, 0.085, 0.96};
        };

        class KitManageButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_KIT_MANAGE;
            text = "MANAGE LOADOUTS";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.025;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.052;
            w = BN_KOTH_MENU_CENTER_W * 0.46;
            h = safeZoneH * 0.038;
            action = "uiNamespace setVariable ['BN_KOTH_menuKitPage', 0]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";
        };

        class KitSaveCurrentButton: KitManageButton
        {
            idc = BN_KOTH_IDC_MENU_KIT_SAVE_CURRENT;
            text = "SAVE CURRENT KIT";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.515;
            action = "uiNamespace setVariable ['BN_KOTH_menuKitSelectedId', '']; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";
        };

        class PrimaryTitle: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_TITLE;
            text = "PRIMARY WEAPON";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.016;
            w = BN_KOTH_MENU_CENTER_W * 0.90;
            h = safeZoneH * 0.04;
            sizeEx = "0.036 * safeZoneH";
        };

        class PrimaryCurrent: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
            text = "CURRENT: NONE";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.054;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.03;
            colorText[] = {0.89, 0.70, 0.24, 0.98};
        };

        class PrimaryList: BN_KOTH_Menu_List
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_LIST;
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.092;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.30;

        };

        class PrimaryDetail: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
            text = "SELECT A PRIMARY WEAPON";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.404;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.085;
            sizeEx = "0.017 * safeZoneH";
        };

        class PrimaryBack: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_BACK;
            text = "BACK";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.095;
            w = BN_KOTH_MENU_CENTER_W * 0.44;
            h = safeZoneH * 0.04;
            action = "if (((uiNamespace getVariable ['BN_KOTH_menuActivePage', '']) isEqualTo 'LOADOUT_EQUIPMENT') && {(uiNamespace getVariable ['BN_KOTH_menuAssignedStage', 1]) isEqualTo 2}) then {uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', -1]; ['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;} else {['LOADOUT'] call bn_koth_fnc_menu_refresh;};";
        };

        class PrimaryApply: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_PRIMARY_APPLY;
            text = "APPLY PRIMARY";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.48;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.095;
            w = BN_KOTH_MENU_CENTER_W * 0.44;
            h = safeZoneH * 0.04;
            action = "[] call bn_koth_fnc_menu_applyPrimary;";
        };

        class CargoMinus: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_CARGO_MINUS;
            text = "-";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.48;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.095;
            w = BN_KOTH_MENU_CENTER_W * 0.21;
            h = safeZoneH * 0.04;
            sizeEx = "0.028 * safeZoneH";
            action = "private _p = uiNamespace getVariable ['BN_KOTH_menuPendingCargo', createHashMap]; _p set ['delta', -1]; uiNamespace setVariable ['BN_KOTH_menuPendingCargo', _p]; [] call bn_koth_fnc_menu_applyCargo;";
        };

        class CargoPlus: CargoMinus
        {
            idc = BN_KOTH_IDC_MENU_CARGO_PLUS;
            text = "+";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.71;
            action = "private _p = uiNamespace getVariable ['BN_KOTH_menuPendingCargo', createHashMap]; _p set ['delta', 1]; uiNamespace setVariable ['BN_KOTH_menuPendingCargo', _p]; [] call bn_koth_fnc_menu_applyCargo;";
        };

        // Fixed reusable two-column browser card pool. The renderer only
        // changes local presentation; it never creates controls at runtime.
        class BrowserTitle: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_TITLE;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.014;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.016;
            w = BN_KOTH_MENU_BROWSER_W * 0.40;
            h = safeZoneH * 0.035;
            sizeEx = "0.036 * safeZoneH";
        };

        class BrowserSubtitle: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_SUBTITLE;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.014;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.052;
            w = BN_KOTH_MENU_BROWSER_W * 0.40;
            h = safeZoneH * 0.024;
        };

        class KitName: BN_KOTH_Menu_Edit
        {
            idc = BN_KOTH_IDC_MENU_KIT_NAME;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.014;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.052;
            w = BN_KOTH_MENU_BROWSER_W * 0.38;
            h = safeZoneH * 0.030;
        };

        class KitSave: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_KIT_SAVE;
            text = "SAVE NEW";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.43;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.052;
            w = BN_KOTH_MENU_BROWSER_W * 0.15;
            h = safeZoneH * 0.030;
            action = "['', ''] call bn_koth_fnc_menu_saveSessionKit;";
        };

        class KitRename: KitSave
        {
            idc = BN_KOTH_IDC_MENU_KIT_RENAME;
            text = "RENAME SELECTED";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.59;
            w = BN_KOTH_MENU_BROWSER_W * 0.20;
            action = "['', uiNamespace getVariable ['BN_KOTH_menuKitSelectedId', '']] call bn_koth_fnc_menu_saveSessionKit;";
        };

        class BrowserBack: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_BACK;
            text = "BACK";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.128;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.020;
            w = safeZoneW * 0.110;
            h = safeZoneH * 0.038;
            action = "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
        };

        class ConfigureMagazines: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_CONFIGURE_MAGAZINES;
            text = "MAGAZINES";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.43;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.020;
            w = safeZoneW * 0.105;
            h = safeZoneH * 0.038;
            action = "uiNamespace setVariable ['BN_KOTH_menuConfigureView', 'MAGAZINES']; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";
        };

        class ConfigureAttachments: ConfigureMagazines
        {
            idc = BN_KOTH_IDC_MENU_CONFIGURE_ATTACHMENTS;
            text = "ATTACHMENTS";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.61;
            w = safeZoneW * 0.108;
            action = "uiNamespace setVariable ['BN_KOTH_menuConfigureView', 'ATTACHMENTS']; uiNamespace setVariable ['BN_KOTH_menuConfigureAttachmentPage', 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";
        };

        class CargoCategoryAmmunition: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_AMMUNITION;
            text = "AMMO";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.056;
            w = (BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6;
            h = safeZoneH * 0.026;
            sizeEx = "0.017 * safeZoneH";
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','AMMUNITION']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };
        class CargoCategoryGrenades: CargoCategoryAmmunition
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_GRENADES;
            text = "GRENADES";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012 + ((BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6) * 1;
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','GRENADES']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };
        class CargoCategorySmoke: CargoCategoryAmmunition
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_SMOKE;
            text = "SMOKE";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012 + ((BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6) * 2;
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','SMOKE']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };
        class CargoCategoryMedical: CargoCategoryAmmunition
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_MEDICAL;
            text = "MEDICAL";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012 + ((BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6) * 3;
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','MEDICAL']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };
        class CargoCategoryNavigation: CargoCategoryAmmunition
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_NAVIGATION;
            text = "NAV / COMMS";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012 + ((BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6) * 4;
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','NAVIGATION']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };
        class CargoCategoryEquipment: CargoCategoryAmmunition
        {
            idc = BN_KOTH_IDC_MENU_CARGO_CATEGORY_EQUIPMENT;
            text = "EQUIPMENT";
            x = BN_KOTH_MENU_BROWSER_X + safeZoneW * 0.012 + ((BN_KOTH_MENU_BROWSER_W - safeZoneW * 0.029) / 6) * 5;
            action = "uiNamespace setVariable ['BN_KOTH_menuCargoCategory','EQUIPMENT']; uiNamespace setVariable ['BN_KOTH_menuCargoPage',0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };

        class BrowserPagePrevious: BrowserBack
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
            text = "<";
            action = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.38;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.060;
            w = safeZoneW * 0.038;
            h = safeZoneH * 0.034;
        };

        class BrowserPageNext: BrowserPagePrevious
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
            text = ">";
            action = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.58;
        };

        class BrowserPageLabel: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL;
            text = "";
            style = 2;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_W * 0.43;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.056;
            w = BN_KOTH_MENU_BROWSER_W * 0.15;
            h = safeZoneH * 0.028;
        };

        class BrowserCardBackground: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_BG;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.088;
            w = BN_KOTH_MENU_BROWSER_CARD_W;
            h = BN_KOTH_MENU_BROWSER_CARD_H;
            colorBackground[] = {0.075, 0.075, 0.065, 0.96};
        };

        class BrowserCardImageArea: BrowserCardBackground
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_IMAGE_AREA;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.098;
            w = BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            h = safeZoneH * 0.120;
            colorBackground[] = {0.025, 0.025, 0.022, 0.92};
        };

        class BrowserCardImage: BN_KOTH_RscPicture
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_IMAGE;
            style = 2096;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.098;
            w = BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            h = safeZoneH * 0.120;
        };

        class BrowserCardName: BN_KOTH_Menu_Value
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_NAME;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.226;
            w = BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            h = safeZoneH * 0.026;
        };

        class BrowserCardStatus: BN_KOTH_Menu_Label
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_STATUS;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.253;
            w = BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            h = safeZoneH * 0.020;
        };

        class BrowserCardLockOverlay: BrowserCardBackground
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_LOCK_OVERLAY;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.088;
            w = BN_KOTH_MENU_BROWSER_CARD_W;
            h = BN_KOTH_MENU_BROWSER_CARD_H;
            colorBackground[] = {0.01, 0.01, 0.01, 0.78};
        };

        class BrowserCardLockText: BN_KOTH_Menu_Title
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_LOCK_TEXT;
            text = "";
            style = 2;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.196;
            w = BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            h = safeZoneH * 0.038;
            sizeEx = "0.024 * safeZoneH";
            colorText[] = {0.94, 0.80, 0.34, 1};
        };

        class BrowserCardPrimaryAction: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_PRIMARY_ACTION;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.294;
            w = (BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 3) * 0.5;
            h = safeZoneH * 0.034;
        };

        class BrowserCardSecondaryAction: BrowserCardPrimaryAction
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_1_SECONDARY_ACTION;
            text = "";
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2 + (BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 3) * 0.5 + BN_KOTH_MENU_BROWSER_CARD_GAP;
        };

        class BrowserCard2Background: BrowserCardBackground
        {
            idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_BG;
            x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2 + BN_KOTH_MENU_BROWSER_CARD_W;
        };
        class BrowserCard2ImageArea: BrowserCardImageArea {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_IMAGE_AREA; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2Image: BrowserCardImage {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_IMAGE; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2Name: BrowserCardName {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_NAME; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2Status: BrowserCardStatus {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_STATUS; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2LockOverlay: BrowserCardLockOverlay {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_LOCK_OVERLAY; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 2 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2LockText: BrowserCardLockText {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_LOCK_TEXT; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2PrimaryAction: BrowserCardPrimaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_PRIMARY_ACTION; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W;};
        class BrowserCard2SecondaryAction: BrowserCardSecondaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_2_SECONDARY_ACTION; x = BN_KOTH_MENU_BROWSER_X + BN_KOTH_MENU_BROWSER_CARD_GAP * 3 + BN_KOTH_MENU_BROWSER_CARD_W + (BN_KOTH_MENU_BROWSER_CARD_W - BN_KOTH_MENU_BROWSER_CARD_GAP * 3) * 0.5 + BN_KOTH_MENU_BROWSER_CARD_GAP;};

        class BrowserCard3Background: BrowserCardBackground {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_BG; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.382;};
        class BrowserCard3ImageArea: BrowserCardImageArea {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_IMAGE_AREA; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.392;};
        class BrowserCard3Image: BrowserCardImage {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_IMAGE; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.392;};
        class BrowserCard3Name: BrowserCardName {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_NAME; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.520;};
        class BrowserCard3Status: BrowserCardStatus {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_STATUS; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.547;};
        class BrowserCard3LockOverlay: BrowserCardLockOverlay {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_LOCK_OVERLAY; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.382;};
        class BrowserCard3LockText: BrowserCardLockText {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_LOCK_TEXT; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.490;};
        class BrowserCard3PrimaryAction: BrowserCardPrimaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_PRIMARY_ACTION; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.588;};
        class BrowserCard3SecondaryAction: BrowserCardSecondaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_3_SECONDARY_ACTION; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.588;};

        class BrowserCard4Background: BrowserCard2Background {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_BG; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.382;};
        class BrowserCard4ImageArea: BrowserCard2ImageArea {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_IMAGE_AREA; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.392;};
        class BrowserCard4Image: BrowserCard2Image {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_IMAGE; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.392;};
        class BrowserCard4Name: BrowserCard2Name {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_NAME; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.520;};
        class BrowserCard4Status: BrowserCard2Status {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_STATUS; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.547;};
        class BrowserCard4LockOverlay: BrowserCard2LockOverlay {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_LOCK_OVERLAY; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.382;};
        class BrowserCard4LockText: BrowserCard2LockText {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_LOCK_TEXT; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.490;};
        class BrowserCard4PrimaryAction: BrowserCard2PrimaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_PRIMARY_ACTION; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.588;};
        class BrowserCard4SecondaryAction: BrowserCard2SecondaryAction {idc = BN_KOTH_IDC_MENU_BROWSER_CARD_4_SECONDARY_ACTION; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.588;};

        class NavLoadout: BN_KOTH_Menu_NavButton
        {
            idc = BN_KOTH_IDC_MENU_NAV_LOADOUT;
            text = "LOADOUT";
            x = BN_KOTH_MENU_RIGHT_X + safeZoneW * 0.010;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.012;
            w = BN_KOTH_MENU_RIGHT_W - safeZoneW * 0.020;
            h = BN_KOTH_MENU_MAIN_H * 0.178;
            action = "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
        };

        class NavStore: NavLoadout
        {
            idc = BN_KOTH_IDC_MENU_NAV_STORE;
            text = "STORE";
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H * 0.205;
            action = "['STORE'] call bn_koth_fnc_menu_refresh;";
        };

        class NavPerks: NavLoadout
        {
            idc = BN_KOTH_IDC_MENU_NAV_PERKS;
            text = "PERKS";
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H * 0.398;
            action = "['PERKS'] call bn_koth_fnc_menu_refresh;";
        };

        class NavStats: NavLoadout
        {
            idc = BN_KOTH_IDC_MENU_NAV_STATS;
            text = "STATS";
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H * 0.591;
            action = "['STATS'] call bn_koth_fnc_menu_refresh;";
        };

        class NavProgression: NavLoadout
        {
            idc = BN_KOTH_IDC_MENU_NAV_PROGRESSION;
            text = "PROGRESSION";
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H * 0.784;
            action = "['PROGRESSION'] call bn_koth_fnc_menu_refresh;";
        };

        class ExitButton: BN_KOTH_Menu_ExitButton
        {
            idc = BN_KOTH_IDC_MENU_EXIT;
            text = "EXIT BASE";
            x = BN_KOTH_MENU_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_BOTTOM_Y + safeZoneH * 0.014;
            w = safeZoneW * 0.12;
            h = BN_KOTH_MENU_BOTTOM_H - safeZoneH * 0.028;
            action = "[] call bn_koth_fnc_menu_close;";
        };

    };
};

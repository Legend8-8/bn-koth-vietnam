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

class BN_KOTH_RscMenu
{
    idd = BN_KOTH_IDD_MENU;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "private _display = _this select 0; uiNamespace setVariable ['BN_KOTH_menuDisplay', _display]; _display displayAddEventHandler ['KeyDown', 'if ((_this select 1) isEqualTo 1) exitWith {[] call bn_koth_fnc_menu_close; true}; false']; ['LOADOUT'] call bn_koth_fnc_menu_refresh;";
    onUnload = "uiNamespace setVariable ['BN_KOTH_menuDisplay', displayNull]; uiNamespace setVariable ['BN_KOTH_menuArsenalEnabled', false]; uiNamespace setVariable ['BN_KOTH_menuIntendedLoadout', []]; uiNamespace setVariable ['BN_KOTH_menuActivePage', 'LOADOUT']; uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', -1]; uiNamespace setVariable ['BN_KOTH_menuPrimaryEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingPrimary', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuHandgunEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingHandgun', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuLauncherEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingLauncher', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuUniformEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingUniform', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuVestEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingVest', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuBackpackEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingBackpack', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuHeadgearEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingHeadgear', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuFacewearEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingFacewear', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuBinocularEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingBinocular', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuAssignedEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingAssigned', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuAttachmentEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingAttachment', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuCargoEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingCargo', createHashMap];";

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
            text = "";
            x = BN_KOTH_MENU_LEFT_X + BN_KOTH_MENU_LEFT_W * 0.08;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.215;
            w = BN_KOTH_MENU_LEFT_W * 0.84;
            h = safeZoneH * 0.30;
            colorText[] = {1, 1, 1, 0.98};
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
            style = 2;
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.058;
            w = BN_KOTH_MENU_CENTER_W - safeZoneW * 0.024;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.078;
            w = BN_KOTH_MENU_CENTER_W * 0.90;
            h = safeZoneH * 0.056;
            colorBackground[] = {0.075, 0.075, 0.065, 0.94};
        };
        class LoadoutBgHandgun: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.138;};
        class LoadoutBgLauncher: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.198;};
        class LoadoutBgUniform: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.258;};
        class LoadoutBgVest: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_VEST; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.318;};
        class LoadoutBgHeadgear: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_HEADGEAR; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.378;};
        class LoadoutBgBackpack: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.438;};
        class LoadoutBgEquipment: LoadoutBgPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_BG_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.498;};

        class SlotPrimaryButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.025;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.078;
            w = BN_KOTH_MENU_CENTER_W * 0.90;
            h = safeZoneH * 0.056;
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0, 0, 0, 0};
            colorFocused[] = {0, 0, 0, 0};
            colorBackgroundDisabled[] = {0, 0, 0, 0};
            colorBorder[] = {0, 0, 0, 0};
            action = "['LOADOUT_PRIMARY'] call bn_koth_fnc_menu_refresh;";
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.138;
            action = "['LOADOUT_HANDGUN'] call bn_koth_fnc_menu_refresh;";
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.198;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.258;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.318;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.378;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.438;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.498;
            action = "['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotCargoButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_CARGO_BUTTON;
            text = "CARGO / ITEMS";
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.492;
            action = "['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotAttachmentsButton: SlotPrimaryButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_ATTACHMENTS_BUTTON;
            text = "ATTACHMENTS";
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.532;
            action = "['LOADOUT_ATTACHMENTS'] call bn_koth_fnc_menu_refresh;";
        };

        // Main LOADOUT page: contained item art and two-line row text.
        class LoadoutPicPrimary: BN_KOTH_RscPicture
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_PRIMARY;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.56;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.083;
            w = BN_KOTH_MENU_CENTER_W * 0.22;
            h = safeZoneH * 0.046;
            colorText[] = {1, 1, 1, 0.96};
            enable = 0;
        };
        class LoadoutPicHandgun: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.143;};
        class LoadoutPicLauncher: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.203;};
        class LoadoutPicUniform: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.263;};
        class LoadoutPicVest: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_VEST; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.323;};
        class LoadoutPicHeadgear: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_HEADGEAR; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.383;};
        class LoadoutPicBackpack: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.443;};
        class LoadoutPicEquipment: LoadoutPicPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_PIC_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.503;};

        class LoadoutRowTextPrimary: BN_KOTH_RscStructuredText
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_PRIMARY;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.055;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.083;
            w = BN_KOTH_MENU_CENTER_W * 0.48;
            h = safeZoneH * 0.050;
            enable = 0;
        };
        class LoadoutRowTextHandgun: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.143;};
        class LoadoutRowTextLauncher: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.203;};
        class LoadoutRowTextUniform: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.263;};
        class LoadoutRowTextVest: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_VEST; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.323;};
        class LoadoutRowTextHeadgear: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_HEADGEAR; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.383;};
        class LoadoutRowTextBackpack: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.443;};
        class LoadoutRowTextEquipment: LoadoutRowTextPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_TEXT_EQUIPMENT; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.503;};

        class LoadoutCogPrimary: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_LOADOUT_COG_PRIMARY;
            text = ">";
            x = BN_KOTH_MENU_CENTER_X + BN_KOTH_MENU_CENTER_W * 0.835;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.088;
            w = BN_KOTH_MENU_CENTER_W * 0.065;
            h = safeZoneH * 0.036;
            sizeEx = "0.022 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
            colorBackgroundActive[] = {0.20, 0.15, 0.08, 0.88};
            colorFocused[] = {0.20, 0.15, 0.08, 0.88};
            action = "uiNamespace setVariable ['BN_KOTH_menuAttachmentSlotFilter','primary']; ['LOADOUT_ATTACHMENTS'] call bn_koth_fnc_menu_refresh;";
        };
        class LoadoutCogHandgun: LoadoutCogPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_COG_HANDGUN; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.148; action = "uiNamespace setVariable ['BN_KOTH_menuAttachmentSlotFilter','handgun']; ['LOADOUT_ATTACHMENTS'] call bn_koth_fnc_menu_refresh;";};
        class LoadoutCogLauncher: LoadoutCogPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_COG_LAUNCHER; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.208; action = "uiNamespace setVariable ['BN_KOTH_menuAttachmentSlotFilter','launcher']; ['LOADOUT_ATTACHMENTS'] call bn_koth_fnc_menu_refresh;";};
        class LoadoutCogUniform: LoadoutCogPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_COG_UNIFORM; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.268; action = "uiNamespace setVariable ['BN_KOTH_menuCargoContainerFilter','uniform']; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";};
        class LoadoutCogVest: LoadoutCogPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_COG_VEST; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.328; action = "uiNamespace setVariable ['BN_KOTH_menuCargoContainerFilter','vest']; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";};
        class LoadoutCogBackpack: LoadoutCogPrimary {idc = BN_KOTH_IDC_MENU_LOADOUT_COG_BACKPACK; y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.448; action = "uiNamespace setVariable ['BN_KOTH_menuCargoContainerFilter','backpack']; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";};

        class SectionFooter: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_MENU_FOOTER_TEXT;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H - safeZoneH * 0.056;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.03;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.84, 0.82, 0.78, 0.74};
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

        class SessionSaveButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SESSION_SAVE_BUTTON;
            text = "SAVE KIT";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W - safeZoneW * 0.37;
            y = BN_KOTH_MENU_BOTTOM_Y + safeZoneH * 0.014;
            w = safeZoneW * 0.11;
            h = BN_KOTH_MENU_BOTTOM_H - safeZoneH * 0.028;
            action = "['slot1'] call bn_koth_fnc_menu_saveSessionKit;";
        };

        class SessionLoadButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SESSION_LOAD_BUTTON;
            text = "LOAD KIT";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W - safeZoneW * 0.25;
            y = BN_KOTH_MENU_BOTTOM_Y + safeZoneH * 0.014;
            w = safeZoneW * 0.11;
            h = BN_KOTH_MENU_BOTTOM_H - safeZoneH * 0.028;
            action = "['slot1'] call bn_koth_fnc_menu_loadSessionKit;";
        };

        class SessionDeleteButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SESSION_DELETE_BUTTON;
            text = "DELETE KIT";
            x = BN_KOTH_MENU_X + BN_KOTH_MENU_W - safeZoneW * 0.13;
            y = BN_KOTH_MENU_BOTTOM_Y + safeZoneH * 0.014;
            w = safeZoneW * 0.11;
            h = BN_KOTH_MENU_BOTTOM_H - safeZoneH * 0.028;
            action = "['slot1'] call bn_koth_fnc_menu_deleteSessionKit;";
        };
    };
};

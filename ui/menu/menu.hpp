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
    onUnload = "uiNamespace setVariable ['BN_KOTH_menuDisplay', displayNull]; uiNamespace setVariable ['BN_KOTH_menuActivePage', 'LOADOUT']; uiNamespace setVariable ['BN_KOTH_menuPrimaryEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingPrimary', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuHandgunEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingHandgun', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuLauncherEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingLauncher', createHashMap]; uiNamespace setVariable ['BN_KOTH_menuUniformEntries', []]; uiNamespace setVariable ['BN_KOTH_menuPendingUniform', createHashMap];";

    class controlsBackground
    {
        class BgScreen: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_SCREEN;
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0.01, 0.01, 0.01, 0.88};
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

        class BgLeft: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_LEFT;
            x = BN_KOTH_MENU_LEFT_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_LEFT_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.05, 0.05, 0.05, 0.86};
        };

        class BgCenter: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_CENTER;
            x = BN_KOTH_MENU_CENTER_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_CENTER_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.06, 0.06, 0.05, 0.88};
        };

        class BgRight: BN_KOTH_Menu_Background
        {
            idc = BN_KOTH_IDC_MENU_BG_RIGHT;
            x = BN_KOTH_MENU_RIGHT_X;
            y = BN_KOTH_MENU_MAIN_Y;
            w = BN_KOTH_MENU_RIGHT_W;
            h = BN_KOTH_MENU_MAIN_H;
            colorBackground[] = {0.05, 0.05, 0.04, 0.88};
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
            y = BN_KOTH_MENU_MAIN_Y + BN_KOTH_MENU_MAIN_H * 0.43;
            w = BN_KOTH_MENU_CENTER_W - safeZoneW * 0.024;
            h = safeZoneH * 0.06;
            sizeEx = "0.034 * safeZoneH";
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

        class SlotPrimaryButton: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
            text = "";
            x = BN_KOTH_MENU_CENTER_X + safeZoneW * 0.012;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.082;
            w = BN_KOTH_MENU_CENTER_W * 0.92;
            h = safeZoneH * 0.032;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.122;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.162;
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
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.212;
            action = "['LOADOUT_UNIFORM'] call bn_koth_fnc_menu_refresh;";
        };

        class SlotVest: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_VEST;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.254;
            text = "VEST";
        };

        class SlotHeadgear: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_HEADGEAR;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.294;
            text = "HEADGEAR";
        };

        class SlotBackpack: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_BACKPACK;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.334;
            text = "BACKPACK";
        };

        class SlotEquipment: SlotPrimary
        {
            idc = BN_KOTH_IDC_MENU_SLOT_EQUIPMENT;
            y = BN_KOTH_MENU_MAIN_Y + safeZoneH * 0.384;
            text = "EQUIPMENT";
        };

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
            onLBSelChanged = "[] call bn_koth_fnc_menu_refresh;";
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
            action = "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
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

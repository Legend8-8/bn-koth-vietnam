#include "idcs.hpp"

#define BN_KOTH_GROUP_X (safeZoneX + safeZoneW * 0.14)
#define BN_KOTH_GROUP_Y (safeZoneY + safeZoneH * 0.15)
#define BN_KOTH_GROUP_W (safeZoneW * 0.72)
#define BN_KOTH_GROUP_H (safeZoneH * 0.70)
#define BN_KOTH_GROUP_GAP (safeZoneW * 0.008)
#define BN_KOTH_GROUP_AVAILABLE_W ((BN_KOTH_GROUP_W - BN_KOTH_GROUP_GAP) * 0.40)
#define BN_KOTH_GROUP_CURRENT_X (BN_KOTH_GROUP_X + BN_KOTH_GROUP_AVAILABLE_W + BN_KOTH_GROUP_GAP)
#define BN_KOTH_GROUP_CURRENT_W (BN_KOTH_GROUP_W - BN_KOTH_GROUP_AVAILABLE_W - BN_KOTH_GROUP_GAP)
#define BN_KOTH_GROUP_MAIN_Y (BN_KOTH_GROUP_Y + safeZoneH * 0.09)
#define BN_KOTH_GROUP_MAIN_H (safeZoneH * 0.515)
#define BN_KOTH_GROUP_FOOTER_Y (BN_KOTH_GROUP_Y + BN_KOTH_GROUP_H - safeZoneH * 0.075)

class BN_KOTH_RscGroupMenu
{
    idd = BN_KOTH_IDD_GROUP_MENU;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "private _display = _this select 0; uiNamespace setVariable ['BN_KOTH_groupMenuDisplay', _display]; _display displayAddEventHandler ['KeyDown', 'if ((_this select 1) isEqualTo 1) exitWith {[] call bn_koth_fnc_groupMenu_close; true}; false']; [_display displayCtrl 9101] call bn_koth_fnc_announcements_configureControl; [] call bn_koth_fnc_groupMenu_refresh;";
    onUnload = "uiNamespace setVariable ['BN_KOTH_groupMenuDisplay', displayNull];";

    class controlsBackground
    {
        class Screen: BN_KOTH_RscText
        {
            x = safeZoneX;
            y = safeZoneY;
            w = safeZoneW;
            h = safeZoneH;
            colorBackground[] = {0.01, 0.01, 0.01, 0.88};
        };
        class Header: BN_KOTH_RscText
        {
            x = BN_KOTH_GROUP_X;
            y = BN_KOTH_GROUP_Y;
            w = BN_KOTH_GROUP_W;
            h = safeZoneH * 0.078;
            colorBackground[] = {0.08, 0.08, 0.07, 0.92};
        };
        class HeaderAccent: BN_KOTH_RscText
        {
            x = BN_KOTH_GROUP_X;
            y = BN_KOTH_GROUP_Y + safeZoneH * 0.075;
            w = BN_KOTH_GROUP_W;
            h = safeZoneH * 0.003;
            colorBackground[] = {0.76, 0.58, 0.20, 0.96};
        };
        class AvailablePanel: BN_KOTH_RscText
        {
            x = BN_KOTH_GROUP_X;
            y = BN_KOTH_GROUP_MAIN_Y;
            w = BN_KOTH_GROUP_AVAILABLE_W;
            h = BN_KOTH_GROUP_MAIN_H;
            colorBackground[] = {0.055, 0.055, 0.05, 0.94};
        };
        class AvailableInset: BN_KOTH_RscText
        {
            x = BN_KOTH_GROUP_X + safeZoneW * 0.0013;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.0013;
            w = BN_KOTH_GROUP_AVAILABLE_W - safeZoneW * 0.0026;
            h = BN_KOTH_GROUP_MAIN_H - safeZoneH * 0.0026;
            colorBackground[] = {0.025, 0.025, 0.022, 0.76};
        };
        class CurrentPanel: AvailablePanel
        {
            x = BN_KOTH_GROUP_CURRENT_X;
            w = BN_KOTH_GROUP_CURRENT_W;
            colorBackground[] = {0.085, 0.082, 0.068, 0.94};
        };
        class CurrentInset: AvailableInset
        {
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.0013;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.0026;
        };
        class Footer: BN_KOTH_RscText
        {
            x = BN_KOTH_GROUP_X;
            y = BN_KOTH_GROUP_FOOTER_Y;
            w = BN_KOTH_GROUP_W;
            h = safeZoneH * 0.075;
            colorBackground[] = {0.08, 0.08, 0.07, 0.82};
        };
    };

    class controls
    {
        class Title: BN_KOTH_Menu_Title
        {
            text = "GROUPS";
            x = BN_KOTH_GROUP_X + safeZoneW * 0.014;
            y = BN_KOTH_GROUP_Y + safeZoneH * 0.009;
            w = BN_KOTH_GROUP_W * 0.45;
            h = safeZoneH * 0.032;
            colorText[] = {0.95, 0.78, 0.28, 1};
        };
        class Status: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_GROUP_STATUS;
            text = "Syncing group state...";
            x = BN_KOTH_GROUP_X + safeZoneW * 0.014;
            y = BN_KOTH_GROUP_Y + safeZoneH * 0.043;
            w = BN_KOTH_GROUP_W - safeZoneW * 0.028;
            h = safeZoneH * 0.022;
            sizeEx = "0.018 * safeZoneH";
            colorText[] = {0.82, 0.82, 0.78, 0.82};
        };
        class AvailableTitle: BN_KOTH_Menu_Label
        {
            text = "AVAILABLE GROUPS";
            x = BN_KOTH_GROUP_X + safeZoneW * 0.012;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.014;
            w = BN_KOTH_GROUP_AVAILABLE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.026;
            sizeEx = "0.020 * safeZoneH";
            colorText[] = {0.88, 0.72, 0.30, 0.94};
        };
        class CurrentTitle: AvailableTitle
        {
            idc = BN_KOTH_IDC_GROUP_CURRENT_TITLE;
            text = "MY GROUP";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.012;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.024;
        };
        class AvailableList: BN_KOTH_Menu_List
        {
            idc = BN_KOTH_IDC_GROUP_AVAILABLE;
            x = BN_KOTH_GROUP_X + safeZoneW * 0.012;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.052;
            w = BN_KOTH_GROUP_AVAILABLE_W - safeZoneW * 0.024;
            h = safeZoneH * 0.34;
            rowHeight = "0.040 * safeZoneH";
            colorBackground[] = {0.025, 0.025, 0.022, 0.52};
            colorSelect[] = {0.98, 0.94, 0.84, 1};
            colorSelect2[] = {0.98, 0.94, 0.84, 1};
            colorTextRight[] = {0.72, 0.72, 0.68, 0.82};
            colorSelectRight[] = {0.98, 0.88, 0.58, 1};
            colorSelect2Right[] = {0.98, 0.88, 0.58, 1};
            colorSelectBackground[] = {0.19, 0.14, 0.07, 0.92};
            colorSelectBackground2[] = {0.19, 0.14, 0.07, 0.92};
            onLBSelChanged = "[true] call bn_koth_fnc_groupMenu_refresh;";
        };
        class CurrentList: AvailableList
        {
            idc = BN_KOTH_IDC_GROUP_CURRENT;
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.012;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.024;
        };
        class AvailableEmpty: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_GROUP_AVAILABLE_EMPTY;
            text = "No groups available on your team.";
            style = 2;
            x = BN_KOTH_GROUP_X + safeZoneW * 0.018;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.175;
            w = BN_KOTH_GROUP_AVAILABLE_W - safeZoneW * 0.036;
            h = safeZoneH * 0.045;
            sizeEx = "0.017 * safeZoneH";
            colorText[] = {0.72, 0.72, 0.68, 0.70};
        };
        class CurrentEmpty: AvailableEmpty
        {
            idc = BN_KOTH_IDC_GROUP_CURRENT_EMPTY;
            text = "Create a group or join an existing squad.";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.018;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.036;
        };
        class Join: BN_KOTH_Menu_ActionButton
        {
            idc = BN_KOTH_IDC_GROUP_JOIN;
            text = "JOIN";
            x = BN_KOTH_GROUP_X + safeZoneW * 0.012;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.425;
            w = safeZoneW * 0.075;
            h = safeZoneH * 0.040;
            action = "['JOIN'] call bn_koth_fnc_groupMenu_action;";
        };
        class Create: Join
        {
            idc = BN_KOTH_IDC_GROUP_CREATE;
            text = "CREATE GROUP";
            x = BN_KOTH_GROUP_X + safeZoneW * 0.095;
            w = safeZoneW * 0.115;
            action = "['CREATE'] call bn_koth_fnc_groupMenu_action;";
        };
        class Leave: Join
        {
            idc = BN_KOTH_IDC_GROUP_LEAVE;
            text = "LEAVE GROUP";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.012;
            w = safeZoneW * 0.090;
            action = "['LEAVE'] call bn_koth_fnc_groupMenu_action;";
        };
        class Kick: Leave
        {
            idc = BN_KOTH_IDC_GROUP_KICK;
            text = "KICK";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.108;
            w = safeZoneW * 0.060;
            action = "['KICK'] call bn_koth_fnc_groupMenu_action;";
        };
        class Transfer: Leave
        {
            idc = BN_KOTH_IDC_GROUP_TRANSFER;
            text = "TRANSFER LEADER";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.174;
            w = safeZoneW * 0.118;
            action = "['TRANSFER'] call bn_koth_fnc_groupMenu_action;";
        };
        class Disband: Leave
        {
            idc = BN_KOTH_IDC_GROUP_DISBAND;
            text = "DISBAND";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.298;
            w = safeZoneW * 0.078;
            colorBackground[] = {0.32, 0.08, 0.06, 0.92};
            colorBackgroundActive[] = {0.48, 0.11, 0.08, 0.98};
            colorFocused[] = {0.42, 0.10, 0.07, 0.98};
            action = "['DISBAND'] call bn_koth_fnc_groupMenu_action;";
        };
        class Invite: Leave
        {
            idc = BN_KOTH_IDC_GROUP_INVITE;
            text = "INVITE";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.012;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.472;
            w = safeZoneW * 0.070;
            h = safeZoneH * 0.034;
            action = "['OPEN_INVITE'] call bn_koth_fnc_groupMenu_action;";
        };
        class Rename: Invite
        {
            idc = BN_KOTH_IDC_GROUP_RENAME;
            text = "RENAME";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.088;
            action = "['OPEN_RENAME'] call bn_koth_fnc_groupMenu_action;";
        };
        class Lock: Invite
        {
            idc = BN_KOTH_IDC_GROUP_LOCK;
            text = "LOCK GROUP";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.164;
            w = safeZoneW * 0.100;
            action = "['TOGGLE_LOCK'] call bn_koth_fnc_groupMenu_action;";
        };
        class RenameEdit: BN_KOTH_Menu_Edit
        {
            idc = BN_KOTH_IDC_GROUP_RENAME_EDIT;
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.024;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.135;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.048;
            h = safeZoneH * 0.042;
            onKeyUp = "[true] call bn_koth_fnc_groupMenu_refresh;";
        };
        class ModalConfirm: Invite
        {
            idc = BN_KOTH_IDC_GROUP_MODAL_CONFIRM;
            text = "CONFIRM";
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.425;
            action = "['MODAL_CONFIRM'] call bn_koth_fnc_groupMenu_action;";
        };
        class ModalBack: ModalConfirm
        {
            idc = BN_KOTH_IDC_GROUP_MODAL_BACK;
            text = "BACK";
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.088;
            action = "['BACK'] call bn_koth_fnc_groupMenu_action;";
        };
        class PendingTitle: BN_KOTH_Menu_Value
        {
            idc = BN_KOTH_IDC_GROUP_PENDING_TITLE;
            text = "GROUP INVITATION";
            style = 2;
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.024;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.125;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.048;
            h = safeZoneH * 0.035;
            colorText[] = {0.95, 0.78, 0.28, 1};
        };
        class PendingDetail: BN_KOTH_Menu_Subtitle
        {
            idc = BN_KOTH_IDC_GROUP_PENDING_DETAIL;
            text = "";
            style = 2;
            x = BN_KOTH_GROUP_CURRENT_X + safeZoneW * 0.024;
            y = BN_KOTH_GROUP_MAIN_Y + safeZoneH * 0.175;
            w = BN_KOTH_GROUP_CURRENT_W - safeZoneW * 0.048;
            h = safeZoneH * 0.060;
        };
        class InviteAccept: ModalConfirm
        {
            idc = BN_KOTH_IDC_GROUP_INVITE_ACCEPT;
            text = "ACCEPT";
            action = "['ACCEPT_INVITE'] call bn_koth_fnc_groupMenu_action;";
        };
        class InviteDecline: ModalBack
        {
            idc = BN_KOTH_IDC_GROUP_INVITE_DECLINE;
            text = "DECLINE";
            action = "['DECLINE_INVITE'] call bn_koth_fnc_groupMenu_action;";
        };
        class Close: BN_KOTH_Menu_ExitButton
        {
            text = "CLOSE";
            x = BN_KOTH_GROUP_X + BN_KOTH_GROUP_W - safeZoneW * 0.112;
            y = BN_KOTH_GROUP_FOOTER_Y + safeZoneH * 0.017;
            w = safeZoneW * 0.10;
            h = safeZoneH * 0.040;
            action = "[] call bn_koth_fnc_groupMenu_close;";
        };

        class Announcement: BN_KOTH_AnnouncementNotice
        {
            x = BN_KOTH_GROUP_X + BN_KOTH_GROUP_W * 0.34;
            y = BN_KOTH_GROUP_FOOTER_Y + safeZoneH * 0.008;
            w = BN_KOTH_GROUP_W * 0.32;
            h = safeZoneH * 0.059;
        };
    };
};

/*
    File: fn_menu_refreshAssignedBrowser.sqf
    Author: Legend
    Description: Renders assigned-equipment slot and candidate stages in the
        shared card browser. It submits intent only through existing handlers.
    Execution: Client
    Parameters: 0: Menu display <DISPLAY>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {};

private _stage = uiNamespace getVariable ["BN_KOTH_menuAssignedStage",1];
private _slotIndex = uiNamespace getVariable ["BN_KOTH_menuAssignedSlot",-1];
private _intended = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout",[]];
private _settings = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = getText (_settings >> "catalogueClass"); if (_catalogueClass isEqualTo "") then {_catalogueClass="CfgBnKothArsenal"};
private _compatibility = missionConfigFile >> _catalogueClass >> "Equipment" >> "Compatibility";
private _entries = [_intended,_compatibility,_stage,_slotIndex] call bn_koth_fnc_menu_buildAssignedEntries;
private _cards = call bn_koth_fnc_menu_getItemCardControls;
private _pageSize = count _cards;
private _pageCount = (ceil ((count _entries)/_pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuBrowserPage",0];
if (uiNamespace getVariable ["BN_KOTH_menuBrowserSnapPending",false]) then {
    private _applied = _entries findIf {_x getOrDefault ["equipped",false]};
    if (_applied >= 0) then {_page=floor (_applied/_pageSize)};
    uiNamespace setVariable ["BN_KOTH_menuBrowserSnapPending",false];
};
_page=(_page max 0) min (_pageCount-1); uiNamespace setVariable ["BN_KOTH_menuBrowserPage",_page];

(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText (if (_stage isEqualTo 1) then {"ASSIGNED GEAR"} else {"CHOOSE ASSIGNED ITEM"});
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlSetText (if (_stage isEqualTo 1) then {"SELECT A SLOT TO MANAGE"} else {"SERVER-VALIDATED EQUIPMENT SELECTION"});
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2",_page+1,_pageCount];
private _back=_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
_back buttonSetAction (if (_stage isEqualTo 2) then {"uiNamespace setVariable ['BN_KOTH_menuAssignedStage',1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot',-1]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage',0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;"} else {"['LOADOUT'] call bn_koth_fnc_menu_refresh;"});
private _prev=_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS; private _next=_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
_prev ctrlEnable (_page>0); _next ctrlEnable (_page<(_pageCount-1));
_prev buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuBrowserPage',0];uiNamespace setVariable ['BN_KOTH_menuBrowserPage',(_p-1) max 0];['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuBrowserPage',0];uiNamespace setVariable ['BN_KOTH_menuBrowserPage',_p+1];['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";

{{(_display displayCtrl _x) ctrlShow false;} forEach _x;} forEach _cards;
{
    private _i=_forEachIndex+(_page*_pageSize); if (_i >= count _entries) then {continue;};
    private _entry=_entries select _i;
    _x params ["_bg","_area","_pic","_name","_status","_overlay","_lock","_primary","_secondary"];
    {(_display displayCtrl _x) ctrlShow true;} forEach [_bg,_area,_pic,_name,_status,_primary];
    (_display displayCtrl _pic) ctrlSetText (_entry getOrDefault ["picture",""]);
    (_display displayCtrl _name) ctrlSetText (_entry getOrDefault ["displayName","UNKNOWN"]);
    private _available=_entry getOrDefault ["available",true]; private _equipped=_entry getOrDefault ["equipped",false];
    (_display displayCtrl _status) ctrlSetText (if (_equipped) then {"CURRENTLY APPLIED"} else {if (_available) then {"AVAILABLE"} else {"LOCKED"}});
    (_display displayCtrl _overlay) ctrlShow (!_available); (_display displayCtrl _lock) ctrlShow (!_available);
    (_display displayCtrl _lock) ctrlSetText (if ((_entry getOrDefault ["entitlementCode",""]) isEqualTo "LOCKED_LEVEL") then {format ["LOCKED UNTIL LEVEL %1",_entry getOrDefault ["minLevel",1]]} else {"REQUIRES ENTITLEMENT"});
    private _button=_display displayCtrl _primary; (_display displayCtrl _secondary) ctrlShow false;
    if (_stage isEqualTo 1) then {
        _button ctrlSetText "OPEN"; _button ctrlEnable true;
        private _target=_entry getOrDefault ["targetPage",""];
        _button buttonSetAction (if !(_target isEqualTo "") then {format ["uiNamespace setVariable ['BN_KOTH_menuBrowserSlot','%1'];uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending',true];['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;",if (_target isEqualTo "LOADOUT_FACEWEAR") then {"facewear"} else {"binocular"}]} else {format ["uiNamespace setVariable ['BN_KOTH_menuAssignedStage',2];uiNamespace setVariable ['BN_KOTH_menuAssignedSlot',%1];uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending',true];['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;",_entry getOrDefault ["assignedIndex",-1]]});
    } else {
        _button ctrlSetText (if (_equipped) then {"APPLIED"} else {"APPLY"}); _button ctrlEnable (_available && {!_equipped});
        _button buttonSetAction (if (_available && {!_equipped}) then {format ["uiNamespace setVariable ['BN_KOTH_menuPendingAssigned',createHashMapFromArray [['available',true],['assignedIndex',%1],['itemClass','%2']]];[] call bn_koth_fnc_menu_applyAssigned;",_entry getOrDefault ["assignedIndex",-1],_entry getOrDefault ["itemClass",""]]} else {""});
    };
} forEach _cards;

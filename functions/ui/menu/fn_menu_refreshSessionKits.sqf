/*
    File: fn_menu_refreshSessionKits.sqf
    Author: Legend
    Description: Renders locally stored named kits in the fixed card workspace.
        LOAD submits untrusted intent to the server-owned validation path.
    Execution: Client
    Parameters: 0: Menu display <DISPLAY>
    Returns: None
    Public: No
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};

private _titleControl = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE;
private _subtitleControl = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE;
private _pageLabelControl = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL;
_titleControl ctrlSetText "SAVED LOADOUTS";
_subtitleControl ctrlSetText "LOCAL CLIENT KITS - SERVER VALIDATED ON LOAD";
_subtitleControl ctrlShow true;
_pageLabelControl ctrlSetText "PAGE 1 / 1";

private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
if ((count _kits) isEqualTo 0) then {
    private _oldKits = profileNamespace getVariable ["BN_KOTH_savedKits_v1", createHashMap];
    if (_oldKits isEqualType createHashMap) then {
        private _oldLoadout = _oldKits getOrDefault ["slot1", []];
        if (_oldLoadout isEqualType [] && {(count _oldLoadout) >= 10}) then {
            _kits pushBack ["kit_migrated_slot1", "MIGRATED KIT", +_oldLoadout];
            profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
            profileNamespace setVariable ["BN_KOTH_savedKits_v1", nil];
            saveProfileNamespace;
        };
    };
};
_kits = _kits select {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType []}};

private _cards = call bn_koth_fnc_menu_getItemCardControls;
private _pageSize = count _cards;
private _pageCount = (ceil ((count _kits) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuKitPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuKitPage", _page];

private _selectedId = uiNamespace getVariable ["BN_KOTH_menuKitSelectedId", ""];
private _selectedIndex = _kits findIf {(_x select 0) isEqualTo _selectedId};
private _nameControl = _display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME;
private _saveControl = _display displayCtrl BN_KOTH_IDC_MENU_KIT_SAVE;
private _renameControl = _display displayCtrl BN_KOTH_IDC_MENU_KIT_RENAME;
if (_selectedIndex >= 0) then {
    _nameControl ctrlSetText ((_kits select _selectedIndex) select 1);
    _saveControl ctrlSetText "DELETE SELECTED";
    _saveControl buttonSetAction format ["%1 call bn_koth_fnc_menu_deleteSessionKit;", str [_selectedId]];
    _renameControl ctrlEnable true;
} else {
    uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", ""];
    _selectedId = "";
    _nameControl ctrlSetText "";
    _saveControl ctrlSetText "SAVE NEW";
    _saveControl buttonSetAction "['', ''] call bn_koth_fnc_menu_saveSessionKit;";
    _renameControl ctrlEnable false;
};

_pageLabelControl ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
private _back = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
private _hasMultiplePages = _pageCount > 1;
_back buttonSetAction "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
_previous ctrlShow _hasMultiplePages;
_next ctrlShow _hasMultiplePages;
_pageLabelControl ctrlShow _hasMultiplePages;
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuKitPage',0]; uiNamespace setVariable ['BN_KOTH_menuKitPage',(_p-1) max 0]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuKitPage',0]; uiNamespace setVariable ['BN_KOTH_menuKitPage',_p+1]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;";

{
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_primary", "_secondary"];
    {(_display displayCtrl _x) ctrlShow false} forEach _x;
    (_display displayCtrl _pic) ctrlSetText "";
    (_display displayCtrl _primary) buttonSetAction "";
    (_display displayCtrl _secondary) buttonSetAction "";
} forEach _cards;

{
    private _index = _forEachIndex + (_page * _pageSize);
    if (_index >= (count _kits)) then {continue};
    private _record = _kits select _index;
    _record params ["_kitId", "_kitName", "_savedLoadout"];
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_primary", "_secondary"];
    {(_display displayCtrl _x) ctrlShow true} forEach [_bg, _area, _name, _status, _primary, _secondary];
    (_display displayCtrl _area) ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    (_display displayCtrl _name) ctrlSetText (toUpper _kitName);
    (_display displayCtrl _status) ctrlSetText (if (_kitId isEqualTo _selectedId) then {"SELECTED FOR RENAME / DELETE"} else {"STORED LOCALLY - VALIDATED WHEN LOADED"});
    (_display displayCtrl _primary) ctrlSetText "LOAD";
    (_display displayCtrl _primary) ctrlEnable true;
    (_display displayCtrl _primary) buttonSetAction format ["%1 call bn_koth_fnc_menu_loadSessionKit;", str [_kitId]];
    (_display displayCtrl _secondary) ctrlSetText (if (_kitId isEqualTo _selectedId) then {"SELECTED"} else {"MANAGE"});
    (_display displayCtrl _secondary) ctrlEnable !(_kitId isEqualTo _selectedId);
    (_display displayCtrl _secondary) buttonSetAction format ["uiNamespace setVariable ['BN_KOTH_menuKitSelectedId',%1]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;", str _kitId];
} forEach _cards;

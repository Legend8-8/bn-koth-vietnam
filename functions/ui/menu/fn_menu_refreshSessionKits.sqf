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
_subtitleControl ctrlShow false;
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
private _defaultActions = [
    BN_KOTH_IDC_MENU_BROWSER_CARD_1_DEFAULT_ACTION,
    BN_KOTH_IDC_MENU_BROWSER_CARD_2_DEFAULT_ACTION,
    BN_KOTH_IDC_MENU_BROWSER_CARD_3_DEFAULT_ACTION,
    BN_KOTH_IDC_MENU_BROWSER_CARD_4_DEFAULT_ACTION
];
private _previewBases = [
    BN_KOTH_IDC_MENU_KIT_CARD_1_PREVIEW_PRIMARY,
    BN_KOTH_IDC_MENU_KIT_CARD_2_PREVIEW_PRIMARY,
    BN_KOTH_IDC_MENU_KIT_CARD_3_PREVIEW_PRIMARY,
    BN_KOTH_IDC_MENU_KIT_CARD_4_PREVIEW_PRIMARY
];
private _resolvePicture = {
    params ["_className"];
    if !(_className isEqualType "" && {!(_className isEqualTo "")}) exitWith {""};
    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {_cfg = configFile >> "CfgVehicles" >> _className;};
    if !(isClass _cfg) exitWith {""};
    getText (_cfg >> "picture")
};
private _readLoadoutClass = {
    params ["_loadout", "_index", ["_stringSlot", false]];
    if !(_loadout isEqualType [] && {(count _loadout) > _index}) exitWith {""};
    private _slot = _loadout select _index;
    if (_stringSlot) exitWith {if (_slot isEqualType "") then {_slot} else {""}};
    if !(_slot isEqualType [] && {(count _slot) > 0} && {(_slot select 0) isEqualType ""}) exitWith {""};
    _slot select 0
};
{
    private _control = _display displayCtrl _x;
    _control ctrlShow false;
    _control ctrlEnable false;
    _control buttonSetAction "";
} forEach _defaultActions;
{
    private _previewBase = _x;
    for "_offset" from 0 to 6 do {
        private _control = _display displayCtrl (_previewBase + _offset);
        _control ctrlSetText "";
        _control ctrlShow false;
    };
} forEach _previewBases;
private _pageSize = count _cards;
private _pageCount = (ceil ((count _kits) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuKitPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuKitPage", _page];

private _preferredId = profileNamespace getVariable ["BN_KOTH_preferredSpawnKitId", ""];
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
    private _cardIndex = _forEachIndex;
    private _index = _cardIndex + (_page * _pageSize);
    if (_index >= (count _kits)) then {continue};
    private _record = _kits select _index;
    _record params ["_kitId", "_kitName", "_savedLoadout"];
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_primary", "_secondary"];
    {(_display displayCtrl _x) ctrlShow true} forEach [_bg, _area, _name, _status, _primary, _secondary];
    private _previewClasses = [
        [_savedLoadout, 0] call _readLoadoutClass,
        [_savedLoadout, 1] call _readLoadoutClass,
        [_savedLoadout, 2] call _readLoadoutClass,
        [_savedLoadout, 3] call _readLoadoutClass,
        [_savedLoadout, 4] call _readLoadoutClass,
        [_savedLoadout, 6, true] call _readLoadoutClass,
        [_savedLoadout, 5] call _readLoadoutClass
    ];
    private _previewBase = _previewBases select _cardIndex;
    for "_offset" from 0 to 6 do {
        private _control = _display displayCtrl (_previewBase + _offset);
        private _picture = [_previewClasses select _offset] call _resolvePicture;
        _control ctrlSetText _picture;
        _control ctrlShow !(_picture isEqualTo "");
    };
    (_display displayCtrl _area) ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    (_display displayCtrl _name) ctrlSetText (toUpper _kitName);
    (_display displayCtrl _status) ctrlSetText (if (_kitId isEqualTo _selectedId) then {"SELECTED - LOAD, EDIT, RENAME OR DELETE"} else {"STORED LOCALLY - VALIDATED WHEN LOADED"});
    if (_kitId isEqualTo _preferredId) then {
        (_display displayCtrl _status) ctrlSetText "DEFAULT SPAWN LOADOUT ✓";
    };
    private _defaultControl = _display displayCtrl (_defaultActions select _cardIndex);
    private _isPreferred = _kitId isEqualTo _preferredId;
    _defaultControl ctrlSetText (if (_isPreferred) then {"DEFAULT ✓"} else {"SET DEFAULT"});
    _defaultControl ctrlEnable !_isPreferred;
    _defaultControl ctrlShow true;
    _defaultControl buttonSetAction format ["%1 call bn_koth_fnc_menu_setSpawnKit;", str [_kitId, "SET"]];
    (_display displayCtrl _primary) ctrlSetText "LOAD";
    (_display displayCtrl _primary) ctrlEnable true;
    (_display displayCtrl _primary) buttonSetAction format ["%1 call bn_koth_fnc_menu_loadSessionKit;", str [_kitId, "LOAD"]];
    private _isSelected = _kitId isEqualTo _selectedId;
    (_display displayCtrl _secondary) ctrlSetText (if (_isSelected) then {"EDIT"} else {"MANAGE"});
    (_display displayCtrl _secondary) ctrlEnable true;
    private _secondaryAction = if (_isSelected) then {
        format ["%1 call bn_koth_fnc_menu_loadSessionKit;", str [_kitId, "EDIT"]]
    } else {
        format ["uiNamespace setVariable ['BN_KOTH_menuKitSelectedId',%1]; ['LOADOUT_KITS'] call bn_koth_fnc_menu_refresh;", str _kitId]
    };
    (_display displayCtrl _secondary) buttonSetAction _secondaryAction;
} forEach _cards;

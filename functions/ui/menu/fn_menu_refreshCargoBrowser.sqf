/*
    File: fn_menu_refreshCargoBrowser.sqf
    Author: Legend
    Description: Renders categorized cargo candidates as quantity cards. All
        changes are submitted through the existing authoritative cargo intent.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Intended loadout snapshot <ARRAY>
        2: Compatibility config root <CONFIG>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];
if (isNull _display) exitWith {};

private _categories = [
    ["AMMUNITION", "AMMO", BN_KOTH_IDC_MENU_CARGO_CATEGORY_AMMUNITION],
    ["GRENADES", "GRENADES", BN_KOTH_IDC_MENU_CARGO_CATEGORY_GRENADES],
    ["SMOKE", "SMOKE / FLARES", BN_KOTH_IDC_MENU_CARGO_CATEGORY_SMOKE],
    ["MEDICAL", "MEDICAL", BN_KOTH_IDC_MENU_CARGO_CATEGORY_MEDICAL],
    ["NAVIGATION", "NAV / COMMS", BN_KOTH_IDC_MENU_CARGO_CATEGORY_NAVIGATION],
    ["EQUIPMENT", "EQUIPMENT", BN_KOTH_IDC_MENU_CARGO_CATEGORY_EQUIPMENT]
];
private _category = toUpper (uiNamespace getVariable ["BN_KOTH_menuCargoCategory", "AMMUNITION"]);
if !(_category in (_categories apply {_x select 0})) then {_category = "AMMUNITION"};

private _allEntries = [_intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_buildCargoEntries;
if ((count (_allEntries select {(_x getOrDefault ["category", "EQUIPMENT"]) isEqualTo _category})) isEqualTo 0) then {
    {
        private _candidateCategory = _x select 0;
        if ((count (_allEntries select {(_x getOrDefault ["category", "EQUIPMENT"]) isEqualTo _candidateCategory})) > 0) exitWith {
            _category = _candidateCategory;
        };
    } forEach _categories;
};
uiNamespace setVariable ["BN_KOTH_menuCargoCategory", _category];
private _entries = _allEntries select {(_x getOrDefault ["category", "EQUIPMENT"]) isEqualTo _category};
private _container = toUpper (uiNamespace getVariable ["BN_KOTH_menuCargoContainerFilter", "KIT"]);

(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText format ["%1 CARGO", _container];
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlShow false;

{
    _x params ["_key", "_label", "_idc"];
    private _ctrl = _display displayCtrl _idc;
    private _active = _key isEqualTo _category;
    _ctrl ctrlEnable ((count (_allEntries select {(_x getOrDefault ["category", "EQUIPMENT"]) isEqualTo _key})) > 0);
    _ctrl ctrlSetBackgroundColor (if (_active) then {[0.20, 0.15, 0.08, 0.95]} else {[0.08, 0.08, 0.07, 0.88]});
    _ctrl ctrlSetTextColor (if (_active) then {[0.94, 0.80, 0.34, 1]} else {[0.92, 0.92, 0.88, 0.96]});
} forEach _categories;

private _returnPage = uiNamespace getVariable ["BN_KOTH_menuSelectorReturnPage", "LOADOUT"];
private _backAction = if (_returnPage isEqualTo "LOADOUT_BROWSER") then {
    "['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;"
} else {
    "['LOADOUT'] call bn_koth_fnc_menu_refresh;"
};
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK) buttonSetAction _backAction;

private _cardIdcs = call bn_koth_fnc_menu_getItemCardControls;
private _pageSize = count _cardIdcs;
private _pageCount = (ceil ((count _entries) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuCargoPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuCargoPage", _page];
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuCargoPage',0]; uiNamespace setVariable ['BN_KOTH_menuCargoPage',(_page - 1) max 0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuCargoPage',0]; uiNamespace setVariable ['BN_KOTH_menuCargoPage',_page + 1]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;";

{
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_minus", "_plus"];
    {(_display displayCtrl _x) ctrlShow false;} forEach _x;
    {
        private _ctrl = _display displayCtrl _x;
        _ctrl ctrlSetText "";
        _ctrl buttonSetAction "";
        _ctrl ctrlEnable false;
    } forEach [_pic, _name, _status, _lock, _minus, _plus];
} forEach _cardIdcs;

{
    private _entryIndex = _forEachIndex + (_page * _pageSize);
    if (_entryIndex >= (count _entries)) then {continue;};
    private _entry = _entries select _entryIndex;
    private _class = _entry getOrDefault ["className", ""];
    private _count = (_entry getOrDefault ["currentCount", 0]) max 0;
    private _entitled = _entry getOrDefault ["entitled", false];
    private _canAdd = _entry getOrDefault ["canAdd", false];
    private _code = _entry getOrDefault ["entitlementCode", "LOCKED_STATE"];
    private _lockText = switch (_code) do {
        case "LOCKED_LEVEL": {format ["LOCKED UNTIL LEVEL %1", _entry getOrDefault ["minLevel", 1]]};
        case "LOCKED_PERK": {
            private _missing = _entry getOrDefault ["missingPerks", []];
            if ((count _missing) > 0) then {format ["REQUIRES PERK: %1", toUpper (_missing joinString ", ")]} else {"REQUIRED PERK MISSING"}
        };
        default {if (_entitled) then {""} else {"ENTITLEMENT UNAVAILABLE"}};
    };

    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_minus", "_plus"];
    {(_display displayCtrl _x) ctrlShow true;} forEach [_bg, _area, _pic, _name, _status];
    (_display displayCtrl _area) ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    (_display displayCtrl _pic) ctrlSetText (_entry getOrDefault ["picture", ""]);
    (_display displayCtrl _name) ctrlSetText (_entry getOrDefault ["itemName", toUpper _class]);
    (_display displayCtrl _status) ctrlSetText format ["IN %1: x%2%3", _container, _count, if (_entitled) then {""} else {format ["  |  %1", _lockText]}];
    (_display displayCtrl _overlay) ctrlShow (!_entitled);
    (_display displayCtrl _lock) ctrlSetText _lockText;
    (_display displayCtrl _lock) ctrlShow (!_entitled);

    private _minusCtrl = _display displayCtrl _minus;
    private _plusCtrl = _display displayCtrl _plus;
    _minusCtrl ctrlSetText "−  REMOVE";
    _plusCtrl ctrlSetText "ADD  +";
    _minusCtrl ctrlShow (_count > 0);
    _minusCtrl ctrlEnable (_count > 0);
    _plusCtrl ctrlShow _canAdd;
    _plusCtrl ctrlEnable _canAdd;
    _minusCtrl buttonSetAction (if (_count > 0) then {format ["%1 call bn_koth_fnc_menu_adjustCargo;", str [toLower _container, _class, -1]]} else {""});
    _plusCtrl buttonSetAction (if (_canAdd) then {format ["%1 call bn_koth_fnc_menu_adjustCargo;", str [toLower _container, _class, 1]]} else {""});
} forEach _cardIdcs;

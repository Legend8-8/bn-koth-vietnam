/*
    File: fn_menu_refreshWearableBrowser.sqf
    Author: Legend
    Description: Renders uniform and backpack browsers from factual config entries and
        shared entitlement rules. It submits intent only and never mutates kit.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Wearable slot (uniform or backpack) <STRING>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"
params [["_display", displayNull, [displayNull]], ["_slot", "uniform", [""]]];
if (isNull _display) exitWith {};

private _cardIdcs = call bn_koth_fnc_menu_getItemCardControls;
private _slotLower = toLower _slot;
if !(_slotLower in ["uniform", "vest", "backpack", "headgear", "facewear", "binocular"]) exitWith {};
private _slotUpper = toUpper _slotLower;
private _cacheKey = format ["BN_KOTH_menuBrowserWearableCatalogue_%1", _slotLower];
private _catalogue = missionNamespace getVariable [_cacheKey, []];
if !(_catalogue isEqualType []) then {_catalogue = []};
if ((count _catalogue) isEqualTo 0) then {
    _catalogue = [_slotUpper] call bn_koth_fnc_menu_buildBrowserWearableEntries;
    missionNamespace setVariable [_cacheKey, _catalogue];
    uiNamespace setVariable ["BN_KOTH_menuBrowserPage", 0];
};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _uid = getPlayerUID player;
private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_assignments isEqualType createHashMap) then {_assignments = createHashMap};
private _assignedSide = _assignments getOrDefault [_uid, sideUnknown];
private _sideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};
private _requiresAppearance = _slotLower in ["uniform", "vest", "backpack", "headgear", "facewear"];
private _intendedLoadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
private _appliedClass = "";
private _loadoutIndex = switch (_slotLower) do {case "uniform": {3}; case "vest": {4}; case "backpack": {5}; case "headgear": {6}; case "facewear": {7}; default {8};};
if ((_intendedLoadout isEqualType []) && {(count _intendedLoadout) > _loadoutIndex}) then {
    private _wearableSlot = _intendedLoadout select _loadoutIndex;
    if (_wearableSlot isEqualType "") then {_appliedClass = toLower _wearableSlot} else {
        if ((_wearableSlot isEqualType []) && {(count _wearableSlot) > 0}) then {_appliedClass = toLower (_wearableSlot select 0)};
    };
};

private _pageSize = count _cardIdcs;
private _pageCount = (ceil ((count _catalogue) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuBrowserPage", 0];
if (uiNamespace getVariable ["BN_KOTH_menuBrowserSnapPending", false]) then {
    private _appliedIndex = _catalogue findIf {(_x getOrDefault ["itemClass", ""]) isEqualTo _appliedClass};
    if (_appliedIndex >= 0) then {_page = floor (_appliedIndex / _pageSize)};
    uiNamespace setVariable ["BN_KOTH_menuBrowserSnapPending", false];
};
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuBrowserPage", _page];

private _title = switch (_slotLower) do {case "uniform":{"UNIFORMS"};case "vest":{"VESTS"};case "backpack":{"BACKPACKS"};case "headgear":{"HEADGEAR"};case "facewear":{"FACEWEAR"};default{"BINOCULARS / RANGEFINDERS"};};
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText _title;
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlSetText format ["S.O.G. PRAIRIE FIRE %1", _title];
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK) buttonSetAction "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', (_page - 1) max 0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', _page + 1]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";

{
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_primary", "_secondary"];
    {(_display displayCtrl _x) ctrlShow false;} forEach _x;
    {
        private _ctrl = _display displayCtrl _x;
        _ctrl ctrlSetText "";
        _ctrl buttonSetAction "";
        _ctrl ctrlEnable false;
    } forEach [_pic, _name, _status, _lock, _primary, _secondary];
} forEach _cardIdcs;

{
    private _entryIndex = _forEachIndex + (_page * _pageSize);
    if (_entryIndex >= (count _catalogue)) then {continue;};
    private _entry = _catalogue select _entryIndex;
    private _metadata = _entry getOrDefault ["metadata", createHashMap];
    private _class = _entry getOrDefault ["itemClass", ""];
    private _entitlement = if (_class isEqualTo "") then {
        createHashMapFromArray [["entitled", true], ["code", "ENTITLED_CLEAR"]]
    } else {
        [_progression, _metadata, _class, _sideToken, _requiresAppearance] call bn_koth_fnc_progression_evaluateItemEntitlementRules
    };
    private _entitled = _entitlement getOrDefault ["entitled", false];
    private _code = _entitlement getOrDefault ["code", "LOCKED_STATE"];
    private _isApplied = _class isEqualTo _appliedClass;
    private _lockText = switch (_code) do {
        case "LOCKED_LEVEL": {format ["LOCKED UNTIL LEVEL %1", _metadata getOrDefault ["minLevel", 1]]};
        case "LOCKED_PERK": {
            private _missing = _entitlement getOrDefault ["missingPerks", []];
            if ((count _missing) > 0) then {format ["REQUIRES PERK: %1", toUpper (_missing joinString ", ")]} else {"REQUIRED PERK MISSING"}
        };
        case "LOCKED_SIDE": {"NOT AVAILABLE TO YOUR SIDE"};
        case "LOCKED_APPEARANCE_SIDE": {"OPPOSING FACTION APPEARANCE"};
        case "LOCKED_APPEARANCE_METADATA": {"APPEARANCE REVIEW REQUIRED"};
        case "LOCKED_SIDE_METADATA": {"SIDE POLICY REVIEW REQUIRED"};
        case "LOCKED_SIDE_STATE": {"SIDE ASSIGNMENT REQUIRED"};
        default {if (_entitled) then {""} else {"ENTITLEMENT UNAVAILABLE"}};
    };
    _x params ["_bg", "_area", "_pic", "_name", "_status", "_overlay", "_lock", "_primary", "_secondary"];
    private _visible = [_bg, _area, _pic, _name, _status];
    {(_display displayCtrl _x) ctrlShow true;} forEach _visible;
    (_display displayCtrl _area) ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    (_display displayCtrl _pic) ctrlSetText (_entry getOrDefault ["picture", ""]);
    (_display displayCtrl _name) ctrlSetText (_entry getOrDefault ["displayName", toUpper _class]);
    (_display displayCtrl _status) ctrlSetText (if (_isApplied) then {"CURRENTLY APPLIED"} else {if (_entitled) then {"AVAILABLE"} else {_lockText}});
    (_display displayCtrl _overlay) ctrlShow (!_entitled);
    (_display displayCtrl _lock) ctrlSetText _lockText;
    (_display displayCtrl _lock) ctrlShow (!_entitled);
    private _apply = _display displayCtrl _primary;
    private _configure = _display displayCtrl _secondary;
    _apply ctrlSetText (if (_isApplied) then {"APPLIED"} else {"APPLY"});
    _apply ctrlShow _entitled;
    _apply ctrlEnable (_entitled && {!_isApplied});
    _apply buttonSetAction (if (_entitled && {!_isApplied}) then {format ["%1 call bn_koth_fnc_menu_applyWearable;", str [_slot, _class]]} else {""});
    _configure ctrlSetText "CONFIGURE";
    private _canConfigure = (_slotLower in ["uniform", "vest", "backpack"]) && {_entitled} && {_isApplied} && {!(_class isEqualTo "")};
    _configure ctrlShow _canConfigure;
    _configure ctrlEnable _canConfigure;
    _configure buttonSetAction (if (_canConfigure) then {format ["uiNamespace setVariable ['BN_KOTH_menuCargoContainerFilter', '%1']; uiNamespace setVariable ['BN_KOTH_menuSelectorReturnPage', 'LOADOUT_BROWSER']; uiNamespace setVariable ['BN_KOTH_menuCargoPage', 0]; ['LOADOUT_CARGO'] call bn_koth_fnc_menu_refresh;", _slotLower]} else {""});
} forEach _cardIdcs;

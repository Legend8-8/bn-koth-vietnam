/*
    File: fn_menu_refreshPerks.sqf
    Author: Legend
    Description: Renders the fixed full-workspace perk catalogue from the
        authoritative progression presentation projection.
    Execution: Client
    Public: No
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _owned = _progression getOrDefault ["ownedPerks", []];
private _active = _progression getOrDefault ["activePerks", []];
private _catalogue = _progression getOrDefault ["perkCatalogue", []];
if !(_owned isEqualType []) then {_owned = []};
if !(_active isEqualType []) then {_active = []};
if !(_catalogue isEqualType []) then {_catalogue = []};

private _maximumActive = (_progression getOrDefault ["maxActivePerks", 0]) max 0;
(_display displayCtrl BN_KOTH_IDC_MENU_PERKS_TITLE) ctrlSetText "PERKS";
(_display displayCtrl BN_KOTH_IDC_MENU_PERKS_SUBTITLE) ctrlSetText format ["PURCHASE PERMANENT PERKS  |  CHOOSE UP TO %1 ACTIVE PERKS", _maximumActive];
(_display displayCtrl BN_KOTH_IDC_MENU_PERKS_ACTIVE) ctrlSetText format ["ACTIVE PERKS %1 / %2", count _active, _maximumActive];

private _cards = [
    [BN_KOTH_IDC_MENU_PERKS_CARD_1_BG, BN_KOTH_IDC_MENU_PERKS_CARD_1_NAME, BN_KOTH_IDC_MENU_PERKS_CARD_1_DESCRIPTION, BN_KOTH_IDC_MENU_PERKS_CARD_1_STATE, BN_KOTH_IDC_MENU_PERKS_CARD_1_PRICE, BN_KOTH_IDC_MENU_PERKS_CARD_1_ACTION],
    [BN_KOTH_IDC_MENU_PERKS_CARD_2_BG, BN_KOTH_IDC_MENU_PERKS_CARD_2_NAME, BN_KOTH_IDC_MENU_PERKS_CARD_2_DESCRIPTION, BN_KOTH_IDC_MENU_PERKS_CARD_2_STATE, BN_KOTH_IDC_MENU_PERKS_CARD_2_PRICE, BN_KOTH_IDC_MENU_PERKS_CARD_2_ACTION],
    [BN_KOTH_IDC_MENU_PERKS_CARD_3_BG, BN_KOTH_IDC_MENU_PERKS_CARD_3_NAME, BN_KOTH_IDC_MENU_PERKS_CARD_3_DESCRIPTION, BN_KOTH_IDC_MENU_PERKS_CARD_3_STATE, BN_KOTH_IDC_MENU_PERKS_CARD_3_PRICE, BN_KOTH_IDC_MENU_PERKS_CARD_3_ACTION],
    [BN_KOTH_IDC_MENU_PERKS_CARD_4_BG, BN_KOTH_IDC_MENU_PERKS_CARD_4_NAME, BN_KOTH_IDC_MENU_PERKS_CARD_4_DESCRIPTION, BN_KOTH_IDC_MENU_PERKS_CARD_4_STATE, BN_KOTH_IDC_MENU_PERKS_CARD_4_PRICE, BN_KOTH_IDC_MENU_PERKS_CARD_4_ACTION]
];

private _pageSize = count _cards;
private _pageCount = (ceil ((count _catalogue) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuPerksPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuPerksPage", _page];

private _previous = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_NEXT;
(_display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuPerksPage',0]; uiNamespace setVariable ['BN_KOTH_menuPerksPage',(_p-1) max 0]; ['PERKS'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuPerksPage',0]; uiNamespace setVariable ['BN_KOTH_menuPerksPage',_p+1]; ['PERKS'] call bn_koth_fnc_menu_refresh;";

{
    _x params ["_bgIdc", "_nameIdc", "_descriptionIdc", "_stateIdc", "_priceIdc", "_actionIdc"];
    {
        private _control = _display displayCtrl _x;
        _control ctrlShow false;
        if (_x isEqualTo _actionIdc) then {_control buttonSetAction ""; _control ctrlEnable false};
    } forEach [_bgIdc, _nameIdc, _descriptionIdc, _stateIdc, _priceIdc, _actionIdc];
} forEach _cards;

private _pageEntries = _catalogue select [_page * _pageSize, _pageSize];
{
    private _perk = _x;
    (_cards select _forEachIndex) params ["_bgIdc", "_nameIdc", "_descriptionIdc", "_stateIdc", "_priceIdc", "_actionIdc"];
    private _bg = _display displayCtrl _bgIdc;
    private _name = _display displayCtrl _nameIdc;
    private _description = _display displayCtrl _descriptionIdc;
    private _state = _display displayCtrl _stateIdc;
    private _price = _display displayCtrl _priceIdc;
    private _action = _display displayCtrl _actionIdc;
    {_x ctrlShow true} forEach [_bg, _name, _description, _state, _price, _action];

    private _perkId = toLower (_perk getOrDefault ["perkId", ""]);
    private _isOwned = _perkId in _owned;
    private _isActive = _perkId in _active;
    private _purchasable = _perk getOrDefault ["purchasable", false];
    private _purchaseCost = _perk getOrDefault ["purchaseCost", -1];
    private _cash = _progression getOrDefault ["cash", 0];

    _bg ctrlSetBackgroundColor (if (_isActive) then {[0.20, 0.15, 0.08, 0.96]} else {[0.075, 0.075, 0.065, 0.96]});
    _name ctrlSetText (toUpper (_perk getOrDefault ["displayName", _perkId]));
    _description ctrlSetStructuredText parseText format ["<t font='RobotoCondensed' size='0.92'>%1</t>", _perk getOrDefault ["description", ""]];
    _state ctrlSetText (if (_isActive) then {"ACTIVE"} else {if (_isOwned) then {"OWNED / INACTIVE"} else {if (_purchasable) then {"NOT OWNED"} else {"COMING SOON"}}});
    _price ctrlSetText (if (!_isOwned && {_purchasable} && {_purchaseCost >= 0}) then {[_purchaseCost] call bn_koth_fnc_ui_formatCash} else {""});

    if (!_isOwned && {_purchasable} && {_purchaseCost >= 0}) then {
        _action ctrlSetText format ["PURCHASE %1", [_purchaseCost] call bn_koth_fnc_ui_formatCash];
        _action ctrlEnable (_cash >= _purchaseCost);
        _action buttonSetAction format ["['PURCHASE',%1] call bn_koth_fnc_menu_requestPerk;", str _perkId];
    } else {
        if (_isActive) then {
            _action ctrlSetText "DEACTIVATE";
            _action ctrlEnable true;
            _action buttonSetAction format ["['DEACTIVATE',%1] call bn_koth_fnc_menu_requestPerk;", str _perkId];
        } else {
            if (_isOwned) then {
                _action ctrlSetText "ACTIVATE";
                _action ctrlEnable ((count _active) < _maximumActive);
                _action buttonSetAction format ["['ACTIVATE',%1] call bn_koth_fnc_menu_requestPerk;", str _perkId];
            } else {
                _action ctrlSetText "COMING SOON";
                _action ctrlEnable false;
                _action buttonSetAction "";
            };
        };
    };
} forEach _pageEntries;

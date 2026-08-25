/*
    File: fn_menu_refreshStore.sqf
    Author: Legend
    Description: Renders the global canonical weapon Store from cached
        presentation state. Transactions are submitted to the server owner.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};

private _title = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _subtitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _list = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _detail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _picture = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
private _buy = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _rent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;
private _storeBack = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
private _workspace = _display displayCtrl BN_KOTH_IDC_MENU_BG_BROWSER_WORKSPACE;

private _workspacePosition = ctrlPosition _workspace;
private _workspaceX = _workspacePosition select 0;
private _workspaceY = _workspacePosition select 1;
private _workspaceW = _workspacePosition select 2;
private _workspaceH = _workspacePosition select 3;
private _padX = safeZoneW * 0.014;
private _columnGap = safeZoneW * 0.012;
private _listW = _workspaceW * 0.43;
private _detailX = _workspaceX + _workspaceW * 0.47;
private _detailW = _workspaceX + _workspaceW - _padX - _detailX;

_title ctrlSetPosition [_workspaceX + _padX, _workspaceY + safeZoneH * 0.016, _listW, safeZoneH * 0.04];
_subtitle ctrlSetPosition [_workspaceX + _padX, _workspaceY + safeZoneH * 0.054, _listW, safeZoneH * 0.03];
_list ctrlSetPosition [_workspaceX + _padX, _workspaceY + safeZoneH * 0.092, _listW, _workspaceH - safeZoneH * 0.118];
_picture ctrlSetPosition [_detailX, _workspaceY + safeZoneH * 0.088, _detailW, safeZoneH * 0.24];
_detail ctrlSetPosition [_detailX, _workspaceY + safeZoneH * 0.342, _detailW, safeZoneH * 0.30];
_buy ctrlSetPosition [_detailX, _workspaceY + _workspaceH - safeZoneH * 0.060, (_detailW - _columnGap) * 0.5, safeZoneH * 0.040];
_rent ctrlSetPosition [_detailX + (_detailW + _columnGap) * 0.5, _workspaceY + _workspaceH - safeZoneH * 0.060, (_detailW - _columnGap) * 0.5, safeZoneH * 0.040];
{
    _x ctrlCommit 0;
} forEach [_title, _subtitle, _list, _picture, _detail, _buy, _rent];

_title ctrlSetText "STORE";
_subtitle ctrlSetText "GLOBAL CANONICAL WEAPONS";
_storeBack ctrlSetText "BACK";
_storeBack buttonSetAction "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
_buy ctrlSetText "BUY";
_rent ctrlSetText "RENT";
_buy buttonSetAction "";
_rent buttonSetAction "";
_buy ctrlSetEventHandler ["ButtonClick", ""];
_rent ctrlSetEventHandler ["ButtonClick", ""];
_buy ctrlEnable false;
_rent ctrlEnable false;
_list ctrlSetEventHandler ["LBSelChanged", ""];
private _entries = [] call bn_koth_fnc_menu_buildStoreWeaponEntries;
uiNamespace setVariable ["BN_KOTH_menuStoreEntries", _entries];

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _cash = (_progression getOrDefault ["cash", 0]) max 0;

private _selectedClass = uiNamespace getVariable ["BN_KOTH_menuStoreSelectedClass", ""];
lbClear _list;
private _selectedIndex = -1;
{
    private _entry = _x;
    private _rowState = [_entry, _cash] call bn_koth_fnc_menu_projectStoreWeaponState;
    private _row = _list lbAdd format [
        "%1  |  %2",
        _entry getOrDefault ["displayName", "UNKNOWN"],
        _rowState getOrDefault ["stateLabel", "UNAVAILABLE"]
    ];
    private _entryPicture = _entry getOrDefault ["picture", ""];
    if !(_entryPicture isEqualTo "") then {_list lbSetPicture [_row, _entryPicture]};
    _list lbSetData [_row, _entry getOrDefault ["weaponClass", ""]];
    if ((_entry getOrDefault ["weaponClass", ""]) isEqualTo _selectedClass) then {_selectedIndex = _row};
} forEach _entries;

if ((count _entries) isEqualTo 0) exitWith {
    _picture ctrlSetText "";
    _detail ctrlSetText "GLOBAL WEAPON CATALOGUE UNAVAILABLE";
    _buy ctrlShow false;
    _rent ctrlShow false;
};
if (_selectedIndex < 0) then {_selectedIndex = 0};
_list lbSetCurSel _selectedIndex;

private _selected = _entries select _selectedIndex;
private _weaponClass = _selected getOrDefault ["weaponClass", ""];
uiNamespace setVariable ["BN_KOTH_menuStoreSelectedClass", _weaponClass];
_picture ctrlSetText (_selected getOrDefault ["picture", ""]);

private _metadata = _selected getOrDefault ["metadata", createHashMap];
private _entitlement = _selected getOrDefault ["entitlement", createHashMap];
private _state = [_selected, _cash] call bn_koth_fnc_menu_projectStoreWeaponState;
private _allowedSides = _metadata getOrDefault ["allowedSides", []];
private _sideLabel = if ((count _allowedSides) > 0) then {_allowedSides joinString " / "} else {"UNCONFIGURED"};
private _purchasePrice = _state getOrDefault ["purchasePrice", -1];
private _rentalPrice = _state getOrDefault ["rentalPrice", -1];
private _purchaseText = if (_purchasePrice >= 0) then {[_purchasePrice] call bn_koth_fnc_ui_formatCash} else {"NOT CONFIGURED"};
private _rentalText = if (_rentalPrice >= 0) then {[_rentalPrice] call bn_koth_fnc_ui_formatCash} else {"NOT CONFIGURED"};
private _masteryKills = _selected getOrDefault ["masteryKills", _entitlement getOrDefault ["masteryKills", 0]];
private _masteryKillsRequired = _metadata getOrDefault ["masteryKillsRequired", 0];
private _masteryText = if (_entitlement getOrDefault ["crossSide", false]) then {
    if (_masteryKills >= _masteryKillsRequired) then {
        format ["MASTERY COMPLETE (%1 / %2)", _masteryKills, _masteryKillsRequired]
    } else {
        format ["MASTERY: %1 / %2", _masteryKills, _masteryKillsRequired]
    }
} else {
    "MASTERY: NOT REQUIRED"
};
private _missingPerks = _entitlement getOrDefault ["missingPerks", []];
private _perkText = if ((count _missingPerks) > 0) then {format ["MISSING PERKS: %1", _missingPerks joinString ", "]} else {"PERKS: READY"};

_detail ctrlSetText format [
    "%1\nTYPE: %2   KOTH AVAILABILITY: %3\nLEVEL: %4 / %5\n%6\n%7\nOWNERSHIP: %8\nBUY: %9   RENT: %10\nSTATUS: %11",
    _selected getOrDefault ["displayName", toUpper _weaponClass],
    toUpper (_selected getOrDefault ["weaponType", "weapon"]),
    _sideLabel,
    _progression getOrDefault ["level", 1],
    _metadata getOrDefault ["minLevel", 1],
    _masteryText,
    _perkText,
    if (_state getOrDefault ["owned", false]) then {"OWNED"} else {if (_state getOrDefault ["rented", false]) then {"RENTED"} else {"NONE"}},
    _purchaseText,
    _rentalText,
    _state getOrDefault ["stateLabel", "UNAVAILABLE"]
];

private _canBuy = _state getOrDefault ["canBuy", false];
private _canRent = _state getOrDefault ["canRent", false];
_buy ctrlShow (_purchasePrice >= 0 && {!(_state getOrDefault ["owned", false])});
_rent ctrlShow (_rentalPrice >= 0 && {!(_state getOrDefault ["owned", false])} && {!(_state getOrDefault ["rented", false])});
_buy ctrlEnable (_canBuy && {_state getOrDefault ["canAffordPurchase", false]});
_rent ctrlEnable (_canRent && {_state getOrDefault ["canAffordRental", false]});
_buy ctrlSetText (if (_state getOrDefault ["owned", false]) then {"OWNED"} else {format ["BUY %1", _purchaseText]});
_rent ctrlSetText (if (_state getOrDefault ["rented", false]) then {"RENTED"} else {format ["RENT %1", _rentalText]});
_buy buttonSetAction format ["['PURCHASE', %1] call bn_koth_fnc_progression_requestWeaponAcquisition;", str _weaponClass];
_rent buttonSetAction format ["['RENT', %1] call bn_koth_fnc_progression_requestWeaponAcquisition;", str _weaponClass];

_list ctrlSetEventHandler [
    "LBSelChanged",
    "params ['_control', '_index']; if (_index >= 0) then {uiNamespace setVariable ['BN_KOTH_menuStoreSelectedClass', _control lbData _index]; [] call bn_koth_fnc_menu_refresh;}"
];

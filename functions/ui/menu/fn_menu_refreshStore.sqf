/*
    File: fn_menu_refreshStore.sqf
    Author: Legend
    Description: Renders the paged Store discovery catalogue in the shared
        item-card visual language. Weapon transactions retain their existing
        server-owned path; vehicles remain presentation-only.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};

private _cards = call bn_koth_fnc_menu_getItemCardControls;
private _title = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE;
private _subtitle = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE;
private _back = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
private _pageLabel = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL;
private _preview = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
private _detail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _primaryAction = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _secondaryAction = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;

private _menuX = safeZoneX + safeZoneW * 0.02;
private _menuY = safeZoneY + safeZoneH * 0.03;
private _menuW = safeZoneW * 0.96;
private _menuH = safeZoneH * 0.94;
private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
private _mainH = _menuH * 0.78;
private _padX = safeZoneW * 0.012;
private _catalogueW = _menuW * 0.61;
private _detailX = _menuX + _menuW * 0.64;
private _detailW = _menuX + _menuW - _padX - _detailX;

_title ctrlSetPosition [_menuX + _padX, _mainY + safeZoneH * 0.016, _catalogueW, safeZoneH * 0.040];
_subtitle ctrlSetPosition [_menuX + _padX, _mainY + safeZoneH * 0.054, _catalogueW, safeZoneH * 0.026];
private _bottomY = _mainY + _mainH + safeZoneH * 0.012;
private _bottomH = _menuY + _menuH - _bottomY;
_back ctrlSetPosition [_menuX + _menuW - safeZoneW * 0.132, _bottomY + safeZoneH * 0.014, safeZoneW * 0.12, _bottomH - safeZoneH * 0.028];
_preview ctrlSetPosition [_detailX, _mainY + safeZoneH * 0.088, _detailW, safeZoneH * 0.285];
_detail ctrlSetPosition [_detailX, _mainY + safeZoneH * 0.388, _detailW, safeZoneH * 0.260];
private _actionGap = safeZoneW * 0.008;
private _actionW = (_detailW - _actionGap) * 0.5;
_primaryAction ctrlSetPosition [_detailX, _mainY + _mainH - safeZoneH * 0.060, _actionW, safeZoneH * 0.040];
_secondaryAction ctrlSetPosition [_detailX + _actionW + _actionGap, _mainY + _mainH - safeZoneH * 0.060, _actionW, safeZoneH * 0.040];
_previous ctrlSetPosition [_menuX + _catalogueW * 0.37, _mainY + _mainH - safeZoneH * 0.060, safeZoneW * 0.040, safeZoneH * 0.040];
_pageLabel ctrlSetPosition [_menuX + _catalogueW * 0.45, _mainY + _mainH - safeZoneH * 0.060, safeZoneW * 0.090, safeZoneH * 0.040];
_next ctrlSetPosition [_menuX + _catalogueW * 0.62, _mainY + _mainH - safeZoneH * 0.060, safeZoneW * 0.040, safeZoneH * 0.040];
{_x ctrlCommit 0} forEach [_title, _subtitle, _back, _preview, _detail, _primaryAction, _secondaryAction, _previous, _pageLabel, _next];
[_display, _menuX + _padX, _mainY + safeZoneH * 0.092, _catalogueW, _mainH - safeZoneH * 0.170] call bn_koth_fnc_menu_layoutItemCards;

private _route = toUpper (uiNamespace getVariable ["BN_KOTH_menuStoreRoute", "ROOT"]);
private _validRoutes = ["ROOT", "INFANTRY", "INFANTRY_PRIMARY", "INFANTRY_SIDEARMS", "INFANTRY_LAUNCHERS", "GROUND", "ROTARY", "FIXED_WING"];
if !(_route in _validRoutes) then {_route = "ROOT"};

private _uid = getPlayerUID player;
private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
private _assignedSide = if (_assignments isEqualType createHashMap) then {_assignments getOrDefault [_uid, side player]} else {side player};
private _sideToken = if (_assignedSide isEqualTo west) then {"WEST"} else {if (_assignedSide isEqualTo east) then {"EAST"} else {""}};
private _locationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
private _capabilityCacheKey = format ["%1|%2", _locationId, _sideToken];
private _capabilities = uiNamespace getVariable ["BN_KOTH_menuStoreLocationCapabilities", createHashMap];
if !((uiNamespace getVariable ["BN_KOTH_menuStoreLocationCapabilitiesKey", ""]) isEqualTo _capabilityCacheKey) then {
    private _locationData = [_locationId] call bn_koth_fnc_zone_getLocationData;
    _capabilities = [_locationData] call bn_koth_fnc_zone_getVehicleCapabilities;
    uiNamespace setVariable ["BN_KOTH_menuStoreLocationCapabilities", _capabilities];
    uiNamespace setVariable ["BN_KOTH_menuStoreLocationCapabilitiesKey", _capabilityCacheKey];
};
private _sideCapabilities = (_capabilities getOrDefault ["sides", createHashMap]) getOrDefault [_sideToken, createHashMap];
private _vehicleFamilies = _sideCapabilities getOrDefault ["families", createHashMap];
private _vehicleRouteEnabled = {
    params ["_category"];
    ((_vehicleFamilies getOrDefault [_category, createHashMap]) getOrDefault ["paid", false])
};

if (_route in ["GROUND", "ROTARY", "FIXED_WING"] && {!([_route] call _vehicleRouteEnabled)}) then {
    _route = "ROOT";
    uiNamespace setVariable ["BN_KOTH_menuStoreSelectedKey", ""];
    uiNamespace setVariable ["BN_KOTH_menuStorePage", 0];
    uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""];
};
uiNamespace setVariable ["BN_KOTH_menuStoreRoute", _route];

private _makeCategory = {
    params ["_routeId", "_displayName", "_description", ["_enabled", true, [true]]];
    createHashMapFromArray [
        ["kind", "CATEGORY"], ["key", format ["C|%1", _routeId]], ["route", _routeId],
        ["displayName", _displayName], ["description", _description], ["picture", ""], ["enabled", _enabled]
    ]
};

private _entryKind = "CATEGORY";
private _breadcrumb = "STORE";
private _routeSubtitle = "SELECT A CATEGORY";
private _entries = [];
private _cachedRoute = uiNamespace getVariable ["BN_KOTH_menuStoreEntriesRoute", ""];
private _cachedEntries = uiNamespace getVariable ["BN_KOTH_menuStoreEntries", []];
if !(_cachedEntries isEqualType []) then {_cachedEntries = []};

switch (_route) do {
    case "ROOT": {
        _entries = [
            ["INFANTRY", "INFANTRY", "Canonical infantry weapons grouped by operational role."] call _makeCategory,
            ["GROUND", "GROUND VEHICLES", if (["GROUND"] call _vehicleRouteEnabled) then {"Curated ground combat and transport progression products."} else {"DISABLED FOR THIS AO"}, ["GROUND"] call _vehicleRouteEnabled] call _makeCategory,
            ["ROTARY", "ROTARY WING", if (["ROTARY"] call _vehicleRouteEnabled) then {"Curated S.O.G. helicopter progression products."} else {"DISABLED FOR THIS AO"}, ["ROTARY"] call _vehicleRouteEnabled] call _makeCategory,
            ["FIXED_WING", "FIXED WING", if (["FIXED_WING"] call _vehicleRouteEnabled) then {"Curated S.O.G. aircraft progression products."} else {"DISABLED FOR THIS AO"}, ["FIXED_WING"] call _vehicleRouteEnabled] call _makeCategory
        ];
    };
    case "INFANTRY": {
        _breadcrumb = "STORE > INFANTRY";
        _entries = [
            ["INFANTRY_PRIMARY", "PRIMARY", "Rifles, SMGs, shotguns, marksman and support weapons."] call _makeCategory,
            ["INFANTRY_SIDEARMS", "SIDEARMS", "Canonical infantry handguns."] call _makeCategory,
            ["INFANTRY_LAUNCHERS", "LAUNCHERS", "Canonical shoulder-fired launcher weapons."] call _makeCategory
        ];
    };
    case "INFANTRY_PRIMARY";
    case "INFANTRY_SIDEARMS";
    case "INFANTRY_LAUNCHERS": {
        _entryKind = "WEAPON";
        private _category = _route select [9];
        _breadcrumb = format ["STORE > INFANTRY > %1", _category];
        _routeSubtitle = "DISCOVER, PURCHASE OR RENT CANONICAL WEAPONS";
        _entries = if (_cachedRoute isEqualTo _route) then {_cachedEntries} else {
            ([] call bn_koth_fnc_menu_buildStoreWeaponEntries) select {(_x getOrDefault ["storeCategory", ""]) isEqualTo _category}
        };
    };
    default {
        _entryKind = "VEHICLE";
        private _label = switch (_route) do {case "GROUND": {"GROUND VEHICLES"}; case "ROTARY": {"ROTARY WING"}; default {"FIXED WING"}};
        _breadcrumb = format ["STORE > %1", _label];
        _routeSubtitle = "CURATED VEHICLE PROGRESSION CATALOGUE";
        _entries = if (_cachedRoute isEqualTo _route) then {_cachedEntries} else {
            ([] call bn_koth_fnc_menu_buildStoreVehicleEntries) select {(_x getOrDefault ["storeCategory", ""]) isEqualTo _route}
        };
    };
};

uiNamespace setVariable ["BN_KOTH_menuStoreEntries", _entries];
uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", _route];
_title ctrlSetText _breadcrumb;
_subtitle ctrlSetText _routeSubtitle;

private _backRoute = switch (_route) do {
    case "ROOT": {"LOADOUT"};
    case "INFANTRY": {"ROOT"};
    case "INFANTRY_PRIMARY";
    case "INFANTRY_SIDEARMS";
    case "INFANTRY_LAUNCHERS": {"INFANTRY"};
    default {"ROOT"};
};
if (_backRoute isEqualTo "LOADOUT") then {
    _back buttonSetAction "uiNamespace setVariable ['BN_KOTH_menuStoreRoute','ROOT']; uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey','']; ['LOADOUT'] call bn_koth_fnc_menu_refresh;";
} else {
    _back buttonSetAction format ["uiNamespace setVariable ['BN_KOTH_menuStoreRoute',%1]; uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey','']; uiNamespace setVariable ['BN_KOTH_menuStorePage',0]; [] call bn_koth_fnc_menu_refresh;", str _backRoute];
};

private _pageSize = count _cards;
private _pageCount = (ceil ((count _entries) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuStorePage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuStorePage", _page];
_pageLabel ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuStorePage',0]; uiNamespace setVariable ['BN_KOTH_menuStorePage',(_p-1) max 0]; uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey','']; [] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuStorePage',0]; uiNamespace setVariable ['BN_KOTH_menuStorePage',_p+1]; uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey','']; [] call bn_koth_fnc_menu_refresh;";

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _cash = (_progression getOrDefault ["cash", 0]) max 0;
private _selectedKey = uiNamespace getVariable ["BN_KOTH_menuStoreSelectedKey", ""];
private _pageStart = _page * _pageSize;
private _pageEntries = _entries select [_pageStart, _pageSize];
private _selectedOnPage = _pageEntries findIf {
    private _entry = _x;
    private _key = switch (_entryKind) do {
        case "CATEGORY": {_entry getOrDefault ["key", ""]};
        case "WEAPON": {format ["W|%1", _entry getOrDefault ["weaponClass", ""]]};
        default {format ["V|%1", _entry getOrDefault ["vehicleClass", ""]]};
    };
    _key isEqualTo _selectedKey
};
if (_selectedOnPage < 0 && {(count _pageEntries) > 0}) then {
    private _first = _pageEntries select 0;
    _selectedKey = switch (_entryKind) do {
        case "CATEGORY": {_first getOrDefault ["key", ""]};
        case "WEAPON": {format ["W|%1", _first getOrDefault ["weaponClass", ""]]};
        default {format ["V|%1", _first getOrDefault ["vehicleClass", ""]]};
    };
    _selectedOnPage = 0;
    uiNamespace setVariable ["BN_KOTH_menuStoreSelectedKey", _selectedKey];
};

{
    private _controlIdcs = _x;
    _controlIdcs params ["_bgIdc", "_imageAreaIdc", "_imageIdc", "_nameIdc", "_statusIdc", "_overlayIdc", "_lockIdc", "_primaryIdc", "_secondaryIdc"];
    {
        private _ctrl = _display displayCtrl _x;
        _ctrl ctrlShow false;
        if (_x in [_primaryIdc, _secondaryIdc]) then {_ctrl buttonSetAction ""; _ctrl ctrlEnable false};
    } forEach _controlIdcs;
} forEach _cards;

{
    private _entry = _x;
    private _controls = _cards select _forEachIndex;
    _controls params ["_bgIdc", "_imageAreaIdc", "_imageIdc", "_nameIdc", "_statusIdc", "_overlayIdc", "_lockIdc", "_primaryIdc", "_secondaryIdc"];
    private _key = switch (_entryKind) do {
        case "CATEGORY": {_entry getOrDefault ["key", ""]};
        case "WEAPON": {format ["W|%1", _entry getOrDefault ["weaponClass", ""]]};
        default {format ["V|%1", _entry getOrDefault ["vehicleClass", ""]]};
    };
    private _state = switch (_entryKind) do {
        case "CATEGORY": {createHashMapFromArray [
            ["stateLabel", _entry getOrDefault ["description", "OPEN CATEGORY"]],
            ["blocking", !(_entry getOrDefault ["enabled", true])]
        ]};
        case "WEAPON": {[_entry, _cash] call bn_koth_fnc_menu_projectStoreWeaponState};
        default {[_entry] call bn_koth_fnc_menu_projectStoreVehicleState};
    };
    private _bg = _display displayCtrl _bgIdc;
    private _imageArea = _display displayCtrl _imageAreaIdc;
    private _image = _display displayCtrl _imageIdc;
    private _name = _display displayCtrl _nameIdc;
    private _status = _display displayCtrl _statusIdc;
    private _overlay = _display displayCtrl _overlayIdc;
    private _lock = _display displayCtrl _lockIdc;
    private _select = _display displayCtrl _primaryIdc;
    private _unused = _display displayCtrl _secondaryIdc;
    {_x ctrlShow true} forEach [_bg, _imageArea, _image, _name, _status, _select];
    private _selectedColor = if (_key isEqualTo _selectedKey) then {[0.20,0.15,0.08,0.96]} else {[0.08,0.08,0.07,0.92]};
    _bg ctrlSetBackgroundColor _selectedColor;
    _imageArea ctrlSetBackgroundColor [0.025,0.025,0.022,0.92];
    _image ctrlSetText (_entry getOrDefault ["picture", ""]);
    _name ctrlSetText (_entry getOrDefault ["displayName", "UNKNOWN"]);
    _status ctrlSetText (_state getOrDefault ["stateLabel", "UNAVAILABLE"]);
    private _blocking = _state getOrDefault ["blocking", false];
    private _statusColor = if (_blocking) then {[0.94, 0.80, 0.34, 1]} else {[0.84, 0.82, 0.78, 0.92]};
    private _statusFontHeight = (if (_blocking) then {0.020} else {0.017}) * safeZoneH;
    _status ctrlSetTextColor _statusColor;
    _status ctrlSetFontHeight _statusFontHeight;
    _overlay ctrlShow false;
    _lock ctrlShow false;
    _unused ctrlShow false;
    if (_entryKind isEqualTo "CATEGORY") then {
        private _nextRoute = _entry getOrDefault ["route", "ROOT"];
        private _enabled = _entry getOrDefault ["enabled", true];
        _select ctrlSetText (if (_enabled) then {"OPEN"} else {"DISABLED"});
        _select ctrlEnable _enabled;
        _select buttonSetAction (if (_enabled) then {
            format ["uiNamespace setVariable ['BN_KOTH_menuStoreRoute',%1]; uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey','']; uiNamespace setVariable ['BN_KOTH_menuStorePage',0]; [] call bn_koth_fnc_menu_refresh;", str _nextRoute]
        } else {""});
    } else {
        private _selectText = if (_key isEqualTo _selectedKey) then {"SELECTED"} else {"SELECT"};
        _select ctrlSetText _selectText;
        _select ctrlEnable !(_key isEqualTo _selectedKey);
        _select buttonSetAction format ["uiNamespace setVariable ['BN_KOTH_menuStoreSelectedKey',%1]; [] call bn_koth_fnc_menu_refresh;", str _key];
    };
} forEach _pageEntries;

_primaryAction ctrlShow false;
_secondaryAction ctrlShow false;
_primaryAction buttonSetAction "";
_secondaryAction buttonSetAction "";
_preview ctrlSetText "";

if ((count _pageEntries) isEqualTo 0) exitWith {
    _detail ctrlSetText "NO PRODUCTS ARE CONFIGURED FOR THIS CATEGORY";
};

private _selected = _pageEntries select _selectedOnPage;
_preview ctrlSetText (_selected getOrDefault ["picture", ""]);
switch (_entryKind) do {
    case "CATEGORY": {
        _detail ctrlSetText ([_selected getOrDefault ["displayName", "CATEGORY"], "", _selected getOrDefault ["description", ""]] joinString endl);
    };
    case "WEAPON": {
        private _weaponClass = _selected getOrDefault ["weaponClass", ""];
        private _metadata = _selected getOrDefault ["metadata", createHashMap];
        private _entitlement = _selected getOrDefault ["entitlement", createHashMap];
        private _state = [_selected, _cash] call bn_koth_fnc_menu_projectStoreWeaponState;
        private _purchasePrice = _state getOrDefault ["purchasePrice", -1];
        private _rentalPrice = _state getOrDefault ["rentalPrice", -1];
        private _purchaseText = if (_purchasePrice >= 0) then {[_purchasePrice] call bn_koth_fnc_ui_formatCash} else {"NOT CONFIGURED"};
        private _rentalText = if (_rentalPrice >= 0) then {[_rentalPrice] call bn_koth_fnc_ui_formatCash} else {"NOT CONFIGURED"};
        private _missingPerks = _entitlement getOrDefault ["missingPerks", []];
        private _crossSide = _state getOrDefault ["crossSide", false];
        private _crossSideAllowed = _state getOrDefault ["crossSideAllowed", false];
        private _sideText = if (!_crossSide) then {
            "NATIVE FACTION"
        } else {
            if (_crossSideAllowed) then {"CROSS-FACTION MASTERY"} else {"FACTION RESTRICTED"}
        };
        private _masteryText = if (_crossSide && {_crossSideAllowed}) then {
            format ["%1 / %2 KILLS", _state getOrDefault ["masteryKills", 0], _state getOrDefault ["masteryRequired", 0]]
        } else {
            if (_crossSide) then {"N/A - FACTION RESTRICTED"} else {"N/A - NATIVE FACTION"}
        };
        private _ownershipText = if (_state getOrDefault ["owned", false]) then {"OWNED"} else {if (_state getOrDefault ["rented", false]) then {"RENTED"} else {"NOT ACQUIRED"}};
        private _detailLines = [
            _selected getOrDefault ["displayName", toUpper _weaponClass],
            "",
            format ["TYPE / CATEGORY: %1 / %2", toUpper (_selected getOrDefault ["weaponType", "weapon"]), _selected getOrDefault ["storeCategory", "INFANTRY"]],
            format ["LEVEL: %1 / %2", _progression getOrDefault ["level", 1], _metadata getOrDefault ["minLevel", 1]],
            format ["MASTERY: %1", _masteryText],
            format ["SIDE: %1", _sideText]
        ];
        _detailLines append [
            "",
            "ACQUISITION",
            format ["PURCHASE %1", _purchaseText],
            format ["RENTAL %1", _rentalText],
            format ["OWNERSHIP %1", _ownershipText],
            "",
            format ["PERKS: %1", if ((count _missingPerks) > 0) then {_missingPerks joinString ", "} else {"READY"}],
            "",
            "STATUS",
            _state getOrDefault ["stateLabel", "UNAVAILABLE"]
        ];
        _detail ctrlSetText (_detailLines joinString endl);
        private _owned = _state getOrDefault ["owned",false];
        private _rented = _state getOrDefault ["rented",false];
        private _canEquipInArsenal = (_owned || {_rented}) && {_entitlement getOrDefault ["entitled", false]};
        if (_canEquipInArsenal) then {
            private _slot = _selected getOrDefault ["arsenalSlot", "primary"];
            _primaryAction ctrlShow true;
            _primaryAction ctrlEnable true;
            _primaryAction ctrlSetText "EQUIP IN ARSENAL";
            _primaryAction buttonSetAction format ["uiNamespace setVariable ['BN_KOTH_menuBrowserSlot',%1]; uiNamespace setVariable ['BN_KOTH_menuBrowserTargetClass',%2]; uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending',true]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage',0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;", str _slot, str _weaponClass];
        } else {
            _primaryAction ctrlShow ((_purchasePrice >= 0) && {!_owned});
            _secondaryAction ctrlShow ((_rentalPrice >= 0) && {!_owned} && {!_rented});
            _primaryAction ctrlEnable ((_state getOrDefault ["canBuy",false]) && {_state getOrDefault ["canAffordPurchase",false]});
            _secondaryAction ctrlEnable ((_state getOrDefault ["canRent",false]) && {_state getOrDefault ["canAffordRental",false]});
            _primaryAction ctrlSetText format ["BUY %1",_purchaseText];
            _secondaryAction ctrlSetText format ["RENT %1",_rentalText];
            _primaryAction buttonSetAction format ["['PURCHASE',%1] call bn_koth_fnc_progression_requestWeaponAcquisition;",str _weaponClass];
            _secondaryAction buttonSetAction format ["['RENT',%1] call bn_koth_fnc_progression_requestWeaponAcquisition;",str _weaponClass];
        };
    };
    default {
        private _vehicleClass = _selected getOrDefault ["vehicleClass",""];
        private _metadata = _selected getOrDefault ["metadata",createHashMap];
        private _state = [_selected] call bn_koth_fnc_menu_projectStoreVehicleState;
        private _allowedSides = _metadata getOrDefault ["allowedSides",[]];
        private _rentalPrice = _state getOrDefault ["rentalPrice",-1];
        private _rentalText=if (_rentalPrice>=0) then {[_rentalPrice] call bn_koth_fnc_ui_formatCash} else {"NOT CONFIGURED"};
        _detail ctrlSetText ([
            _selected getOrDefault ["displayName","VEHICLE"],"",
            format ["CATEGORY: %1",_metadata getOrDefault ["storeCategory",""]],
            format ["ROLE: %1",_metadata getOrDefault ["vehicleRole",""]],
            format ["KOTH AVAILABILITY: %1",if ((count _allowedSides)>0) then {_allowedSides joinString " / "} else {"UNCONFIGURED"}],
            format ["LEVEL: %1 / %2",_progression getOrDefault ["level",1],_metadata getOrDefault ["minLevel",1]],"",
            "RENTAL",_rentalText,"","ACCESS","ONE VEHICLE LIFE","","STATUS",_state getOrDefault ["stateLabel","UNAVAILABLE"]
        ] joinString endl);
        if (_state getOrDefault ["canRent",false]) then {
            _primaryAction ctrlShow true;_primaryAction ctrlEnable (_cash>=_rentalPrice);_primaryAction ctrlSetText format ["RENT %1",_rentalText];
            _primaryAction buttonSetAction format ["['RENT',%1,''] call bn_koth_fnc_vehicles_requestRental;",str _vehicleClass];
        } else {
            if (_state getOrDefault ["active",false]) then {_primaryAction ctrlShow true;_primaryAction ctrlEnable false;_primaryAction ctrlSetText "VEHICLE ACTIVE"};
        };
    };
};

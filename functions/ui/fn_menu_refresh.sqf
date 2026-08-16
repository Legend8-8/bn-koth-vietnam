/*
    File: fn_menu_refresh.sqf
    Author: Legend
    Description: Refreshes deployed menu content and current page styling.
    Execution: Client
    Parameters:
        0: Optional page id <STRING>
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\menu\idcs.hpp"

params [
    ["_requestedPage", "", [""]]
];

if (!hasInterface) exitWith {};

disableSerialization;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};
if (isNull _display) exitWith {};

private _validPages = [
    "LOADOUT",
    "LOADOUT_PRIMARY",
    "LOADOUT_HANDGUN",
    "LOADOUT_LAUNCHER",
    "LOADOUT_UNIFORM",
    "LOADOUT_VEST",
    "LOADOUT_BACKPACK",
    "LOADOUT_HEADGEAR",
    "LOADOUT_FACEWEAR",
    "LOADOUT_BINOCULAR",
    "LOADOUT_EQUIPMENT",
    "LOADOUT_ATTACHMENTS",
    "LOADOUT_CARGO",
    "STORE",
    "PERKS",
    "STATS",
    "PROGRESSION"
];
private _activePage = uiNamespace getVariable ["BN_KOTH_menuActivePage", "LOADOUT"];

if !(_requestedPage isEqualTo "") then {
    private _candidate = toUpper _requestedPage;
    if (_candidate in _validPages) then {
        _activePage = _candidate;
        uiNamespace setVariable ["BN_KOTH_menuActivePage", _activePage];
    };
};

private _ctrlServer = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_SERVER;
private _ctrlOperatorName = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_NAME;
private _ctrlOperatorTeam = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_TEAM;
private _ctrlOperatorRole = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_ROLE_VALUE;
private _ctrlSectionTitle = _display displayCtrl BN_KOTH_IDC_MENU_SECTION_TITLE;
private _ctrlNotice = _display displayCtrl BN_KOTH_IDC_MENU_NOTICE;
private _ctrlFooter = _display displayCtrl BN_KOTH_IDC_MENU_FOOTER_TEXT;

private _ctrlPrimary = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_PRIMARY;
private _ctrlHandgun = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HANDGUN;
private _ctrlLauncher = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_LAUNCHER;
private _ctrlUniform = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_UNIFORM;
private _ctrlVest = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_VEST;
private _ctrlHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HEADGEAR;
private _ctrlBackpack = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BACKPACK;
private _ctrlFacewear = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_FACEWEAR;
private _ctrlBinocular = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BINOCULAR;
private _ctrlEquipment = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_EQUIPMENT;

private _ctrlPrimaryButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
private _ctrlHandgunButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HANDGUN_BUTTON;
private _ctrlLauncherButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_LAUNCHER_BUTTON;
private _ctrlUniformButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_UNIFORM_BUTTON;
private _ctrlVestButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_VEST_BUTTON;
private _ctrlBackpackButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BACKPACK_BUTTON;
private _ctrlHeadgearButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HEADGEAR_BUTTON;
private _ctrlFacewearButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_FACEWEAR_BUTTON;
private _ctrlBinocularButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_BINOCULAR_BUTTON;
private _ctrlEquipmentButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_EQUIPMENT_BUTTON;
private _ctrlCargoButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_CARGO_BUTTON;
private _ctrlAttachmentsButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_ATTACHMENTS_BUTTON;

private _ctrlNavLoadout = _display displayCtrl BN_KOTH_IDC_MENU_NAV_LOADOUT;
private _ctrlNavStore = _display displayCtrl BN_KOTH_IDC_MENU_NAV_STORE;
private _ctrlNavPerks = _display displayCtrl BN_KOTH_IDC_MENU_NAV_PERKS;
private _ctrlNavStats = _display displayCtrl BN_KOTH_IDC_MENU_NAV_STATS;
private _ctrlNavProgression = _display displayCtrl BN_KOTH_IDC_MENU_NAV_PROGRESSION;

private _ctrlPrimaryTitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _ctrlPrimaryCurrent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _ctrlPrimaryList = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _ctrlPrimaryDetail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _ctrlPrimaryBack = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _ctrlPrimaryApply = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;

private _resolveItemName = {
    params ["_className"];

    if (_className isEqualTo "") exitWith {"NONE"};

    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };

    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {toUpper _className} else {_displayName}
};

private _setLine = {
    params ["_ctrl", "_label", "_value"];
    _ctrl ctrlSetText format ["%1: %2", _label, _value];
};

private _setNavState = {
    params ["_ctrl", "_isActive"];
    if (_isActive) then {
        _ctrl ctrlSetBackgroundColor [0.20, 0.15, 0.08, 0.95];
        _ctrl ctrlSetTextColor [0.94, 0.80, 0.34, 1];
    } else {
        _ctrl ctrlSetBackgroundColor [0.08, 0.08, 0.07, 0.88];
        _ctrl ctrlSetTextColor [0.92, 0.92, 0.88, 0.96];
    };
};

private _serverName = serverName;
if (_serverName isEqualTo "") then {
    _serverName = "LOCAL SESSION";
};
_ctrlServer ctrlSetText format ["SERVER  %1", _serverName];

private _playerName = if (!isNull player) then {name player} else {profileName};
_ctrlOperatorName ctrlSetText toUpper _playerName;

private _sideLabel = "UNASSIGNED";
if (!isNull player) then {
    _sideLabel = switch (side group player) do {
        case west: {"SOG RECON TEAM"};
        case east: {"NVA TEAM"};
        case independent: {"INDEPENDENT"};
        case civilian: {"CIVILIAN"};
        default {"UNASSIGNED"};
    };
};
_ctrlOperatorTeam ctrlSetText _sideLabel;

private _roleText = "N/A";
if (!isNull player) then {
    private _unitClass = typeOf player;
    private _unitCfg = configFile >> "CfgVehicles" >> _unitClass;
    _roleText = if (isClass _unitCfg) then {
        private _displayName = getText (_unitCfg >> "displayName");
        if (_displayName isEqualTo "") then {_unitClass} else {_displayName}
    } else {
        _unitClass
    };
};
_ctrlOperatorRole ctrlSetText _roleText;

private _loadoutPages = [
    "LOADOUT",
    "LOADOUT_PRIMARY",
    "LOADOUT_HANDGUN",
    "LOADOUT_LAUNCHER",
    "LOADOUT_UNIFORM",
    "LOADOUT_VEST",
    "LOADOUT_BACKPACK",
    "LOADOUT_HEADGEAR",
    "LOADOUT_FACEWEAR",
    "LOADOUT_BINOCULAR",
    "LOADOUT_EQUIPMENT",
    "LOADOUT_ATTACHMENTS",
    "LOADOUT_CARGO"
];

[_ctrlNavLoadout, _activePage in _loadoutPages] call _setNavState;
[_ctrlNavStore, _activePage isEqualTo "STORE"] call _setNavState;
[_ctrlNavPerks, _activePage isEqualTo "PERKS"] call _setNavState;
[_ctrlNavStats, _activePage isEqualTo "STATS"] call _setNavState;
[_ctrlNavProgression, _activePage isEqualTo "PROGRESSION"] call _setNavState;

private _mainViewControls = [
    _ctrlPrimary,
    _ctrlHandgun,
    _ctrlLauncher,
    _ctrlUniform,
    _ctrlVest,
    _ctrlHeadgear,
    _ctrlBackpack,
    _ctrlFacewear,
    _ctrlBinocular,
    _ctrlEquipment,
    _ctrlPrimaryButton,
    _ctrlHandgunButton,
    _ctrlLauncherButton,
    _ctrlUniformButton,
    _ctrlVestButton,
    _ctrlBackpackButton,
    _ctrlHeadgearButton,
    _ctrlFacewearButton,
    _ctrlBinocularButton,
    _ctrlEquipmentButton,
    _ctrlCargoButton,
    _ctrlAttachmentsButton,
    _ctrlSectionTitle,
    _ctrlNotice,
    _ctrlFooter
];

private _selectorViewControls = [
    _ctrlPrimaryTitle,
    _ctrlPrimaryCurrent,
    _ctrlPrimaryList,
    _ctrlPrimaryDetail,
    _ctrlPrimaryBack,
    _ctrlPrimaryApply
];

private _showMainView = {
    { _x ctrlShow true; } forEach _mainViewControls;
    { _x ctrlShow false; } forEach _selectorViewControls;
};

private _showSelectorView = {
    { _x ctrlShow false; } forEach _mainViewControls;
    { _x ctrlShow true; } forEach _selectorViewControls;
};

private _showComingSoon = {
    params ["_pageName"];
    call _showMainView;

    _ctrlSectionTitle ctrlSetText _pageName;
    _ctrlNotice ctrlSetText "FEATURE COMING SOON";
    _ctrlFooter ctrlSetText "This section is planned but not implemented in this slice.";

    {
        (_x select 0) ctrlSetText format ["%1: --", _x select 1];
    } forEach [
        [_ctrlPrimary, "PRIMARY"],
        [_ctrlHandgun, "HANDGUN"],
        [_ctrlLauncher, "LAUNCHER"],
        [_ctrlUniform, "UNIFORM"],
        [_ctrlVest, "VEST"],
        [_ctrlHeadgear, "HEADGEAR"],
        [_ctrlBackpack, "BACKPACK"],
        [_ctrlFacewear, "FACEWEAR"],
        [_ctrlBinocular, "BINOCULAR"],
        [_ctrlEquipment, "EQUIPMENT"]
    ];

    {
        _x ctrlSetText "";
        _x ctrlEnable false;
    } forEach [
        _ctrlPrimaryButton,
        _ctrlHandgunButton,
        _ctrlLauncherButton,
        _ctrlUniformButton,
        _ctrlVestButton,
        _ctrlBackpackButton,
        _ctrlHeadgearButton,
        _ctrlFacewearButton,
        _ctrlBinocularButton,
        _ctrlEquipmentButton,
        _ctrlCargoButton,
        _ctrlAttachmentsButton
    ];
};

if !(_activePage in _loadoutPages) exitWith {
    [_activePage] call _showComingSoon;
};

private _intendedLoadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if !((_intendedLoadout isEqualType []) && {(count _intendedLoadout) >= 10}) then {
    if (!isNull player) then {
        _intendedLoadout = getUnitLoadout player;
    };
};
if !((_intendedLoadout isEqualType []) && {(count _intendedLoadout) >= 10}) then {
    _intendedLoadout = [];
};

private _readWeaponNameFromLoadoutSlot = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !((_slot isEqualType []) && {(count _slot) >= 1}) exitWith {"NONE"};
    [toLower (_slot select 0)] call _resolveItemName
};

private _readContainerNameFromLoadoutSlot = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !((_slot isEqualType []) && {(count _slot) >= 1}) exitWith {"NONE"};
    [toLower (_slot select 0)] call _resolveItemName
};

private _readStringSlotName = {
    params ["_loadout", "_index"];
    if !((_loadout isEqualType []) && {(count _loadout) > _index}) exitWith {"NONE"};
    private _slot = _loadout select _index;
    if !(_slot isEqualType "") exitWith {"NONE"};
    [toLower _slot] call _resolveItemName
};

private _primaryName = [_intendedLoadout, 0] call _readWeaponNameFromLoadoutSlot;
private _handgunName = [_intendedLoadout, 2] call _readWeaponNameFromLoadoutSlot;
private _launcherName = [_intendedLoadout, 1] call _readWeaponNameFromLoadoutSlot;
private _uniformName = [_intendedLoadout, 3] call _readContainerNameFromLoadoutSlot;
private _vestName = [_intendedLoadout, 4] call _readContainerNameFromLoadoutSlot;
private _backpackName = [_intendedLoadout, 5] call _readContainerNameFromLoadoutSlot;
private _headgearName = [_intendedLoadout, 6] call _readStringSlotName;
private _facewearName = [_intendedLoadout, 7] call _readStringSlotName;

private _binocularName = "NONE";
if ((count _intendedLoadout) > 8) then {
    private _binocSlot = _intendedLoadout select 8;
    if (_binocSlot isEqualType "") then {
        _binocularName = [toLower _binocSlot] call _resolveItemName;
    } else {
        if ((_binocSlot isEqualType []) && {(count _binocSlot) > 0}) then {
            _binocularName = [toLower (_binocSlot select 0)] call _resolveItemName;
        };
    };
};

if (_activePage isEqualTo "LOADOUT") exitWith {
    call _showMainView;

    _ctrlSectionTitle ctrlSetText "LOADOUT";
    _ctrlNotice ctrlSetText "SERVER-AUTHORITATIVE INTENDED KIT";

    private _assignedCount = 0;
    if ((count _intendedLoadout) > 9) then {
        private _assigned = _intendedLoadout select 9;
        if (_assigned isEqualType []) then {
            _assignedCount = {_x isEqualType "" && {!(_x isEqualTo "")}} count _assigned;
        };
    };

    private _cargoEntries = 0;
    {
        if ((count _intendedLoadout) > _x) then {
            private _slot = _intendedLoadout select _x;
            if ((_slot isEqualType []) && {(count _slot) > 1}) then {
                private _cargo = _slot select 1;
                if (_cargo isEqualType []) then {
                    _cargoEntries = _cargoEntries + (count _cargo);
                };
            };
        };
    } forEach [3, 4, 5];

    [_ctrlPrimary, "PRIMARY", _primaryName] call _setLine;
    [_ctrlHandgun, "HANDGUN", _handgunName] call _setLine;
    [_ctrlLauncher, "LAUNCHER", _launcherName] call _setLine;
    [_ctrlUniform, "UNIFORM", _uniformName] call _setLine;
    [_ctrlVest, "VEST", _vestName] call _setLine;
    [_ctrlBackpack, "BACKPACK", _backpackName] call _setLine;
    [_ctrlHeadgear, "HEADGEAR", _headgearName] call _setLine;
    [_ctrlFacewear, "FACEWEAR", _facewearName] call _setLine;
    [_ctrlBinocular, "BINOCULAR", _binocularName] call _setLine;
    [_ctrlEquipment, "EQUIPMENT", format ["ASSIGNED %1 | CARGO ENTRIES %2", _assignedCount, _cargoEntries]] call _setLine;

    _ctrlPrimaryButton ctrlSetText format ["PRIMARY: %1", _primaryName];
    _ctrlHandgunButton ctrlSetText format ["HANDGUN: %1", _handgunName];
    _ctrlLauncherButton ctrlSetText format ["LAUNCHER: %1", _launcherName];
    _ctrlUniformButton ctrlSetText format ["UNIFORM: %1", _uniformName];
    _ctrlVestButton ctrlSetText format ["VEST: %1", _vestName];
    _ctrlBackpackButton ctrlSetText format ["BACKPACK: %1", _backpackName];
    _ctrlHeadgearButton ctrlSetText format ["HEADGEAR: %1", _headgearName];
    _ctrlFacewearButton ctrlSetText format ["FACEWEAR: %1", _facewearName];
    _ctrlBinocularButton ctrlSetText format ["BINOCULAR: %1", _binocularName];
    _ctrlEquipmentButton ctrlSetText "ASSIGNED EQUIPMENT";
    _ctrlCargoButton ctrlSetText "CARGO / ITEMS";
    _ctrlAttachmentsButton ctrlSetText "ATTACHMENTS";

    {
        _x ctrlEnable !isNull player;
    } forEach [
        _ctrlPrimaryButton,
        _ctrlHandgunButton,
        _ctrlLauncherButton,
        _ctrlUniformButton,
        _ctrlVestButton,
        _ctrlBackpackButton,
        _ctrlHeadgearButton,
        _ctrlFacewearButton,
        _ctrlBinocularButton,
        _ctrlEquipmentButton,
        _ctrlCargoButton,
        _ctrlAttachmentsButton
    ];

    _ctrlFooter ctrlSetText "SESSION KIT: USE SAVE KIT / LOAD KIT / DELETE KIT IN BOTTOM BAR";
};

call _showSelectorView;

private _selectorMode = switch (_activePage) do {
    case "LOADOUT_HANDGUN": {"HANDGUN"};
    case "LOADOUT_LAUNCHER": {"LAUNCHER"};
    case "LOADOUT_UNIFORM": {"UNIFORM"};
    case "LOADOUT_VEST": {"VEST"};
    case "LOADOUT_BACKPACK": {"BACKPACK"};
    case "LOADOUT_HEADGEAR": {"HEADGEAR"};
    case "LOADOUT_FACEWEAR": {"FACEWEAR"};
    case "LOADOUT_BINOCULAR": {"BINOCULAR"};
    case "LOADOUT_EQUIPMENT": {"ASSIGNED"};
    case "LOADOUT_ATTACHMENTS": {"ATTACHMENT"};
    case "LOADOUT_CARGO": {"CARGO"};
    default {"PRIMARY"};
};

private _entriesNamespaceKey = switch (_selectorMode) do {
    case "HANDGUN": {"BN_KOTH_menuHandgunEntries"};
    case "LAUNCHER": {"BN_KOTH_menuLauncherEntries"};
    case "UNIFORM": {"BN_KOTH_menuUniformEntries"};
    case "VEST": {"BN_KOTH_menuVestEntries"};
    case "BACKPACK": {"BN_KOTH_menuBackpackEntries"};
    case "HEADGEAR": {"BN_KOTH_menuHeadgearEntries"};
    case "FACEWEAR": {"BN_KOTH_menuFacewearEntries"};
    case "BINOCULAR": {"BN_KOTH_menuBinocularEntries"};
    case "ASSIGNED": {"BN_KOTH_menuAssignedEntries"};
    case "ATTACHMENT": {"BN_KOTH_menuAttachmentEntries"};
    case "CARGO": {"BN_KOTH_menuCargoEntries"};
    default {"BN_KOTH_menuPrimaryEntries"};
};

private _pendingNamespaceKey = switch (_selectorMode) do {
    case "HANDGUN": {"BN_KOTH_menuPendingHandgun"};
    case "LAUNCHER": {"BN_KOTH_menuPendingLauncher"};
    case "UNIFORM": {"BN_KOTH_menuPendingUniform"};
    case "VEST": {"BN_KOTH_menuPendingVest"};
    case "BACKPACK": {"BN_KOTH_menuPendingBackpack"};
    case "HEADGEAR": {"BN_KOTH_menuPendingHeadgear"};
    case "FACEWEAR": {"BN_KOTH_menuPendingFacewear"};
    case "BINOCULAR": {"BN_KOTH_menuPendingBinocular"};
    case "ASSIGNED": {"BN_KOTH_menuPendingAssigned"};
    case "ATTACHMENT": {"BN_KOTH_menuPendingAttachment"};
    case "CARGO": {"BN_KOTH_menuPendingCargo"};
    default {"BN_KOTH_menuPendingPrimary"};
};

private _selectorTitle = switch (_selectorMode) do {
    case "HANDGUN": {"HANDGUN"};
    case "LAUNCHER": {"LAUNCHER"};
    case "UNIFORM": {"UNIFORM"};
    case "VEST": {"VEST"};
    case "BACKPACK": {"BACKPACK"};
    case "HEADGEAR": {"HEADGEAR"};
    case "FACEWEAR": {"FACEWEAR"};
    case "BINOCULAR": {"BINOCULAR / RANGEFINDER"};
    case "ASSIGNED": {"ASSIGNED EQUIPMENT"};
    case "ATTACHMENT": {"WEAPON ATTACHMENTS"};
    case "CARGO": {"CARGO / ITEMS"};
    default {"PRIMARY WEAPON"};
};

private _selectorApplyText = switch (_selectorMode) do {
    case "HANDGUN": {"APPLY HANDGUN"};
    case "LAUNCHER": {"APPLY LAUNCHER"};
    case "UNIFORM": {"APPLY UNIFORM"};
    case "VEST": {"APPLY VEST"};
    case "BACKPACK": {"APPLY BACKPACK"};
    case "HEADGEAR": {"APPLY HEADGEAR"};
    case "FACEWEAR": {"APPLY FACEWEAR"};
    case "BINOCULAR": {"APPLY BINOCULAR"};
    case "ASSIGNED": {"APPLY EQUIPMENT"};
    case "ATTACHMENT": {"APPLY ATTACHMENT"};
    case "CARGO": {"APPLY CARGO CHANGE"};
    default {"APPLY PRIMARY"};
};

private _selectorNoEntriesText = switch (_selectorMode) do {
    case "HANDGUN": {"NO CANONICAL HANDGUNS AVAILABLE."};
    case "LAUNCHER": {"NO CANONICAL LAUNCHERS AVAILABLE."};
    case "UNIFORM": {"NO CANONICAL S.O.G. UNIFORMS AVAILABLE."};
    case "VEST": {"NO CANONICAL S.O.G. VESTS AVAILABLE."};
    case "BACKPACK": {"NO CANONICAL S.O.G. BACKPACKS AVAILABLE."};
    case "HEADGEAR": {"NO CANONICAL S.O.G. HEADGEAR AVAILABLE."};
    case "FACEWEAR": {"NO CANONICAL S.O.G. FACEWEAR AVAILABLE."};
    case "BINOCULAR": {"NO CANONICAL BINOCULARS AVAILABLE."};
    case "ASSIGNED": {"NO ASSIGNED-EQUIPMENT ENTRIES AVAILABLE."};
    case "ATTACHMENT": {"NO ATTACHMENT CHANGES AVAILABLE."};
    case "CARGO": {"NO CARGO CHANGES AVAILABLE."};
    default {"NO CANONICAL PRIMARY WEAPONS AVAILABLE."};
};

private _currentWeaponClass = toLower (switch (_selectorMode) do {
    case "HANDGUN": {
        private _slot = _intendedLoadout select 2;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "LAUNCHER": {
        private _slot = _intendedLoadout select 1;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "UNIFORM": {
        private _slot = _intendedLoadout select 3;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "VEST": {
        private _slot = _intendedLoadout select 4;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "BACKPACK": {
        private _slot = _intendedLoadout select 5;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
    case "HEADGEAR": {toLower (_intendedLoadout select 6)};
    case "FACEWEAR": {toLower (_intendedLoadout select 7)};
    case "BINOCULAR": {
        private _slot = _intendedLoadout select 8;
        if (_slot isEqualType "") then {toLower _slot} else {""}
    };
    default {
        private _slot = _intendedLoadout select 0;
        if ((_slot isEqualType []) && {(count _slot) >= 1}) then {_slot select 0} else {""}
    };
});

_ctrlPrimaryTitle ctrlSetText _selectorTitle;
_ctrlPrimaryCurrent ctrlSetText format ["CURRENT: %1", switch (_selectorMode) do {
    case "HANDGUN": {_handgunName};
    case "LAUNCHER": {_launcherName};
    case "UNIFORM": {_uniformName};
    case "VEST": {_vestName};
    case "BACKPACK": {_backpackName};
    case "HEADGEAR": {_headgearName};
    case "FACEWEAR": {_facewearName};
    case "BINOCULAR": {_binocularName};
    case "ASSIGNED": {"USE LIST TO PICK SLOT + ITEM"};
    case "ATTACHMENT": {"USE LIST TO ADD/REMOVE ATTACHMENTS"};
    case "CARGO": {"USE LIST TO ADD/REMOVE CARGO"};
    default {_primaryName};
}];

_ctrlPrimaryApply ctrlSetText _selectorApplyText;
_ctrlPrimaryApply ctrlSetEventHandler [
    "ButtonClick",
    switch (_selectorMode) do {
        case "HANDGUN": {"[] call bn_koth_fnc_menu_applyHandgun;"};
        case "LAUNCHER": {"[] call bn_koth_fnc_menu_applyLauncher;"};
        case "UNIFORM": {"[] call bn_koth_fnc_menu_applyUniform;"};
        case "VEST": {"[] call bn_koth_fnc_menu_applyVest;"};
        case "BACKPACK": {"[] call bn_koth_fnc_menu_applyBackpack;"};
        case "HEADGEAR": {"[] call bn_koth_fnc_menu_applyHeadgear;"};
        case "FACEWEAR": {"[] call bn_koth_fnc_menu_applyFacewear;"};
        case "BINOCULAR": {"[] call bn_koth_fnc_menu_applyBinocular;"};
        case "ASSIGNED": {"[] call bn_koth_fnc_menu_applyAssigned;"};
        case "ATTACHMENT": {"[] call bn_koth_fnc_menu_applyAttachment;"};
        case "CARGO": {"[] call bn_koth_fnc_menu_applyCargo;"};
        default {"[] call bn_koth_fnc_menu_applyPrimary;"};
    }
];

if (isNull player) exitWith {
    lbClear _ctrlPrimaryList;
    _ctrlPrimaryDetail ctrlSetText "NO PLAYER CONTEXT";
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = if (isClass _settingsCfg) then {getText (_settingsCfg >> "catalogueClass")} else {"CfgBnKothArsenal"};
if (_catalogueClass isEqualTo "") then {_catalogueClass = "CfgBnKothArsenal";};
private _compatibilityCfg = missionConfigFile >> _catalogueClass >> "Equipment" >> "Compatibility";
private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
private _weaponAttachmentsCfg = _compatibilityCfg >> "WeaponAttachments";

private _buildEntries = {
    private _entries = [];

    if (_selectorMode isEqualTo "UNIFORM") exitWith {
        {
            private _cfg = _x;
            private _class = toLower (configName _cfg);
            if ((_class find "vn_") != 0) then {continue;};
            if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
            private _itemInfo = _cfg >> "ItemInfo";
            if !(isClass _itemInfo) then {continue;};
            if !((getNumber (_itemInfo >> "type")) isEqualTo 801) then {continue;};

            private _name = getText (_cfg >> "displayName");
            if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

            _entries pushBack (createHashMapFromArray [
                ["displayName", _name],
                ["weaponClass", _class],
                ["available", true],
                ["equipped", _class isEqualTo _currentWeaponClass]
            ]);
        } forEach ("true" configClasses (configFile >> "CfgWeapons"));

        _entries sort true;
        _entries
    };

    if (_selectorMode isEqualTo "VEST") exitWith {
        {
            private _cfg = _x;
            private _class = toLower (configName _cfg);
            if ((_class find "vn_") != 0) then {continue;};
            if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
            private _itemInfo = _cfg >> "ItemInfo";
            if !(isClass _itemInfo) then {continue;};
            if !((getNumber (_itemInfo >> "type")) isEqualTo 701) then {continue;};

            private _name = getText (_cfg >> "displayName");
            if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

            _entries pushBack (createHashMapFromArray [
                ["displayName", _name],
                ["weaponClass", _class],
                ["available", true],
                ["equipped", _class isEqualTo _currentWeaponClass]
            ]);
        } forEach ("true" configClasses (configFile >> "CfgWeapons"));

        _entries sort true;
        _entries
    };

    if (_selectorMode isEqualTo "BACKPACK") exitWith {
        _entries pushBack (createHashMapFromArray [
            ["displayName", "NONE / NO BACKPACK"],
            ["weaponClass", ""],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ]);

        {
            private _cfg = _x;
            private _class = toLower (configName _cfg);
            if ((_class find "vn_") != 0) then {continue;};
            if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
            if !(_class isKindOf ["Bag_Base", configFile >> "CfgVehicles"]) then {continue;};

            private _name = getText (_cfg >> "displayName");
            if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

            _entries pushBack (createHashMapFromArray [
                ["displayName", _name],
                ["weaponClass", _class],
                ["available", true],
                ["equipped", _class isEqualTo _currentWeaponClass]
            ]);
        } forEach ("true" configClasses (configFile >> "CfgVehicles"));

        _entries
    };

    if (_selectorMode isEqualTo "HEADGEAR") exitWith {
        _entries pushBack (createHashMapFromArray [
            ["displayName", "NONE / NO HEADGEAR"],
            ["weaponClass", ""],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ]);

        {
            private _cfg = _x;
            private _class = toLower (configName _cfg);
            if ((_class find "vn_") != 0) then {continue;};
            if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
            private _itemInfo = _cfg >> "ItemInfo";
            if !(isClass _itemInfo) then {continue;};
            if !((getNumber (_itemInfo >> "type")) isEqualTo 605) then {continue;};

            private _name = getText (_cfg >> "displayName");
            if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

            _entries pushBack (createHashMapFromArray [
                ["displayName", _name],
                ["weaponClass", _class],
                ["available", true],
                ["equipped", _class isEqualTo _currentWeaponClass]
            ]);
        } forEach ("true" configClasses (configFile >> "CfgWeapons"));

        _entries
    };

    if (_selectorMode isEqualTo "FACEWEAR") exitWith {
        _entries pushBack (createHashMapFromArray [
            ["displayName", "NONE / NO FACEWEAR"],
            ["weaponClass", ""],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ]);

        {
            private _cfg = _x;
            private _class = toLower (configName _cfg);
            if ((_class find "vn_") != 0) then {continue;};
            if ((getNumber (_cfg >> "scope")) < 2) then {continue;};
            private _name = getText (_cfg >> "displayName");
            if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

            _entries pushBack (createHashMapFromArray [
                ["displayName", _name],
                ["weaponClass", _class],
                ["available", true],
                ["equipped", _class isEqualTo _currentWeaponClass]
            ]);
        } forEach ("true" configClasses (configFile >> "CfgGlasses"));

        _entries
    };

    if (_selectorMode isEqualTo "BINOCULAR") exitWith {
        _entries pushBack (createHashMapFromArray [
            ["displayName", "NONE / NO BINOCULAR"],
            ["binocularClass", ""],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ]);

        if (isClass _sourceItemsCfg) then {
            {
                private _cfg = _x;
                private _class = toLower (configName _cfg);
                private _itemType = toLower (getText (_cfg >> "itemType"));
                if !(_itemType isEqualTo "binocular") then {continue;};

                private _name = getText (_cfg >> "displayName");
                if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

                _entries pushBack (createHashMapFromArray [
                    ["displayName", _name],
                    ["binocularClass", _class],
                    ["available", true],
                    ["equipped", _class isEqualTo _currentWeaponClass]
                ]);
            } forEach ("true" configClasses _sourceItemsCfg);
        };

        _entries
    };

    if (_selectorMode isEqualTo "ASSIGNED") exitWith {
        private _assigned = if ((count _intendedLoadout) > 9 && {(_intendedLoadout select 9) isEqualType []}) then {+(_intendedLoadout select 9)} else {[]};
        while {(count _assigned) < 6} do {_assigned pushBack "";};

        private _slotLabels = ["MAP", "GPS/UAV", "RADIO", "COMPASS", "WATCH", "NVG"];
        private _slotSubtypePredicates = [
            {params ["_subType"]; _subType isEqualTo "map"},
            {params ["_subType"]; (_subType isEqualTo "gps") || {_subType find "uav" >= 0}},
            {params ["_subType"]; _subType isEqualTo "radio"},
            {params ["_subType"]; _subType isEqualTo "compass"},
            {params ["_subType"]; _subType isEqualTo "watch"},
            {params ["_subType"]; _subType find "nvg" >= 0}
        ];

        for "_i" from 0 to 5 do {
            _entries pushBack (createHashMapFromArray [
                ["displayName", format ["%1: NONE", _slotLabels select _i]],
                ["assignedIndex", _i],
                ["itemClass", ""],
                ["available", true],
                ["equipped", (toLower (_assigned select _i)) isEqualTo ""]
            ]);

            {
                private _cfg = _x;
                private _class = toLower (configName _cfg);
                private _itemType = [_class] call BIS_fnc_itemType;
                if !((_itemType isEqualType []) && {(count _itemType) >= 2}) then {continue;};

                private _subType = toLower (_itemType select 1);
                if !([_subType] call (_slotSubtypePredicates select _i)) then {continue;};

                private _name = getText (_cfg >> "displayName");
                if (_name isEqualTo "") then {_name = [_class] call _resolveItemName;};

                _entries pushBack (createHashMapFromArray [
                    ["displayName", format ["%1: %2", _slotLabels select _i, _name]],
                    ["assignedIndex", _i],
                    ["itemClass", _class],
                    ["available", true],
                    ["equipped", _class isEqualTo toLower (_assigned select _i)]
                ]);
            } forEach ("true" configClasses (configFile >> "CfgWeapons"));
        };

        _entries
    };

    if (_selectorMode isEqualTo "ATTACHMENT") exitWith {
        if (!(isClass _weaponAttachmentsCfg) || {!(isClass _sourceItemsCfg)}) exitWith {_entries};

        {
            _x params ["_slotName", "_slotIndex", "_slotLabel"];
            private _slot = _intendedLoadout select _slotIndex;
            if !((_slot isEqualType []) && {(count _slot) >= 7}) then {continue;};

            private _weaponClass = toLower (_slot select 0);
            if (_weaponClass isEqualTo "") then {continue;};

            private _currentAttachments = [];
            {
                private _att = toLower (_slot select _x);
                if !(_att isEqualTo "") then {
                    _currentAttachments pushBackUnique _att;
                };
            } forEach [1, 2, 3, 6];

            {
                private _attClass = _x;
                private _attName = [toLower _attClass] call _resolveItemName;
                _entries pushBack (createHashMapFromArray [
                    ["displayName", format ["%1 REMOVE: %2", _slotLabel, _attName]],
                    ["weaponSlot", _slotName],
                    ["attachmentClass", toLower _attClass],
                    ["mode", "remove"],
                    ["available", true],
                    ["equipped", true]
                ]);
            } forEach _currentAttachments;

            private _compatCfg = _weaponAttachmentsCfg >> _weaponClass;
            if (isClass _compatCfg) then {
                {
                    private _attClass = toLower _x;
                    if (_attClass in _currentAttachments) then {continue;};
                    if !(isClass (_sourceItemsCfg >> _attClass)) then {continue;};

                    private _attName = [_attClass] call _resolveItemName;
                    _entries pushBack (createHashMapFromArray [
                        ["displayName", format ["%1 ADD: %2", _slotLabel, _attName]],
                        ["weaponSlot", _slotName],
                        ["attachmentClass", _attClass],
                        ["mode", "add"],
                        ["available", true],
                        ["equipped", false]
                    ]);
                } forEach (getArray (_compatCfg >> "values"));
            };
        } forEach [
            ["primary", 0, "PRIMARY"],
            ["launcher", 1, "LAUNCHER"],
            ["handgun", 2, "HANDGUN"]
        ];

        _entries
    };

    if (_selectorMode isEqualTo "CARGO") exitWith {
        private _containers = [];
        {
            _x params ["_name", "_index"];
            private _slot = _intendedLoadout select _index;
            if ((_slot isEqualType []) && {(count _slot) >= 2}) then {
                private _containerClass = toLower (_slot select 0);
                if !(_containerClass isEqualTo "") then {
                    _containers pushBack _x;
                };
            };
        } forEach [["uniform", 3], ["vest", 4], ["backpack", 5]];

        {
            _x params ["_containerName", "_index"];
            private _slot = _intendedLoadout select _index;
            private _cargo = _slot select 1;
            if !(_cargo isEqualType []) then {_cargo = [];};

            {
                if ((_x isEqualType []) && {(count _x) >= 2}) then {
                    private _entryClass = toLower (_x select 0);
                    private _entryCount = _x select 1;
                    if ((_entryClass isEqualType "") && {(_entryCount isEqualType 0)} && {_entryCount > 0}) then {
                        _entries pushBack (createHashMapFromArray [
                            ["displayName", format ["REMOVE %1: %2 (x%3)", toUpper _containerName, [_entryClass] call _resolveItemName, _entryCount]],
                            ["container", _containerName],
                            ["className", _entryClass],
                            ["delta", -1],
                            ["available", true],
                            ["equipped", false]
                        ]);
                    };
                };
            } forEach _cargo;
        } forEach _containers;

        private _candidateClasses = [];

        if (isClass _weaponMagazinesCfg) then {
            {
                private _slot = _intendedLoadout select _x;
                if ((_slot isEqualType []) && {(count _slot) >= 1}) then {
                    private _weaponClass = toLower (_slot select 0);
                    private _magCfg = _weaponMagazinesCfg >> _weaponClass;
                    if (isClass _magCfg) then {
                        {
                            _candidateClasses pushBackUnique (toLower _x);
                        } forEach (getArray (_magCfg >> "values"));
                    };
                };
            } forEach [0, 1, 2];
        };

        if (isClass _sourceMagazinesCfg) then {
            {
                private _class = toLower (configName _x);
                private _category = toLower (getText (_x >> "category"));
                if (((_category find "grenade") >= 0) || {(_category find "smoke") >= 0}) then {
                    _candidateClasses pushBackUnique _class;
                };
            } forEach ("true" configClasses _sourceMagazinesCfg);
        };

        if (isClass _sourceItemsCfg) then {
            {
                private _class = toLower (configName _x);
                private _classStr = toLower _class;
                if (
                    (_classStr find "firstaid") >= 0 ||
                    (_classStr find "medikit") >= 0 ||
                    (_classStr find "toolkit") >= 0 ||
                    (_classStr find "radio") >= 0 ||
                    (_classStr find "compass") >= 0 ||
                    (_classStr find "watch") >= 0 ||
                    (_classStr find "map") >= 0 ||
                    (_classStr find "wiretap") >= 0
                ) then {
                    _candidateClasses pushBackUnique _class;
                };
            } forEach ("true" configClasses _sourceItemsCfg);
        };

        private _added = 0;
        {
            private _className = _x;
            if (_added > 250) then {break;};
            {
                _x params ["_containerName", "_index"];
                _entries pushBack (createHashMapFromArray [
                    ["displayName", format ["ADD %1: %2", toUpper _containerName, [_className] call _resolveItemName]],
                    ["container", _containerName],
                    ["className", _className],
                    ["delta", 1],
                    ["available", true],
                    ["equipped", false]
                ]);
                _added = _added + 1;
            } forEach _containers;
        } forEach _candidateClasses;

        _entries
    };

    private _selectorWeaponTypes = switch (_selectorMode) do {
        case "HANDGUN": {["handgun"]};
        case "LAUNCHER": {["launcher"]};
        default {["rifle", "lmg", "smg", "shotgun", "marksman"]};
    };
    private _selectorEngineType = switch (_selectorMode) do {
        case "HANDGUN": {2};
        case "LAUNCHER": {4};
        default {1};
    };

    if (!(isClass _sourceWeaponsCfg) || {!(isClass _weaponMagazinesCfg)}) exitWith {_entries};

    private _sortable = [];
    {
        private _weaponCfg = _x;
        private _weaponClass = toLower (configName _weaponCfg);
        private _variantOf = toLower (getText (_weaponCfg >> "variantOf"));
        private _weaponType = toLower (getText (_weaponCfg >> "weaponType"));

        if !(_variantOf isEqualTo "") then {continue;};
        if !(_weaponType in _selectorWeaponTypes) then {continue;};

        private _engineCfg = configFile >> "CfgWeapons" >> _weaponClass;
        if !(isClass _engineCfg) then {continue;};
        if !((getNumber (_engineCfg >> "type")) isEqualTo _selectorEngineType) then {continue;};

        private _magCfg = _weaponMagazinesCfg >> _weaponClass;
        private _magazines = if (isClass _magCfg) then {(getArray (_magCfg >> "values")) apply {toLower _x}} else {[]};
        private _baseMagazine = toLower (getText (_weaponCfg >> "baseMagazine"));
        private _defaultMagazine = if (_baseMagazine in _magazines) then {_baseMagazine} else {if ((count _magazines) > 0) then {_magazines select 0} else {""}};

        private _available = !(_defaultMagazine isEqualTo "") && {isClass (configFile >> "CfgMagazines" >> _defaultMagazine)};
        private _displayName = getText (_weaponCfg >> "displayName");
        if (_displayName isEqualTo "") then {_displayName = [_weaponClass] call _resolveItemName;};

        private _defaultMagazineName = if (_available) then {[_defaultMagazine] call _resolveItemName} else {"NO COMPATIBLE DEFAULT MAGAZINE"};

        _sortable pushBack [toLower _displayName, createHashMapFromArray [
            ["displayName", _displayName],
            ["weaponClass", _weaponClass],
            ["defaultMagazine", _defaultMagazine],
            ["defaultMagazineName", _defaultMagazineName],
            ["available", _available],
            ["equipped", _weaponClass isEqualTo _currentWeaponClass]
        ]];
    } forEach ("true" configClasses _sourceWeaponsCfg);

    _sortable sort true;

    if (_selectorMode isEqualTo "LAUNCHER") then {
        _entries pushBack (createHashMapFromArray [
            ["displayName", "NONE"],
            ["weaponClass", ""],
            ["defaultMagazine", ""],
            ["defaultMagazineName", "NO LAUNCHER"],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ]);
    };

    {
        _entries pushBack (_x select 1);
    } forEach _sortable;

    _entries
};

private _entries = call _buildEntries;
uiNamespace setVariable [_entriesNamespaceKey, _entries];

lbClear _ctrlPrimaryList;
{
    private _label = _x getOrDefault ["displayName", "UNKNOWN"];
    if (_x getOrDefault ["equipped", false]) then {
        _label = format ["[EQUIPPED] %1", _label];
    };
    if !(_x getOrDefault ["available", false]) then {
        _label = format ["%1 [UNAVAILABLE]", _label];
    };

    private _row = _ctrlPrimaryList lbAdd _label;
    _ctrlPrimaryList lbSetData [_row, str _x];
    _ctrlPrimaryList lbSetValue [_row, if (_x getOrDefault ["available", false]) then {1} else {0}];

    if !(_x getOrDefault ["available", false]) then {
        _ctrlPrimaryList lbSetColor [_row, [0.58, 0.58, 0.56, 0.9]];
    };
} forEach _entries;

if ((count _entries) <= 0) exitWith {
    _ctrlPrimaryDetail ctrlSetText _selectorNoEntriesText;
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _selectedIndex = lbCurSel _ctrlPrimaryList;
if ((_selectedIndex < 0) || {_selectedIndex >= (count _entries)}) then {
    _selectedIndex = 0;
    _ctrlPrimaryList lbSetCurSel _selectedIndex;
};

private _selected = _entries select _selectedIndex;
private _selectedName = _selected getOrDefault ["displayName", "UNKNOWN"];
private _selectedAvailable = _selected getOrDefault ["available", false];

if (_selectedAvailable) then {
    switch (_selectorMode) do {
        case "UNIFORM": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["uniformClass", _selected getOrDefault ["weaponClass", ""]],
                ["available", true]
            ]];
        };
        case "VEST": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["vestClass", _selected getOrDefault ["weaponClass", ""]],
                ["available", true]
            ]];
        };
        case "BACKPACK": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["backpackClass", _selected getOrDefault ["weaponClass", ""]],
                ["available", true]
            ]];
        };
        case "HEADGEAR": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["headgearClass", _selected getOrDefault ["weaponClass", ""]],
                ["available", true]
            ]];
        };
        case "FACEWEAR": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["facewearClass", _selected getOrDefault ["weaponClass", ""]],
                ["available", true]
            ]];
        };
        case "BINOCULAR": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["binocularClass", _selected getOrDefault ["binocularClass", ""]],
                ["available", true]
            ]];
        };
        case "ASSIGNED": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SET ASSIGNED SLOT", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["assignedIndex", _selected getOrDefault ["assignedIndex", -1]],
                ["itemClass", _selected getOrDefault ["itemClass", ""]],
                ["available", true]
            ]];
        };
        case "ATTACHMENT": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO CHANGE ATTACHMENT", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["weaponSlot", _selected getOrDefault ["weaponSlot", ""]],
                ["attachmentClass", _selected getOrDefault ["attachmentClass", ""]],
                ["mode", _selected getOrDefault ["mode", "add"]],
                ["available", true]
            ]];
        };
        case "CARGO": {
            _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nAPPLY TO SEND CARGO DELTA", _selectedName];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["container", _selected getOrDefault ["container", ""]],
                ["className", _selected getOrDefault ["className", ""]],
                ["delta", _selected getOrDefault ["delta", 0]],
                ["available", true]
            ]];
        };
        default {
            private _weaponClass = _selected getOrDefault ["weaponClass", ""];
            private _magClass = _selected getOrDefault ["defaultMagazine", ""];
            private _magName = _selected getOrDefault ["defaultMagazineName", ""];

            _ctrlPrimaryDetail ctrlSetText format [
                "SELECTED: %1\nDEFAULT MAGAZINE: %2\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST",
                _selectedName,
                _magName
            ];

            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["weaponClass", _weaponClass],
                ["magazineClass", _magClass],
                ["available", true]
            ]];
        };
    };

    _ctrlPrimaryApply ctrlEnable true;
} else {
    _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nSTATUS: UNAVAILABLE", _selectedName];
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
    _ctrlPrimaryApply ctrlEnable false;
};

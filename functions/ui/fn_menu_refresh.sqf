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

private _validPages = ["LOADOUT", "LOADOUT_PRIMARY", "LOADOUT_HANDGUN", "LOADOUT_LAUNCHER", "LOADOUT_UNIFORM", "STORE", "PERKS", "STATS", "PROGRESSION"];
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
private _ctrlEquipment = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_EQUIPMENT;
private _ctrlPrimaryButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_PRIMARY_BUTTON;
private _ctrlHandgunButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_HANDGUN_BUTTON;
private _ctrlLauncherButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_LAUNCHER_BUTTON;
private _ctrlUniformButton = _display displayCtrl BN_KOTH_IDC_MENU_SLOT_UNIFORM_BUTTON;

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

private _resolveConfigDisplayName = {
    params ["_className", "_cfgPath"];

    if (_className isEqualTo "") exitWith {"NONE"};

    private _cfg = _cfgPath >> _className;
    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {
        toUpper _className
    } else {
        _displayName
    }
};

private _serverName = serverName;
if (_serverName isEqualTo "") then {
    _serverName = "LOCAL SESSION";
};
_ctrlServer ctrlSetText format ["SERVER  %1", _serverName];

private _playerName = profileName;
if (!isNull player) then {
    _playerName = name player;
};
_ctrlOperatorName ctrlSetText toUpper _playerName;

private _sideLabel = "UNASSIGNED";
if (!isNull player) then {
    private _side = side group player;
    _sideLabel = switch (_side) do {
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
        if (_displayName isEqualTo "") then {
            _unitClass
        } else {
            _displayName
        }
    } else {
        _unitClass
    };
};
_ctrlOperatorRole ctrlSetText _roleText;

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
    if (_displayName isEqualTo "") then {
        toUpper _className
    } else {
        _displayName
    }
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

[_ctrlNavLoadout, _activePage in ["LOADOUT", "LOADOUT_PRIMARY", "LOADOUT_HANDGUN", "LOADOUT_LAUNCHER", "LOADOUT_UNIFORM"]] call _setNavState;
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
    _ctrlEquipment,
    _ctrlPrimaryButton,
    _ctrlHandgunButton,
    _ctrlLauncherButton,
    _ctrlUniformButton,
    _ctrlSectionTitle,
    _ctrlNotice,
    _ctrlFooter
];

private _primaryViewControls = [
    _ctrlPrimaryTitle,
    _ctrlPrimaryCurrent,
    _ctrlPrimaryList,
    _ctrlPrimaryDetail,
    _ctrlPrimaryBack,
    _ctrlPrimaryApply
];

{
    _x ctrlShow false;
} forEach _primaryViewControls;

private _showMainView = {
    {
        _x ctrlShow true;
    } forEach _mainViewControls;

    {
        _x ctrlShow false;
    } forEach _primaryViewControls;
};

private _showPrimaryView = {
    {
        _x ctrlShow false;
    } forEach _mainViewControls;

    {
        _x ctrlShow true;
    } forEach _primaryViewControls;
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
        [_ctrlEquipment, "EQUIPMENT"]
    ];

    _ctrlPrimaryButton ctrlSetText "";
    _ctrlPrimaryButton ctrlEnable false;
    _ctrlHandgunButton ctrlSetText "";
    _ctrlHandgunButton ctrlEnable false;
    _ctrlLauncherButton ctrlSetText "";
    _ctrlLauncherButton ctrlEnable false;
    _ctrlUniformButton ctrlSetText "";
    _ctrlUniformButton ctrlEnable false;
};

if !(_activePage in ["LOADOUT", "LOADOUT_PRIMARY", "LOADOUT_HANDGUN", "LOADOUT_LAUNCHER", "LOADOUT_UNIFORM"]) exitWith {
    [_activePage] call _showComingSoon;
};

private _primaryName = if (isNull player) then {"NONE"} else {[primaryWeapon player] call _resolveItemName};
private _handgunName = if (isNull player) then {"NONE"} else {[handgunWeapon player] call _resolveItemName};
private _launcherName = if (isNull player) then {"NONE"} else {[secondaryWeapon player] call _resolveItemName};
private _uniformName = if (isNull player) then {"NONE"} else {[uniform player] call _resolveItemName};
private _vestName = if (isNull player) then {"NONE"} else {[vest player] call _resolveItemName};
private _headgearName = if (isNull player) then {"NONE"} else {[headgear player] call _resolveItemName};
private _backpackName = if (isNull player) then {"NONE"} else {[backpack player] call _resolveItemName};

if (_activePage isEqualTo "LOADOUT") exitWith {
    call _showMainView;

    _ctrlSectionTitle ctrlSetText "LOADOUT";
    _ctrlNotice ctrlSetText "";

    private _equipmentSummary = if (isNull player) then {
        "NO PLAYER CONTEXT"
    } else {
        format [
            "MAG %1 | ITEMS %2 | ASSIGNED %3",
            count (magazines player),
            count (items player),
            count (assignedItems player)
        ]
    };

    [_ctrlPrimary, "PRIMARY", _primaryName] call _setLine;
    [_ctrlHandgun, "HANDGUN", _handgunName] call _setLine;
    [_ctrlLauncher, "LAUNCHER", _launcherName] call _setLine;
    [_ctrlUniform, "UNIFORM", _uniformName] call _setLine;
    [_ctrlVest, "VEST", _vestName] call _setLine;
    [_ctrlHeadgear, "HEADGEAR", _headgearName] call _setLine;
    [_ctrlBackpack, "BACKPACK", _backpackName] call _setLine;
    [_ctrlEquipment, "EQUIPMENT", _equipmentSummary] call _setLine;

    _ctrlPrimaryButton ctrlSetText format ["PRIMARY: %1", _primaryName];
    _ctrlPrimaryButton ctrlEnable !isNull player;
    _ctrlHandgunButton ctrlSetText format ["HANDGUN: %1", _handgunName];
    _ctrlHandgunButton ctrlEnable !isNull player;
    _ctrlLauncherButton ctrlSetText format ["LAUNCHER: %1", _launcherName];
    _ctrlLauncherButton ctrlEnable !isNull player;
    _ctrlUniformButton ctrlSetText format ["UNIFORM: %1", _uniformName];
    _ctrlUniformButton ctrlEnable !isNull player;

    private _weaponsCount = if (isNull player) then {0} else {count (weapons player)};
    _ctrlFooter ctrlSetText format ["LIVE KIT READOUT - %1 WEAPONS EQUIPPED", _weaponsCount];
};

call _showPrimaryView;

private _selectorMode = switch (_activePage) do {
    case "LOADOUT_HANDGUN": {"HANDGUN"};
    case "LOADOUT_LAUNCHER": {"LAUNCHER"};
    case "LOADOUT_UNIFORM": {"UNIFORM"};
    default {"PRIMARY"};
};

private _entriesNamespaceKey = switch (_selectorMode) do {
    case "HANDGUN": {"BN_KOTH_menuHandgunEntries"};
    case "LAUNCHER": {"BN_KOTH_menuLauncherEntries"};
    case "UNIFORM": {"BN_KOTH_menuUniformEntries"};
    default {"BN_KOTH_menuPrimaryEntries"};
};

private _pendingNamespaceKey = switch (_selectorMode) do {
    case "HANDGUN": {"BN_KOTH_menuPendingHandgun"};
    case "LAUNCHER": {"BN_KOTH_menuPendingLauncher"};
    case "UNIFORM": {"BN_KOTH_menuPendingUniform"};
    default {"BN_KOTH_menuPendingPrimary"};
};

private _requestedSelectorPage = switch (_selectorMode) do {
    case "HANDGUN": {"LOADOUT_HANDGUN"};
    case "LAUNCHER": {"LOADOUT_LAUNCHER"};
    case "UNIFORM": {"LOADOUT_UNIFORM"};
    default {"LOADOUT_PRIMARY"};
};

private _selectorTitle = switch (_selectorMode) do {
    case "HANDGUN": {"HANDGUN"};
    case "LAUNCHER": {"LAUNCHER"};
    case "UNIFORM": {"UNIFORM"};
    default {"PRIMARY WEAPON"};
};

private _selectorApplyText = switch (_selectorMode) do {
    case "HANDGUN": {"APPLY HANDGUN"};
    case "LAUNCHER": {"APPLY LAUNCHER"};
    case "UNIFORM": {"APPLY UNIFORM"};
    default {"APPLY PRIMARY"};
};

private _selectorNoEntriesText = switch (_selectorMode) do {
    case "HANDGUN": {"NO CANONICAL HANDGUNS AVAILABLE."};
    case "LAUNCHER": {"NO CANONICAL LAUNCHERS AVAILABLE."};
    case "UNIFORM": {"NO CANONICAL S.O.G. UNIFORMS AVAILABLE."};
    default {"NO CANONICAL PRIMARY WEAPONS AVAILABLE."};
};

private _selectorWeaponTypes = switch (_selectorMode) do {
    case "HANDGUN": {["handgun"]};
    case "LAUNCHER": {["launcher"]};
    case "UNIFORM": {[]};
    default {["rifle", "lmg", "smg", "shotgun", "marksman"]};
};

private _selectorEngineType = switch (_selectorMode) do {
    case "HANDGUN": {2};
    case "LAUNCHER": {4};
    case "UNIFORM": {-1};
    default {1};
};

private _currentWeaponClass = toLower (switch (_selectorMode) do {
    case "HANDGUN": {handgunWeapon player};
    case "LAUNCHER": {secondaryWeapon player};
    case "UNIFORM": {uniform player};
    default {primaryWeapon player};
});

_ctrlPrimaryTitle ctrlSetText _selectorTitle;
_ctrlPrimaryCurrent ctrlSetText format ["CURRENT: %1", switch (_selectorMode) do {
    case "HANDGUN": {_handgunName};
    case "LAUNCHER": {_launcherName};
    case "UNIFORM": {_uniformName};
    default {_primaryName};
}];
_ctrlPrimaryApply ctrlSetText _selectorApplyText;
_ctrlPrimaryApply ctrlSetEventHandler [
    "ButtonClick",
    switch (_selectorMode) do {
        case "HANDGUN": {"[] call bn_koth_fnc_menu_applyHandgun;"};
        case "LAUNCHER": {"[] call bn_koth_fnc_menu_applyLauncher;"};
        case "UNIFORM": {"[] call bn_koth_fnc_menu_applyUniform;"};
        default {"[] call bn_koth_fnc_menu_applyPrimary;"};
    }
];

if (isNull player) exitWith {
    lbClear _ctrlPrimaryList;
    _ctrlPrimaryDetail ctrlSetText "NO PLAYER CONTEXT";
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _buildPrimaryEntries = {
    if (_selectorMode isEqualTo "UNIFORM") exitWith {
        private _sortableEntries = [];

        {
            private _uniformCfg = _x;
            private _uniformClass = toLower (configName _uniformCfg);

            if !((_uniformClass find "vn_") isEqualTo 0) then {
                continue;
            };

            if ((getNumber (_uniformCfg >> "scope")) < 2) then {
                continue;
            };

            private _itemInfoCfg = _uniformCfg >> "ItemInfo";
            if !(isClass _itemInfoCfg) then {
                continue;
            };

            if !((getNumber (_itemInfoCfg >> "type")) isEqualTo 801) then {
                continue;
            };

            private _uniformUnitClass = toLower (getText (_itemInfoCfg >> "uniformClass"));
            if (_uniformUnitClass isEqualTo "") then {
                continue;
            };

            private _displayName = getText (_uniformCfg >> "displayName");
            if (_displayName isEqualTo "") then {
                _displayName = [_uniformClass, configFile >> "CfgWeapons"] call _resolveConfigDisplayName;
            };

            private _entry = createHashMapFromArray [
                ["weaponClass", _uniformClass],
                ["displayName", _displayName],
                ["weaponType", "uniform"],
                ["defaultMagazine", ""],
                ["defaultMagazineName", ""],
                ["available", true],
                ["equipped", _uniformClass isEqualTo _currentWeaponClass],
                ["uniformClass", _uniformUnitClass]
            ];

            _sortableEntries pushBack [toLower _displayName, _entry];
        } forEach ("true" configClasses (configFile >> "CfgWeapons"));

        _sortableEntries sort true;

        private _entries = [];
        {
            _entries pushBack (_x select 1);
        } forEach _sortableEntries;

        _entries
    };

    private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
    private _catalogueClass = if (isClass _settingsCfg) then {
        getText (_settingsCfg >> "catalogueClass")
    } else {
        "CfgBnKothArsenal"
    };

    if (_catalogueClass isEqualTo "") then {
        _catalogueClass = "CfgBnKothArsenal";
    };

    private _compatibilityCfg = missionConfigFile >> _catalogueClass >> "Equipment" >> "Compatibility";
    private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
    private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";

    if !(isClass _sourceWeaponsCfg) exitWith {[]};
    if !(isClass _weaponMagazinesCfg) exitWith {[]};

    private _sortableEntries = [];

    {
        private _weaponCfg = _x;
        private _weaponClass = toLower (configName _weaponCfg);
        private _variantOf = toLower (getText (_weaponCfg >> "variantOf"));
        private _weaponType = toLower (getText (_weaponCfg >> "weaponType"));

        if !(_variantOf isEqualTo "") then {
            continue;
        };

        if !(_weaponType in _selectorWeaponTypes) then {
            continue;
        };

        private _engineCfg = configFile >> "CfgWeapons" >> _weaponClass;
        if !(isClass _engineCfg) then {
            continue;
        };

        if !((getNumber (_engineCfg >> "type")) isEqualTo _selectorEngineType) then {
            continue;
        };

        private _magazinesCfg = _weaponMagazinesCfg >> _weaponClass;
        private _magazines = if (isClass _magazinesCfg) then {
            (getArray (_magazinesCfg >> "values")) apply {toLower _x}
        } else {
            []
        };

        private _baseMagazine = toLower (getText (_weaponCfg >> "baseMagazine"));
        private _defaultMagazine = "";

        if (!(_baseMagazine isEqualTo "") && {_baseMagazine in _magazines}) then {
            _defaultMagazine = _baseMagazine;
        } else {
            if ((count _magazines) > 0) then {
                _defaultMagazine = _magazines select 0;
            };
        };

        private _available = !(_defaultMagazine isEqualTo "") && {isClass (configFile >> "CfgMagazines" >> _defaultMagazine)};
        private _displayName = getText (_weaponCfg >> "displayName");
        if (_displayName isEqualTo "") then {
            _displayName = [_weaponClass, configFile >> "CfgWeapons"] call _resolveConfigDisplayName;
        };

        private _defaultMagazineName = if (_available) then {
            [_defaultMagazine, configFile >> "CfgMagazines"] call _resolveConfigDisplayName
        } else {
            "NO COMPATIBLE DEFAULT MAGAZINE"
        };

        private _entry = createHashMapFromArray [
            ["weaponClass", _weaponClass],
            ["displayName", _displayName],
            ["weaponType", _weaponType],
            ["defaultMagazine", _defaultMagazine],
            ["defaultMagazineName", _defaultMagazineName],
            ["available", _available],
            ["equipped", _weaponClass isEqualTo _currentWeaponClass]
        ];

        _sortableEntries pushBack [toLower _displayName, _entry];
    } forEach ("true" configClasses _sourceWeaponsCfg);

    _sortableEntries sort true;

    private _entries = [];
    if (_selectorMode isEqualTo "LAUNCHER") then {
        private _noneEntry = createHashMapFromArray [
            ["weaponClass", ""],
            ["displayName", "NONE"],
            ["weaponType", "launcher"],
            ["defaultMagazine", ""],
            ["defaultMagazineName", "NO LAUNCHER"],
            ["available", true],
            ["equipped", _currentWeaponClass isEqualTo ""]
        ];

        _entries pushBack _noneEntry;
    };

    {
        _entries pushBack (_x select 1);
    } forEach _sortableEntries;

    _entries
};

private _entries = uiNamespace getVariable [_entriesNamespaceKey, []];
private _openRequestedSelectorView = (toUpper _requestedPage) isEqualTo _requestedSelectorPage;
if (_openRequestedSelectorView || {!(_entries isEqualType [])} || {(count _entries) isEqualTo 0}) then {
    _entries = call _buildPrimaryEntries;
    uiNamespace setVariable [_entriesNamespaceKey, _entries];

    lbClear _ctrlPrimaryList;
    {
        private _displayName = _x getOrDefault ["displayName", "UNKNOWN"];
        private _weaponClass = _x getOrDefault ["weaponClass", ""];
        private _available = _x getOrDefault ["available", false];
        private _equipped = _x getOrDefault ["equipped", false];

        private _label = _displayName;
        if (_equipped) then {
            _label = format ["[EQUIPPED] %1", _label];
        };
        if (!_available) then {
            _label = format ["%1 [UNAVAILABLE]", _label];
        };

        private _row = _ctrlPrimaryList lbAdd _label;
        _ctrlPrimaryList lbSetData [_row, _weaponClass];
        _ctrlPrimaryList lbSetValue [_row, if (_available) then {1} else {0}];

        if (!_available) then {
            _ctrlPrimaryList lbSetColor [_row, [0.58, 0.58, 0.56, 0.9]];
        } else {
            if (_equipped) then {
                _ctrlPrimaryList lbSetColor [_row, [0.94, 0.80, 0.34, 0.98]];
            };
        };
    } forEach _entries;

    private _pending = uiNamespace getVariable [_pendingNamespaceKey, createHashMap];
    private _pendingClass = if (_pending isEqualType createHashMap) then {
        if (_selectorMode isEqualTo "UNIFORM") then {
            _pending getOrDefault ["uniformClass", ""]
        } else {
            _pending getOrDefault ["weaponClass", ""]
        }
    } else {
        ""
    };
    _pendingClass = toLower _pendingClass;

    private _currentClass = _currentWeaponClass;
    private _targetClass = if !(_pendingClass isEqualTo "") then {_pendingClass} else {_currentClass};
    private _targetIndex = -1;

    for "_i" from 0 to ((count _entries) - 1) do {
        if (((_entries select _i) getOrDefault ["weaponClass", ""]) isEqualTo _targetClass) exitWith {
            _targetIndex = _i;
        };
    };

    if ((_targetIndex < 0) && {(count _entries) > 0}) then {
        _targetIndex = _entries findIf {_x getOrDefault ["available", false]};
        if (_targetIndex < 0) then {
            _targetIndex = 0;
        };
    };

    if (_targetIndex >= 0) then {
        _ctrlPrimaryList lbSetCurSel _targetIndex;
    };
};

if ((count _entries) <= 0) exitWith {
    _ctrlPrimaryDetail ctrlSetText _selectorNoEntriesText;
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _selectedIndex = lbCurSel _ctrlPrimaryList;
if (_selectedIndex < 0) then {
    _selectedIndex = 0;
    _ctrlPrimaryList lbSetCurSel _selectedIndex;
};

if (_selectedIndex >= (count _entries)) then {
    _selectedIndex = (count _entries) - 1;
};

private _selected = _entries select _selectedIndex;
private _selectedName = _selected getOrDefault ["displayName", "UNKNOWN"];
private _selectedWeaponClass = _selected getOrDefault ["weaponClass", ""];
private _selectedMagazine = _selected getOrDefault ["defaultMagazine", ""];
private _selectedMagazineName = _selected getOrDefault ["defaultMagazineName", ""];
private _selectedAvailable = _selected getOrDefault ["available", false];

if (_selectedAvailable) then {
    if (_selectorMode isEqualTo "UNIFORM") then {
        _ctrlPrimaryDetail ctrlSetText format [
            "SELECTED: %1\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST",
            _selectedName
        ];
    } else {
        if ((_selectorMode isEqualTo "LAUNCHER") && {_selectedWeaponClass isEqualTo ""}) then {
            _ctrlPrimaryDetail ctrlSetText "SELECTED: NONE\nEFFECT: CLEAR LAUNCHER SLOT\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST";
        } else {
            _ctrlPrimaryDetail ctrlSetText format [
                "SELECTED: %1\nDEFAULT MAGAZINE: %2\nAPPLY TO SUBMIT AUTHORITATIVE REQUEST",
                _selectedName,
                _selectedMagazineName
            ];
        };
    };

    if (_selectorMode isEqualTo "UNIFORM") then {
        uiNamespace setVariable [
            _pendingNamespaceKey,
            createHashMapFromArray [
                ["uniformClass", _selectedWeaponClass],
                ["uniformDisplayName", _selectedName],
                ["available", true]
            ]
        ];
    } else {
        uiNamespace setVariable [
            _pendingNamespaceKey,
            createHashMapFromArray [
                ["weaponClass", _selectedWeaponClass],
                ["weaponDisplayName", _selectedName],
                ["magazineClass", _selectedMagazine],
                ["magazineDisplayName", _selectedMagazineName],
                ["available", true]
            ]
        ];
    };

    _ctrlPrimaryApply ctrlEnable true;
} else {
    if (_selectorMode isEqualTo "UNIFORM") then {
        _ctrlPrimaryDetail ctrlSetText format [
            "SELECTED: %1\nSTATUS: UNAVAILABLE",
            _selectedName
        ];

        uiNamespace setVariable [
            _pendingNamespaceKey,
            createHashMapFromArray [
                ["uniformClass", _selectedWeaponClass],
                ["uniformDisplayName", _selectedName],
                ["available", false]
            ]
        ];
    } else {
        _ctrlPrimaryDetail ctrlSetText format [
            "SELECTED: %1\nSTATUS: UNAVAILABLE\nNO VALID DEFAULT MAGAZINE COULD BE RESOLVED",
            _selectedName
        ];

        uiNamespace setVariable [
            _pendingNamespaceKey,
            createHashMapFromArray [
                ["weaponClass", _selectedWeaponClass],
                ["weaponDisplayName", _selectedName],
                ["magazineClass", ""],
                ["magazineDisplayName", ""],
                ["available", false]
            ]
        ];
    };

    _ctrlPrimaryApply ctrlEnable false;
};

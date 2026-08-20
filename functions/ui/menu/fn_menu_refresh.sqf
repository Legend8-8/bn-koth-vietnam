/*
    File: fn_menu_refresh.sqf
    Author: Legend
    Description: Routes deployed menu pages and delegates rendering to focused builders/renderers.
    Execution: Client
    Parameters:
        0: Optional page id <STRING>
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"

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
private _ctrlHeaderPlayer = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_PLAYER;
private _ctrlHeaderLevel = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_LEVEL;
private _ctrlHeaderXp = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_XP;
private _ctrlHeaderXpTrack = _display displayCtrl BN_KOTH_IDC_MENU_BG_XP_TRACK;
private _ctrlHeaderXpFill = _display displayCtrl BN_KOTH_IDC_MENU_BG_XP_FILL;
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

private _ctrlLoadoutBgPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_PRIMARY;
private _ctrlLoadoutBgHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_HANDGUN;
private _ctrlLoadoutBgLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_LAUNCHER;
private _ctrlLoadoutBgUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_UNIFORM;
private _ctrlLoadoutBgVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_VEST;
private _ctrlLoadoutBgHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_HEADGEAR;
private _ctrlLoadoutBgBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_BACKPACK;
private _ctrlLoadoutBgEquipment = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_BG_EQUIPMENT;
private _ctrlLoadoutTextPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_PRIMARY;
private _ctrlLoadoutTextHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_HANDGUN;
private _ctrlLoadoutTextLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_LAUNCHER;
private _ctrlLoadoutTextUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_UNIFORM;
private _ctrlLoadoutTextVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_VEST;
private _ctrlLoadoutTextHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_HEADGEAR;
private _ctrlLoadoutTextBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_BACKPACK;
private _ctrlLoadoutTextEquipment = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_TEXT_EQUIPMENT;
private _ctrlLoadoutPicPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_PRIMARY;
private _ctrlLoadoutPicHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_HANDGUN;
private _ctrlLoadoutPicLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_LAUNCHER;
private _ctrlLoadoutPicUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_UNIFORM;
private _ctrlLoadoutPicVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_VEST;
private _ctrlLoadoutPicHeadgear = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_HEADGEAR;
private _ctrlLoadoutPicBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_BACKPACK;
private _ctrlLoadoutPicEquipment = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_PIC_EQUIPMENT;
private _ctrlLoadoutCogPrimary = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_PRIMARY;
private _ctrlLoadoutCogHandgun = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_HANDGUN;
private _ctrlLoadoutCogLauncher = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_LAUNCHER;
private _ctrlLoadoutCogUniform = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_UNIFORM;
private _ctrlLoadoutCogVest = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_VEST;
private _ctrlLoadoutCogBackpack = _display displayCtrl BN_KOTH_IDC_MENU_LOADOUT_COG_BACKPACK;
private _ctrlPrimaryPreview = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
private _ctrlPrimaryTitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _ctrlPrimaryCurrent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _ctrlPrimaryList = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _ctrlPrimaryDetail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _ctrlPrimaryBack = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _ctrlCargoMinus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_MINUS;
private _ctrlCargoPlus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_PLUS;
private _ctrlPrimaryApply = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;

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
private _playerNameUpper = toUpper _playerName;
_ctrlOperatorName ctrlSetText _playerNameUpper;
_ctrlHeaderPlayer ctrlSetText _playerNameUpper;

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};

private _level = (_progression getOrDefault ["level", 1]) max 1;
private _xp = (_progression getOrDefault ["xp", 0]) max 0;

private _levelProgress = [_xp, _level] call bn_koth_fnc_progression_xp_getLevelProgress;
_level = _levelProgress getOrDefault ["level", 1];
private _maxLevel = _levelProgress getOrDefault ["maxLevel", 270];
private _xpIntoLevel = _levelProgress getOrDefault ["xpIntoLevel", 0];
private _xpRequired = _levelProgress getOrDefault ["xpRequired", 0];
private _xpRatio = _levelProgress getOrDefault ["ratio", 1];

_ctrlHeaderLevel ctrlSetText format ["LEVEL %1", _level];

if (_level >= _maxLevel) then {
    _ctrlHeaderXp ctrlSetText format ["MAX LEVEL  |  %1 XP", _xp];
} else {
    _ctrlHeaderXp ctrlSetText format ["%1 / %2 XP", round _xpIntoLevel, round _xpRequired];
};

private _trackPos = ctrlPosition _ctrlHeaderXpTrack;
_ctrlHeaderXpFill ctrlSetPosition [
    _trackPos select 0,
    _trackPos select 1,
    (_trackPos select 2) * _xpRatio,
    _trackPos select 3
];
_ctrlHeaderXpFill ctrlCommit 0;

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
    _ctrlLoadoutBgPrimary,
    _ctrlLoadoutBgHandgun,
    _ctrlLoadoutBgLauncher,
    _ctrlLoadoutBgUniform,
    _ctrlLoadoutBgVest,
    _ctrlLoadoutBgHeadgear,
    _ctrlLoadoutBgBackpack,
    _ctrlLoadoutBgEquipment,
    _ctrlLoadoutTextPrimary,
    _ctrlLoadoutTextHandgun,
    _ctrlLoadoutTextLauncher,
    _ctrlLoadoutTextUniform,
    _ctrlLoadoutTextVest,
    _ctrlLoadoutTextHeadgear,
    _ctrlLoadoutTextBackpack,
    _ctrlLoadoutTextEquipment,
    _ctrlLoadoutPicPrimary,
    _ctrlLoadoutPicHandgun,
    _ctrlLoadoutPicLauncher,
    _ctrlLoadoutPicUniform,
    _ctrlLoadoutPicVest,
    _ctrlLoadoutPicHeadgear,
    _ctrlLoadoutPicBackpack,
    _ctrlLoadoutPicEquipment,
    _ctrlLoadoutCogPrimary,
    _ctrlLoadoutCogHandgun,
    _ctrlLoadoutCogLauncher,
    _ctrlLoadoutCogUniform,
    _ctrlLoadoutCogVest,
    _ctrlLoadoutCogBackpack,
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
    _ctrlCargoMinus,
    _ctrlCargoPlus,
    _ctrlPrimaryPreview,
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

if !(_activePage isEqualTo "LOADOUT_ATTACHMENTS") then {
    uiNamespace setVariable ["BN_KOTH_menuAttachmentSlotFilter", ""];
};
if !(_activePage isEqualTo "LOADOUT_CARGO") then {
    uiNamespace setVariable ["BN_KOTH_menuCargoContainerFilter", ""];
    uiNamespace setVariable ["BN_KOTH_menuCargoInitialContainer", ""];
    uiNamespace setVariable ["BN_KOTH_menuCargoInitialInKit", createHashMap];
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

private _settingsCfg = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogueClass = if (isClass _settingsCfg) then {getText (_settingsCfg >> "catalogueClass")} else {"CfgBnKothArsenal"};
if (_catalogueClass isEqualTo "") then {
    _catalogueClass = "CfgBnKothArsenal";
};
private _compatibilityCfg = missionConfigFile >> _catalogueClass >> "Equipment" >> "Compatibility";

if (_activePage isEqualTo "LOADOUT") exitWith {
    call _showMainView;
    [_display, _intendedLoadout] call bn_koth_fnc_menu_refreshLoadout;
};

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

if !(_selectorMode isEqualTo "ASSIGNED") then {
    uiNamespace setVariable ["BN_KOTH_menuAssignedStage", 1];
    uiNamespace setVariable ["BN_KOTH_menuAssignedSlot", -1];
};

call _showSelectorView;
[_display, _selectorMode, _intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_refreshSelector;

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
    "LOADOUT_BROWSER",
    "LOADOUT_CONFIGURE",
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
    "LOADOUT_KITS",
    "STORE",
    "PERKS",
    "STATS",
    "PROGRESSION"
];

private _activePage = uiNamespace getVariable ["BN_KOTH_menuActivePage", "LOADOUT"];
private _previousPage = _activePage;
if !(_requestedPage isEqualTo "") then {
    private _candidate = toUpper _requestedPage;
    if (_candidate in _validPages) then {
        _activePage = _candidate;
        uiNamespace setVariable ["BN_KOTH_menuActivePage", _activePage];
    };
};
if (_previousPage isEqualTo "STATS" && {!(_activePage isEqualTo "STATS")}) then {
    private _deferredScript = uiNamespace getVariable ["BN_KOTH_menuStatsDeferredScript", scriptNull];
    if !(scriptDone _deferredScript) then {terminate _deferredScript};
    uiNamespace setVariable ["BN_KOTH_menuStatsLifecycle", (uiNamespace getVariable ["BN_KOTH_menuStatsLifecycle", 0]) + 1];
    uiNamespace setVariable ["BN_KOTH_menuStatsDeferred", false];
    uiNamespace setVariable ["BN_KOTH_menuStatsDeferredScript", scriptNull];
    uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", -1];
};

private _ctrlServer = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_SERVER;
private _ctrlHeaderPlayer = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_PLAYER;
private _ctrlBgLeft = _display displayCtrl BN_KOTH_IDC_MENU_BG_LEFT;
private _ctrlBrowserWorkspace = _display displayCtrl BN_KOTH_IDC_MENU_BG_BROWSER_WORKSPACE;
private _ctrlOperatorTitle = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_TITLE;
private _ctrlOperatorName = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_NAME;
private _ctrlOperatorTeam = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_TEAM;
private _ctrlOperatorRoleLabel = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_ROLE_LABEL;
private _ctrlOperatorRole = _display displayCtrl BN_KOTH_IDC_MENU_OPERATOR_ROLE_VALUE;
private _ctrlPlayerPreview = _display displayCtrl BN_KOTH_IDC_MENU_PLAYER_PREVIEW;
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
private _ctrlPrimaryPreview = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
private _ctrlPrimaryTitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _ctrlPrimaryCurrent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _ctrlPrimaryList = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _ctrlPrimaryDetail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _ctrlPrimaryBack = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _ctrlCargoMinus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_MINUS;
private _ctrlCargoPlus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_PLUS;
private _ctrlPrimaryApply = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;
private _ctrlBrowserTitle = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE;
private _ctrlBrowserSubtitle = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE;
private _ctrlBrowserBack = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
private _ctrlBrowserPagePrevious = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _ctrlBrowserPageNext = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
private _ctrlBrowserPageLabel = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL;
private _ctrlConfigureMagazines = _display displayCtrl BN_KOTH_IDC_MENU_CONFIGURE_MAGAZINES;
private _ctrlConfigureAttachments = _display displayCtrl BN_KOTH_IDC_MENU_CONFIGURE_ATTACHMENTS;
private _ctrlCargoCategoryAmmunition = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_AMMUNITION;
private _ctrlCargoCategoryGrenades = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_GRENADES;
private _ctrlCargoCategorySmoke = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_SMOKE;
private _ctrlCargoCategoryMedical = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_MEDICAL;
private _ctrlCargoCategoryNavigation = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_NAVIGATION;
private _ctrlCargoCategoryEquipment = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_CATEGORY_EQUIPMENT;
private _ctrlKitName = _display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME;
private _ctrlKitSave = _display displayCtrl BN_KOTH_IDC_MENU_KIT_SAVE;
private _ctrlKitRename = _display displayCtrl BN_KOTH_IDC_MENU_KIT_RENAME;
private _ctrlKitManage = _display displayCtrl BN_KOTH_IDC_MENU_KIT_MANAGE;
private _ctrlKitSaveCurrent = _display displayCtrl BN_KOTH_IDC_MENU_KIT_SAVE_CURRENT;
private _ctrlPerksTitle = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_TITLE;
private _ctrlPerksSubtitle = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_SUBTITLE;
private _ctrlPerksActive = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_ACTIVE;
private _ctrlPerksBack = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_BACK;
private _ctrlPerksPagePrevious = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_PREVIOUS;
private _ctrlPerksPageNext = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_NEXT;
private _ctrlPerksPageLabel = _display displayCtrl BN_KOTH_IDC_MENU_PERKS_PAGE_LABEL;
private _ctrlMasteryTitle = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_TITLE;
private _ctrlMasterySubtitle = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_SUBTITLE;
private _ctrlMasteryBack = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_BACK;
private _ctrlMasteryRank = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_RANK;
private _ctrlMasteryLevel = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_LEVEL;
private _ctrlMasteryXp = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP;
private _ctrlMasteryXpTrack = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP_TRACK;
private _ctrlMasteryXpFill = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP_FILL;
private _ctrlMasteryHelp = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_HELP;
private _ctrlMasteryFilterProgress = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_FILTER_PROGRESS;
private _ctrlMasteryFilterCompleted = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_FILTER_COMPLETED;
private _ctrlMasteryFilterAll = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_FILTER_ALL;
private _ctrlMasteryEmpty = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_EMPTY;
private _ctrlMasteryPagePrevious = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_PREVIOUS;
private _ctrlMasteryPageNext = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_NEXT;
private _ctrlMasteryPageLabel = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_LABEL;

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

[_display] call bn_koth_fnc_menu_refreshProgressionHeader;

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
    "LOADOUT_BROWSER",
    "LOADOUT_CONFIGURE",
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
    "LOADOUT_KITS"
];

[_ctrlNavLoadout, _activePage in _loadoutPages] call _setNavState;
[_ctrlNavStore, _activePage isEqualTo "STORE"] call _setNavState;
[_ctrlNavPerks, _activePage isEqualTo "PERKS"] call _setNavState;
[_ctrlNavStats, _activePage isEqualTo "STATS"] call _setNavState;
[_ctrlNavProgression, _activePage isEqualTo "PROGRESSION"] call _setNavState;

private _loadoutContentControls = [
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
    _ctrlKitManage,
    _ctrlKitSaveCurrent
];

private _mainViewControls = _loadoutContentControls + [
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

private _browserViewControls = [
    _ctrlBrowserTitle,
    _ctrlBrowserSubtitle,
    _ctrlBrowserBack,
    _ctrlBrowserPagePrevious,
    _ctrlBrowserPageNext,
    _ctrlBrowserPageLabel
];

private _browserCardControls = [];

private _configureViewControls = [
    _ctrlConfigureMagazines,
    _ctrlConfigureAttachments
];

private _cargoBrowserControls = [
    _ctrlCargoCategoryAmmunition,
    _ctrlCargoCategoryGrenades,
    _ctrlCargoCategorySmoke,
    _ctrlCargoCategoryMedical,
    _ctrlCargoCategoryNavigation,
    _ctrlCargoCategoryEquipment
];

private _kitManagerControls = [_ctrlKitName, _ctrlKitSave, _ctrlKitRename];

// Store V1 deliberately reuses these fixed controls, but owns their
// visibility, geometry, text, and actions while STORE is active.
private _storeViewControls = [
    _ctrlPrimaryPreview,
    _ctrlPrimaryDetail,
    _ctrlPrimaryBack,
    _ctrlPrimaryApply,
    _ctrlBrowserTitle,
    _ctrlBrowserSubtitle,
    _ctrlBrowserBack,
    _ctrlBrowserPagePrevious,
    _ctrlBrowserPageNext,
    _ctrlBrowserPageLabel
];

private _perkViewControls = [
    _ctrlPerksTitle,
    _ctrlPerksSubtitle,
    _ctrlPerksActive,
    _ctrlPerksBack,
    _ctrlPerksPagePrevious,
    _ctrlPerksPageNext,
    _ctrlPerksPageLabel
];
{
    _perkViewControls append [
        _display displayCtrl _x,
        _display displayCtrl (_x + 1),
        _display displayCtrl (_x + 2),
        _display displayCtrl (_x + 3),
        _display displayCtrl (_x + 4),
        _display displayCtrl (_x + 5)
    ];
} forEach [
    BN_KOTH_IDC_MENU_PERKS_CARD_1_BG,
    BN_KOTH_IDC_MENU_PERKS_CARD_2_BG,
    BN_KOTH_IDC_MENU_PERKS_CARD_3_BG,
    BN_KOTH_IDC_MENU_PERKS_CARD_4_BG
];

// Every route begins with PERKS' independently owned pool hidden. The PERKS
// view is the only owner that may reveal or mutate these controls.
{_x ctrlShow false} forEach _perkViewControls;

private _masteryViewControls = [
    _ctrlMasteryTitle,
    _ctrlMasterySubtitle,
    _ctrlMasteryBack,
    _ctrlMasteryRank,
    _ctrlMasteryLevel,
    _ctrlMasteryXp,
    _ctrlMasteryXpTrack,
    _ctrlMasteryXpFill,
    _ctrlMasteryHelp,
    _ctrlMasteryFilterProgress,
    _ctrlMasteryFilterCompleted,
    _ctrlMasteryFilterAll,
    _ctrlMasteryEmpty,
    _ctrlMasteryPagePrevious,
    _ctrlMasteryPageNext,
    _ctrlMasteryPageLabel
];
{
    _masteryViewControls append [
        _display displayCtrl _x,
        _display displayCtrl (_x + 1),
        _display displayCtrl (_x + 2),
        _display displayCtrl (_x + 3),
        _display displayCtrl (_x + 4),
        _display displayCtrl (_x + 5),
        _display displayCtrl (_x + 6)
    ];
} forEach [
    BN_KOTH_IDC_MENU_MASTERY_CARD_1_BG,
    BN_KOTH_IDC_MENU_MASTERY_CARD_2_BG,
    BN_KOTH_IDC_MENU_MASTERY_CARD_3_BG,
    BN_KOTH_IDC_MENU_MASTERY_CARD_4_BG
];
{_x ctrlShow false} forEach _masteryViewControls;

private _statsViewControls = [];
{_statsViewControls pushBack (_display displayCtrl _x)} forEach [
    BN_KOTH_IDC_MENU_STATS_TITLE, BN_KOTH_IDC_MENU_STATS_SUBTITLE, BN_KOTH_IDC_MENU_STATS_BACK,
    BN_KOTH_IDC_MENU_STATS_CAREER_BG, BN_KOTH_IDC_MENU_STATS_CAREER_TITLE, BN_KOTH_IDC_MENU_STATS_RANK,
    BN_KOTH_IDC_MENU_STATS_LEVEL, BN_KOTH_IDC_MENU_STATS_XP, BN_KOTH_IDC_MENU_STATS_CASH, BN_KOTH_IDC_MENU_STATS_CAREER_STATE,
    BN_KOTH_IDC_MENU_STATS_TILE_1, BN_KOTH_IDC_MENU_STATS_TILE_2, BN_KOTH_IDC_MENU_STATS_TILE_3,
    BN_KOTH_IDC_MENU_STATS_TILE_4, BN_KOTH_IDC_MENU_STATS_TILE_5, BN_KOTH_IDC_MENU_STATS_TILE_6,
    BN_KOTH_IDC_MENU_STATS_TILE_7, BN_KOTH_IDC_MENU_STATS_TILE_8, BN_KOTH_IDC_MENU_STATS_TILE_9,
    BN_KOTH_IDC_MENU_STATS_LEADER_BG, BN_KOTH_IDC_MENU_STATS_LEADER_TITLE,
    BN_KOTH_IDC_MENU_STATS_PERIOD_24H, BN_KOTH_IDC_MENU_STATS_PERIOD_7D, BN_KOTH_IDC_MENU_STATS_PERIOD_30D, BN_KOTH_IDC_MENU_STATS_PERIOD_ALL,
    BN_KOTH_IDC_MENU_STATS_MODE_TOP, BN_KOTH_IDC_MENU_STATS_MODE_AROUND, BN_KOTH_IDC_MENU_STATS_TABLE_HEADER,
    BN_KOTH_IDC_MENU_STATS_ROW_1, BN_KOTH_IDC_MENU_STATS_ROW_2, BN_KOTH_IDC_MENU_STATS_ROW_3,
    BN_KOTH_IDC_MENU_STATS_ROW_4, BN_KOTH_IDC_MENU_STATS_ROW_5, BN_KOTH_IDC_MENU_STATS_ROW_6,
    BN_KOTH_IDC_MENU_STATS_ROW_7, BN_KOTH_IDC_MENU_STATS_ROW_8, BN_KOTH_IDC_MENU_STATS_ROW_9,
    BN_KOTH_IDC_MENU_STATS_ROW_10, BN_KOTH_IDC_MENU_STATS_LEADER_STATE, BN_KOTH_IDC_MENU_STATS_POSITION
];
{_x ctrlShow false} forEach _statsViewControls;

private _operatorControls = [
    _ctrlBgLeft,
    _ctrlOperatorTitle,
    _ctrlOperatorName,
    _ctrlOperatorTeam,
    _ctrlOperatorRoleLabel,
    _ctrlOperatorRole,
    _ctrlPlayerPreview
];

private _setDefaultWorkspaceGeometry = {
    private _menuX = safeZoneX + safeZoneW * 0.02;
    private _menuY = safeZoneY + safeZoneH * 0.03;
    private _menuW = safeZoneW * 0.96;
    private _menuH = safeZoneH * 0.94;
    private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
    private _mainH = _menuH * 0.78;
    private _bottomY = _mainY + _mainH + safeZoneH * 0.012;
    private _bottomH = _menuY + _menuH - _bottomY;
    private _gap = safeZoneW * 0.01;
    private _leftW = _menuW * 0.34;
    private _centerW = _menuW * 0.28;
    private _centerX = _menuX + _leftW + _gap;
    private _browserX = _menuX + _leftW + _gap;
    private _browserW = _menuW - _leftW - _gap;

    _ctrlBrowserWorkspace ctrlSetPosition [_browserX, _mainY, _browserW, _mainH];
    _ctrlBrowserTitle ctrlSetPosition [_browserX + safeZoneW * 0.014, _mainY + safeZoneH * 0.016, _browserW * 0.40, safeZoneH * 0.035];
    _ctrlBrowserSubtitle ctrlSetPosition [_browserX + safeZoneW * 0.014, _mainY + safeZoneH * 0.052, _browserW * 0.40, safeZoneH * 0.024];
    _ctrlBrowserBack ctrlSetPosition [_menuX + _menuW - safeZoneW * 0.132, _bottomY + safeZoneH * 0.014, safeZoneW * 0.12, _bottomH - safeZoneH * 0.028];
    _ctrlPrimaryPreview ctrlSetPosition [_menuX + _leftW * 0.08, _mainY + safeZoneH * 0.215, _leftW * 0.84, safeZoneH * 0.30];
    _ctrlPrimaryDetail ctrlSetPosition [_centerX + safeZoneW * 0.012, _mainY + safeZoneH * 0.404, _centerW * 0.92, safeZoneH * 0.085];
    _ctrlPrimaryBack ctrlSetPosition [_menuX + _menuW - safeZoneW * 0.132, _bottomY + safeZoneH * 0.014, safeZoneW * 0.12, _bottomH - safeZoneH * 0.028];
    _ctrlPrimaryApply ctrlSetPosition [_centerX + _centerW * 0.48, _mainY + _mainH - safeZoneH * 0.095, _centerW * 0.44, safeZoneH * 0.04];
    _ctrlBrowserPagePrevious ctrlSetPosition [_browserX + _browserW * 0.38, _mainY + _mainH - safeZoneH * 0.060, safeZoneW * 0.038, safeZoneH * 0.034];
    _ctrlBrowserPageNext ctrlSetPosition [_browserX + _browserW * 0.58, _mainY + _mainH - safeZoneH * 0.060, safeZoneW * 0.038, safeZoneH * 0.034];
    _ctrlBrowserPageLabel ctrlSetPosition [_browserX + _browserW * 0.43, _mainY + _mainH - safeZoneH * 0.056, _browserW * 0.15, safeZoneH * 0.028];
    {
        _x ctrlCommit 0;
    } forEach [
        _ctrlBrowserWorkspace,
        _ctrlBrowserTitle,
        _ctrlBrowserSubtitle,
        _ctrlBrowserBack,
        _ctrlPrimaryPreview,
        _ctrlPrimaryDetail,
        _ctrlPrimaryBack,
        _ctrlPrimaryApply,
        _ctrlBrowserPagePrevious,
        _ctrlBrowserPageNext,
        _ctrlBrowserPageLabel
    ];

    _ctrlBrowserBack buttonSetAction "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
    _ctrlPrimaryBack buttonSetAction "if (((uiNamespace getVariable ['BN_KOTH_menuActivePage', '']) isEqualTo 'LOADOUT_EQUIPMENT') && {(uiNamespace getVariable ['BN_KOTH_menuAssignedStage', 1]) isEqualTo 2}) then {uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', -1]; ['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;} else {['LOADOUT'] call bn_koth_fnc_menu_refresh;};";
    _ctrlPrimaryApply buttonSetAction "[] call bn_koth_fnc_menu_applyPrimary;";
    _ctrlBrowserPagePrevious buttonSetAction "";
    _ctrlBrowserPageNext buttonSetAction "";

    [_display, _browserX + safeZoneW * 0.010, _mainY + safeZoneH * 0.105, _browserW - safeZoneW * 0.020, _mainH - safeZoneH * 0.170] call bn_koth_fnc_menu_layoutItemCards;
};

{
    _browserCardControls append [
        _display displayCtrl _x,
        _display displayCtrl (_x + 1),
        _display displayCtrl (_x + 2),
        _display displayCtrl (_x + 3),
        _display displayCtrl (_x + 4),
        _display displayCtrl (_x + 5),
        _display displayCtrl (_x + 6),
        _display displayCtrl (_x + 7),
        _display displayCtrl (_x + 8)
    ];
} forEach [
    BN_KOTH_IDC_MENU_BROWSER_CARD_1_BG,
    BN_KOTH_IDC_MENU_BROWSER_CARD_2_BG,
    BN_KOTH_IDC_MENU_BROWSER_CARD_3_BG,
    BN_KOTH_IDC_MENU_BROWSER_CARD_4_BG
];

private _navControls = [
    _ctrlNavLoadout,
    _ctrlNavStore,
    _ctrlNavPerks,
    _ctrlNavStats,
    _ctrlNavProgression
];

private _showMainView = {
    call _setDefaultWorkspaceGeometry;
    {_x ctrlShow true} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow false;
    { _x ctrlShow true; } forEach _mainViewControls;
    { _x ctrlShow false; } forEach _selectorViewControls;
    { _x ctrlShow false; } forEach _browserViewControls;
    { _x ctrlShow false; } forEach _browserCardControls;
    { _x ctrlShow false; } forEach _configureViewControls;
    { _x ctrlShow false; } forEach _cargoBrowserControls;
    { _x ctrlShow false; } forEach _kitManagerControls;
    { _x ctrlShow true; } forEach _navControls;
};

private _showSelectorView = {
    call _setDefaultWorkspaceGeometry;
    {_x ctrlShow true} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow false;
    { _x ctrlShow false; } forEach _mainViewControls;
    { _x ctrlShow true; } forEach _selectorViewControls;
    { _x ctrlShow false; } forEach _browserViewControls;
    { _x ctrlShow false; } forEach _browserCardControls;
    { _x ctrlShow false; } forEach _configureViewControls;
    { _x ctrlShow false; } forEach _cargoBrowserControls;
    { _x ctrlShow false; } forEach _kitManagerControls;
    { _x ctrlShow true; } forEach _navControls;
};

private _showBrowserView = {
    call _setDefaultWorkspaceGeometry;
    {_x ctrlShow true} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow true;
    { _x ctrlShow false; } forEach _mainViewControls;
    { _x ctrlShow false; } forEach _selectorViewControls;
    { _x ctrlShow true; } forEach _browserViewControls;
    { _x ctrlShow false; } forEach _browserCardControls;
    { _x ctrlShow false; } forEach _configureViewControls;
    { _x ctrlShow false; } forEach _cargoBrowserControls;
    { _x ctrlShow false; } forEach _kitManagerControls;
    { _x ctrlShow false; } forEach _navControls;
};

private _showConfigureView = {
    call _showBrowserView;
    { _x ctrlShow true; } forEach _configureViewControls;
};

private _showComingSoon = {
    params ["_pageName"];
    call _showMainView;
    { _x ctrlShow false; } forEach _loadoutContentControls;

    _ctrlSectionTitle ctrlSetText _pageName;
    _ctrlNotice ctrlSetText "FEATURE COMING SOON";
    _ctrlFooter ctrlSetText "This section is planned but not implemented in this slice.";

};

private _showStoreView = {
    private _menuX = safeZoneX + safeZoneW * 0.02;
    private _menuY = safeZoneY + safeZoneH * 0.03;
    private _menuW = safeZoneW * 0.96;
    private _menuH = safeZoneH * 0.94;
    private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
    private _mainH = _menuH * 0.78;
    _ctrlBrowserWorkspace ctrlSetPosition [_menuX, _mainY, _menuW, _mainH];
    _ctrlBrowserWorkspace ctrlCommit 0;
    {_x ctrlShow false} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow true;
    { _x ctrlShow false; } forEach _mainViewControls;
    { _x ctrlShow false; } forEach _selectorViewControls;
    { _x ctrlShow false; } forEach _browserViewControls;
    { _x ctrlShow false; } forEach _browserCardControls;
    { _x ctrlShow false; } forEach _configureViewControls;
    { _x ctrlShow false; } forEach _cargoBrowserControls;
    { _x ctrlShow false; } forEach _kitManagerControls;
    { _x ctrlShow false; } forEach _navControls;
    { _x ctrlShow true; } forEach _storeViewControls;
};

private _showPerksView = {
    private _menuX = safeZoneX + safeZoneW * 0.02;
    private _menuY = safeZoneY + safeZoneH * 0.03;
    private _menuW = safeZoneW * 0.96;
    private _menuH = safeZoneH * 0.94;
    private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
    private _mainH = _menuH * 0.78;
    _ctrlBrowserWorkspace ctrlSetPosition [_menuX, _mainY, _menuW, _mainH];
    _ctrlBrowserWorkspace ctrlCommit 0;
    {_x ctrlShow false} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow true;
    {_x ctrlShow false} forEach _mainViewControls;
    {_x ctrlShow false} forEach _selectorViewControls;
    {_x ctrlShow false} forEach _browserViewControls;
    {_x ctrlShow false} forEach _browserCardControls;
    {_x ctrlShow false} forEach _configureViewControls;
    {_x ctrlShow false} forEach _cargoBrowserControls;
    {_x ctrlShow false} forEach _kitManagerControls;
    {_x ctrlShow false} forEach _navControls;
    {_x ctrlShow false} forEach _storeViewControls;
    {_x ctrlShow true} forEach _perkViewControls;
};

private _showProgressionView = {
    private _menuX = safeZoneX + safeZoneW * 0.02;
    private _menuY = safeZoneY + safeZoneH * 0.03;
    private _menuW = safeZoneW * 0.96;
    private _menuH = safeZoneH * 0.94;
    private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
    private _mainH = _menuH * 0.78;
    private _bottomY = _mainY + _mainH + safeZoneH * 0.012;
    private _bottomH = _menuY + _menuH - _bottomY;
    _ctrlBrowserWorkspace ctrlSetPosition [_menuX, _mainY, _menuW, _mainH];
    _ctrlBrowserWorkspace ctrlCommit 0;
    {_x ctrlShow false} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow true;
    {_x ctrlShow false} forEach _mainViewControls;
    {_x ctrlShow false} forEach _selectorViewControls;
    {_x ctrlShow false} forEach _browserViewControls;
    {_x ctrlShow false} forEach _browserCardControls;
    {_x ctrlShow false} forEach _configureViewControls;
    {_x ctrlShow false} forEach _cargoBrowserControls;
    {_x ctrlShow false} forEach _kitManagerControls;
    {_x ctrlShow false} forEach _navControls;
    {_x ctrlShow false} forEach _storeViewControls;
    {_x ctrlShow false} forEach _perkViewControls;
    {_x ctrlShow true} forEach _masteryViewControls;
};

private _showStatsView = {
    private _menuX = safeZoneX + safeZoneW * 0.02;
    private _menuY = safeZoneY + safeZoneH * 0.03;
    private _menuW = safeZoneW * 0.96;
    private _menuH = safeZoneH * 0.94;
    private _mainY = _menuY + (_menuH * 0.095) + safeZoneH * 0.012;
    private _mainH = _menuH * 0.78;
    _ctrlBrowserWorkspace ctrlSetPosition [_menuX, _mainY, _menuW, _mainH];
    _ctrlBrowserWorkspace ctrlCommit 0;
    {_x ctrlShow false} forEach _operatorControls;
    _ctrlBrowserWorkspace ctrlShow true;
    {_x ctrlShow false} forEach _mainViewControls;
    {_x ctrlShow false} forEach _selectorViewControls;
    {_x ctrlShow false} forEach _browserViewControls;
    {_x ctrlShow false} forEach _browserCardControls;
    {_x ctrlShow false} forEach _configureViewControls;
    {_x ctrlShow false} forEach _cargoBrowserControls;
    {_x ctrlShow false} forEach _kitManagerControls;
    {_x ctrlShow false} forEach _navControls;
    {_x ctrlShow false} forEach _storeViewControls;
    {_x ctrlShow false} forEach _perkViewControls;
    {_x ctrlShow false} forEach _masteryViewControls;
    {_x ctrlShow true} forEach _statsViewControls;
};

if !(_activePage isEqualTo "LOADOUT_ATTACHMENTS") then {
    uiNamespace setVariable ["BN_KOTH_menuAttachmentSlotFilter", ""];
};
if !(_activePage isEqualTo "LOADOUT_CARGO") then {
    uiNamespace setVariable ["BN_KOTH_menuCargoContainerFilter", ""];
    uiNamespace setVariable ["BN_KOTH_menuCargoInitialContainer", ""];
    uiNamespace setVariable ["BN_KOTH_menuCargoInitialInKit", createHashMap];
    if !(_activePage isEqualTo "LOADOUT_BROWSER") then {
        uiNamespace setVariable ["BN_KOTH_menuSelectorReturnPage", "LOADOUT"];
    };
};

private _showKitManagerView = {
    call _showBrowserView;
    { _x ctrlShow true; } forEach _kitManagerControls;
};

private _showCargoBrowserView = {
    call _showBrowserView;
    { _x ctrlShow true; } forEach _cargoBrowserControls;
};

if (_activePage isEqualTo "STORE") exitWith {
    call _showStoreView;
    [_display] call bn_koth_fnc_menu_refreshStore;
};

if (_activePage isEqualTo "PERKS") exitWith {
    call _showPerksView;
    [_display] call bn_koth_fnc_menu_refreshPerks;
};

if (_activePage isEqualTo "PROGRESSION") exitWith {
    if !(_previousPage isEqualTo "PROGRESSION") then {
        uiNamespace setVariable ["BN_KOTH_menuMasteryFilter", "IN_PROGRESS"];
        uiNamespace setVariable ["BN_KOTH_menuMasteryPage", 0];
    };
    call _showProgressionView;
    [_display] call bn_koth_fnc_menu_refreshProgression;
};

if (_activePage isEqualTo "STATS") exitWith {
    if !(_previousPage isEqualTo "STATS") then {
        uiNamespace setVariable ["BN_KOTH_menuStatsLifecycle", (uiNamespace getVariable ["BN_KOTH_menuStatsLifecycle", 0]) + 1];
        uiNamespace setVariable ["BN_KOTH_menuStatsDeferred", false];
        uiNamespace setVariable ["BN_KOTH_menuStatsLastRequest", -100];
        uiNamespace setVariable ["BN_KOTH_menuStatsLatestRequestId", -1];
        uiNamespace setVariable ["BN_KOTH_menuStatsMetric", 1];
        uiNamespace setVariable ["BN_KOTH_menuStatsPeriod", 0];
        uiNamespace setVariable ["BN_KOTH_menuStatsMode", "TOP"];
        uiNamespace setVariable ["BN_KOTH_menuStatsResponse", createHashMap];
        uiNamespace setVariable ["BN_KOTH_menuStatsLoading", true];
    };
    call _showStatsView;
    [_display] call bn_koth_fnc_menu_refreshStats;
    if !(_previousPage isEqualTo "STATS") then {[] call bn_koth_fnc_menu_requestStats};
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

if (_activePage isEqualTo "LOADOUT_BROWSER") exitWith {
    call _showBrowserView;
    [_display] call bn_koth_fnc_menu_refreshBrowser;
};

if (_activePage isEqualTo "LOADOUT_CONFIGURE") exitWith {
    call _showConfigureView;
    [_display] call bn_koth_fnc_menu_refreshConfigure;
};

if (_activePage isEqualTo "LOADOUT_CARGO") exitWith {
    call _showCargoBrowserView;
    [_display, _intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_refreshCargoBrowser;
};

if (_activePage isEqualTo "LOADOUT_KITS") exitWith {
    call _showKitManagerView;
    [_display] call bn_koth_fnc_menu_refreshSessionKits;
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

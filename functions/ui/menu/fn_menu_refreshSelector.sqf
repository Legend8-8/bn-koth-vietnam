/*
    File: fn_menu_refreshSelector.sqf
    Author: Legend
    Description: Renders selector pages, including list/detail and pending request payload state.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Selector mode <STRING>
        2: Intended loadout snapshot <ARRAY>
        3: Compatibility config root <CONFIG>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [
    ["_display", displayNull, [displayNull]],
    ["_selectorMode", "PRIMARY", [""]],
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]]
];

if (isNull _display) exitWith {};

disableSerialization;

private _ctrlPrimaryPreview = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
private _ctrlPrimaryTitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _ctrlPrimaryCurrent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _ctrlPrimaryList = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _ctrlPrimaryDetail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _ctrlPrimaryApply = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;
private _ctrlPrimaryBack = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;
private _ctrlLeftBackground = _display displayCtrl BN_KOTH_IDC_MENU_BG_LEFT;
private _ctrlCenterBackground = _display displayCtrl BN_KOTH_IDC_MENU_BG_CENTER;

// Store V1 reuses this fixed control pool in wide mode. The selector renderer
// restores its complete narrow/left-column geometry before owning the pool.
private _leftPosition = ctrlPosition _ctrlLeftBackground;
private _centerPosition = ctrlPosition _ctrlCenterBackground;
private _leftX = _leftPosition select 0;
private _leftW = _leftPosition select 2;
private _centerX = _centerPosition select 0;
private _centerY = _centerPosition select 1;
private _centerW = _centerPosition select 2;
private _centerH = _centerPosition select 3;

_ctrlPrimaryPreview ctrlSetPosition [_leftX + _leftW * 0.08, _centerY + safeZoneH * 0.215, _leftW * 0.84, safeZoneH * 0.30];
_ctrlPrimaryTitle ctrlSetPosition [_centerX + safeZoneW * 0.012, _centerY + safeZoneH * 0.016, _centerW * 0.90, safeZoneH * 0.04];
_ctrlPrimaryCurrent ctrlSetPosition [_centerX + safeZoneW * 0.012, _centerY + safeZoneH * 0.054, _centerW * 0.92, safeZoneH * 0.03];
_ctrlPrimaryList ctrlSetPosition [_centerX + safeZoneW * 0.012, _centerY + safeZoneH * 0.092, _centerW * 0.92, safeZoneH * 0.30];
_ctrlPrimaryDetail ctrlSetPosition [_centerX + safeZoneW * 0.012, _centerY + safeZoneH * 0.404, _centerW * 0.92, safeZoneH * 0.085];
private _menuX = safeZoneX + safeZoneW * 0.02;
private _menuY = safeZoneY + safeZoneH * 0.03;
private _menuW = safeZoneW * 0.96;
private _menuH = safeZoneH * 0.94;
private _bottomY = _centerY + _centerH + safeZoneH * 0.012;
private _bottomH = _menuY + _menuH - _bottomY;
_ctrlPrimaryBack ctrlSetPosition [_menuX + _menuW - safeZoneW * 0.132, _bottomY + safeZoneH * 0.014, safeZoneW * 0.12, _bottomH - safeZoneH * 0.028];
_ctrlPrimaryApply ctrlSetPosition [_centerX + _centerW * 0.48, _centerY + _centerH - safeZoneH * 0.095, _centerW * 0.44, safeZoneH * 0.04];
{
    _x ctrlCommit 0;
} forEach [_ctrlPrimaryPreview, _ctrlPrimaryTitle, _ctrlPrimaryCurrent, _ctrlPrimaryList, _ctrlPrimaryDetail, _ctrlPrimaryBack, _ctrlPrimaryApply];

private _ctrlCargoMinus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_MINUS;
private _ctrlCargoPlus = _display displayCtrl BN_KOTH_IDC_MENU_CARGO_PLUS;

// This function owns PrimaryList selection behaviour. Suppress selection
// callbacks while rows are rebuilt or selected programmatically.
_ctrlPrimaryList ctrlSetEventHandler ["LBSelChanged", ""];

private _resolveEntryPicture = {
    params ["_entry"];

    if !(_entry isEqualType createHashMap) exitWith {""};

    private _className = "";
    {
        if (_className isEqualTo "") then {
            private _candidate = _entry getOrDefault [_x, ""];
            if (_candidate isEqualType "" && {!(_candidate isEqualTo "")}) then {
                _className = toLower _candidate;
            };
        };
    } forEach [
        "weaponClass",
        "binocularClass",
        "itemClass",
        "attachmentClass",
        "className"
    ];

    if (_className isEqualTo "") exitWith {""};

    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgMagazines" >> _className;
    };
    if !(isClass _cfg) exitWith {""};

    getText (_cfg >> "picture")
};

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

private _assignedStage = if (_selectorMode isEqualTo "ASSIGNED") then {
    uiNamespace getVariable ["BN_KOTH_menuAssignedStage", 1]
} else {
    1
};

private _assignedSlotIndex = if (_selectorMode isEqualTo "ASSIGNED") then {
    uiNamespace getVariable ["BN_KOTH_menuAssignedSlot", -1]
} else {
    -1
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
private _isCargoMode = _selectorMode isEqualTo "CARGO";
_ctrlCargoMinus ctrlShow _isCargoMode;
_ctrlCargoPlus ctrlShow _isCargoMode;
_ctrlPrimaryApply ctrlShow (!_isCargoMode);

if (_isCargoMode) then {
    private _applyPos = ctrlPosition _ctrlPrimaryApply;

    // Intentional visual rhythm:
    // -  [gap]  +
    private _cargoGap = safeZoneW * 0.004;
    private _cargoStartX = _applyPos select 0;
    private _buttonWidth = (((_applyPos select 2) - _cargoGap) / 2) max 0;

    _ctrlCargoMinus ctrlSetPosition [
        _cargoStartX,
        _applyPos select 1,
        _buttonWidth,
        _applyPos select 3
    ];
    _ctrlCargoMinus ctrlCommit 0;

    _ctrlCargoPlus ctrlSetPosition [
        _cargoStartX + _buttonWidth + _cargoGap,
        _applyPos select 1,
        _buttonWidth,
        _applyPos select 3
    ];
    _ctrlCargoPlus ctrlCommit 0;
};
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
        case "ASSIGNED": {
            if (_assignedStage isEqualTo 1) then {
                "false"
            } else {
                "[] call bn_koth_fnc_menu_applyAssigned;"
            }
        };
        case "ATTACHMENT": {"[] call bn_koth_fnc_menu_applyAttachment;"};
        case "CARGO": {"[] call bn_koth_fnc_menu_applyCargo;"};
        default {"[] call bn_koth_fnc_menu_applyPrimary;"};
    }
];

private _backText = switch (_selectorMode) do {
    case "ASSIGNED": {
        if (_assignedStage isEqualTo 2) then {"BACK TO SLOTS"} else {"BACK"};
    };
    default {"BACK"};
};

_ctrlPrimaryBack ctrlSetText _backText;
private _backAction = if (_selectorMode isEqualTo "ASSIGNED" && {_assignedStage isEqualTo 2}) then {
    "uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 1]; uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', -1]; ['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;"
} else {
    if (
        (_selectorMode isEqualTo "CARGO") &&
        {(uiNamespace getVariable ["BN_KOTH_menuSelectorReturnPage", "LOADOUT"]) isEqualTo "LOADOUT_BROWSER"}
    ) then {
        "uiNamespace setVariable ['BN_KOTH_menuBrowserSlot', 'uniform']; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;"
    } else {
        "['LOADOUT'] call bn_koth_fnc_menu_refresh;"
    }
};
_ctrlPrimaryBack buttonSetAction _backAction;


if (isNull player) exitWith {
    _ctrlPrimaryPreview ctrlSetText "";
    lbClear _ctrlPrimaryList;
    _ctrlPrimaryDetail ctrlSetText "NO PLAYER CONTEXT";
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _entries = switch (_selectorMode) do {
    case "ASSIGNED": {[_intendedLoadout, _compatibilityCfg, _assignedStage, _assignedSlotIndex] call bn_koth_fnc_menu_buildAssignedEntries};
    case "ATTACHMENT": {[_intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_buildAttachmentEntries};
    case "CARGO": {[_intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_buildCargoEntries};
    case "UNIFORM";
    case "VEST";
    case "BACKPACK";
    case "HEADGEAR";
    case "FACEWEAR";
    case "BINOCULAR": {[_selectorMode, _intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_buildWearableEntries};
    default {[_selectorMode, _intendedLoadout, _compatibilityCfg] call bn_koth_fnc_menu_buildWeaponEntries};
};

uiNamespace setVariable [_entriesNamespaceKey, _entries];

lbClear _ctrlPrimaryList;
{
    private _label = _x getOrDefault ["displayName", "UNKNOWN"];
    if (_x getOrDefault ["equipped", false]) then {
        _label = format ["[EQUIPPED] %1", _label];
    };
    if !(_x getOrDefault ["available", false]) then {
        private _technicalAvailable = _x getOrDefault ["technicalAvailable", true];
        private _entitlementCode = _x getOrDefault ["entitlementCode", ""];

        if (!_technicalAvailable) then {
            _label = format ["%1 [UNAVAILABLE]", _label];
        } else {
            private _lockSuffix = switch (_entitlementCode) do {
                case "LOCKED_LEVEL": {
                    format ["LVL %1", _x getOrDefault ["minLevel", 1]]
                };
                case "LOCKED_MASTERY": {
                    format [
                        "%1/%2 KILLS",
                        _x getOrDefault ["weaponKills", 0],
                        _x getOrDefault ["masteryKillsRequired", 0]
                    ]
                };
                case "LOCKED_PERK": {"PERK"};
                case "REQUIRES_ACQUISITION": {"OWNERSHIP"};
                default {"LOCKED"};
            };

            _label = format ["%1 [%2]", _label, _lockSuffix];
        };
    };

    private _row = _ctrlPrimaryList lbAdd _label;
    private _picture = [_x] call _resolveEntryPicture;
    if !(_picture isEqualTo "") then {
        _ctrlPrimaryList lbSetPicture [_row, _picture];
    };
    _ctrlPrimaryList lbSetData [_row, str _x];
    _ctrlPrimaryList lbSetValue [_row, if (_x getOrDefault ["available", false]) then {1} else {0}];

    if !(_x getOrDefault ["available", false]) then {
        _ctrlPrimaryList lbSetColor [_row, [0.58, 0.58, 0.56, 0.9]];
    };
} forEach _entries;

if ((count _entries) <= 0) exitWith {
    _ctrlPrimaryPreview ctrlSetText "";
    _ctrlPrimaryDetail ctrlSetText _selectorNoEntriesText;
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
};

private _selectedIndex = lbCurSel _ctrlPrimaryList;

// Assigned equipment stage 1 is a pure slot picker. Never infer intent from a
// row that happens to remain selected while the list is rebuilt. Clear the
// selection with callbacks suppressed, then arm one explicit user-selection
// handler that advances to stage 2.
if (
    (_selectorMode isEqualTo "ASSIGNED") &&
    {_assignedStage isEqualTo 1}
) exitWith {
    _ctrlPrimaryPreview ctrlSetText "";
    _ctrlPrimaryList lbSetCurSel -1;
    _ctrlPrimaryDetail ctrlSetText "SELECT AN ASSIGNED-EQUIPMENT SLOT";
    _ctrlPrimaryApply ctrlEnable false;
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];

    _ctrlPrimaryList ctrlSetEventHandler [
        "LBSelChanged",
        "
            params ['_control', '_selectedIndex'];

            if (
                ((uiNamespace getVariable ['BN_KOTH_menuActivePage', '']) isEqualTo 'LOADOUT_EQUIPMENT') &&
                {(uiNamespace getVariable ['BN_KOTH_menuAssignedStage', 1]) isEqualTo 1}
            ) then {
                private _entries = uiNamespace getVariable ['BN_KOTH_menuAssignedEntries', []];

                if (
                    (_selectedIndex >= 0) &&
                    {_selectedIndex < (count _entries)}
                ) then {
                    private _selected = _entries select _selectedIndex;
                    private _targetPage = _selected getOrDefault ['targetPage', ''];

                    if !(_targetPage isEqualTo '') then {
                        private _browserSlot = switch (_targetPage) do {
                            case 'LOADOUT_FACEWEAR': {'facewear'};
                            case 'LOADOUT_BINOCULAR': {'binocular'};
                            default {''};
                        };
                        if !(_browserSlot isEqualTo '') then {
                            uiNamespace setVariable ['BN_KOTH_menuBrowserSlot', _browserSlot];
                            uiNamespace setVariable ['BN_KOTH_menuBrowserSnapPending', true];
                            ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;
                        } else {
                            [_targetPage] call bn_koth_fnc_menu_refresh;
                        };
                    } else {
                        private _nextSlot = _selected getOrDefault ['assignedIndex', -1];

                        if (_nextSlot in [0, 1, 2, 3, 4, 5]) then {
                        uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 2];
                        uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', _nextSlot];
                        uiNamespace setVariable ['BN_KOTH_menuPendingAssigned', createHashMapFromArray [['available', false]]];
                            ['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;
                        };
                    };
                };
            };
        "
    ];
};

if ((_selectedIndex < 0) || {_selectedIndex >= (count _entries)}) then {
    _selectedIndex = 0;
    _ctrlPrimaryList lbSetCurSel _selectedIndex;
};

private _selected = _entries select _selectedIndex;
private _selectedName = _selected getOrDefault ["displayName", "UNKNOWN"];
private _selectedAvailable = _selected getOrDefault ["available", false];

private _selectedPicture = [_selected] call _resolveEntryPicture;
_ctrlPrimaryPreview ctrlSetText _selectedPicture;

if (_selectedAvailable) then {
    private _enableApply = true;
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
            _ctrlPrimaryApply ctrlEnable true;
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
            private _currentCount = (_selected getOrDefault ["currentCount", 0]) max 0;
            private _priorityReason = _selected getOrDefault ["priorityReason", "AVAILABLE"];
            _ctrlPrimaryDetail ctrlSetText format [
                "SELECTED: %1\nCURRENT: x%2\n%3\nUSE - / + TO ADJUST",
                _selectedName,
                _currentCount,
                _priorityReason
            ];
            uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [
                ["container", _selected getOrDefault ["container", ""]],
                ["className", _selected getOrDefault ["className", ""]],
                ["currentCount", _currentCount],
                ["delta", 0],
                ["available", true]
            ]];
            _ctrlCargoMinus ctrlEnable (_currentCount > 0);
            _ctrlCargoPlus ctrlEnable (_selected getOrDefault ["canAdd", true]);
            _enableApply = false;
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

    if (_enableApply) then {
        _ctrlPrimaryApply ctrlEnable true;
    };
} else {
    private _technicalAvailable = _selected getOrDefault ["technicalAvailable", true];
    private _entitlementMessage = _selected getOrDefault ["entitlementMessage", ""];
    private _entitlementCode = _selected getOrDefault ["entitlementCode", ""];

    if (!_technicalAvailable) then {
        _ctrlPrimaryDetail ctrlSetText format [
            "SELECTED: %1\nSTATUS: UNAVAILABLE\nNO COMPATIBLE DEFAULT MAGAZINE",
            _selectedName
        ];
    } else {
        private _extraLine = switch (_entitlementCode) do {
            case "LOCKED_LEVEL": {
                format [
                    "LEVEL %1 / %2",
                    _selected getOrDefault ["playerLevel", 1],
                    _selected getOrDefault ["minLevel", 1]
                ]
            };
            case "LOCKED_MASTERY": {
                format [
                    "MASTERY %1 / %2",
                    _selected getOrDefault ["weaponKills", 0],
                    _selected getOrDefault ["masteryKillsRequired", 0]
                ]
            };
            case "LOCKED_PERK": {
                format [
                    "MISSING PERKS: %1",
                    (_selected getOrDefault ["missingPerks", []]) joinString ", "
                ]
            };
            case "REQUIRES_ACQUISITION": {
                "OWNERSHIP / RENTAL REQUIRED"
            };
            default {""};
        };

        _ctrlPrimaryDetail ctrlSetText format [
            "SELECTED: %1\nSTATUS: LOCKED\n%2\n%3",
            _selectedName,
            _entitlementMessage,
            _extraLine
        ];
    };

    uiNamespace setVariable [
        _pendingNamespaceKey,
        createHashMapFromArray [["available", false]]
    ];
    _ctrlPrimaryApply ctrlEnable false;
};

_ctrlPrimaryList ctrlSetEventHandler [
    "LBSelChanged",
    "[] call bn_koth_fnc_menu_refresh;"
];

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

private _ctrlPrimaryTitle = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_TITLE;
private _ctrlPrimaryCurrent = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_CURRENT;
private _ctrlPrimaryList = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_LIST;
private _ctrlPrimaryDetail = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_DETAIL;
private _ctrlPrimaryApply = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_APPLY;
private _ctrlPrimaryBack = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_BACK;

// This function owns PrimaryList selection behaviour. Suppress selection
// callbacks while rows are rebuilt or selected programmatically.
_ctrlPrimaryList ctrlSetEventHandler ["LBSelChanged", ""];

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


if (isNull player) exitWith {
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

// Assigned equipment stage 1 is a pure slot picker. Never infer intent from a
// row that happens to remain selected while the list is rebuilt. Clear the
// selection with callbacks suppressed, then arm one explicit user-selection
// handler that advances to stage 2.
if (
    (_selectorMode isEqualTo "ASSIGNED") &&
    {_assignedStage isEqualTo 1}
) exitWith {
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
                    private _nextSlot = _selected getOrDefault ['assignedIndex', -1];

                    if (_nextSlot in [0, 1, 2, 3, 4, 5]) then {
                        uiNamespace setVariable ['BN_KOTH_menuAssignedStage', 2];
                        uiNamespace setVariable ['BN_KOTH_menuAssignedSlot', _nextSlot];
                        uiNamespace setVariable ['BN_KOTH_menuPendingAssigned', createHashMapFromArray [['available', false]]];
                        ['LOADOUT_EQUIPMENT'] call bn_koth_fnc_menu_refresh;
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

    if (_enableApply) then {
        _ctrlPrimaryApply ctrlEnable true;
    };
} else {
    _ctrlPrimaryDetail ctrlSetText format ["SELECTED: %1\nSTATUS: UNAVAILABLE", _selectedName];
    uiNamespace setVariable [_pendingNamespaceKey, createHashMapFromArray [["available", false]]];
    _ctrlPrimaryApply ctrlEnable false;
};

_ctrlPrimaryList ctrlSetEventHandler [
    "LBSelChanged",
    "[] call bn_koth_fnc_menu_refresh;"
];

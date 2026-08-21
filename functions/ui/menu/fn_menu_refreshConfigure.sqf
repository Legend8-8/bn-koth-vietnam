/*
    File: fn_menu_refreshConfigure.sqf
    Author: Legend
    Description: Renders factual compatible magazines for one locally selected
        canonical browser weapon and supports client-local draft selection.
        This presentation view submits no gameplay request or application.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _context = uiNamespace getVariable ["BN_KOTH_menuConfigureContext", createHashMap];
if !(_context isEqualType createHashMap) exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};

private _weaponClass = toLower (_context getOrDefault ["weaponClass", ""]);
private _weaponSlot = toLower (_context getOrDefault ["weaponSlot", "primary"]);
if (_weaponClass isEqualTo "") exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};
if !(_weaponSlot in ["primary", "handgun", "launcher"]) exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};
private _loadoutSlotIndex = switch (_weaponSlot) do {
    case "handgun": {2};
    case "launcher": {1};
    default {0};
};

private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
private _canonicalClass = _metadata getOrDefault ["canonicalClass", ""];
if !(_metadata getOrDefault ["success", false]) exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};
if !(_canonicalClass isEqualTo _weaponClass) exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};

private _uid = if (!isNull player) then {getPlayerUID player} else {""};
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};
private _level = (_progression getOrDefault ["level", 1]) max 1;

private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_assignments isEqualType createHashMap) then {
    _assignments = createHashMap;
};
private _assignedSide = _assignments getOrDefault [_uid, sideUnknown];
private _sideToken = switch (_assignedSide) do {
    case west: {"WEST"};
    case east: {"EAST"};
    default {""};
};

private _entitlement = if !(_sideToken isEqualTo "") then {
    [
        _uid,
        _sideToken,
        _progression,
        _metadata,
        _canonicalClass
    ] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules
} else {
    createHashMapFromArray [["accessType", "NONE"]]
};

if !((_entitlement getOrDefault ["accessType", "NONE"]) in ["OWNED", "RENTED", "UNCONTROLLED"]) exitWith {
    ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh
};

private _configureView = toUpper (uiNamespace getVariable ["BN_KOTH_menuConfigureView", "MAGAZINES"]);
if !(_configureView in ["MAGAZINES", "ATTACHMENTS"]) then {
    _configureView = "MAGAZINES";
};
uiNamespace setVariable ["BN_KOTH_menuConfigureView", _configureView];

private _magazinesTab = _display displayCtrl BN_KOTH_IDC_MENU_CONFIGURE_MAGAZINES;
private _attachmentsTab = _display displayCtrl BN_KOTH_IDC_MENU_CONFIGURE_ATTACHMENTS;
{
    _x params ["_control", "_isActive"];
    private _backgroundColor = if (_isActive) then {[0.20, 0.15, 0.08, 0.95]} else {[0.08, 0.08, 0.07, 0.90]};
    private _textColor = if (_isActive) then {[0.94, 0.80, 0.34, 1]} else {[0.94, 0.92, 0.88, 0.96]};
    _control ctrlSetBackgroundColor _backgroundColor;
    _control ctrlSetTextColor _textColor;
} forEach [
    [_magazinesTab, _configureView isEqualTo "MAGAZINES"],
    [_attachmentsTab, _configureView isEqualTo "ATTACHMENTS"]
];

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

// Configure drafts are client-local intent, but their initial state must come
// from the server-returned intended loadout so an accepted composition remains
// editable after the menu has been fully closed and reopened.
private _existingDrafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
if !(_existingDrafts isEqualType createHashMap) then {
    _existingDrafts = createHashMap;
};

private _existingDraft = _existingDrafts getOrDefault [_canonicalClass, createHashMap];
private _hasExistingDraft =
    (_existingDraft isEqualType createHashMap) &&
    {(count _existingDraft) > 0} &&
    {(toLower (_existingDraft getOrDefault ["weaponClass", ""])) isEqualTo _canonicalClass};

if (!_hasExistingDraft) then {
    private _intendedLoadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
    if ((_intendedLoadout isEqualType []) && {(count _intendedLoadout) > _loadoutSlotIndex}) then {
        private _intendedSlot = _intendedLoadout select _loadoutSlotIndex;
        if ((_intendedSlot isEqualType []) && {(count _intendedSlot) >= 5}) then {
            private _appliedWeaponClass = _intendedSlot select 0;
            private _magazineSlot = _intendedSlot select 4;
            if ((_appliedWeaponClass isEqualType "") && {_magazineSlot isEqualType []} && {(count _magazineSlot) >= 1}) then {
                private _appliedMetadata = [toLower _appliedWeaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
                private _appliedMagazine = _magazineSlot select 0;
                if (
                    (_appliedMetadata getOrDefault ["success", false]) &&
                    {(_appliedMetadata getOrDefault ["canonicalClass", ""]) isEqualTo _canonicalClass} &&
                    {_appliedMagazine isEqualType ""} &&
                    {!(_appliedMagazine isEqualTo "")}
                ) then {
                    private _appliedAttachments = [];
                    {
                        if (_x < (count _intendedSlot)) then {
                            private _attachmentClass = _intendedSlot select _x;
                            if (_attachmentClass isEqualType "") then {
                                _attachmentClass = toLower _attachmentClass;
                                if !(_attachmentClass isEqualTo "") then {
                                    _appliedAttachments pushBackUnique _attachmentClass;
                                };
                            };
                        };
                    } forEach [1, 2, 3, 6];
                    _appliedAttachments sort true;

                    private _appliedEvaluation = [
                        _canonicalClass,
                        _appliedAttachments,
                        [toLower _appliedMagazine],
                        _compatibilityCfg
                    ] call bn_koth_fnc_menu_evaluateWeaponComposition;

                    if (
                        (_appliedEvaluation getOrDefault ["available", false]) &&
                        {_appliedEvaluation getOrDefault ["complete", false]}
                    ) then {
                        _existingDrafts set [_canonicalClass, createHashMapFromArray [
                            ["weaponClass", _canonicalClass],
                            ["magazineClass", toLower _appliedMagazine],
                            ["attachments", _appliedEvaluation getOrDefault ["attachments", []]]
                        ]];
                    };
                };
            };
        };
    };
};
uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _existingDrafts];

if (_configureView isEqualTo "ATTACHMENTS") exitWith {
    [_display, _canonicalClass, _compatibilityCfg] call bn_koth_fnc_menu_refreshConfigureAttachments
};

private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
private _compatibleCfg = _weaponMagazinesCfg >> _canonicalClass;
private _magazineClasses = if (isClass _compatibleCfg) then {
    getArray (_compatibleCfg >> "values")
} else {
    []
};

private _seenMagazines = [];
private _sortable = [];
{
    private _magazineClass = toLower _x;
    if (_magazineClass in _seenMagazines) then {continue;};
    if !(isClass (_sourceMagazinesCfg >> _magazineClass)) then {continue;};

    private _magazineCfg = configFile >> "CfgMagazines" >> _magazineClass;
    if !(isClass _magazineCfg) then {continue;};

    private _displayName = getText (_magazineCfg >> "displayName");
    if (_displayName isEqualTo "") then {
        _displayName = toUpper _magazineClass;
    };

    _seenMagazines pushBack _magazineClass;
    _sortable pushBack [
        format ["%1|%2", toLower _displayName, _magazineClass],
        createHashMapFromArray [
            ["className", _magazineClass],
            ["displayName", _displayName],
            ["picture", getText (_magazineCfg >> "picture")]
        ]
    ];
} forEach _magazineClasses;
_sortable sort true;

private _magazines = [];
{_magazines pushBack (_x select 1);} forEach _sortable;

private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
if !(_drafts isEqualType createHashMap) then {
    _drafts = createHashMap;
    uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _drafts];
};

private _draft = _drafts getOrDefault [_canonicalClass, createHashMap];
private _selectedMagazine = "";
private _selectedAttachments = [];
if (_draft isEqualType createHashMap) then {
    private _draftWeapon = toLower (_draft getOrDefault ["weaponClass", ""]);
    private _draftMagazine = toLower (_draft getOrDefault ["magazineClass", ""]);
    if (_draftWeapon isEqualTo _canonicalClass) then {
        private _draftAttachments = _draft getOrDefault ["attachments", []];
        if (_draftAttachments isEqualType []) then {
            {
                if (_x isEqualType "") then {
                    private _attachment = toLower _x;
                    if !(_attachment isEqualTo "") then {
                        _selectedAttachments pushBackUnique _attachment;
                    };
                };
            } forEach _draftAttachments;
            _selectedAttachments sort true;
        };

        private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
        private _attachmentMetadataRoot = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Attachments";
        private _unlockedAttachments = [];
        {
            private _attachmentClass = _x;
            if !(isClass (_sourceItemsCfg >> _attachmentClass)) then {continue;};

            private _attachmentMetadataCfg = _attachmentMetadataRoot >> _attachmentClass;
            private _isLocked = false;
            if (isClass _attachmentMetadataCfg && {isNumber (_attachmentMetadataCfg >> "minLevel")}) then {
                private _minLevel = (getNumber (_attachmentMetadataCfg >> "minLevel")) max 1;
                _isLocked = _level < _minLevel;
            };
            if (_isLocked) then {continue;};

            _unlockedAttachments pushBackUnique _attachmentClass;
        } forEach _selectedAttachments;
        _unlockedAttachments sort true;
        _selectedAttachments = _unlockedAttachments;

        private _attachmentEvaluation = [_canonicalClass, _selectedAttachments, [], _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
        if (_attachmentEvaluation getOrDefault ["available", false]) then {
            _selectedAttachments = _attachmentEvaluation getOrDefault ["attachments", []];
        } else {
            _selectedAttachments = [];
        };

        if !(_draftMagazine isEqualTo "") then {
            private _magazineEvaluation = [_canonicalClass, _selectedAttachments, [_draftMagazine], _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
            if (_magazineEvaluation getOrDefault ["available", false]) then {
                _selectedMagazine = _draftMagazine;
                _selectedAttachments = _magazineEvaluation getOrDefault ["attachments", []];
            };
        };
    };
};

if (_selectedMagazine isEqualTo "" && {(count _selectedAttachments) <= 0}) then {
    _drafts deleteAt _canonicalClass;
} else {
    _drafts set [_canonicalClass, createHashMapFromArray [
        ["weaponClass", _canonicalClass],
        ["magazineClass", _selectedMagazine],
        ["attachments", _selectedAttachments]
    ]];
};
if (_draft isEqualType createHashMap) then {
    uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _drafts];
};

private _cardIdcs = call bn_koth_fnc_menu_getItemCardControls;
private _pageSize = count _cardIdcs;
private _pageCount = (ceil ((count _magazines) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuConfigurePage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuConfigurePage", _page];

private _weaponCfg = configFile >> "CfgWeapons" >> _canonicalClass;
private _weaponName = if (isClass _weaponCfg) then {
    getText (_weaponCfg >> "displayName")
} else {
    ""
};
if (_weaponName isEqualTo "") then {
    _weaponName = toUpper _canonicalClass;
};
private _weaponPicture = if (isClass _weaponCfg) then {getText (_weaponCfg >> "picture")} else {""};
private _weaponPreview = _display displayCtrl BN_KOTH_IDC_MENU_PRIMARY_PREVIEW;
_weaponPreview ctrlSetText _weaponPicture;
_weaponPreview ctrlShow true;
private _configureSubtitle = if (_selectedMagazine isEqualTo "") then {
    "COMPATIBLE MAGAZINES - NO MAGAZINE SELECTED"
} else {
    "COMPATIBLE MAGAZINES - MAGAZINE SELECTED"
};

(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText _weaponName;
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlSetText _configureSubtitle;
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];

private _back = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
_back buttonSetAction "private _context = uiNamespace getVariable ['BN_KOTH_menuConfigureContext', createHashMap]; private _returnPage = _context getOrDefault ['browserPage', 0]; if !(_returnPage isEqualType 0) then {_returnPage = 0}; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', _returnPage max 0]; uiNamespace setVariable ['BN_KOTH_menuConfigureContext', createHashMap]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";

private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuConfigurePage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', (_page - 1) max 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuConfigurePage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', _page + 1]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";

// Reset the complete fixed pool before rendering so a weapon switch or partial
// final page cannot expose stale magazine content or button behavior.
{
    _x params [
        "_backgroundIdc",
        "_imageAreaIdc",
        "_imageIdc",
        "_nameIdc",
        "_statusIdc",
        "_overlayIdc",
        "_lockTextIdc",
        "_primaryActionIdc",
        "_secondaryActionIdc"
    ];

    private _image = _display displayCtrl _imageIdc;
    private _nameCtrl = _display displayCtrl _nameIdc;
    private _statusCtrl = _display displayCtrl _statusIdc;
    private _lockCtrl = _display displayCtrl _lockTextIdc;
    private _primaryAction = _display displayCtrl _primaryActionIdc;
    private _secondaryAction = _display displayCtrl _secondaryActionIdc;

    _image ctrlSetText "";
    _nameCtrl ctrlSetText "";
    _statusCtrl ctrlSetText "";
    _lockCtrl ctrlSetText "";
    _primaryAction ctrlSetText "";
    _secondaryAction ctrlSetText "";
    _primaryAction buttonSetAction "";
    _secondaryAction buttonSetAction "";
    _primaryAction ctrlEnable false;
    _secondaryAction ctrlEnable false;

    {
        (_display displayCtrl _x) ctrlShow false;
    } forEach _x;
} forEach _cardIdcs;

{
    private _cardIndex = _forEachIndex + (_page * _pageSize);
    if (_cardIndex >= (count _magazines)) then {continue;};

    private _controls = _x;
    private _magazine = _magazines select _cardIndex;
    private _background = _display displayCtrl (_controls select 0);
    private _imageArea = _display displayCtrl (_controls select 1);
    private _image = _display displayCtrl (_controls select 2);
    private _nameCtrl = _display displayCtrl (_controls select 3);
    private _statusCtrl = _display displayCtrl (_controls select 4);
    private _overlay = _display displayCtrl (_controls select 5);
    private _lockCtrl = _display displayCtrl (_controls select 6);
    private _primaryAction = _display displayCtrl (_controls select 7);
    private _secondaryAction = _display displayCtrl (_controls select 8);
    private _magazineClass = _magazine getOrDefault ["className", ""];
    private _isSelected = _magazineClass isEqualTo _selectedMagazine;
    private _magazineEvaluation = [_canonicalClass, _selectedAttachments, [_magazineClass], _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
    private _canSelectMagazine = _magazineEvaluation getOrDefault ["available", false];
    private _magazineStatus = if (_isSelected) then {
        "SELECTED"
    } else {
        if (_canSelectMagazine) then {"COMPATIBLE MAGAZINE"} else {"INCOMPATIBLE WITH ATTACHMENTS"}
    };

    {
        _x ctrlShow true;
    } forEach [_background, _imageArea, _image, _nameCtrl, _statusCtrl];

    _imageArea ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    _image ctrlSetText (_magazine getOrDefault ["picture", ""]);
    _nameCtrl ctrlSetText (_magazine getOrDefault ["displayName", "UNKNOWN"]);
    _statusCtrl ctrlSetText _magazineStatus;
    _overlay ctrlShow (!_canSelectMagazine && {!_isSelected});
    _lockCtrl ctrlSetText "";
    _lockCtrl ctrlShow false;
    _primaryAction ctrlSetText "SELECT";
    private _selectAction = if (_isSelected || {!_canSelectMagazine}) then {
        ""
    } else {
        format [
            "%1 call bn_koth_fnc_menu_selectConfigureMagazine;",
            str [_canonicalClass, _magazineClass]
        ]
    };
    _primaryAction buttonSetAction _selectAction;
    _secondaryAction buttonSetAction "";
    _primaryAction ctrlShow (!_isSelected && {_canSelectMagazine});
    _secondaryAction ctrlShow false;
    _primaryAction ctrlEnable (!_isSelected && {_canSelectMagazine});
    _secondaryAction ctrlEnable false;
} forEach _cardIdcs;

if ((count _magazines) <= 0) then {
    private _firstCard = _cardIdcs select 0;
    private _background = _display displayCtrl (_firstCard select 0);
    private _imageArea = _display displayCtrl (_firstCard select 1);
    private _image = _display displayCtrl (_firstCard select 2);
    private _nameCtrl = _display displayCtrl (_firstCard select 3);
    private _statusCtrl = _display displayCtrl (_firstCard select 4);

    {
        _x ctrlShow true;
    } forEach [_background, _imageArea, _image, _nameCtrl, _statusCtrl];

    _image ctrlSetText _weaponPicture;
    _nameCtrl ctrlSetText "NO COMPATIBLE MAGAZINES";
    _statusCtrl ctrlSetText "FACTUAL COMPATIBILITY DATA UNAVAILABLE";
};

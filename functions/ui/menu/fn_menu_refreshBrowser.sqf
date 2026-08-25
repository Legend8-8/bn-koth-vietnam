/*
    File: fn_menu_refreshBrowser.sqf
    Author: Legend
    Description: Renders the fixed local-only item-browser card pool from one
        cached canonical S.O.G. weapon-slot catalogue and presents supplied
        owner-only entitlement state. It may submit explicit weapon-and-magazine
        intent through the shared authoritative request path, but never mutates
        equipment or authoritative state directly.
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

private _cardIdcs = call bn_koth_fnc_menu_getItemCardControls;
private _weaponSlot = toLower (uiNamespace getVariable ["BN_KOTH_menuBrowserSlot", "primary"]);
if !(_weaponSlot in ["primary", "handgun", "launcher", "uniform", "vest", "headgear", "facewear", "binocular", "backpack", "assigned"]) then {
    _weaponSlot = "primary";
};
uiNamespace setVariable ["BN_KOTH_menuBrowserSlot", _weaponSlot];
if (_weaponSlot isEqualTo "assigned") exitWith {
    [_display] call bn_koth_fnc_menu_refreshAssignedBrowser;
};
if (_weaponSlot in ["uniform", "vest", "headgear", "facewear", "binocular", "backpack"]) exitWith {
    [_display, _weaponSlot] call bn_koth_fnc_menu_refreshWearableBrowser;
};
private _weaponSlotUpper = toUpper _weaponSlot;
private _loadoutSlotIndex = switch (_weaponSlot) do {
    case "handgun": {2};
    case "launcher": {1};
    default {0};
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
private _catalogueReadyKey = format ["BN_KOTH_menuBrowserWeaponCatalogueReady_%1", _weaponSlot];
private _catalogueKey = format ["BN_KOTH_menuBrowserWeaponCatalogue_%1", _weaponSlot];
private _catalogueReady = missionNamespace getVariable [_catalogueReadyKey, false];
private _catalogue = missionNamespace getVariable [_catalogueKey, []];

if (!_catalogueReady) then {
    _catalogue = [_compatibilityCfg, _weaponSlotUpper] call bn_koth_fnc_menu_buildBrowserWeaponEntries;
    missionNamespace setVariable [_catalogueKey, _catalogue];
    missionNamespace setVariable [_catalogueReadyKey, true];
    uiNamespace setVariable ["BN_KOTH_menuBrowserPage", 0];
};
if !(_catalogue isEqualType []) then {
    _catalogue = [];
};

// This is populated only by the server-validated loadout receiver. Do not fall
// back to the player's local inventory when deciding whether a card is applied.
private _intendedWeaponClass = "";
private _intendedMagazine = "";
private _intendedAttachments = [];
private _intendedLoadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if ((_intendedLoadout isEqualType []) && {(count _intendedLoadout) > _loadoutSlotIndex}) then {
    private _intendedSlot = _intendedLoadout select _loadoutSlotIndex;

    if ((_intendedSlot isEqualType []) && {(count _intendedSlot) >= 5}) then {
        private _appliedClass = _intendedSlot select 0;
        private _appliedMagazineSlot = _intendedSlot select 4;

        if (
            (_appliedClass isEqualType "") &&
            {!(_appliedClass isEqualTo "")} &&
            (_appliedMagazineSlot isEqualType []) &&
            {(count _appliedMagazineSlot) >= 1}
        ) then {
            private _appliedMagazine = _appliedMagazineSlot select 0;
            private _appliedMetadata = [toLower _appliedClass] call bn_koth_fnc_loadouts_getWeaponMetadata;

            if (
                (_appliedMagazine isEqualType "") &&
                {!(_appliedMagazine isEqualTo "")} &&
                {_appliedMetadata getOrDefault ["success", false]}
            ) then {
                private _canonicalAppliedClass = _appliedMetadata getOrDefault ["canonicalClass", ""];
                private _canonicalAppliedMagazine = toLower _appliedMagazine;
                private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
                private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
                private _compatibleCfg = _weaponMagazinesCfg >> _canonicalAppliedClass;
                private _compatibleMagazines = if (isClass _compatibleCfg) then {
                    (getArray (_compatibleCfg >> "values")) apply {toLower _x}
                } else {
                    []
                };

                if (
                    !(_canonicalAppliedClass isEqualTo "") &&
                    {_canonicalAppliedMagazine in _compatibleMagazines} &&
                    {isClass (_sourceMagazinesCfg >> _canonicalAppliedMagazine)} &&
                    {isClass (configFile >> "CfgMagazines" >> _canonicalAppliedMagazine)}
                ) then {
                    _intendedWeaponClass = _canonicalAppliedClass;
                    _intendedMagazine = _canonicalAppliedMagazine;
                    {
                        if (_x < (count _intendedSlot)) then {
                            private _attachmentClass = _intendedSlot select _x;
                            if (_attachmentClass isEqualType "") then {
                                _attachmentClass = toLower _attachmentClass;
                                if !(_attachmentClass isEqualTo "") then {
                                    _intendedAttachments pushBackUnique _attachmentClass;
                                };
                            };
                        };
                    } forEach [1, 2, 3, 6];
                    _intendedAttachments sort true;
                };
            };
        };
    };
};

private _uid = if (!isNull player) then {getPlayerUID player} else {""};
private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};

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

private _entries = [];
{
    private _metadata = _x getOrDefault ["metadata", createHashMap];
    private _weaponClass = _x getOrDefault ["weaponClass", ""];
    private _clearSlot = _x getOrDefault ["clearSlot", false];
    private _entitlement = if (_clearSlot) then {
        createHashMapFromArray [
            ["success", true],
            ["entitled", true],
            ["code", "ENTITLED_CLEAR"],
            ["message", "Empty launcher slot requires no entitlement."],
            ["accessType", "UNCONTROLLED"]
        ]
    } else {
        if !(_sideToken isEqualTo "") then {
        [
            _uid,
            _sideToken,
            _progression,
            _metadata,
            _weaponClass
        ] call bn_koth_fnc_progression_evaluateWeaponEntitlementRules
        } else {
            createHashMapFromArray [
                ["success", false],
                ["entitled", false],
                ["code", "LOCKED_STATE"],
                ["message", "Player presentation state is not ready."],
                ["accessType", "NONE"]
            ]
        }
    };

    // The Arsenal is the assigned faction's equipment surface. Omit only an
    // explicit side-policy rejection; same-side progression locks remain in
    // the entry list for normal locked/acquisition presentation.
    if (
        ((_entitlement getOrDefault ["code", ""]) isEqualTo "LOCKED_SIDE")
        || {_entitlement getOrDefault ["crossSide", false]}
    ) then {continue;};

    _entries pushBack (createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["displayName", _x getOrDefault ["displayName", toUpper _weaponClass]],
        ["picture", _x getOrDefault ["picture", ""]],
        ["metadata", _metadata],
        ["entitlement", _entitlement],
        ["clearSlot", _clearSlot]
    ]);
} forEach _catalogue;

private _pageSize = count _cardIdcs;
private _pageCount = ceil ((count _entries) / _pageSize);
_pageCount = _pageCount max 1;

private _page = uiNamespace getVariable ["BN_KOTH_menuBrowserPage", 0];
if (uiNamespace getVariable ["BN_KOTH_menuBrowserSnapPending", false]) then {
    private _appliedIndex = _entries findIf {(_x getOrDefault ["weaponClass", ""]) isEqualTo _intendedWeaponClass};
    if (_appliedIndex >= 0) then {_page = floor (_appliedIndex / _pageSize)};
    uiNamespace setVariable ["BN_KOTH_menuBrowserSnapPending", false];
};
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuBrowserPage", _page];

private _browserTitle = switch (_weaponSlot) do {
    case "handgun": {"SIDEARMS"};
    case "launcher": {"LAUNCHERS"};
    default {"PRIMARY WEAPONS"};
};
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText _browserTitle;
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlSetText "CANONICAL S.O.G. WEAPONS";
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];

private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
private _back = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_BACK;
_back buttonSetAction "['LOADOUT'] call bn_koth_fnc_menu_refresh;";
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', (_page - 1) max 0]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]; uiNamespace setVariable ['BN_KOTH_menuBrowserPage', _page + 1]; ['LOADOUT_BROWSER'] call bn_koth_fnc_menu_refresh;";

// Reset the complete fixed pool before rendering so partial pages and any
// interrupted previous render cannot expose stale card state.
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
    private _controls = _x;

    private _cardIndex = _forEachIndex + (_page * _pageSize);
    if (_cardIndex >= (count _entries)) then {continue;};

    private _entry = _entries select _cardIndex;
    private _metadata = _entry getOrDefault ["metadata", createHashMap];
    private _entitlement = _entry getOrDefault ["entitlement", createHashMap];
    private _entitlementCode = _entitlement getOrDefault ["code", "LOCKED_STATE"];
    private _accessType = _entitlement getOrDefault ["accessType", "NONE"];
    private _lockedByLevel = _entitlementCode isEqualTo "LOCKED_LEVEL";
    private _hasAccess = _accessType in ["OWNED", "RENTED", "UNCONTROLLED"];
    private _entryWeaponClass = _entry getOrDefault ["weaponClass", ""];
    private _clearSlot = _entry getOrDefault ["clearSlot", false];
    private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
    if !(_drafts isEqualType createHashMap) then {_drafts = createHashMap};

    private _draft = if (_clearSlot) then {createHashMap} else {_drafts getOrDefault [_entryWeaponClass, createHashMap]};
    private _draftWeaponClass = "";
    private _draftMagazineClass = "";
    private _draftAttachments = [];
    if (_draft isEqualType createHashMap) then {
        _draftWeaponClass = toLower (_draft getOrDefault ["weaponClass", ""]);
        _draftMagazineClass = toLower (_draft getOrDefault ["magazineClass", ""]);
        private _rawDraftAttachments = _draft getOrDefault ["attachments", []];
        if (_rawDraftAttachments isEqualType []) then {
            {
                if (_x isEqualType "") then {
                    private _attachment = toLower _x;
                    if !(_attachment isEqualTo "") then {
                        _draftAttachments pushBackUnique _attachment;
                    };
                };
            } forEach _rawDraftAttachments;
            _draftAttachments sort true;
        };
    };

    private _draftIsValid = false;
    private _hasAttachmentDraft = (_draftWeaponClass isEqualTo _entryWeaponClass) && {(count _draftAttachments) > 0};
    if (
        (_draftWeaponClass isEqualTo _entryWeaponClass) &&
        {!(_draftMagazineClass isEqualTo "")}
    ) then {
        private _draftEvaluation = [_draftWeaponClass, _draftAttachments, [_draftMagazineClass], _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
        _draftIsValid =
            (_draftEvaluation getOrDefault ["available", false]) &&
            {_draftEvaluation getOrDefault ["complete", false]};
    };
    private _draftMatchesIntended =
        _draftIsValid &&
        {_draftWeaponClass isEqualTo _intendedWeaponClass} &&
        {_draftMagazineClass isEqualTo _intendedMagazine} &&
        {_draftAttachments isEqualTo _intendedAttachments};
    private _hasPendingAttachmentDraft = _hasAttachmentDraft && {!_draftMatchesIntended};
    private _canApply = if (_clearSlot) then {
        !(_intendedWeaponClass isEqualTo "")
    } else {
        _hasAccess && {_draftIsValid} && {!_draftMatchesIntended}
    };
    private _isApplied = if (_clearSlot) then {
        _intendedWeaponClass isEqualTo ""
    } else {
        _hasAccess &&
        {(_entryWeaponClass isEqualTo _intendedWeaponClass)} &&
        {
            !_draftIsValid ||
            {_draftMatchesIntended}
        }
    };
    private _primaryActionText = if (_isApplied) then {"APPLIED"} else {"APPLY"};
    private _lockText = if (_lockedByLevel) then {
        format ["LOCKED UNTIL LEVEL %1", _metadata getOrDefault ["minLevel", 1]]
    } else {
        ""
    };

    private _status = if (_clearSlot) then {
        if (_isApplied) then {"NO LAUNCHER SELECTED"} else {"REMOVE CURRENT LAUNCHER"}
    } else {
        switch (_accessType) do {
            case "OWNED": {"OWNED"};
            case "RENTED": {"RENTED"};
            case "UNCONTROLLED": {"AVAILABLE - NO KOTH RESTRICTION"};
            default {
                if (_lockedByLevel) then {
                    format ["LOCKED UNTIL LEVEL %1", _metadata getOrDefault ["minLevel", 1]]
                } else {
                    if (_hasPendingAttachmentDraft) then {
                        "ATTACHMENT APPLY PENDING"
                    } else {
                        switch (_entitlementCode) do {
                            case "REQUIRES_ACQUISITION": {"ACQUISITION REQUIRED"};
                            case "LOCKED_MASTERY": {"CROSS-FACTION MASTERY REQUIRED"};
                            case "LOCKED_PERK": {"REQUIRED PERK MISSING"};
                            default {"PRESENTATION STATE UNAVAILABLE"};
                        }
                    }
                }
            };
        }
    };

    if (_hasAccess && {_hasPendingAttachmentDraft}) then {
        _status = "ATTACHMENT APPLY PENDING";
    };

    private _background = _display displayCtrl (_controls select 0);
    private _imageArea = _display displayCtrl (_controls select 1);
    private _image = _display displayCtrl (_controls select 2);
    private _nameCtrl = _display displayCtrl (_controls select 3);
    private _statusCtrl = _display displayCtrl (_controls select 4);
    private _overlay = _display displayCtrl (_controls select 5);
    private _lockCtrl = _display displayCtrl (_controls select 6);
    private _primaryAction = _display displayCtrl (_controls select 7);
    private _secondaryAction = _display displayCtrl (_controls select 8);

    {
        _x ctrlShow true;
    } forEach [_background, _imageArea, _image, _nameCtrl, _statusCtrl];

    _imageArea ctrlSetBackgroundColor [0.025, 0.025, 0.022, 0.92];
    _image ctrlSetText (_entry getOrDefault ["picture", ""]);
    _nameCtrl ctrlSetText (_entry getOrDefault ["displayName", "UNKNOWN"]);
    _statusCtrl ctrlSetText _status;
    _overlay ctrlShow _lockedByLevel;
    _lockCtrl ctrlSetText _lockText;
    _lockCtrl ctrlShow _lockedByLevel;

    _primaryAction ctrlSetText _primaryActionText;
    _secondaryAction ctrlSetText "CONFIGURE";
    _primaryAction buttonSetAction "";
    _secondaryAction buttonSetAction "";
    _primaryAction ctrlShow _hasAccess;
    _secondaryAction ctrlShow (_hasAccess && {!_clearSlot});
    _primaryAction ctrlEnable (_canApply && {!_isApplied});
    _secondaryAction ctrlEnable (_hasAccess && {!_clearSlot});

    private _applyArguments = if (_clearSlot) then {
        [_weaponSlot, "", "", []]
    } else {
        [_weaponSlot, _draftWeaponClass, _draftMagazineClass, _draftAttachments]
    };
    private _applyAction = if (_canApply && {!_isApplied}) then {
        format [
            "%1 call bn_koth_fnc_menu_applyWeaponComposition;",
            str _applyArguments
        ]
    } else {
        ""
    };
    _primaryAction buttonSetAction _applyAction;

    if (_hasAccess && {!_clearSlot}) then {
        _secondaryAction buttonSetAction format [
            "uiNamespace setVariable ['BN_KOTH_menuConfigureContext', createHashMapFromArray [['weaponClass', '%1'], ['weaponSlot', '%2'], ['browserPage', uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]]]]; uiNamespace setVariable ['BN_KOTH_menuConfigureView', 'MAGAZINES']; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigureAttachmentPage', 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;",
            _entryWeaponClass,
            _weaponSlot
        ];
    };
} forEach _cardIdcs;

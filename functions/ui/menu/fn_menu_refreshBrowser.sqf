/*
    File: fn_menu_refreshBrowser.sqf
    Author: Legend
    Description: Renders the fixed local-only item-browser card pool from the
        cached canonical S.O.G. primary-weapon catalogue and presents supplied
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
private _catalogueReady = missionNamespace getVariable ["BN_KOTH_menuBrowserWeaponCatalogueReady", false];
private _catalogue = missionNamespace getVariable ["BN_KOTH_menuBrowserWeaponCatalogue", []];

if (!_catalogueReady) then {
    _catalogue = [_compatibilityCfg] call bn_koth_fnc_menu_buildBrowserWeaponEntries;
    missionNamespace setVariable ["BN_KOTH_menuBrowserWeaponCatalogue", _catalogue];
    missionNamespace setVariable ["BN_KOTH_menuBrowserWeaponCatalogueReady", true];
    uiNamespace setVariable ["BN_KOTH_menuBrowserPage", 0];
};
if !(_catalogue isEqualType []) then {
    _catalogue = [];
};

// This is populated only by the server-validated loadout receiver. Do not fall
// back to the player's local inventory when deciding whether a card is applied.
private _intendedPrimaryClass = "";
private _intendedPrimaryMagazine = "";
private _intendedLoadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if ((_intendedLoadout isEqualType []) && {(count _intendedLoadout) >= 1}) then {
    private _primarySlot = _intendedLoadout select 0;

    if ((_primarySlot isEqualType []) && {(count _primarySlot) >= 5}) then {
        private _primaryClass = _primarySlot select 0;
        private _primaryMagazineSlot = _primarySlot select 4;

        if (
            (_primaryClass isEqualType "") &&
            {!(_primaryClass isEqualTo "")} &&
            (_primaryMagazineSlot isEqualType []) &&
            {(count _primaryMagazineSlot) >= 1}
        ) then {
            private _primaryMagazine = _primaryMagazineSlot select 0;
            private _primaryMetadata = [toLower _primaryClass] call bn_koth_fnc_loadouts_getWeaponMetadata;

            if (
                (_primaryMagazine isEqualType "") &&
                {!(_primaryMagazine isEqualTo "")} &&
                {_primaryMetadata getOrDefault ["success", false]}
            ) then {
                private _canonicalPrimaryClass = _primaryMetadata getOrDefault ["canonicalClass", ""];
                private _canonicalPrimaryMagazine = toLower _primaryMagazine;
                private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
                private _weaponMagazinesCfg = _compatibilityCfg >> "WeaponMagazines";
                private _compatibleCfg = _weaponMagazinesCfg >> _canonicalPrimaryClass;
                private _compatibleMagazines = if (isClass _compatibleCfg) then {
                    (getArray (_compatibleCfg >> "values")) apply {toLower _x}
                } else {
                    []
                };

                if (
                    !(_canonicalPrimaryClass isEqualTo "") &&
                    {_canonicalPrimaryMagazine in _compatibleMagazines} &&
                    {isClass (_sourceMagazinesCfg >> _canonicalPrimaryMagazine)} &&
                    {isClass (configFile >> "CfgMagazines" >> _canonicalPrimaryMagazine)}
                ) then {
                    _intendedPrimaryClass = _canonicalPrimaryClass;
                    _intendedPrimaryMagazine = _canonicalPrimaryMagazine;
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
    private _entitlement = if !(_sideToken isEqualTo "") then {
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
    };

    _entries pushBack (createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["displayName", _x getOrDefault ["displayName", toUpper _weaponClass]],
        ["picture", _x getOrDefault ["picture", ""]],
        ["metadata", _metadata],
        ["entitlement", _entitlement]
    ]);
} forEach _catalogue;

private _pageSize = count _cardIdcs;
private _pageCount = ceil ((count _entries) / _pageSize);
_pageCount = _pageCount max 1;

private _page = uiNamespace getVariable ["BN_KOTH_menuBrowserPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuBrowserPage", _page];

(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_TITLE) ctrlSetText "PRIMARY WEAPONS";
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
    private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
    if !(_drafts isEqualType createHashMap) then {_drafts = createHashMap};

    private _draft = _drafts getOrDefault [_entryWeaponClass, createHashMap];
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
        _draftIsValid = _draftEvaluation getOrDefault ["available", false];
    };
    private _canApply = _hasAccess && {_draftIsValid} && {!_hasAttachmentDraft};
    private _isApplied =
        _hasAccess &&
        {!_hasAttachmentDraft} &&
        {(_entryWeaponClass isEqualTo _intendedPrimaryClass)} &&
        {
            !_draftIsValid ||
            {(_draftMagazineClass isEqualTo _intendedPrimaryMagazine)}
        };
    private _primaryActionText = if (_isApplied) then {"APPLIED"} else {"APPLY"};
    private _lockText = if (_lockedByLevel) then {
        format ["LOCKED UNTIL LEVEL %1", _metadata getOrDefault ["minLevel", 1]]
    } else {
        ""
    };

    private _status = switch (_accessType) do {
        case "OWNED": {"OWNED"};
        case "RENTED": {"RENTED"};
        case "UNCONTROLLED": {"AVAILABLE - NO KOTH RESTRICTION"};
        default {
            if (_lockedByLevel) then {
                format ["LOCKED UNTIL LEVEL %1", _metadata getOrDefault ["minLevel", 1]]
            } else {
                if (_hasAttachmentDraft) then {
                    "ATTACHMENT APPLY PENDING"
                } else {
                    switch (_entitlementCode) do {
                        case "REQUIRES_ACQUISITION": {"ACQUISITION REQUIRED"};
                        case "LOCKED_SIDE_LICENSE": {"CROSS-FACTION LICENSE REQUIRED"};
                        case "LOCKED_PERK": {"REQUIRED PERK MISSING"};
                        default {"PRESENTATION STATE UNAVAILABLE"};
                    }
                }
            }
        };
    };

    if (_hasAccess && {_hasAttachmentDraft}) then {
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
    _secondaryAction ctrlShow _hasAccess;
    _primaryAction ctrlEnable (_canApply && {!_isApplied});
    _secondaryAction ctrlEnable _hasAccess;

    private _applyAction = if (_canApply && {!_isApplied}) then {
        format [
            "%1 call bn_koth_fnc_menu_applyPrimary;",
            str [_draftWeaponClass, _draftMagazineClass]
        ]
    } else {
        ""
    };
    _primaryAction buttonSetAction _applyAction;

    if (_hasAccess) then {
        _secondaryAction buttonSetAction format [
            "uiNamespace setVariable ['BN_KOTH_menuConfigureContext', createHashMapFromArray [['weaponClass', '%1'], ['browserPage', uiNamespace getVariable ['BN_KOTH_menuBrowserPage', 0]]]]; uiNamespace setVariable ['BN_KOTH_menuConfigureView', 'MAGAZINES']; uiNamespace setVariable ['BN_KOTH_menuConfigurePage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigureAttachmentPage', 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;",
            _entryWeaponClass
        ];
    };
} forEach _cardIdcs;
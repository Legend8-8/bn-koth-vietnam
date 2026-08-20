/*
    File: fn_menu_refreshConfigureAttachments.sqf
    Author: Legend
    Description: Renders factual attachment candidates for one canonical
        Configure weapon, evaluates client-local complete and viable-incomplete
        composition presentation states, and supports local attachment draft
        SELECT/REMOVE presentation. It submits no gameplay request, applies no
        equipment, and remains non-authoritative.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
        1: Canonical weapon classname <STRING>
        2: Canonical compatibility config root <CONFIG>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [
    ["_display", displayNull, [displayNull]],
    ["_canonicalWeaponClass", "", [""]],
    ["_compatibilityCfg", configNull, [configNull]]
];

if (isNull _display) exitWith {};
if (_canonicalWeaponClass isEqualTo "" || {!(isClass _compatibilityCfg)}) exitWith {};

private _sourceWeaponsCfg = _compatibilityCfg >> "SourceWeapons";
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
private _weaponAttachmentsCfg = _compatibilityCfg >> "WeaponAttachments";
private _transformingCfg = _compatibilityCfg >> "WeaponVariantTransformingAttachments";
if (
    !(isClass _sourceWeaponsCfg) ||
    {!(isClass _sourceItemsCfg)} ||
    {!(isClass _weaponAttachmentsCfg)} ||
    {!(isClass _transformingCfg)}
) exitWith {};

private _cache = missionNamespace getVariable ["BN_KOTH_menuConfigureAttachmentCatalogues", createHashMap];
if !(_cache isEqualType createHashMap) then {
    _cache = createHashMap;
};

private _cacheReadyKey = _canonicalWeaponClass + "_ready";
private _entries = _cache getOrDefault [_canonicalWeaponClass, []];
if !(_entries isEqualType []) then {
    _entries = [];
};

if !(_cache getOrDefault [_cacheReadyKey, false]) then {
    private _candidateClasses = [];

    {
        private _sourceWeaponClass = toLower (configName _x);
        private _metadata = [_sourceWeaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
        if ((_metadata getOrDefault ["canonicalClass", ""]) isEqualTo _canonicalWeaponClass) then {
            private _attachmentCfg = _weaponAttachmentsCfg >> _sourceWeaponClass;
            if (isClass _attachmentCfg) then {
                {_candidateClasses pushBackUnique (toLower _x)} forEach (getArray (_attachmentCfg >> "values"));
            };

            private _transformCfg = _transformingCfg >> _sourceWeaponClass;
            if (isClass _transformCfg) then {
                {_candidateClasses pushBackUnique (toLower _x)} forEach (getArray (_transformCfg >> "values"));
            };
        };
    } forEach ("true" configClasses _sourceWeaponsCfg);

    private _metadataAttachmentsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Attachments";
    private _sortable = [];
    {
        private _attachmentClass = _x;
        if !(isClass (_sourceItemsCfg >> _attachmentClass)) then {continue;};

        private _attachmentCfg = configFile >> "CfgWeapons" >> _attachmentClass;
        if !(isClass _attachmentCfg) then {continue;};

        private _displayName = getText (_attachmentCfg >> "displayName");
        if (_displayName isEqualTo "") then {
            _displayName = toUpper _attachmentClass;
        };

        private _itemType = toUpper (getText ((_sourceItemsCfg >> _attachmentClass) >> "itemType"));
        if (_itemType isEqualTo "") then {
            _itemType = "ATTACHMENT";
        };

        private _minLevel = 1;
        private _hasMinLevel = false;
        private _attachmentMetadataCfg = _metadataAttachmentsCfg >> _attachmentClass;
        if (isClass _attachmentMetadataCfg && {isNumber (_attachmentMetadataCfg >> "minLevel")}) then {
            _minLevel = (getNumber (_attachmentMetadataCfg >> "minLevel")) max 1;
            _hasMinLevel = true;
        };

        private _levelText = str _minLevel;
        private _levelSortKey = ("000000" + _levelText) select [(count _levelText), 6];
        _sortable pushBack [
            format ["%1|%2|%3", _levelSortKey, toLower _displayName, _attachmentClass],
            createHashMapFromArray [
                ["className", _attachmentClass],
                ["displayName", _displayName],
                ["picture", getText (_attachmentCfg >> "picture")],
                ["category", _itemType],
                ["minLevel", _minLevel],
                ["hasMinLevel", _hasMinLevel]
            ]
        ];
    } forEach _candidateClasses;
    _sortable sort true;
    _entries = [];
    {_entries pushBack (_x select 1);} forEach _sortable;

    _cache set [_canonicalWeaponClass, _entries];
    _cache set [_cacheReadyKey, true];
    missionNamespace setVariable ["BN_KOTH_menuConfigureAttachmentCatalogues", _cache];
};

private _cardIdcs = call bn_koth_fnc_menu_getItemCardControls;
private _pageSize = count _cardIdcs;
private _pageCount = (ceil ((count _entries) / _pageSize)) max 1;
private _page = uiNamespace getVariable ["BN_KOTH_menuConfigureAttachmentPage", 0];
if !(_page isEqualType 0) then {_page = 0};
_page = (_page max 0) min (_pageCount - 1);
uiNamespace setVariable ["BN_KOTH_menuConfigureAttachmentPage", _page];

(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_SUBTITLE) ctrlSetText "FACTUAL COMPATIBLE ATTACHMENTS";
(_display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];

private _previous = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_BROWSER_PAGE_NEXT;
_previous ctrlEnable (_page > 0);
_next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuConfigureAttachmentPage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigureAttachmentPage', (_page - 1) max 0]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";
_next buttonSetAction "private _page = uiNamespace getVariable ['BN_KOTH_menuConfigureAttachmentPage', 0]; uiNamespace setVariable ['BN_KOTH_menuConfigureAttachmentPage', _page + 1]; ['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;";

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

private _presentationProgression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_presentationProgression isEqualType createHashMap) then {
    _presentationProgression = createHashMap;
};
private _playerLevel = (_presentationProgression getOrDefault ["level", 1]) max 1;

private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
if !(_drafts isEqualType createHashMap) then {
    _drafts = createHashMap;
};

private _draft = _drafts getOrDefault [_canonicalWeaponClass, createHashMap];
private _selectedMagazine = "";
private _selectedAttachmentsRaw = [];
if (_draft isEqualType createHashMap) then {
    if ((toLower (_draft getOrDefault ["weaponClass", ""])) isEqualTo _canonicalWeaponClass) then {
        _selectedMagazine = toLower (_draft getOrDefault ["magazineClass", ""]);
        private _draftAttachments = _draft getOrDefault ["attachments", []];
        if (_draftAttachments isEqualType []) then {
            {
                if (_x isEqualType "") then {
                    private _attachment = toLower _x;
                    if !(_attachment isEqualTo "") then {
                        _selectedAttachmentsRaw pushBackUnique _attachment;
                    };
                };
            } forEach _draftAttachments;
            _selectedAttachmentsRaw sort true;
        };
    };
};

private _entryByClass = createHashMap;
{
    _entryByClass set [_x getOrDefault ["className", ""], _x];
} forEach _entries;

private _selectedAttachments = [];
{
    private _attachmentClass = _x;
    private _entry = _entryByClass getOrDefault [_attachmentClass, createHashMap];
    if !(_entry isEqualType createHashMap) then {continue;};
    if ((count _entry) <= 0) then {continue;};

    private _minLevel = _entry getOrDefault ["minLevel", 1];
    private _hasMinLevel = _entry getOrDefault ["hasMinLevel", false];
    if (_hasMinLevel && {_playerLevel < _minLevel}) then {continue;};

    _selectedAttachments pushBackUnique _attachmentClass;
} forEach _selectedAttachmentsRaw;
_selectedAttachments sort true;

private _magazines = if (_selectedMagazine isEqualTo "") then {[]} else {[_selectedMagazine]};
private _storedDraftEvaluation = [_canonicalWeaponClass, _selectedAttachments, _magazines, _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
if (_storedDraftEvaluation getOrDefault ["available", false]) then {
    _selectedAttachments = _storedDraftEvaluation getOrDefault ["attachments", []];
} else {
    _selectedAttachments = [];
};

if (_selectedMagazine isEqualTo "" && {(count _selectedAttachments) <= 0}) then {
    _drafts deleteAt _canonicalWeaponClass;
} else {
    _drafts set [_canonicalWeaponClass, createHashMapFromArray [
        ["weaponClass", _canonicalWeaponClass],
        ["magazineClass", _selectedMagazine],
        ["attachments", _selectedAttachments]
    ]];
};
uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _drafts];

{
    private _cardIndex = _forEachIndex + (_page * _pageSize);
    if (_cardIndex >= (count _entries)) then {continue;};

    private _controls = _x;
    private _entry = _entries select _cardIndex;
    private _minLevel = _entry getOrDefault ["minLevel", 1];
    private _hasMinLevel = _entry getOrDefault ["hasMinLevel", false];
    private _locked = _hasMinLevel && {_playerLevel < _minLevel};
    private _attachmentClass = _entry getOrDefault ["className", ""];
    private _isSelected = _attachmentClass in _selectedAttachments;
    private _proposedAttachments = if (_isSelected) then {
        _selectedAttachments - [_attachmentClass]
    } else {
        private _candidateAttachments = +_selectedAttachments;
        _candidateAttachments pushBackUnique _attachmentClass;
        _candidateAttachments
    };
    _proposedAttachments sort true;

    private _magazines = if (_selectedMagazine isEqualTo "") then {[]} else {[_selectedMagazine]};
    private _compositionEvaluation = [_canonicalWeaponClass, _proposedAttachments, _magazines, _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
    private _compositionAvailable = _compositionEvaluation getOrDefault ["available", false];
    private _compositionState = _compositionEvaluation getOrDefault ["state", "INVALID"];
    private _status = if (_locked) then {
        format ["LOCKED UNTIL LEVEL %1", _minLevel]
    } else {
        if (_isSelected) then {
            "SELECTED"
        } else {
            if (_compositionAvailable) then {
                if (_compositionState isEqualTo "INCOMPLETE") then {
                    "REQUIRES ADDITIONAL ATTACHMENT"
                } else {
                    format ["COMPATIBLE %1", _entry getOrDefault ["category", "ATTACHMENT"]]
                }
            } else {
                "INCOMPATIBLE WITH SELECTION"
            }
        }
    };
    private _lockText = if (_locked) then {format ["LOCKED UNTIL LEVEL %1", _minLevel]} else {""};
    private _actionText = if (_isSelected) then {"REMOVE"} else {"SELECT"};
    private _hasAction = !_locked && {_compositionAvailable};

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
    _overlay ctrlShow (_locked || {!_compositionAvailable && {!_isSelected}});
    _lockCtrl ctrlSetText _lockText;
    _lockCtrl ctrlShow _locked;
    _primaryAction ctrlSetText _actionText;
    _primaryAction ctrlShow _hasAction;
    _secondaryAction ctrlShow false;
    _primaryAction ctrlEnable _hasAction;
    _secondaryAction ctrlEnable false;
    private _actionMode = if (_isSelected) then {"REMOVE"} else {"SELECT"};
    private _action = if (_hasAction) then {
        format [
            "%1 call bn_koth_fnc_menu_selectConfigureAttachment;",
            str [_canonicalWeaponClass, _attachmentClass, _actionMode]
        ]
    } else {
        ""
    };
    _primaryAction buttonSetAction _action;
    _secondaryAction buttonSetAction "";
} forEach _cardIdcs;

if ((count _entries) <= 0) then {
    private _firstCard = _cardIdcs select 0;
    private _background = _display displayCtrl (_firstCard select 0);
    private _imageArea = _display displayCtrl (_firstCard select 1);
    private _nameCtrl = _display displayCtrl (_firstCard select 3);
    private _statusCtrl = _display displayCtrl (_firstCard select 4);

    {
        _x ctrlShow true;
    } forEach [_background, _imageArea, _nameCtrl, _statusCtrl];

    _nameCtrl ctrlSetText "NO COMPATIBLE ATTACHMENTS";
    _statusCtrl ctrlSetText "FACTUAL COMPATIBILITY DATA UNAVAILABLE";
};
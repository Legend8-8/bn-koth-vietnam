/*
    File: fn_menu_selectConfigureAttachment.sqf
    Author: Legend
    Description: Stores a client-local attachment draft mutation for the
        current Configure weapon after validating the complete factual weapon,
        attachment, and selected-magazine composition. It submits no request.
    Execution: Client
    Parameters:
        0: Canonical weapon classname <STRING>
        1: Attachment classname <STRING>
        2: Mode: SELECT or REMOVE <STRING>
    Returns:
        True when the local draft is stored, otherwise false <BOOL>
    Public: No
*/

params [
    ["_weaponClass", "", [""]],
    ["_attachmentClass", "", [""]],
    ["_mode", "", [""]]
];

if (!hasInterface) exitWith {false};

_weaponClass = toLower _weaponClass;
_attachmentClass = toLower _attachmentClass;
_mode = toUpper _mode;
if (_weaponClass isEqualTo "" || {_attachmentClass isEqualTo ""}) exitWith {false};
if !(_mode in ["SELECT", "REMOVE"]) exitWith {false};

private _context = uiNamespace getVariable ["BN_KOTH_menuConfigureContext", createHashMap];
if !(_context isEqualType createHashMap) exitWith {false};
if !((toLower (_context getOrDefault ["weaponClass", ""])) isEqualTo _weaponClass) exitWith {false};

private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {false};
if !((_metadata getOrDefault ["canonicalClass", ""]) isEqualTo _weaponClass) exitWith {false};

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
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
if !(isClass (_sourceItemsCfg >> _attachmentClass)) exitWith {false};
if !(isClass (configFile >> "CfgWeapons" >> _attachmentClass)) exitWith {false};

private _attachmentMetadataCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Attachments" >> _attachmentClass;
private _isLocked = false;
if (isClass _attachmentMetadataCfg && {isNumber (_attachmentMetadataCfg >> "minLevel")}) then {
    private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
    if !(_progression isEqualType createHashMap) then {
        _progression = createHashMap;
    };

    private _playerLevel = (_progression getOrDefault ["level", 1]) max 1;
    private _minLevel = (getNumber (_attachmentMetadataCfg >> "minLevel")) max 1;
    _isLocked = _playerLevel < _minLevel;
};
if (_isLocked) exitWith {false};

private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
if !(_drafts isEqualType createHashMap) then {
    _drafts = createHashMap;
};

private _draft = _drafts getOrDefault [_weaponClass, createHashMap];
private _selectedMagazine = "";
private _selectedAttachments = [];
if (_draft isEqualType createHashMap) then {
    if ((toLower (_draft getOrDefault ["weaponClass", ""])) isEqualTo _weaponClass) then {
        _selectedMagazine = toLower (_draft getOrDefault ["magazineClass", ""]);
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
    };
};

private _proposedAttachments = +_selectedAttachments;
if (_mode isEqualTo "SELECT") then {
    _proposedAttachments pushBackUnique _attachmentClass;
} else {
    _proposedAttachments = _proposedAttachments - [_attachmentClass];
};
_proposedAttachments sort true;

private _magazines = if (_selectedMagazine isEqualTo "") then {[]} else {[_selectedMagazine]};
private _evaluation = [_weaponClass, _proposedAttachments, _magazines, _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
if !(_evaluation getOrDefault ["available", false]) exitWith {false};

private _canonicalAttachments = _evaluation getOrDefault ["attachments", []];
if !(_canonicalAttachments isEqualType []) then {
    _canonicalAttachments = [];
};

if (_selectedMagazine isEqualTo "" && {(count _canonicalAttachments) <= 0}) then {
    _drafts deleteAt _weaponClass;
} else {
    _drafts set [_weaponClass, createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["magazineClass", _selectedMagazine],
        ["attachments", _canonicalAttachments]
    ]];
};
uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _drafts];

['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;
true
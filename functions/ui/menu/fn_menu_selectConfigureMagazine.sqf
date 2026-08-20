/*
    File: fn_menu_selectConfigureMagazine.sqf
    Author: Legend
    Description: Validates one factual compatible magazine against the current
        Configure weapon context and stores a client-local composition draft.
        It does not submit gameplay intent or mutate loadout state.
    Execution: Client
    Parameters:
        0: Canonical weapon classname <STRING>
        1: Compatible magazine classname <STRING>
    Returns:
        True when the local draft is stored, otherwise false <BOOL>
    Public: No
*/

params [
    ["_weaponClass", "", [""]],
    ["_magazineClass", "", [""]]
];

if (!hasInterface) exitWith {false};

_weaponClass = toLower _weaponClass;
_magazineClass = toLower _magazineClass;
if (_weaponClass isEqualTo "" || {_magazineClass isEqualTo ""}) exitWith {false};

private _context = uiNamespace getVariable ["BN_KOTH_menuConfigureContext", createHashMap];
if !(_context isEqualType createHashMap) exitWith {false};
if !((_context getOrDefault ["weaponClass", ""]) isEqualTo _weaponClass) exitWith {false};

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
private _sourceMagazinesCfg = _compatibilityCfg >> "SourceMagazines";
if !(isClass (_sourceMagazinesCfg >> _magazineClass)) exitWith {false};
if !(isClass (configFile >> "CfgMagazines" >> _magazineClass)) exitWith {false};

private _drafts = uiNamespace getVariable ["BN_KOTH_menuConfigureDrafts", createHashMap];
if !(_drafts isEqualType createHashMap) then {
    _drafts = createHashMap;
};

private _draft = _drafts getOrDefault [_weaponClass, createHashMap];
private _selectedAttachments = [];
if (_draft isEqualType createHashMap) then {
    if ((toLower (_draft getOrDefault ["weaponClass", ""])) isEqualTo _weaponClass) then {
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

private _evaluation = [_weaponClass, _selectedAttachments, [_magazineClass], _compatibilityCfg] call bn_koth_fnc_menu_evaluateWeaponComposition;
if !(_evaluation getOrDefault ["available", false]) exitWith {false};

_drafts set [_weaponClass, createHashMapFromArray [
    ["weaponClass", _weaponClass],
    ["magazineClass", _magazineClass],
    ["attachments", _evaluation getOrDefault ["attachments", []]]
]];
uiNamespace setVariable ["BN_KOTH_menuConfigureDrafts", _drafts];

['LOADOUT_CONFIGURE'] call bn_koth_fnc_menu_refresh;
true
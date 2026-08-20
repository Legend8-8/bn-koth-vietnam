/*
    File: fn_menu_applyPrimary.sqf
    Author: Legend
    Description: Sends a complete primary weapon composition intent through the
        authoritative loadout request path. With no parameters, it uses the
        legacy selector pending-primary state.
    Execution: Client
    Parameters:
        0: Explicit canonical primary weapon classname (optional) <STRING>
        1: Explicit compatible magazine classname (optional) <STRING>
        2: Explicit compatible attachment classnames (optional) <ARRAY>
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

params [
    ["_explicitWeaponClass", "", [""]],
    ["_explicitMagazineClass", "", [""]],
    ["_explicitAttachments", [], [[]]]
];

if (!hasInterface) exitWith {false};

private _weaponClass = "";
private _magazineClass = "";
private _attachments = [];
private _available = false;
private _hasExplicitIntent = !(_explicitWeaponClass isEqualTo "") || {!(_explicitMagazineClass isEqualTo "")};

if (_hasExplicitIntent) then {
    _weaponClass = toLower _explicitWeaponClass;
    _magazineClass = toLower _explicitMagazineClass;
    {
        if (_x isEqualType "") then {
            private _attachmentClass = toLower _x;
            if !(_attachmentClass isEqualTo "") then {
                _attachments pushBackUnique _attachmentClass;
            };
        };
    } forEach _explicitAttachments;
    _attachments sort true;
    _available = !(_weaponClass isEqualTo "") && {!(_magazineClass isEqualTo "")};
} else {
    private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingPrimary", createHashMap];
    if !(_pending isEqualType createHashMap) exitWith {false};

    _weaponClass = _pending getOrDefault ["weaponClass", ""];
    _magazineClass = _pending getOrDefault ["magazineClass", ""];
    _available = _pending getOrDefault ["available", false];
};

if (!_available || {_weaponClass isEqualTo ""} || {_magazineClass isEqualTo ""}) exitWith {
    ["PRIMARY SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["primary", createHashMapFromArray [
            ["weaponClass", _weaponClass],
            ["magazines", [_magazineClass]],
            ["attachments", _attachments]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;

true

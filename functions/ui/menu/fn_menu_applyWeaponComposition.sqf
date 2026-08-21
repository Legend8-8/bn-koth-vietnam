/*
    File: fn_menu_applyWeaponComposition.sqf
    Author: Legend
    Description: Sends one complete weapon-slot composition intent, or an
        explicit empty-launcher intent, through the authoritative loadout
        request path.
    Execution: Client
    Parameters:
        0: Weapon slot: PRIMARY, HANDGUN, or LAUNCHER <STRING>
        1: Canonical weapon classname <STRING>
        2: Compatible magazine classname <STRING>
        3: Compatible attachment classnames <ARRAY>
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

params [
    ["_weaponSlot", "", [""]],
    ["_weaponClass", "", [""]],
    ["_magazineClass", "", [""]],
    ["_attachments", [], [[]]]
];

if (!hasInterface) exitWith {false};

_weaponSlot = toLower _weaponSlot;
_weaponClass = toLower _weaponClass;
_magazineClass = toLower _magazineClass;
if !(_weaponSlot in ["primary", "handgun", "launcher"]) exitWith {false};

private _isLauncherClear = (_weaponSlot isEqualTo "launcher") && {_weaponClass isEqualTo ""};
if (!_isLauncherClear && {_weaponClass isEqualTo "" || {_magazineClass isEqualTo ""}}) exitWith {false};
if (_isLauncherClear && {!(_magazineClass isEqualTo "") || {(count _attachments) > 0}}) exitWith {false};

private _canonicalAttachments = [];
{
    if (_x isEqualType "") then {
        private _attachmentClass = toLower _x;
        if !(_attachmentClass isEqualTo "") then {
            _canonicalAttachments pushBackUnique _attachmentClass;
        };
    };
} forEach _attachments;
_canonicalAttachments sort true;

private _magazines = if (_isLauncherClear) then {[]} else {[_magazineClass]};
private _weapons = createHashMap;
_weapons set [_weaponSlot, createHashMapFromArray [
    ["weaponClass", _weaponClass],
    ["magazines", _magazines],
    ["attachments", _canonicalAttachments]
]];

private _request = createHashMapFromArray [["weapons", _weapons]];
[_request] call bn_koth_fnc_loadouts_request;

true

/*
    File: fn_menu_applyPrimary.sqf
    Author: Legend
    Description: Sends the currently pending primary weapon intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingPrimary", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _weaponClass = _pending getOrDefault ["weaponClass", ""];
private _magazineClass = _pending getOrDefault ["magazineClass", ""];
private _available = _pending getOrDefault ["available", false];

if (!_available || {_weaponClass isEqualTo ""} || {_magazineClass isEqualTo ""}) exitWith {
    ["PRIMARY SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["primary", createHashMapFromArray [
            ["weaponClass", _weaponClass],
            ["magazines", [_magazineClass]],
            ["attachments", []]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["PRIMARY REQUEST SENT."] call bn_koth_fnc_ui_notify;

true

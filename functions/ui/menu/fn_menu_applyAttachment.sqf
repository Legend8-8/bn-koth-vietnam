/*
    File: fn_menu_applyAttachment.sqf
    Author: Legend
    Description: Sends pending weapon-attachment intent through the authoritative loadout mutation path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingAttachment", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];
private _weaponSlot = toLower (_pending getOrDefault ["weaponSlot", ""]);
private _attachmentClass = toLower (_pending getOrDefault ["attachmentClass", ""]);
private _mode = toLower (_pending getOrDefault ["mode", "add"]);

if (!_available || {!(_weaponSlot in ["primary", "launcher", "handgun"])} || {_attachmentClass isEqualTo ""} || {!(_mode in ["add", "remove"])}) exitWith {
    ["ATTACHMENT SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["mutation", createHashMapFromArray [
        ["op", "set_attachment"],
        ["weaponSlot", _weaponSlot],
        ["attachmentClass", _attachmentClass],
        ["mode", _mode]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
true

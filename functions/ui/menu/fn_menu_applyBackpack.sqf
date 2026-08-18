/*
    File: fn_menu_applyBackpack.sqf
    Author: Legend
    Description: Sends the currently pending backpack intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingBackpack", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

// "backpackClass" may legitimately be "" (NONE intent); guard only on the available flag.
private _backpackClass = _pending getOrDefault ["backpackClass", "UNSET"];
private _available = _pending getOrDefault ["available", false];

if (!_available || {!(_backpackClass isEqualType "")}) exitWith {
    ["BACKPACK SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["backpack", createHashMapFromArray [
            ["backpackClass", _backpackClass]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;

true

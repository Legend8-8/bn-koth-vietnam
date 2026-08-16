/*
    File: fn_menu_applyHeadgear.sqf
    Author: Legend
    Description: Sends the currently pending headgear intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingHeadgear", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];

// headgearClass may legitimately be "" (NONE intent); guard only on the available flag.
if (!_available || {!("headgearClass" in keys _pending)}) exitWith {
    ["HEADGEAR SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _headgearClass = _pending getOrDefault ["headgearClass", ""];

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["headgear", createHashMapFromArray [
            ["headgearClass", _headgearClass]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["HEADGEAR REQUEST SENT."] call bn_koth_fnc_ui_notify;

true

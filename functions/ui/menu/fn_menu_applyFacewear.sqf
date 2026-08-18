/*
    File: fn_menu_applyFacewear.sqf
    Author: Legend
    Description: Sends the currently pending facewear intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingFacewear", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];

// facewearClass may legitimately be "" (NONE intent); guard only on the available flag.
if (!_available || {!("facewearClass" in keys _pending)}) exitWith {
    ["FACEWEAR SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _facewearClass = _pending getOrDefault ["facewearClass", ""];

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["facewear", createHashMapFromArray [
            ["facewearClass", _facewearClass]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;

true

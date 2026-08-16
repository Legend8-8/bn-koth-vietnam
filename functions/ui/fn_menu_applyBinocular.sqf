/*
    File: fn_menu_applyBinocular.sqf
    Author: GitHub Copilot
    Description: Sends pending binocular intent through the authoritative loadout mutation path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingBinocular", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];
if (!_available || {!("binocularClass" in keys _pending)}) exitWith {
    ["BINOCULAR SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _binocularClass = _pending getOrDefault ["binocularClass", ""];

private _request = createHashMapFromArray [
    ["mutation", createHashMapFromArray [
        ["op", "set_binocular"],
        ["binocularClass", _binocularClass]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["BINOCULAR REQUEST SENT."] call bn_koth_fnc_ui_notify;
true

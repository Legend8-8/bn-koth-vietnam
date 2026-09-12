/*
    File: fn_menu_applyVest.sqf
    Author: Legend
    Description: Sends the currently pending vest intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingVest", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _vestClass = _pending getOrDefault ["vestClass", ""];
private _available = _pending getOrDefault ["available", false];

if (!_available || {_vestClass isEqualTo ""}) exitWith {
    ["VEST SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["vest", createHashMapFromArray [
            ["vestClass", _vestClass]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;

true

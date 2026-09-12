/*
    File: fn_menu_applyCargo.sqf
    Author: Legend
    Description: Sends pending cargo delta intent through the authoritative loadout mutation path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingCargo", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _available = _pending getOrDefault ["available", false];
private _container = toLower (_pending getOrDefault ["container", ""]);
private _className = toLower (_pending getOrDefault ["className", ""]);
private _delta = _pending getOrDefault ["delta", 0];

if (!_available || {!(_container in ["uniform", "vest", "backpack"])} || {_className isEqualTo ""} || {!(_delta isEqualType 0)} || {_delta isEqualTo 0}) exitWith {
    ["CARGO EDIT SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["mutation", createHashMapFromArray [
        ["op", "adjust_cargo"],
        ["container", _container],
        ["className", _className],
        ["delta", _delta]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
true

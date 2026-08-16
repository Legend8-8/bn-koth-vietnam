/*
    File: fn_menu_applyUniform.sqf
    Author: Legend
    Description: Sends the currently pending uniform intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingUniform", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _uniformClass = _pending getOrDefault ["uniformClass", ""];
private _available = _pending getOrDefault ["available", false];

if (!_available || {_uniformClass isEqualTo ""}) exitWith {
    ["UNIFORM SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["uniform", createHashMapFromArray [
            ["uniformClass", _uniformClass]
        ]]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["UNIFORM REQUEST SENT."] call bn_koth_fnc_ui_notify;

true

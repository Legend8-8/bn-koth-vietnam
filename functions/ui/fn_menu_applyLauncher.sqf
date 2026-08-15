/*
    File: fn_menu_applyLauncher.sqf
    Author: Legend
    Description: Sends the currently pending launcher intent through the authoritative loadout request path.
    Execution: Client
    Parameters:
        None
    Returns:
        True when request sent, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _pending = uiNamespace getVariable ["BN_KOTH_menuPendingLauncher", createHashMap];
if !(_pending isEqualType createHashMap) exitWith {false};

private _weaponClass = _pending getOrDefault ["weaponClass", ""];
private _magazineClass = _pending getOrDefault ["magazineClass", ""];
private _available = _pending getOrDefault ["available", false];

if !_available exitWith {
    ["LAUNCHER SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
    false
};

private _launcherIntent = if (_weaponClass isEqualTo "") then {
    // Explicit clear intent for "NONE" launcher selection.
    createHashMapFromArray [
        ["weaponClass", ""],
        ["magazines", []],
        ["attachments", []]
    ]
} else {
    if (_magazineClass isEqualTo "") exitWith {
        ["LAUNCHER SELECTION UNAVAILABLE."] call bn_koth_fnc_ui_notify;
        false
    };

    createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["magazines", [_magazineClass]],
        ["attachments", []]
    ]
};

if (_launcherIntent isEqualType false) exitWith {false};

private _request = createHashMapFromArray [
    ["weapons", createHashMapFromArray [
        ["launcher", _launcherIntent]
    ]]
];

[_request] call bn_koth_fnc_loadouts_request;
["LAUNCHER REQUEST SENT."] call bn_koth_fnc_ui_notify;

true

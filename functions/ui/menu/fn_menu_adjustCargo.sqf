/*
    File: fn_menu_adjustCargo.sqf
    Author: Legend
    Description: Converts one cargo card quantity click into the existing
        authoritative cargo mutation intent.
    Execution: Client
    Parameters:
        0: Container name <STRING>
        1: Item classname <STRING>
        2: Delta (-1|1) <NUMBER>
    Returns: True when submitted <BOOL>
    Public: No
*/

params [["_container", "", [""]], ["_className", "", [""]], ["_delta", 0, [0]]];
if (!hasInterface) exitWith {false};
if !((toLower _container) in ["uniform", "vest", "backpack"]) exitWith {false};
if (_className isEqualTo "") exitWith {false};
if !(_delta in [-1, 1]) exitWith {false};

uiNamespace setVariable ["BN_KOTH_menuPendingCargo", createHashMapFromArray [
    ["container", toLower _container],
    ["className", toLower _className],
    ["delta", _delta],
    ["available", true]
]];
call bn_koth_fnc_menu_applyCargo

/*
    File: fn_menu_open.sqf
    Author: Legend
    Description: Opens the deployed menu on the local client.
    Execution: Client
    Parameters:
        0: Arsenal capability requested by the local menu opener <BOOL> (optional, default false)
    Returns:
        True when open, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [
    ["_arsenalEnabled", false, [true]]
];

if (!hasInterface) exitWith {false};

uiNamespace setVariable ["BN_KOTH_menuArsenalEnabled", _arsenalEnabled];

disableSerialization;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};

if (!isNull _display) exitWith {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
    [createHashMapFromArray [["mutation", createHashMapFromArray [["op", "snapshot"]]]]] call bn_koth_fnc_loadouts_request;
    true
};

private _opened = createDialog "BN_KOTH_RscMenu";
if (_opened) then {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
    [createHashMapFromArray [["mutation", createHashMapFromArray [["op", "snapshot"]]]]] call bn_koth_fnc_loadouts_request;
};

_opened

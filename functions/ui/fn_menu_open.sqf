/*
    File: fn_menu_open.sqf
    Author: GitHub Copilot
    Description: Opens the deployed menu on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        True when open, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\ui\menu\idcs.hpp"

if (!hasInterface) exitWith {false};

disableSerialization;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};

if (!isNull _display) exitWith {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
    true
};

private _opened = createDialog "BN_KOTH_RscMenu";
if (_opened) then {
    ['LOADOUT'] call bn_koth_fnc_menu_refresh;
};

_opened

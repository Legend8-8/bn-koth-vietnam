/*
    File: fn_menu_close.sqf
    Author: Legend
    Description: Closes the deployed menu on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"

if (!hasInterface) exitWith {};

disableSerialization;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_MENU;
};

if (!isNull _display) then {
    _display closeDisplay 2;
};

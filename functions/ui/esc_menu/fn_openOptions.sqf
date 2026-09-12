/*
    File: fn_openOptions.sqf
    Author: tylervip
    Description: Opens the ESC options display.
    Execution: Client
    Parameters:
        0: Parent display (optional) <DISPLAY>
    Returns:
        True when opened/already open <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\esc_menu\idcs.hpp"

params [["_parentDisplay", displayNull, [displayNull]]];

if (!hasInterface) exitWith {false};
if (!isNull (findDisplay BN_KOTH_IDD_ESC_MENU_OPTIONS)) exitWith {true};

if (!isNull _parentDisplay) exitWith {!isNull (_parentDisplay createDisplay "BN_KOTH_RscEscMenuOptions")};
createDialog "BN_KOTH_RscEscMenuOptions";

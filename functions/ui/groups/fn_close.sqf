/*
    File: fn_close.sqf
    Author: Legend
    Description: Closes the custom Group Menu.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

#include "..\..\..\ui\groups\idcs.hpp"

if (!hasInterface) exitWith {};
private _display = uiNamespace getVariable ["BN_KOTH_groupMenuDisplay", displayNull];
if (isNull _display) then {_display = findDisplay BN_KOTH_IDD_GROUP_MENU};
if (!isNull _display) then {_display closeDisplay 2};
uiNamespace setVariable ["BN_KOTH_groupMenuMode", "MAIN"];

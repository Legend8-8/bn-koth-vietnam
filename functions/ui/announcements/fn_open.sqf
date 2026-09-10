/*
    File: fn_open.sqf
    Author: Legend
    Description: Opens the active announcement in the shared modal display.
    Execution: Client
    Parameters:
        0: Announcement notice control <CONTROL>
    Returns: True when the popup is open, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\announcements\idcs.hpp"

params [["_control", controlNull, [controlNull]]];

if (!hasInterface) exitWith {false};
if (isNull ([] call bn_koth_fnc_announcements_getActive)) exitWith {false};

private _existing = uiNamespace getVariable ["BN_KOTH_announcementPopupDisplay", displayNull];
if (isNull _existing) then {_existing = findDisplay BN_KOTH_IDD_ANNOUNCEMENT_POPUP};
if (!isNull _existing) exitWith {true};

private _parent = if (isNull _control) then {displayNull} else {ctrlParent _control};
if (isNull _parent) exitWith {false};

!isNull (_parent createDisplay "BN_KOTH_RscAnnouncementPopup")

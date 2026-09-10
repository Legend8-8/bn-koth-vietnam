/*
    File: fn_popupOnLoad.sqf
    Author: Legend
    Description: Populates the shared announcement popup from mission config.
    Execution: Client
    Parameters:
        0: Announcement popup display <DISPLAY>
    Returns: None
    Public: Yes
*/

#include "..\..\..\ui\announcements\idcs.hpp"

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
uiNamespace setVariable ["BN_KOTH_announcementPopupDisplay", _display];

private _announcement = [] call bn_koth_fnc_announcements_getActive;
if (isNull _announcement) exitWith {_display closeDisplay 2};

private _titleControl = _display displayCtrl BN_KOTH_IDC_ANNOUNCEMENT_POPUP_TITLE;
private _bodyControl = _display displayCtrl BN_KOTH_IDC_ANNOUNCEMENT_POPUP_BODY;
if (isNull _titleControl || {isNull _bodyControl}) exitWith {_display closeDisplay 2};

_titleControl ctrlSetText getText (_announcement >> "popupTitle");
_bodyControl ctrlSetStructuredText parseText getText (_announcement >> "popupText");

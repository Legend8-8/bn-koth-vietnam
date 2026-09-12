/*
    File: fn_configureControl.sqf
    Author: Legend
    Description: Applies the active announcement to a reusable notice control.
    Execution: Client
    Parameters:
        0: Announcement notice control <CONTROL>
    Returns: True when an enabled announcement is shown, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\..\ui\menu\idcs.hpp"
#include "..\..\..\ui\announcements\idcs.hpp"

params [["_control", controlNull, [controlNull]]];

if (!hasInterface || {isNull _control}) exitWith {false};

private _parentDisplay = ctrlParent _control;
private _isMenuControl =
    (ctrlIDD _parentDisplay) isEqualTo BN_KOTH_IDD_MENU &&
    {(ctrlIDC _control) isEqualTo BN_KOTH_IDC_ANNOUNCEMENT_NOTICE};

private _announcement = [] call bn_koth_fnc_announcements_getActive;
if (isNull _announcement) exitWith {
    _control ctrlShow false;
    _control ctrlEnable false;
    false
};

private _title = getText (_announcement >> "title");
private _subtitle = getText (_announcement >> "subtitle");

if (_isMenuControl) then {
    private _pos = ctrlPosition _control;
    _control ctrlSetPosition [
        _pos select 0,
        (_pos select 1) + safeZoneH * 0.008,
        _pos select 2,
        (_pos select 3) - safeZoneH * 0.008
    ];
    _control ctrlCommit 0;

    _control ctrlSetStructuredText parseText format [
        "<t align='center' font='PuristaSemiBold' size='1.15'>%1</t><br/><t align='center' size='0.68'>%2</t>",
        _title,
        _subtitle
    ];
} else {
    _control ctrlSetStructuredText parseText format [
        "<t font='PuristaSemiBold' size='1.15'>%1</t><br/><t size='0.68'>%2</t>",
        _title,
        _subtitle
    ];
};

_control ctrlShow true;
_control ctrlEnable true;

if !(_control getVariable ["BN_KOTH_announcementConfigured", false]) then {
    _control setVariable ["BN_KOTH_announcementConfigured", true];

    _control ctrlAddEventHandler ["MouseButtonClick", {
        params ["_control", "_button"];
        if (_button isEqualTo 0) then {
            [_control] call bn_koth_fnc_announcements_open;
        };
    }];

    _control ctrlAddEventHandler ["MouseEnter", {
        params ["_control"];
        _control ctrlSetBackgroundColor [0.62, 0.17, 0.09, 1];
    }];

    _control ctrlAddEventHandler ["MouseExit", {
        params ["_control"];
        _control ctrlSetBackgroundColor [0.48, 0.12, 0.075, 0.96];
    }];
};

true

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

params [["_control", controlNull, [controlNull]]];

if (!hasInterface || {isNull _control}) exitWith {false};

private _announcement = [] call bn_koth_fnc_announcements_getActive;
if (isNull _announcement) exitWith {
    _control ctrlShow false;
    _control ctrlEnable false;
    false
};

private _title = getText (_announcement >> "title");
private _subtitle = getText (_announcement >> "subtitle");
_control ctrlSetStructuredText parseText format [
    "<t font='PuristaSemiBold' size='1.15'>%1</t><br/><t size='0.68'>%2</t>",
    _title,
    _subtitle
];
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

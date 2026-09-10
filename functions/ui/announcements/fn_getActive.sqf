/*
    File: fn_getActive.sqf
    Author: Legend
    Description: Resolves the single enabled player-facing announcement.
    Execution: Client
    Parameters: None
    Returns: Active announcement config, otherwise configNull <CONFIG>
    Public: No
*/

private _root = missionConfigFile >> "CfgBnKothAnnouncements";
if !(isClass _root) exitWith {configNull};

private _activeName = getText (_root >> "activeAnnouncement");
if (_activeName isEqualTo "") exitWith {configNull};

private _announcement = _root >> _activeName;
if !(isClass _announcement) exitWith {configNull};
if ((getNumber (_announcement >> "enabled")) <= 0) exitWith {configNull};

private _requiredText = ["title", "subtitle", "popupTitle", "popupText"];
if (_requiredText findIf {getText (_announcement >> _x) isEqualTo ""} >= 0) exitWith {configNull};

_announcement

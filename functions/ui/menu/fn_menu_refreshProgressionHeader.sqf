/*
    File: fn_menu_refreshProgressionHeader.sqf
    Author: Legend
    Description: Refreshes only the deployed-menu progression header from the
        local authoritative presentation copy.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];

if (!hasInterface || {isNull _display}) exitWith {};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {
    _progression = createHashMap;
};

private _level = (_progression getOrDefault ["level", 1]) max 1;
private _xp = (_progression getOrDefault ["xp", 0]) max 0;
private _cash = (_progression getOrDefault ["cash", 0]) max 0;

private _levelProgress = [_xp, _level] call bn_koth_fnc_progression_xp_getLevelProgress;
_level = _levelProgress getOrDefault ["level", 1];
private _maxLevel = _levelProgress getOrDefault ["maxLevel", 270];
private _xpIntoLevel = _levelProgress getOrDefault ["xpIntoLevel", 0];
private _xpRequired = _levelProgress getOrDefault ["xpRequired", 0];
private _xpRatio = _levelProgress getOrDefault ["ratio", 1];
private _rank = [_level] call bn_koth_fnc_progression_resolveRankPresentation;

private _ctrlHeaderLevel = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_LEVEL;
private _ctrlHeaderXp = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_XP;
private _ctrlHeaderCash = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_CASH;
private _ctrlHeaderRankBadge = _display displayCtrl BN_KOTH_IDC_MENU_HEADER_RANK_BADGE;
private _ctrlHeaderXpTrack = _display displayCtrl BN_KOTH_IDC_MENU_BG_XP_TRACK;
private _ctrlHeaderXpFill = _display displayCtrl BN_KOTH_IDC_MENU_BG_XP_FILL;

_ctrlHeaderRankBadge ctrlSetText (_rank getOrDefault ["icon", ""]);
_ctrlHeaderRankBadge ctrlSetTextColor (_rank getOrDefault ["color", [1, 1, 1, 0]]);
_ctrlHeaderRankBadge ctrlShow (_rank getOrDefault ["hasIcon", false]);
_ctrlHeaderLevel ctrlSetText format ["LEVEL %1", _level];

if (_level >= _maxLevel) then {
    _ctrlHeaderXp ctrlSetText format ["MAX LEVEL  |  %1 XP", _xp];
} else {
    _ctrlHeaderXp ctrlSetText format ["%1 / %2 XP", round _xpIntoLevel, round _xpRequired];
};
_ctrlHeaderCash ctrlSetText ([_cash] call bn_koth_fnc_ui_formatCash);

private _trackPos = ctrlPosition _ctrlHeaderXpTrack;
_ctrlHeaderXpFill ctrlSetPosition [
    _trackPos select 0,
    _trackPos select 1,
    (_trackPos select 2) * _xpRatio,
    _trackPos select 3
];
_ctrlHeaderXpFill ctrlCommit 0;

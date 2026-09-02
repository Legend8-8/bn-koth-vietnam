/*
    File: fn_menu_refreshProgression.sqf
    Author: Legend
    Description: Renders the fixed-control weapon mastery page from
        the local authoritative progression projection and authored metadata.
    Execution: Client
    Parameters:
        0: Menu display <DISPLAY>
    Returns: None
    Public: No
*/

#include "..\..\..\ui\menu\idcs.hpp"

params [["_display", displayNull, [displayNull]]];
if (!hasInterface || {isNull _display}) exitWith {};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};

private _level = (_progression getOrDefault ["level", 1]) max 1;
private _xp = (_progression getOrDefault ["xp", 0]) max 0;
private _levelProgress = [_xp, _level] call bn_koth_fnc_progression_xp_getLevelProgress;
private _xpRatio = ((_levelProgress getOrDefault ["ratio", 0]) max 0) min 1;
private _rank = [_level] call bn_koth_fnc_progression_resolveRankPresentation;

(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_TITLE) ctrlSetText "WEAPON MASTERY";
(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_SUBTITLE) ctrlSetText "TRACK YOUR WEAPON MASTERY";
private _rankCtrl = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_RANK;
_rankCtrl ctrlSetText (_rank getOrDefault ["icon", ""]);
_rankCtrl ctrlSetTextColor (_rank getOrDefault ["color", [1,1,1,0]]);
_rankCtrl ctrlShow (_rank getOrDefault ["hasIcon", false]);
(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_LEVEL) ctrlSetText format ["LEVEL %1", _level];
private _maxLevel = _levelProgress getOrDefault ["maxLevel", 270];
(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP) ctrlSetText (if (_level >= _maxLevel) then {format ["MAX LEVEL  |  %1 XP", round _xp]} else {format ["%1 / %2 XP", round (_levelProgress getOrDefault ["xpIntoLevel", 0]), round (_levelProgress getOrDefault ["xpRequired", 0])]});
private _xpTrack = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP_TRACK;
private _xpFill = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_XP_FILL;
private _xpPos = ctrlPosition _xpTrack;
_xpFill ctrlSetPosition [_xpPos select 0, _xpPos select 1, (_xpPos select 2) * _xpRatio, _xpPos select 3];
_xpFill ctrlCommit 0;

(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_HELP) ctrlSetStructuredText parseText "<t font='RobotoCondensed' size='0.82' color='#EFCB57'>HOW MASTERY WORKS</t><br/><t font='RobotoCondensed' size='0.66'>Valid kills with a weapon build its Mastery. Completing Mastery allows eligible cross-faction use once Level, required Perks, side policy and acquisition requirements are met. Mastery does not grant ownership or bypass those requirements. You can build Mastery before reaching the weapon's required Level.</t>";

private _catalogue = uiNamespace getVariable ["BN_KOTH_menuMasteryCatalogue", []];
if !(_catalogue isEqualType []) then {_catalogue = []};
if ((count _catalogue) == 0) then {
    private _weaponsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Weapons";
    private _sortable = [];
    if (isClass _weaponsCfg) then {
        {
            private _weaponClass = toLower (configName _x);
            private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
            private _required = floor ((_metadata getOrDefault ["masteryKillsRequired", 0]) max 0);
            if !(_metadata getOrDefault ["success", false] && {_metadata getOrDefault ["configured", false]} && {_required > 0} && {(_metadata getOrDefault ["canonicalClass", ""]) isEqualTo _weaponClass}) then {continue};
            private _weaponCfg = configFile >> "CfgWeapons" >> _weaponClass;
            if !(isClass _weaponCfg) then {continue};
            private _displayName = getText (_weaponCfg >> "displayName");
            if (_displayName isEqualTo "") then {_displayName = toUpper _weaponClass};
            private _entry = createHashMapFromArray [
                ["weaponClass", _weaponClass], ["displayName", _displayName],
                ["picture", getText (_weaponCfg >> "picture")], ["required", _required]
            ];
            _sortable pushBack [format ["%1|%2", toLower _displayName, _weaponClass], _entry];
        } forEach ("true" configClasses _weaponsCfg);
    };
    _sortable sort true;
    {_catalogue pushBack (_x select 1)} forEach _sortable;
    uiNamespace setVariable ["BN_KOTH_menuMasteryCatalogue", _catalogue];
};

private _filter = toUpper (uiNamespace getVariable ["BN_KOTH_menuMasteryFilter", "IN_PROGRESS"]);
if !(_filter in ["IN_PROGRESS", "COMPLETED", "ALL"]) then {_filter = "IN_PROGRESS"};
uiNamespace setVariable ["BN_KOTH_menuMasteryFilter", _filter];
{
    _x params ["_idc", "_value"];
    private _ctrl = _display displayCtrl _idc;
    private _selected = _filter isEqualTo _value;
    _ctrl ctrlSetBackgroundColor (if (_selected) then {[0.27,0.19,0.08,0.98]} else {[0.08,0.08,0.07,0.92]});
    _ctrl ctrlSetTextColor (if (_selected) then {[0.94,0.80,0.34,1]} else {[0.92,0.92,0.88,0.96]});
} forEach [[BN_KOTH_IDC_MENU_MASTERY_FILTER_PROGRESS,"IN_PROGRESS"],[BN_KOTH_IDC_MENU_MASTERY_FILTER_COMPLETED,"COMPLETED"],[BN_KOTH_IDC_MENU_MASTERY_FILTER_ALL,"ALL"]];

private _cards = [
    [BN_KOTH_IDC_MENU_MASTERY_CARD_1_BG,BN_KOTH_IDC_MENU_MASTERY_CARD_1_IMAGE,BN_KOTH_IDC_MENU_MASTERY_CARD_1_NAME,BN_KOTH_IDC_MENU_MASTERY_CARD_1_STATUS,BN_KOTH_IDC_MENU_MASTERY_CARD_1_TRACK,BN_KOTH_IDC_MENU_MASTERY_CARD_1_FILL,BN_KOTH_IDC_MENU_MASTERY_CARD_1_PERCENT],
    [BN_KOTH_IDC_MENU_MASTERY_CARD_2_BG,BN_KOTH_IDC_MENU_MASTERY_CARD_2_IMAGE,BN_KOTH_IDC_MENU_MASTERY_CARD_2_NAME,BN_KOTH_IDC_MENU_MASTERY_CARD_2_STATUS,BN_KOTH_IDC_MENU_MASTERY_CARD_2_TRACK,BN_KOTH_IDC_MENU_MASTERY_CARD_2_FILL,BN_KOTH_IDC_MENU_MASTERY_CARD_2_PERCENT],
    [BN_KOTH_IDC_MENU_MASTERY_CARD_3_BG,BN_KOTH_IDC_MENU_MASTERY_CARD_3_IMAGE,BN_KOTH_IDC_MENU_MASTERY_CARD_3_NAME,BN_KOTH_IDC_MENU_MASTERY_CARD_3_STATUS,BN_KOTH_IDC_MENU_MASTERY_CARD_3_TRACK,BN_KOTH_IDC_MENU_MASTERY_CARD_3_FILL,BN_KOTH_IDC_MENU_MASTERY_CARD_3_PERCENT],
    [BN_KOTH_IDC_MENU_MASTERY_CARD_4_BG,BN_KOTH_IDC_MENU_MASTERY_CARD_4_IMAGE,BN_KOTH_IDC_MENU_MASTERY_CARD_4_NAME,BN_KOTH_IDC_MENU_MASTERY_CARD_4_STATUS,BN_KOTH_IDC_MENU_MASTERY_CARD_4_TRACK,BN_KOTH_IDC_MENU_MASTERY_CARD_4_FILL,BN_KOTH_IDC_MENU_MASTERY_CARD_4_PERCENT]
];
{
    {(_display displayCtrl _x) ctrlShow false} forEach _x;
} forEach _cards;

private _pageSize = count _cards;
private _requestedPage = uiNamespace getVariable ["BN_KOTH_menuMasteryPage", 0];
private _projection = [_catalogue, _weaponKills, _filter, _requestedPage, _pageSize] call bn_koth_fnc_menu_projectMasteryEntries;
private _entries = _projection getOrDefault ["entries", []];
private _pageEntries = _projection getOrDefault ["pageEntries", []];
private _page = _projection getOrDefault ["page", 0];
private _pageCount = _projection getOrDefault ["pageCount", 1];
uiNamespace setVariable ["BN_KOTH_menuMasteryPage", _page];
private _previous = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_PREVIOUS;
private _next = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_NEXT;
(_display displayCtrl BN_KOTH_IDC_MENU_MASTERY_PAGE_LABEL) ctrlSetText format ["PAGE %1 / %2", _page + 1, _pageCount];
_previous ctrlEnable (_page > 0); _next ctrlEnable (_page < (_pageCount - 1));
_previous buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuMasteryPage',0]; uiNamespace setVariable ['BN_KOTH_menuMasteryPage',(_p-1) max 0]; [uiNamespace getVariable ['BN_KOTH_menuDisplay',displayNull]] call bn_koth_fnc_menu_refreshProgression;";
_next buttonSetAction "private _p=uiNamespace getVariable ['BN_KOTH_menuMasteryPage',0]; uiNamespace setVariable ['BN_KOTH_menuMasteryPage',_p+1]; [uiNamespace getVariable ['BN_KOTH_menuDisplay',displayNull]] call bn_koth_fnc_menu_refreshProgression;";

{
    (_cards select _forEachIndex) params ["_bgIdc","_imageIdc","_nameIdc","_statusIdc","_trackIdc","_fillIdc","_percentIdc"];
    private _bg = _display displayCtrl _bgIdc; private _image = _display displayCtrl _imageIdc; private _name = _display displayCtrl _nameIdc;
    private _status = _display displayCtrl _statusIdc; private _track = _display displayCtrl _trackIdc; private _fill = _display displayCtrl _fillIdc; private _percent = _display displayCtrl _percentIdc;
    {_x ctrlShow true} forEach [_bg,_image,_name,_status,_track,_fill,_percent];
    private _complete = _x get "complete"; private _ratio = _x get "ratio"; private _kills = _x get "kills"; private _required = _x get "required";
    _bg ctrlSetBackgroundColor (if (_complete) then {[0.20,0.15,0.07,0.98]} else {[0.075,0.075,0.065,0.96]});
    _image ctrlSetText (_x getOrDefault ["picture", ""]);
    _name ctrlSetText (toUpper (_x get "displayName"));
    _name ctrlSetFontHeight (safeZoneH * 0.024);
    private _availableWidth = (ctrlPosition _name) select 2;
    private _renderedWidth = ctrlTextWidth _name;
    if (_renderedWidth > _availableWidth && {_renderedWidth > 0}) then {_name ctrlSetFontHeight ((safeZoneH * 0.024 * (_availableWidth / _renderedWidth)) max (safeZoneH * 0.017))};
    _status ctrlSetText (if (_complete) then {format ["MASTERED  |  %1 / %2 KILLS", _kills, _required]} else {format ["%1 / %2 KILLS", _kills, _required]});
    _status ctrlSetTextColor (if (_complete) then {[0.94,0.80,0.34,1]} else {[0.82,0.82,0.77,1]});
    _percent ctrlSetText (if (_complete) then {"MASTERED"} else {format ["%1%2", floor (_ratio * 100), "%"]});
    _percent ctrlSetTextColor (if (_complete) then {[0.94,0.80,0.34,1]} else {[0.82,0.82,0.77,1]});
    private _trackPos = ctrlPosition _track;
    _fill ctrlSetPosition [_trackPos select 0, _trackPos select 1, (_trackPos select 2) * _ratio, _trackPos select 3];
    _fill ctrlSetBackgroundColor (if (_complete) then {[0.94,0.72,0.20,1]} else {[0.76,0.58,0.20,1]});
    _fill ctrlCommit 0;
} forEach _pageEntries;

private _empty = _display displayCtrl BN_KOTH_IDC_MENU_MASTERY_EMPTY;
private _isEmpty = (count _entries) == 0;
_empty ctrlShow _isEmpty;
if (_isEmpty) then {
    private _message = switch (_filter) do {
        case "COMPLETED": {"<t align='center' font='RobotoCondensedBold' size='1.20'>NO WEAPONS MASTERED YET</t><br/><t align='center' font='RobotoCondensed' size='0.90' color='#AAA99F'>Complete a weapon's Mastery requirement to add it here.</t>"};
        case "ALL": {"<t align='center' font='RobotoCondensedBold' size='1.20'>NO WEAPON MASTERY AVAILABLE</t><br/><t align='center' font='RobotoCondensed' size='0.90' color='#AAA99F'>No valid mastery metadata is currently authored.</t>"};
        default {"<t align='center' font='RobotoCondensedBold' size='1.20'>NO WEAPON MASTERY IN PROGRESS</t><br/><t align='center' font='RobotoCondensed' size='0.90' color='#AAA99F'>Valid weapon kills will begin filling this list.</t>"};
    };
    _empty ctrlSetStructuredText parseText _message;
};

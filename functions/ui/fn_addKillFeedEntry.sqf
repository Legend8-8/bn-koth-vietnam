/*
    File: fn_addKillFeedEntry.sqf
    Author: SpadeMe
    Description: Renders one kill feed entry, top-right. Presentation only -
        this function never decides whether a kill counts, how much detail
        to show, or who should see it; combat_publishKillFeed already
        decided that server-side and this just displays what arrived.
    Execution: Client
    Parameters:
        0: STRING - _type        ("kill" / "suicide" / "environment" / "down")
        1: STRING - _killerName
        2: STRING - _killerSide   ("WEST" / "EAST" / "GUER" / "CIV" / "UNKNOWN")
        3: STRING - _weapon       (display name, may be "")
        4: STRING - _victimName
        5: STRING - _victimSide   ("WEST" / "EAST" / "GUER" / "CIV" / "UNKNOWN")
        6: STRING - _distText     (already-rounded, e.g. "~120m", or "")
    Returns:
        None
    Public: Yes
*/

params ["_type", "_killerName", "_killerSide", "_weapon", "_victimName", "_victimSide", "_distText", ["_weaponPicture", "", [""]]];

if (!hasInterface) exitWith {};

#define BN_KOTH_KF_MAX_ENTRIES 5
#define BN_KOTH_KF_LIFETIME    6
#define BN_KOTH_KF_FADE_TIME   1
#define BN_KOTH_KF_ENTRY_W     0.24
#define BN_KOTH_KF_ENTRY_H     0.024
#define BN_KOTH_KF_SPACING     0.0015
#define BN_KOTH_KF_MARGIN      0.005
#define BN_KOTH_KF_TOP_OFFSET  0.1

private _display = uiNamespace getVariable ["BN_KOTH_killFeedDisplay", displayNull];
if (isNull _display) then {
    private _layer = "BN_KOTH_KillFeed" call BIS_fnc_rscLayer;
    _layer cutRsc ["BN_KOTH_RscKillFeed", "PLAIN", 0, false];

    _display = uiNamespace getVariable ["BN_KOTH_killFeedDisplay", displayNull];
};
if (isNull _display) exitWith {};

private _colorFor = {
    switch (toUpper _this) do {
        case "WEST": {"#5DA9E9"};
        case "EAST": {"#E96A6A"};
        case "GUER": {"#7FC97F"};
        case "CIV":  {"#E9D75D"};
        default      {"#C8C8C8"};
    };
};

private _escapeStructuredText = {
    params [["_value", "", [""]]];

    private _escaped = "";
    {
        _escaped = _escaped + (switch (_x) do {
            case 38: {"&amp;"};
            case 60: {"&lt;"};
            case 62: {"&gt;"};
            default {toString [_x]};
        });
    } forEach (toArray _value);

    _escaped
};

private _limitNameLength = {
    params [["_value", "", [""]], ["_maxChars", 24, [0]]];

    private _chars = toArray _value;
    if ((count _chars) > _maxChars) then {
        toString (_chars select [0, _maxChars])
    } else {
        _value
    };
};

private _killerNameDisplay = [_killerName] call _limitNameLength;
private _victimNameDisplay = [_victimName] call _limitNameLength;
_killerName = [_killerNameDisplay] call _escapeStructuredText;
_victimName = [_victimNameDisplay] call _escapeStructuredText;

private _weaponTag = if (_weaponPicture isEqualTo "") then {""} else {
    format [" <img image='%1' size='0.65' /> ", _weaponPicture]
};

private _text = switch (_type) do {
    case "kill": {
        format [
            "<t align='right' color='%1'>%2</t>%3<t align='right' color='#999999'>killed</t> <t align='right' color='%4'>%5</t> <t align='right' color='#777777' size='0.8'>%6</t>",
            (_killerSide call _colorFor), _killerName, _weaponTag,
            (_victimSide call _colorFor), _victimName,
            _distText
        ];
    };
    case "suicide": {
        format [
            "<t align='right' color='%1'>%2</t> <t align='right' color='#999999'>died by own hand</t>",
            (_victimSide call _colorFor), _victimName
        ];
    };
    case "down": {
        format [
            "<t align='right' color='%1'>%2</t> <t align='right' color='#999999'>is down</t>",
            (_victimSide call _colorFor), _victimName
        ];
    };
    default {
        format [
            "<t align='right' color='%1'>%2</t> <t align='right' color='#999999'>died</t>",
            (_victimSide call _colorFor), _victimName
        ];
    };
};

private _maxRowWidth = 1;
private _w = BN_KOTH_KF_ENTRY_W * safeZoneW;
private _h = BN_KOTH_KF_ENTRY_H * safeZoneH;

private _fncReposition = {
    params ["_list", "_posX", "_w", "_h"];

    {
        _x params ["_group"];
        private _posY = (safeZoneY + (BN_KOTH_KF_TOP_OFFSET * safeZoneH))
            + (_forEachIndex * ((BN_KOTH_KF_ENTRY_H + BN_KOTH_KF_SPACING) * safeZoneH));

        _group ctrlSetPosition [_posX, _posY, _w, _h];
        _group ctrlCommit 0.15;
    } forEach _list;
};

private _entries = uiNamespace getVariable ["BN_KOTH_killFeedEntries", []];

if (count _entries >= BN_KOTH_KF_MAX_ENTRIES) then {
    (_entries select 0) params ["_oldGroup"];
    if !(isNull _oldGroup) then {
        ctrlDelete _oldGroup;
    };
    _entries deleteAt 0;
};

private _tableGroup = _display ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_tableGroup ctrlSetBackgroundColor [0, 0, 0, 0];

private _isKillType = _type isEqualTo "kill";
private _showKiller = _isKillType;
private _showImage = _isKillType && !(_weaponPicture isEqualTo "");
private _showKilledLabel = _isKillType;
private _showDistance = _isKillType;

private _killedLabelText = if (_isKillType) then { "killed" } else { "" };

private _killerChars = count toArray _killerNameDisplay;
private _victimChars = count toArray _victimNameDisplay;
private _baseKillerWidth = if (_showKiller) then { 0.22 + (_killerChars * 0.0062) } else { 0 };
private _baseVictimWidth = if (_showKiller) then { 0.22 + (_victimChars * 0.0062) } else { 0.22 + (_victimChars * 0.0066) };
private _imageWidth = if (_showImage) then { 0.045 } else { 0 };
private _imageHeight = _h * 1.18;
private _killedWidth = if (_showKilledLabel) then { 0.055 } else { 0 };
private _distWidth = if (_showDistance) then { 0.08 } else { 0 };

private _killerWidth = if (_showKiller) then { (_baseKillerWidth min 0.42) max 0.22 } else { 0 };
private _victimWidth = if (_showKiller) then { (_baseVictimWidth min 0.42) max 0.22 } else { (_baseVictimWidth min 0.42) max 0.22 };

private _contentWidth = _killerWidth + _imageWidth + _killedWidth + _victimWidth + _distWidth + 0.03;
private _rowWidth = (_contentWidth min _maxRowWidth) max 0.40;
private _ctrlX = safeZoneX + safeZoneW - _rowWidth - (BN_KOTH_KF_MARGIN * safeZoneW);

private _mainText = switch (_type) do {
    case "kill": {""};
    case "suicide": {format ["<t align='right' noWrap='1' color='%1'>%2</t><t align='right' noWrap='1' color='#999999'> died by own hand</t>", (_victimSide call _colorFor), _victimName]};
    case "down": {format ["<t align='right' noWrap='1' color='%1'>%2</t><t align='right' noWrap='1' color='#999999'> is down</t>", (_victimSide call _colorFor), _victimName]};
    default {format ["<t align='right' noWrap='1' color='%1'>%2</t><t align='right' noWrap='1' color='#999999'> died</t>", (_victimSide call _colorFor), _victimName]};
};

private _xCursor = 0;

private _killerCtrl = objNull;
if (_showKiller) then {
    _killerCtrl = _display ctrlCreate ["RscStructuredText", -1, _tableGroup];
    _killerCtrl ctrlSetStructuredText (parseText format ["<t align='right' valign='middle' noWrap='1' color='%1'>%2</t>", (_killerSide call _colorFor), _killerName]);
    _killerCtrl ctrlSetPosition [0, 0, _killerWidth, _h];
    _killerCtrl ctrlCommit 0;
    _xCursor = _xCursor + _killerWidth + 0.008;
};

private _imageCtrl = objNull;
if (_showImage) then {
    _imageCtrl = _display ctrlCreate ["RscPictureKeepAspect", -1, _tableGroup];
    _imageCtrl ctrlSetText _weaponPicture;
    _imageCtrl ctrlSetPosition [_xCursor, ((_h - _imageHeight) * 0.5), _imageWidth, _imageHeight];
    _imageCtrl ctrlCommit 0;
    _xCursor = _xCursor + _imageWidth + 0.008;
};

private _killedCtrl = objNull;
if (_showKilledLabel) then {
    _killedCtrl = _display ctrlCreate ["RscText", -1, _tableGroup];
    _killedCtrl ctrlSetText _killedLabelText;
    _killedCtrl ctrlSetTextColor [0.7, 0.7, 0.7, 1];
    _killedCtrl ctrlSetPosition [_xCursor, 0, _killedWidth, _h];
    _killedCtrl ctrlCommit 0;
    _xCursor = _xCursor + _killedWidth + 0.008;
};

private _distCtrl = objNull;
if (_showDistance) then {
    _distCtrl = _display ctrlCreate ["RscStructuredText", -1, _tableGroup];
    _distCtrl ctrlSetStructuredText (parseText format ["<t align='center' valign='middle' noWrap='1' color='#999999'>%1</t>", _distText]);
    _distCtrl ctrlSetPosition [_xCursor, 0, _distWidth, _h];
    _distCtrl ctrlCommit 0;
    _xCursor = _xCursor + _distWidth + 0.008;
};

private _victimCtrl = objNull;
if (_isKillType) then {
    _victimCtrl = _display ctrlCreate ["RscStructuredText", -1, _tableGroup];
    _victimCtrl ctrlSetStructuredText (parseText format ["<t align='left' valign='middle' noWrap='1' color='%1'>%2</t>", (_victimSide call _colorFor), _victimName]);
    _victimCtrl ctrlSetPosition [_xCursor, 0, _victimWidth, _h];
    _victimCtrl ctrlCommit 0;
    _xCursor = _xCursor + _victimWidth + 0.008;
} else {
    _victimCtrl = _display ctrlCreate ["RscStructuredText", -1, _tableGroup];
    _victimCtrl ctrlSetStructuredText (parseText _mainText);
    _victimCtrl ctrlSetPosition [0, 0, _rowWidth, _h];
    _victimCtrl ctrlCommit 0;
    _xCursor = _rowWidth;
};

_tableGroup ctrlSetPosition [_ctrlX, safeZoneY + (BN_KOTH_KF_TOP_OFFSET * safeZoneH), _rowWidth, _h];
_tableGroup ctrlCommit 0;

_tableGroup ctrlSetFade 1;
_tableGroup ctrlCommit 0;
_tableGroup ctrlSetFade 0;
_tableGroup ctrlCommit 0.15;

_entries pushBack [_tableGroup, _ctrlX];
uiNamespace setVariable ["BN_KOTH_killFeedEntries", _entries];

[_entries, _ctrlX, _rowWidth, _h] call _fncReposition;

[_tableGroup, _ctrlX, _rowWidth, _h, _fncReposition] spawn {
    private _group = _this select 0;
    private _posX = _this select 1;
    private _w = _this select 2;
    private _h = _this select 3;
    private _fncReposition = _this select 4;

    if (isNil "_group") exitWith {
        ["ui_addKillFeedEntry: expiry thread received nil _group - control reference did not survive into spawn", "WARN"] call bn_koth_fnc_common_log;
    };

    sleep (BN_KOTH_KF_LIFETIME - BN_KOTH_KF_FADE_TIME);
    if (isNull _group) exitWith {};

    _group ctrlSetFade 1;
    _group ctrlCommit BN_KOTH_KF_FADE_TIME;

    sleep BN_KOTH_KF_FADE_TIME;
    if (isNull _group) exitWith {};

    ctrlDelete _group;

    private _entries = uiNamespace getVariable ["BN_KOTH_killFeedEntries", []];
    _entries = _entries select {
        !((_x select 0) isEqualTo _group)
    };
    uiNamespace setVariable ["BN_KOTH_killFeedEntries", _entries];

    [_entries, _posX, _w, _h] call _fncReposition;
};

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

params ["_type", "_killerName", "_killerSide", "_weapon", "_victimName", "_victimSide", "_distText"];

if (!hasInterface) exitWith {};

#define BN_KOTH_KF_MAX_ENTRIES 5
#define BN_KOTH_KF_LIFETIME    6
#define BN_KOTH_KF_FADE_TIME   1
#define BN_KOTH_KF_ENTRY_W     0.24
#define BN_KOTH_KF_ENTRY_H     0.032
#define BN_KOTH_KF_SPACING     0.004
#define BN_KOTH_KF_MARGIN      0.02
#define BN_KOTH_KF_TOP_OFFSET  0.16

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

_killerName = [_killerName] call _escapeStructuredText;
_victimName = [_victimName] call _escapeStructuredText;

private _weaponTag = if (_weapon isEqualTo "") then {""} else {
    format [" <t align='right' color='#888888'>[%1]</t>", _weapon]
};

private _text = switch (_type) do {
    case "kill": {
        format [
            "<t align='right' color='%1'>%2</t>%3 <t align='right' color='#999999'>killed</t> <t align='right' color='%4'>%5</t> <t align='right' color='#777777' size='0.8'>%6</t>",
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

private _w = BN_KOTH_KF_ENTRY_W * safeZoneW;
private _minH = BN_KOTH_KF_ENTRY_H * safeZoneH;
private _spacing = BN_KOTH_KF_SPACING * safeZoneH;
private _ctrlX = safeZoneX + safeZoneW - _w - (BN_KOTH_KF_MARGIN * safeZoneW);

private _fncReposition = {
    params ["_list", "_posX", "_w", "_spacing"];

    private _posY = safeZoneY + (BN_KOTH_KF_TOP_OFFSET * safeZoneH);
    {
        _x params ["_c", "_entryH"];
        if (!isNull _c) then {
            _c ctrlSetPosition [_posX, _posY, _w, _entryH];
            _c ctrlCommit 0.15;
            _posY = _posY + _entryH + _spacing;
        };
    } forEach _list;
};

private _entries = uiNamespace getVariable ["BN_KOTH_killFeedEntries", []];

if (count _entries >= BN_KOTH_KF_MAX_ENTRIES) then {
    (_entries select 0) params ["_oldCtrl"];
    if (!isNull _oldCtrl) then {
        ctrlDelete _oldCtrl;
    };
    _entries deleteAt 0;
};

private _ctrl = _display ctrlCreate ["RscStructuredText", -1];
_ctrl ctrlSetStructuredText (parseText _text);
_ctrl ctrlSetBackgroundColor [0, 0, 0, 0.35];

// Set final width first, then measure rendered structured-text height.
_ctrl ctrlSetPosition [
    _ctrlX,
    safeZoneY + (BN_KOTH_KF_TOP_OFFSET * safeZoneH),
    _w,
    _minH
];
_ctrl ctrlCommit 0;

private _entryH = (ctrlTextHeight _ctrl) max _minH;
_ctrl ctrlSetPosition [
    _ctrlX,
    safeZoneY + (BN_KOTH_KF_TOP_OFFSET * safeZoneH),
    _w,
    _entryH
];
_ctrl ctrlCommit 0;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 0;
_ctrl ctrlSetFade 0;
_ctrl ctrlCommit 0.15;

_entries pushBack [_ctrl, _entryH];
uiNamespace setVariable ["BN_KOTH_killFeedEntries", _entries];

[_entries, _ctrlX, _w, _spacing] call _fncReposition;

[_ctrl, _ctrlX, _w, _spacing, _fncReposition] spawn {
    private _ctrl = _this select 0;
    private _posX = _this select 1;
    private _w = _this select 2;
    private _spacing = _this select 3;
    private _fncReposition = _this select 4;

    if (isNil "_ctrl") exitWith {
        ["ui_addKillFeedEntry: expiry thread received nil _ctrl - control reference did not survive into spawn", "WARN"] call bn_koth_fnc_common_log;
    };

    sleep (BN_KOTH_KF_LIFETIME - BN_KOTH_KF_FADE_TIME);
    if (isNull _ctrl) exitWith {};

    _ctrl ctrlSetFade 1;
    _ctrl ctrlCommit BN_KOTH_KF_FADE_TIME;

    sleep BN_KOTH_KF_FADE_TIME;
    if (isNull _ctrl) exitWith {};

    ctrlDelete _ctrl;

    private _entries = uiNamespace getVariable ["BN_KOTH_killFeedEntries", []];
    _entries = _entries select {
        !((_x select 0) isEqualTo _ctrl)
    };
    uiNamespace setVariable ["BN_KOTH_killFeedEntries", _entries];

    [_entries, _posX, _w, _spacing] call _fncReposition;
};

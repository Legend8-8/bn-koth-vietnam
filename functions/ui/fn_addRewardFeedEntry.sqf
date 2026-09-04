/*
    File: fn_addRewardFeedEntry.sqf
    Author: Tylervip
    Description: Renders one reward feed entry above the main HUD, showing
        XP or cash gains with their source reason label. Presentation only;
        authoritative award amounts are issued elsewhere.
    Execution: Client
    Parameters:
        0: STRING - _rewardType ("xp" or "cash")
        1: NUMBER - _amount
        2: STRING - _reasonLabel
    Returns:
        None
    Public: Yes
*/

params [
    ["_rewardType", "xp", [""]],
    ["_amount", 0, [0]],
    ["_reasonLabel", "", [""]]
];

if (!hasInterface) exitWith {};

private _type = toLower _rewardType;
if !(_type in ["xp", "cash"]) exitWith {};

#define BN_KOTH_RF_MAX_ENTRIES 10
#define BN_KOTH_RF_LIFETIME    6
#define BN_KOTH_RF_FADE_TIME   1.5
#define BN_KOTH_RF_ENTRY_W     0.18
#define BN_KOTH_RF_ENTRY_H     0.020
#define BN_KOTH_RF_SPACING     0.0015
#define BN_KOTH_RF_MARGIN      0.012
#define BN_KOTH_RF_BOTTOM_GAP  0.008

private _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
if (isNull _display) then {
    private _layer = "BN_KOTH_RewardFeed" call BIS_fnc_rscLayer;
    _layer cutRsc ["BN_KOTH_RscRewardFeed", "PLAIN", 0, false];

    _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
};
if (isNull _display) exitWith {
    private _fallback = if (_type isEqualTo "cash") then {
        format ["[CASH] %1 %2$%3", _reasonLabel, if (_amount > 0) then {"+"} else {""}, _amount]
    } else {
        format ["[XP] %1 +%2 XP", _reasonLabel, _amount]
    };
    systemChat _fallback;
};

private _color = if (_type isEqualTo "xp") then {"#D8B04B"} else {"#75D66D"};
private _amountText = if (_type isEqualTo "xp") then {
    format ["%1%2 XP", if (_amount >= 0) then {"+"} else {""}, _amount]
} else {
    format ["%1$%2", if (_amount >= 0) then {"+"} else {"-"}, abs _amount]
};

private _reasonText = if (_reasonLabel isEqualTo "") then {""} else {
    format ["<t align='right' color='#D5D1C8'>%1</t>", _reasonLabel]
};

private _text = format [
    "<t align='right' color='%1'>%2</t> %3",
    _color,
    _amountText,
    _reasonText
];

private _hudW = safeZoneW * 0.19;
private _hudH = safeZoneH * 0.12;
private _hudX = safeZoneX + safeZoneW - _hudW - (safeZoneW * 0.012);
private _hudY = safeZoneY + safeZoneH - _hudH - (safeZoneH * 0.025);

private _w = BN_KOTH_RF_ENTRY_W * safeZoneW;
private _h = BN_KOTH_RF_ENTRY_H * safeZoneH;
private _posX = _hudX + _hudW - _w;
private _baseY = _hudY - (BN_KOTH_RF_BOTTOM_GAP * safeZoneH) - _h;

private _fncReposition = {
    params ["_list", "_baseY", "_posX", "_w", "_h"];

    {
        _x params ["_c"];
        private _posY = _baseY - (_forEachIndex * ((BN_KOTH_RF_ENTRY_H + BN_KOTH_RF_SPACING) * safeZoneH));

        _c ctrlSetPosition [_posX, _posY, _w, _h];
        _c ctrlCommit 0.15;
    } forEach _list;
};

private _entries = uiNamespace getVariable ["BN_KOTH_rewardFeedEntries", []];

if (count _entries >= BN_KOTH_RF_MAX_ENTRIES) then {
    (_entries select 0) params ["_oldCtrl"];
    if (!isNull _oldCtrl) then {
        ctrlDelete _oldCtrl;
    };
    _entries deleteAt 0;
};

private _ctrl = _display ctrlCreate ["RscStructuredText", -1];
_ctrl ctrlSetStructuredText (parseText _text);
_ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
_ctrl ctrlSetPosition [_posX, _baseY, _w, _h];
_ctrl ctrlCommit 0;

_ctrl ctrlSetFade 1;
_ctrl ctrlCommit 0;
_ctrl ctrlSetFade 0;
_ctrl ctrlCommit 0.15;

_entries pushBack [_ctrl];
uiNamespace setVariable ["BN_KOTH_rewardFeedEntries", _entries];

[_entries, _baseY, _posX, _w, _h] call _fncReposition;

[_ctrl, _baseY, _posX, _w, _h, _fncReposition] spawn {
    params ["_ctrl", "_baseY", "_posX", "_w", "_h", "_fncReposition"];

    if (isNil "_ctrl") exitWith {
        ["ui_addRewardFeedEntry: expiry thread received nil _ctrl - control reference did not survive into spawn", "WARN"] call bn_koth_fnc_common_log;
    };

    sleep (BN_KOTH_RF_LIFETIME - BN_KOTH_RF_FADE_TIME);
    if (isNull _ctrl) exitWith {};

    _ctrl ctrlSetFade 1;
    _ctrl ctrlCommit BN_KOTH_RF_FADE_TIME;

    sleep BN_KOTH_RF_FADE_TIME;
    if (isNull _ctrl) exitWith {};

    ctrlDelete _ctrl;

    private _entries = uiNamespace getVariable ["BN_KOTH_rewardFeedEntries", []];
    _entries = _entries select {
        !((_x select 0) isEqualTo _ctrl)
    };
    uiNamespace setVariable ["BN_KOTH_rewardFeedEntries", _entries];

    [_entries, _baseY, _posX, _w, _h] call _fncReposition;
};

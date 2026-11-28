/*
    File: fn_notify.sqf
    Author: Legend
    Description: Queues and presents cards; explicit progression cards wait for
        the server-published friendly safe-zone state.
    Execution: Client
    Parameters:
        0: Message <STRING> or notification fields <HASHMAP>
           (title, body, footer, duration, category)
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\menu\idcs.hpp"

params [["_notification", "", ["", createHashMap]]];
if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

private _entry = if (_notification isEqualType "") then {
    if (_notification isEqualTo "") exitWith {createHashMap};
    createHashMapFromArray [["title", "NOTICE"], ["body", _notification], ["footer", ""], ["duration", 5], ["category", "GENERAL"]]
} else {
    createHashMapFromArray [
        ["title", _notification getOrDefault ["title", "NOTICE"]],
        ["body", _notification getOrDefault ["body", ""]],
        ["footer", _notification getOrDefault ["footer", ""]],
        ["duration", _notification getOrDefault ["duration", 5]],
        ["category", _notification getOrDefault ["category", "GENERAL"]]
    ]
};
if ((count _entry) isEqualTo 0 || {(_entry getOrDefault ["body", ""]) isEqualTo ""}) exitWith {};
if !((_entry get "category") isEqualTo "PROGRESSION") then {_entry set ["category", "GENERAL"]};
private _queue = uiNamespace getVariable ["BN_KOTH_notificationQueue", []];
if !(_queue isEqualType []) then {_queue = []};
_queue pushBack _entry;
uiNamespace setVariable ["BN_KOTH_notificationQueue", _queue];

if (isNil {uiNamespace getVariable "BN_KOTH_notificationPump"}) then {
    uiNamespace setVariable ["BN_KOTH_notificationPump", {
        disableSerialization;
        private _pending = uiNamespace getVariable ["BN_KOTH_notificationQueue", []];
        private _visible = uiNamespace getVariable ["BN_KOTH_notificationVisible", []];
        if !(_pending isEqualType []) then {_pending = []};
        if !(_visible isEqualType []) then {_visible = []};
        if ((count _pending) isEqualTo 0 && {(count _visible) isEqualTo 0}) exitWith {};

        private _friendly = !isNull player && {player getVariable ["BN_KOTH_safeZoneProtected", false]};
        if ((count _visible) isEqualTo 0 && {(_pending findIf {(_x get "category") isNotEqualTo "PROGRESSION" || {_friendly}}) < 0}) exitWith {};
        private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
        private _container = controlNull;
        private _onMenu = !isNull _display;
        if (_onMenu) then {
            _container = _display displayCtrl BN_KOTH_IDC_MENU_NOTIFICATION_OVERLAY;
        };
        if (_onMenu && {isNull _container}) exitWith {};
        if (isNull _display) then {
            _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
            if (isNull _display) then {
                private _layer = "BN_KOTH_RewardFeed" call BIS_fnc_rscLayer;
                _layer cutRsc ["BN_KOTH_RscRewardFeed", "PLAIN", 0, false];
                _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
            };
        };
        if (isNull _display) exitWith {};

        private _now = diag_tickTime;
        private _escape = {
            params ["_value"];
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
        private _draw = {
            params ["_display", "_container", "_entry", "_escape"];
            private _minimumCardWidth = safeZoneW * 0.100;
            private _maximumCardWidth = safeZoneW * 0.255;
            private _minimumCardHeight = safeZoneH * 0.050;
            private _maximumCardHeight = safeZoneH * 0.135;
            private _textLeftPadding = safeZoneW * 0.010;
            private _textRightPadding = safeZoneW * 0.008;
            private _textY = safeZoneH * 0.007;
            private _titleValue = toUpper (_entry getOrDefault ["title", "NOTICE"]);
            private _bodyValue = _entry getOrDefault ["body", ""];
            private _footerValue = _entry getOrDefault ["footer", ""];
            private _group = if (isNull _container) then {
                _display ctrlCreate ["RscControlsGroupNoScrollbars", -1]
            } else {
                _display ctrlCreate ["RscControlsGroupNoScrollbars", -1, _container]
            };
            _group ctrlSetPosition [if (isNull _container) then {safeZoneX + safeZoneW * 0.018} else {0}, if (isNull _container) then {safeZoneY + safeZoneH * 0.085} else {0}, _maximumCardWidth, _maximumCardHeight];
            _group ctrlCommit 0;
            _group ctrlEnable false;
            private _background = _display ctrlCreate ["RscText", -1, _group];
            _background ctrlSetBackgroundColor [0.035, 0.035, 0.03, 0.96];
            _background ctrlEnable false;
            private _accent = _display ctrlCreate ["RscText", -1, _group];
            _accent ctrlSetBackgroundColor [0.72, 0.28, 0.10, 1];
            _accent ctrlEnable false;
            private _title = [_titleValue] call _escape;
            private _body = [_bodyValue] call _escape;
            private _footer = [_footerValue] call _escape;
            private _footerText = if (_footer isEqualTo "") then {""} else {format ["<br/><t size='0.72' color='#AAA69C'>%1</t>", _footer]};
            private _text = _display ctrlCreate ["RscStructuredText", -1, _group];
            // Measure each natural line at maximum width before final wrapping determines height.
            _text ctrlSetPosition [_textLeftPadding, _textY, _maximumCardWidth - _textLeftPadding - _textRightPadding, _maximumCardHeight - (2 * _textY)];
            _text ctrlSetStructuredText parseText format ["<t font='PuristaSemiBold' size='0.92'>%1</t>", _title];
            _text ctrlCommit 0;
            private _contentWidth = ctrlTextWidth _text;
            _text ctrlSetStructuredText parseText format ["<t size='0.82'>%1</t>", _body];
            _text ctrlCommit 0;
            _contentWidth = _contentWidth max (ctrlTextWidth _text);
            if !(_footer isEqualTo "") then {
                _text ctrlSetStructuredText parseText format ["<t size='0.72'>%1</t>", _footer];
                _text ctrlCommit 0;
                _contentWidth = _contentWidth max (ctrlTextWidth _text);
            };
            private _cardWidth = ((_contentWidth + _textLeftPadding + _textRightPadding) max _minimumCardWidth) min _maximumCardWidth;
            private _textWidth = _cardWidth - _textLeftPadding - _textRightPadding;
            _text ctrlSetStructuredText parseText format [
                "<t font='PuristaSemiBold' size='0.92' color='#E3C56A'>%1</t><br/><t size='0.82' color='#F0EDE5'>%2</t>%3",
                _title, _body, _footerText
            ];
            _text ctrlSetPosition [_textLeftPadding, _textY, _textWidth, _maximumCardHeight - (2 * _textY)];
            _text ctrlCommit 0;
            _text ctrlEnable false;
            private _cardHeight = (((ctrlTextHeight _text) + (2 * _textY)) max _minimumCardHeight) min _maximumCardHeight;
            _group ctrlSetPosition [(ctrlPosition _group) select 0, (ctrlPosition _group) select 1, _cardWidth, _cardHeight];
            _group ctrlCommit 0;
            _background ctrlSetPosition [0, 0, _cardWidth, _cardHeight];
            _background ctrlCommit 0;
            _accent ctrlSetPosition [0, 0, safeZoneW * 0.004, _cardHeight];
            _accent ctrlCommit 0;
            _text ctrlSetPosition [_textLeftPadding, _textY, _textWidth, _cardHeight - (2 * _textY)];
            _text ctrlCommit 0;
            _group
        };

        private _survivors = [];
        private _deferred = [];
        {
            _x params ["_group", "_entry", "_remaining", "_lastTick", "_owner", "_slot"];
            private _eligible = !((_entry get "category") isEqualTo "PROGRESSION") || {_friendly};
            if (!_eligible) then {
                if (!isNull _group) then {ctrlDelete _group};
                _entry set ["remaining", _remaining];
                _deferred pushBack _entry;
            } else {
                _remaining = _remaining - ((_now - _lastTick) max 0);
            };
            if (_eligible && {_remaining > 0}) then {
                if (isNull _group || {_owner isNotEqualTo _display}) then {
                    if (!isNull _group) then {ctrlDelete _group};
                    _group = [_display, _container, _entry, _escape] call _draw;
                    _owner = _display;
                    _slot = -1;
                };
                private _targetFade = if (_remaining <= 1) then {1} else {0};
                if ((ctrlFade _group) isNotEqualTo _targetFade) then {
                    _group ctrlSetFade _targetFade;
                    _group ctrlCommit (if (_remaining <= 1) then {_remaining} else {0.15});
                };
                _survivors pushBack [_group, _entry, _remaining, _now, _owner, _slot];
            } else {
                if (_eligible && {!isNull _group}) then {ctrlDelete _group};
            };
        } forEach _visible;
        _visible = _survivors;
        _pending = _deferred + _pending;

        while {(count _visible) < 4 && {(count _pending) > 0}} do {
            private _index = _pending findIf {(_x get "category") isNotEqualTo "PROGRESSION" || {_friendly}};
            if (_index < 0) exitWith {};
            private _next = _pending deleteAt _index;
            private _group = [_display, _container, _next, _escape] call _draw;
            _group ctrlSetFade 1;
            _group ctrlCommit 0;
            _group ctrlSetFade 0;
            _group ctrlCommit 0.15;
            _visible pushBack [_group, _next, _next getOrDefault ["remaining", (((_next getOrDefault ["duration", 5]) max 1) min 10) + 1], _now, _display, -1];
        };
        private _stackY = if (_onMenu) then {0} else {safeZoneY + safeZoneH * 0.085};
        {
            private _group = _x select 0;
            private _position = ctrlPosition _group;
            if ((_x select 5) isNotEqualTo _stackY) then {
                _group ctrlSetPosition [if (_onMenu) then {0} else {safeZoneX + safeZoneW * 0.018}, _stackY, _position select 2, _position select 3];
                _group ctrlCommit 0.15;
                _x set [5, _stackY];
            };
            _stackY = _stackY + (_position select 3) + safeZoneH * 0.010;
        } forEach _visible;
        uiNamespace setVariable ["BN_KOTH_notificationQueue", _pending];
        uiNamespace setVariable ["BN_KOTH_notificationVisible", _visible];
    }];
};

call (uiNamespace getVariable ["BN_KOTH_notificationPump", {}]);

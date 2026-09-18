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
            private _group = if (isNull _container) then {
                _display ctrlCreate ["RscControlsGroupNoScrollbars", -1]
            } else {
                _display ctrlCreate ["RscControlsGroupNoScrollbars", -1, _container]
            };
            _group ctrlSetPosition [if (isNull _container) then {safeZoneX + safeZoneW * 0.018} else {0}, if (isNull _container) then {safeZoneY + safeZoneH * 0.085} else {0}, safeZoneW * 0.255, safeZoneH * 0.076];
            _group ctrlCommit 0;
            _group ctrlEnable false;
            private _background = _display ctrlCreate ["RscText", -1, _group];
            _background ctrlSetBackgroundColor [0.035, 0.035, 0.03, 0.96];
            _background ctrlSetPosition [0, 0, safeZoneW * 0.255, safeZoneH * 0.076];
            _background ctrlCommit 0;
            _background ctrlEnable false;
            private _accent = _display ctrlCreate ["RscText", -1, _group];
            _accent ctrlSetBackgroundColor [0.72, 0.28, 0.10, 1];
            _accent ctrlSetPosition [0, 0, safeZoneW * 0.004, safeZoneH * 0.076];
            _accent ctrlCommit 0;
            _accent ctrlEnable false;
            private _title = [toUpper (_entry getOrDefault ["title", "NOTICE"])] call _escape;
            private _body = [_entry getOrDefault ["body", ""]] call _escape;
            private _footer = [_entry getOrDefault ["footer", ""]] call _escape;
            private _footerText = if (_footer isEqualTo "") then {""} else {format ["<br/><t size='0.72' color='#AAA69C'>%1</t>", _footer]};
            private _text = _display ctrlCreate ["RscStructuredText", -1, _group];
            _text ctrlSetStructuredText parseText format [
                "<t font='PuristaSemiBold' size='0.92' color='#E3C56A'>%1</t><br/><t size='0.82' color='#F0EDE5'>%2</t>%3",
                _title, _body, _footerText
            ];
            _text ctrlSetPosition [safeZoneW * 0.010, safeZoneH * 0.007, safeZoneW * 0.237, safeZoneH * 0.064];
            _text ctrlCommit 0;
            _text ctrlEnable false;
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
        {
            if ((_x select 5) isNotEqualTo _forEachIndex) then {
                private _group = _x select 0;
                _group ctrlSetPosition [if (_onMenu) then {0} else {safeZoneX + safeZoneW * 0.018}, if (_onMenu) then {safeZoneH * (_forEachIndex * 0.086)} else {safeZoneY + safeZoneH * (0.085 + (_forEachIndex * 0.086))}, safeZoneW * 0.255, safeZoneH * 0.076];
                _group ctrlCommit 0.15;
                _x set [5, _forEachIndex];
            };
        } forEach _visible;
        uiNamespace setVariable ["BN_KOTH_notificationQueue", _pending];
        uiNamespace setVariable ["BN_KOTH_notificationVisible", _visible];
    }];
};

call (uiNamespace getVariable ["BN_KOTH_notificationPump", {}]);

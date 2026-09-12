/*
    File: fn_notify.sqf
    Author: Legend
    Description: Queues a lightweight top-left notification card. String
        callers remain supported; structured callers may supply title, body,
        and footer without creating a separate presentation path.
    Execution: Client
    Parameters:
        0: Message text <STRING> or notification fields <HASHMAP>
    Returns:
        None
    Public: Yes
*/

params [["_notification", "", ["", createHashMap]]];

if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

private _entry = if (_notification isEqualType "") then {
    if (_notification isEqualTo "") exitWith {createHashMap};
    createHashMapFromArray [
        ["title", "NOTICE"],
        ["body", _notification],
        ["footer", ""]
    ]
} else {
    createHashMapFromArray [
        ["title", _notification getOrDefault ["title", "NOTICE"]],
        ["body", _notification getOrDefault ["body", ""]],
        ["footer", _notification getOrDefault ["footer", ""]]
    ]
};
if ((count _entry) isEqualTo 0 || {(_entry getOrDefault ["body", ""]) isEqualTo ""}) exitWith {};

private _queue = uiNamespace getVariable ["BN_KOTH_notificationQueue", []];
if !(_queue isEqualType []) then {_queue = []};
_queue pushBack _entry;
uiNamespace setVariable ["BN_KOTH_notificationQueue", _queue];

private _pump = uiNamespace getVariable ["BN_KOTH_notificationPump", {}];
if (isNil {uiNamespace getVariable "BN_KOTH_notificationPump"}) then {
    _pump = {
        disableSerialization;

        private _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
        if (isNull _display) then {
            private _layer = "BN_KOTH_RewardFeed" call BIS_fnc_rscLayer;
            _layer cutRsc ["BN_KOTH_RscRewardFeed", "PLAIN", 0, false];
            _display = uiNamespace getVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
        };
        if (isNull _display) exitWith {};

        private _visible = uiNamespace getVariable ["BN_KOTH_notificationVisible", []];
        if !(_visible isEqualType []) then {_visible = []};
        _visible = _visible select {!isNull (_x select 0)};
        private _pending = uiNamespace getVariable ["BN_KOTH_notificationQueue", []];
        if !(_pending isEqualType []) then {_pending = []};

        private _escape = {
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

        private _reposition = {
            params ["_entries"];
            {
                private _group = _x select 0;
                if (!isNull _group) then {
                    _group ctrlSetPosition [
                        safeZoneX + safeZoneW * 0.018,
                        safeZoneY + safeZoneH * (0.085 + (_forEachIndex * 0.086)),
                        safeZoneW * 0.255,
                        safeZoneH * 0.076
                    ];
                    _group ctrlCommit 0.15;
                };
            } forEach _entries;
        };

        while {(count _visible) < 4 && {(count _pending) > 0}} do {
            private _next = _pending deleteAt 0;
            private _group = _display ctrlCreate ["RscControlsGroupNoScrollbars", -1];
            _group ctrlSetPosition [safeZoneX + safeZoneW * 0.018, safeZoneY + safeZoneH * 0.085, safeZoneW * 0.255, safeZoneH * 0.076];
            _group ctrlCommit 0;

            private _background = _display ctrlCreate ["RscText", -1, _group];
            _background ctrlSetBackgroundColor [0.035, 0.035, 0.03, 0.96];
            _background ctrlSetPosition [0, 0, safeZoneW * 0.255, safeZoneH * 0.076];
            _background ctrlCommit 0;

            private _accent = _display ctrlCreate ["RscText", -1, _group];
            _accent ctrlSetBackgroundColor [0.72, 0.28, 0.10, 1];
            _accent ctrlSetPosition [0, 0, safeZoneW * 0.004, safeZoneH * 0.076];
            _accent ctrlCommit 0;

            private _title = [toUpper (_next getOrDefault ["title", "NOTICE"])] call _escape;
            private _body = [_next getOrDefault ["body", ""]] call _escape;
            private _footer = [_next getOrDefault ["footer", ""]] call _escape;
            private _footerText = if (_footer isEqualTo "") then {""} else {format ["<br/><t size='0.72' color='#AAA69C'>%1</t>", _footer]};

            private _text = _display ctrlCreate ["RscStructuredText", -1, _group];
            _text ctrlSetStructuredText parseText format [
                "<t font='PuristaSemiBold' size='0.92' color='#E3C56A'>%1</t><br/><t size='0.82' color='#F0EDE5'>%2</t>%3",
                _title,
                _body,
                _footerText
            ];
            _text ctrlSetPosition [safeZoneW * 0.010, safeZoneH * 0.007, safeZoneW * 0.237, safeZoneH * 0.064];
            _text ctrlCommit 0;

            _group ctrlSetFade 1;
            _group ctrlCommit 0;
            _group ctrlSetFade 0;
            _group ctrlCommit 0.15;
            _visible pushBack [_group];

            [_group] spawn {
                params ["_group"];
                uiSleep 5;
                if (!isNull _group) then {
                    _group ctrlSetFade 1;
                    _group ctrlCommit 1;
                    uiSleep 1;
                    if (!isNull _group) then {ctrlDelete _group};
                };

                private _entries = uiNamespace getVariable ["BN_KOTH_notificationVisible", []];
                _entries = _entries select {!((_x select 0) isEqualTo _group)};
                uiNamespace setVariable ["BN_KOTH_notificationVisible", _entries];
                call (uiNamespace getVariable ["BN_KOTH_notificationPump", {}]);
            };
        };

        uiNamespace setVariable ["BN_KOTH_notificationQueue", _pending];
        uiNamespace setVariable ["BN_KOTH_notificationVisible", _visible];
        [_visible] call _reposition;
    };
    uiNamespace setVariable ["BN_KOTH_notificationPump", _pump];
};

call _pump;

/*
    File: fn_startReviveHoldActionDiagnosticsLocal.sqf
    Author: Legend
    Description: Runs one bounded playtest probe that logs native BIS/S.O.G.
        hold-action start/end state without changing the action or revive.
    Execution: Client (scheduled probe)
    Parameters: None
    Returns: True when enabled or already running <BOOL>
    Public: No
*/

if (!hasInterface) exitWith {false};

private _config = missionConfigFile >> "CfgBnKothRespawn";
if ((getNumber (_config >> "experimentalHoldActionDiagnostics")) <= 0) exitWith {false};

private _existing = missionNamespace getVariable ["BN_KOTH_reviveHoldActionDiagnosticHandle", scriptNull];
if (!scriptDone _existing) exitWith {true};

private _duration = (getNumber (_config >> "experimentalHoldActionDiagnosticSeconds")) max 1;
private _interval = (getNumber (_config >> "experimentalHoldActionDiagnosticInterval")) max 0.05;

private _handle = [_duration, _interval] spawn {
    params ["_duration", "_interval"];

    private _deadline = diag_tickTime + _duration;
    private _wasRunning = false;
    private _startedAt = -1;

    diag_log format [
        "[BN_KOTH][INFO] REVIVE HOLD DIAGNOSTIC enabled duration=%1 interval=%2 consumptionImplemented=false",
        _duration,
        _interval
    ];

    while {diag_tickTime < _deadline} do {
        private _running = missionNamespace getVariable ["bis_fnc_holdAction_running", false];
        if !(_running isEqualType true) then {_running = false};

        if (_running && {!_wasRunning}) then {
            // VN_fnc_holdActionAdd's engine action wrapper stores its raw
            // [target, caller, actionId, arguments] _this here. The probe logs
            // the raw value and metadata; it does not treat the layout as a
            // production Resuscitate identity until playtest evidence proves it.
            uiSleep 0.05;
            private _params = missionNamespace getVariable ["bis_fnc_holdAction_params", []];
            private _target = if (_params isEqualType []) then {_params param [0, objNull, [objNull]]} else {objNull};
            private _caller = if (_params isEqualType []) then {_params param [1, objNull, [objNull]]} else {objNull};
            private _actionId = if (_params isEqualType []) then {_params param [2, -1, [0]]} else {-1};
            private _actionMetadata = if (!isNull _target && {_actionId >= 0}) then {_target actionParams _actionId} else {[]};
            private _metadataText = toLower (str _actionMetadata);
            private _identity = if ((_metadataText find "bn_koth_fnc_respawn_requestcasualtyhelp") >= 0) then {
                "KOTH_CALL_FOR_HELP"
            } else {
                if ((_metadataText find "vn_fnc_revive_action_respawn") >= 0) then {
                    "KOTH_GIVE_UP"
                } else {
                    if ((_metadataText find "vn_fnc_revive_action_revive") >= 0) then {"NATIVE_REVIVE_CANDIDATE"} else {"AMBIGUOUS"}
                }
            };

            private _cursor = cursorObject;
            private _cursorActions = [];
            if (!isNull _cursor) then {
                {
                    _cursorActions pushBack [_x, _cursor actionParams _x];
                } forEach actionIDs _cursor;
            };

            _startedAt = diag_tickTime;
            diag_log format [
                "[BN_KOTH][INFO] REVIVE HOLD DIAGNOSTIC START identity=%1 rawParams=%2 target=%3 targetNetId=%4 caller=%5 callerIsCurrentPlayer=%6 actionId=%7 actionMetadata=%8 cursor=%9 cursorNetId=%10 cursorActions=%11",
                _identity,
                _params,
                _target,
                if (isNull _target) then {""} else {netId _target},
                _caller,
                !isNull _caller && {_caller isEqualTo player},
                _actionId,
                _actionMetadata,
                _cursor,
                if (isNull _cursor) then {""} else {netId _cursor},
                _cursorActions
            ];
        };

        if (!_running && {_wasRunning}) then {
            diag_log format [
                "[BN_KOTH][INFO] REVIVE HOLD DIAGNOSTIC END duration=%1 currentPlayer=%2 lifeState=%3 vnIncap=%4",
                (diag_tickTime - _startedAt) max 0,
                player,
                if (isNull player) then {"<null>"} else {lifeState player},
                !isNull player && {player getVariable ["vn_revive_incapacitated", false]}
            ];
            _startedAt = -1;
        };

        _wasRunning = _running;
        uiSleep _interval;
    };

    diag_log "[BN_KOTH][INFO] REVIVE HOLD DIAGNOSTIC stopped: bounded capture window expired";
};

missionNamespace setVariable ["BN_KOTH_reviveHoldActionDiagnosticHandle", _handle];
true

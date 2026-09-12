/*
    File: fn_reportReviveState.sqf
    Author: Legend
    Description: Accepts a casualty-only client observation and converts it into
        a bounded, server-validated progression transaction. The authenticated
        casualty owner reports lifecycle; another sender is a completion candidate.
        The client supplies no phase, identity, side, token, reward or trusted flag.
    Execution: Server, RemoteExec from the casualty owner or native Resuscitate caller
    Parameters:
        0: Casualty representation <OBJECT>
    Returns: True when the report was accepted for processing <BOOL>
    Public: Yes, client-to-server RemoteExec endpoint
*/

params [["_casualty", objNull, [objNull]]];

if (!isServer || {!isRemoteExecuted}) exitWith {false};
if (isNull _casualty || {!(_casualty isKindOf "Man")}) exitWith {false};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {false};

private _sender = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _sender || {!isPlayer _sender}) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {false};

private _senderUid = [_sender, _records] call bn_koth_fnc_common_resolvePlayerUid;
if (_senderUid isEqualTo "") exitWith {false};
private _senderRecord = _records getOrDefault [_senderUid, createHashMap];
if !(_senderRecord isEqualType createHashMap) exitWith {false};

private _senderValid = (_senderRecord getOrDefault ["currentUnit", objNull]) isEqualTo _sender
    && {(_senderRecord getOrDefault ["ownerId", -1]) isEqualTo _ownerId}
    && {(owner _sender) isEqualTo _ownerId}
    && {(_senderRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {_senderRecord getOrDefault ["deployed", false]}
    && {alive _sender};
if (!_senderValid) exitWith {false};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {false};

private _casualtyUid = [_casualty, _records] call bn_koth_fnc_common_resolvePlayerUid;
if (_casualtyUid isEqualTo "") exitWith {false};
private _casualtyRecord = _records getOrDefault [_casualtyUid, createHashMap];
if !(_casualtyRecord isEqualType createHashMap) exitWith {false};

private _casualtyOwner = _casualtyRecord getOrDefault ["ownerId", -1];
private _casualtyValid = (_casualtyRecord getOrDefault ["currentUnit", objNull]) isEqualTo _casualty
    && {_casualtyOwner > 0}
    && {(owner _casualty) isEqualTo _casualtyOwner}
    && {(_casualtyRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {_casualtyRecord getOrDefault ["deployed", false]}
    && {isPlayer _casualty}
    && {alive _casualty};
if (!_casualtyValid) exitWith {false};

private _cycle = _casualty getVariable ["BN_KOTH_reviveRewardCycleServer", createHashMap];
if !(_cycle isEqualType createHashMap) then {_cycle = createHashMap};
private _isCasualtyOwnerReport = _sender isEqualTo _casualty && {_senderUid isEqualTo _casualtyUid};
private _maximumDistance = missionNamespace getVariable ["BN_KOTH_reviveRewardDistanceMeters", 4];
private _completionWindow = missionNamespace getVariable ["BN_KOTH_reviveRewardCompletionWindowSeconds", 2];

if (_isCasualtyOwnerReport) exitWith {
    private _sameRepresentationCycle = (_cycle getOrDefault ["casualty", objNull]) isEqualTo _casualty
        && {(_cycle getOrDefault ["casualtyUid", ""]) isEqualTo _casualtyUid}
        && {serverTime <= (_cycle getOrDefault ["expiresAt", -1])};
    private _status = _cycle getOrDefault ["status", ""];
    private _recoveryAlreadyReported = (_cycle getOrDefault ["recoveryReportedAt", -1]) >= 0;

    // The casualty sends exactly once on each local transition. Once the
    // server has accepted this representation's incapacitation report, its
    // next report is recovery intent even if public-variable replication is
    // still catching up. Awarding still requires server-observed recovery.
    if (_sameRepresentationCycle && {!_recoveryAlreadyReported} && {_status in ["ACTIVE", "PENDING"]}) exitWith {
        private _token = _cycle getOrDefault ["token", ""];
        _cycle set ["recoveryReportedAt", serverTime];
        if (_status isEqualTo "ACTIVE") then {
            _cycle set ["status", "RECOVERED"];
        };
        _casualty setVariable ["BN_KOTH_reviveRewardCycleServer", _cycle, false];

        if (_status isEqualTo "ACTIVE") then {
            [_casualty, _token, _completionWindow] spawn {
                params ["_casualty", "_token", "_window"];
                uiSleep _window;

                if (isNull _casualty) exitWith {};
                private _cycle = _casualty getVariable ["BN_KOTH_reviveRewardCycleServer", createHashMap];
                if (
                    _cycle isEqualType createHashMap
                    && {(_cycle getOrDefault ["token", ""]) isEqualTo _token}
                    && {(_cycle getOrDefault ["status", ""]) isEqualTo "RECOVERED"}
                ) then {
                    [_casualty, "RECOVERY_WITHOUT_COMPLETION"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
                };
            };
        };
        true
    };

    if (_sameRepresentationCycle && {_recoveryAlreadyReported} && {!([_casualty] call bn_koth_fnc_respawn_isIncapacitated)}) exitWith {true};
    if !([_casualty] call bn_koth_fnc_respawn_isIncapacitated) exitWith {false};

    private _counter = (missionNamespace getVariable ["BN_KOTH_reviveRewardCycleCounter", 0]) + 1;
    missionNamespace setVariable ["BN_KOTH_reviveRewardCycleCounter", _counter];
    private _token = format ["revive:%1:%2:%3", _casualtyUid, round (serverTime * 1000), _counter];
    private _bleedout = missionNamespace getVariable ["vn_revive_bleedout_time", 600];
    if !(_bleedout isEqualType 0 && {finite _bleedout} && {_bleedout > 0}) then {_bleedout = 600};

    _cycle = createHashMapFromArray [
        ["token", _token],
        ["status", "ACTIVE"],
        ["casualty", _casualty],
        ["casualtyUid", _casualtyUid],
        ["casualtyOwner", _casualtyOwner],
        ["startedAt", serverTime],
        ["expiresAt", serverTime + _bleedout + 5]
    ];
    _casualty setVariable ["BN_KOTH_reviveRewardCycleServer", _cycle, false];
    true
};

// COMPLETED may only come from another current human representation. The
// server derives that reviver from remoteExecutedOwner and accepts no UID.
if (_sender isEqualTo _casualty || {_senderUid isEqualTo _casualtyUid}) exitWith {false};
if ([_sender] call bn_koth_fnc_respawn_isIncapacitated) exitWith {false};
if !((_senderRecord getOrDefault ["assignedSide", sideUnknown]) isEqualTo (_casualtyRecord getOrDefault ["assignedSide", sideUnknown])) exitWith {false};
if !([_senderRecord getOrDefault ["assignedSide", sideUnknown]] call bn_koth_fnc_teams_validateSide) exitWith {false};
if ((_sender distance _casualty) > _maximumDistance) exitWith {false};

private _cycleStatus = _cycle getOrDefault ["status", ""];
private _recoveredWithinWindow = _cycleStatus isEqualTo "RECOVERED"
    && {serverTime <= ((_cycle getOrDefault ["recoveryReportedAt", -1]) + _completionWindow)};
private _cycleMatches = (_cycle getOrDefault ["casualty", objNull]) isEqualTo _casualty
    && {(_cycle getOrDefault ["casualtyUid", ""]) isEqualTo _casualtyUid}
    && {(_cycle getOrDefault ["casualtyOwner", -1]) isEqualTo _casualtyOwner}
    && {_cycleStatus isEqualTo "ACTIVE" || {_recoveredWithinWindow}}
    && {serverTime <= (_cycle getOrDefault ["expiresAt", -1])}
    && {!((_cycle getOrDefault ["token", ""]) isEqualTo "")};
if (!_cycleMatches) exitWith {false};

private _token = _cycle get "token";
private _completionDeadline = serverTime + _completionWindow;
_cycle set ["status", "PENDING"];
_cycle set ["pendingReviverUid", _senderUid];
_cycle set ["pendingOwner", _ownerId];
_cycle set ["pendingAt", serverTime];
_cycle set ["pendingExpiresAt", _completionDeadline];
_casualty setVariable ["BN_KOTH_reviveRewardCycleServer", _cycle, false];

[_casualty, _casualtyUid, _senderUid, _ownerId, _token, _completionDeadline, _maximumDistance, _completionWindow] spawn {
    params ["_casualty", "_casualtyUid", "_reviverUid", "_reviverOwner", "_token", "_deadline", "_maximumDistance", "_completionWindow"];

    waitUntil {
        uiSleep 0.1;
        private _currentCycle = if (isNull _casualty) then {
            createHashMap
        } else {
            _casualty getVariable ["BN_KOTH_reviveRewardCycleServer", createHashMap]
        };
        private _sameCycle = _currentCycle isEqualType createHashMap
            && {(_currentCycle getOrDefault ["token", ""]) isEqualTo _token};
        private _recoveryReported = _sameCycle
            && {(_currentCycle getOrDefault ["recoveryReportedAt", -1]) >= 0};
        isNull _casualty
        || {!alive _casualty}
        || {!_sameCycle}
        || {!([_casualty] call bn_koth_fnc_respawn_isIncapacitated) && {_recoveryReported}}
        || {serverTime >= _deadline}
        || {!(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE")}
    };

    if (isNull _casualty) exitWith {};
    private _cycle = _casualty getVariable ["BN_KOTH_reviveRewardCycleServer", createHashMap];
    private _pendingMatches = _cycle isEqualType createHashMap
        && {(_cycle getOrDefault ["token", ""]) isEqualTo _token}
        && {(_cycle getOrDefault ["status", ""]) isEqualTo "PENDING"}
        && {(_cycle getOrDefault ["pendingReviverUid", ""]) isEqualTo _reviverUid}
        && {(_cycle getOrDefault ["pendingOwner", -1]) isEqualTo _reviverOwner};
    if (!_pendingMatches) exitWith {};

    if (!alive _casualty) exitWith {
        [_casualty, "CASUALTY_DIED_DURING_COMPLETION"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
    };
    if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {
        [_casualty, "ROUND_ENDED_DURING_COMPLETION"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
    };
    private _stillIncapacitated = [_casualty] call bn_koth_fnc_respawn_isIncapacitated;
    private _recoveryReportedAt = _cycle getOrDefault ["recoveryReportedAt", -1];
    if (serverTime >= _deadline || {_stillIncapacitated} || {_recoveryReportedAt < 0}) exitWith {
        if (_stillIncapacitated && {_recoveryReportedAt < 0}) then {
            _cycle set ["status", "ACTIVE"];
            _cycle deleteAt "pendingReviverUid";
            _cycle deleteAt "pendingOwner";
            _cycle deleteAt "pendingAt";
            _cycle deleteAt "pendingExpiresAt";
            _casualty setVariable ["BN_KOTH_reviveRewardCycleServer", _cycle, false];
            [format ["Revive completion expired target=%1 token=%2", _casualtyUid, _token], "WARN"] call bn_koth_fnc_common_log;
        } else {
            [_casualty, "RECOVERY_CONFIRMATION_FAILED"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
        };
    };

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    if !(_records isEqualType createHashMap) exitWith {
        [_casualty, "COMPLETION_RECORDS_UNAVAILABLE"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
    };
    private _reviverRecord = _records getOrDefault [_reviverUid, createHashMap];
    private _casualtyRecord = _records getOrDefault [_casualtyUid, createHashMap];
    if !(_reviverRecord isEqualType createHashMap && {_casualtyRecord isEqualType createHashMap}) exitWith {
        [_casualty, "COMPLETION_RECORD_MISSING"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
    };

    private _reviver = _reviverRecord getOrDefault ["currentUnit", objNull];
    private _reviverValid = !isNull _reviver
        && {isPlayer _reviver}
        && {alive _reviver}
        && {!([_reviver] call bn_koth_fnc_respawn_isIncapacitated)}
        && {(_reviverRecord getOrDefault ["ownerId", -1]) isEqualTo _reviverOwner}
        && {(owner _reviver) isEqualTo _reviverOwner}
        && {(_reviverRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
        && {_reviverRecord getOrDefault ["deployed", false]};
    private _casualtyValid = (_casualtyRecord getOrDefault ["currentUnit", objNull]) isEqualTo _casualty
        && {isPlayer _casualty}
        && {alive _casualty}
        && {!([_casualty] call bn_koth_fnc_respawn_isIncapacitated)}
        && {(_casualtyRecord getOrDefault ["ownerId", -1]) isEqualTo owner _casualty}
        && {(_casualtyRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
        && {_casualtyRecord getOrDefault ["deployed", false]};
    private _sameTeam = (_reviverRecord getOrDefault ["assignedSide", sideUnknown]) isEqualTo (_casualtyRecord getOrDefault ["assignedSide", sideUnknown]);
    private _recoveryReportValid = _recoveryReportedAt >= 0
        && {(serverTime - _recoveryReportedAt) <= _completionWindow};
    private _commitValid = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE"
        && {_reviverValid}
        && {_casualtyValid}
        && {_recoveryReportValid}
        && {_sameTeam}
        && {_reviver isNotEqualTo _casualty}
        && {(_reviver distance _casualty) <= _maximumDistance};
    if (!_commitValid) exitWith {
        [_casualty, "COMPLETION_VALIDATION_FAILED"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
    };

    // Consume before progression mutation so concurrent or replayed reports
    // cannot produce a second winner for this recovery cycle.
    _cycle set ["status", "CONSUMED"];
    _casualty setVariable ["BN_KOTH_reviveRewardCycleServer", _cycle, false];

    private _completion = createHashMapFromArray [
        ["trustedNativeCompletion", true],
        ["wasIncapacitated", true],
        ["nativeRecoveryConfirmed", true],
        ["reviverUid", _reviverUid],
        ["casualty", _casualty],
        ["cycleToken", _token]
    ];
    private _result = [_completion] call bn_koth_fnc_progression_xp_awardRevive;
    if !(_result getOrDefault ["success", false]) then {
        [format ["Revive completion consumed without reward target=%1 reviver=%2 token=%3 code=%4", _casualtyUid, _reviverUid, _token, _result getOrDefault ["code", "UNKNOWN"]], "WARN"] call bn_koth_fnc_common_log;
    };
    [_casualty, "SUCCESSFUL_RECOVERY"] call bn_koth_fnc_respawn_clearReviveRewardCycle;
};

true

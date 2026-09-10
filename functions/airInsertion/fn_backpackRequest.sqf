/*
    File: fn_backpackRequest.sqf
    Author: Legend
    Description: Validates owner acknowledgements and landing intent for one server-owned temporary insertion backpack state.
    Execution: Server (scheduled RemoteExec)
    Parameters:
        0: PREPARED, LANDED, or RESTORED <STRING>
        1: Insertion session ID <STRING>
        2: Owner-local physical restore comparison result <BOOL>
    Returns: None
    Public: Yes
*/

params [["_operation", "", [""]], ["_sessionId", "", [""]], ["_reportedRestoreMatch", false, [true]]];
if (!isServer || {!isRemoteExecuted} || {!canSuspend} || {_sessionId isEqualTo ""}) exitWith {};

_operation = toUpper _operation;
private _ownerId = remoteExecutedOwner;
private _unit = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _unit) exitWith {};
private _uid = getPlayerUID _unit;
private _states = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
private _state = _states getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {};
if !((_state getOrDefault ["sessionId", ""]) isEqualTo _sessionId) exitWith {};
if !((_state getOrDefault ["unit", objNull]) isEqualTo _unit) exitWith {};
private _now = diag_tickTime;
private _acknowledgementCooldown = (getNumber (missionConfigFile >> "CfgBnKothAirInsertion" >> "backpackAcknowledgementCooldownSeconds")) max 0.1;
private _lastAcknowledgementOperation = _state getOrDefault ["lastAcknowledgementOperation", ""];
if (_operation isEqualTo _lastAcknowledgementOperation
    && {(_now - (_state getOrDefault ["lastAcknowledgementAt", -999])) < _acknowledgementCooldown}) exitWith {};
_state set ["lastAcknowledgementAt", _now];
_state set ["lastAcknowledgementOperation", _operation];
_states set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];

switch (_operation) do {
    case "PREPARED": {
        if !((_state getOrDefault ["phase", ""]) isEqualTo "PREPARING") exitWith {};
        private _parachuteClass = getText (missionConfigFile >> "CfgBnKothAirInsertion" >> "parachuteBackpackClass");
        private _deadline = diag_tickTime + 2;
        waitUntil {
            sleep 0.1;
            (backpack _unit) isEqualTo _parachuteClass || {diag_tickTime >= _deadline}
        };
        if !((backpack _unit) isEqualTo _parachuteClass) exitWith {};
        _state set ["phase", "READY"];
        _states set [_uid, _state];
        missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
    };
    case "LANDED": {
        if !((_state getOrDefault ["phase", ""]) isEqualTo "READY") exitWith {};
        if (!alive _unit || {!((objectParent _unit) isEqualTo objNull)}) exitWith {};
        if (!isTouchingGround _unit && {((getPosATL _unit) select 2) >= 1.5}) exitWith {};
        [_uid, "RESTORE", "PARACHUTE_LANDED"] call bn_koth_fnc_airInsertion_cleanupBackpack;
    };
    case "RESTORED": {
        if !((_state getOrDefault ["phase", ""]) isEqualTo "RESTORING") exitWith {};
        private _originalSlot = _state getOrDefault ["originalSlot", []];
        private _deadline = diag_tickTime + 2;
        waitUntil {
            sleep 0.1;
            ((getUnitLoadout _unit) param [5, []]) isEqualTo _originalSlot || {diag_tickTime >= _deadline}
        };
        private _observedSlot = (getUnitLoadout _unit) param [5, []];
        private _serverMatch = _observedSlot isEqualTo _originalSlot;
        _states = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
        private _currentState = _states getOrDefault [_uid, createHashMap];
        if !(_currentState isEqualType createHashMap
            && {(_currentState getOrDefault ["sessionId", ""]) isEqualTo _sessionId}
            && {(_currentState getOrDefault ["phase", ""]) isEqualTo "RESTORING"}) exitWith {};

        if (_reportedRestoreMatch && {_serverMatch}) then {
            _states deleteAt _uid;
            missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
        } else {
            private _attempts = _currentState getOrDefault ["restoreAttempts", 0];
            [format ["Air insertion backpack restore mismatch. uid=%1 expected=%2 actual=%3 clientMatch=%4 serverMatch=%5 attempt=%6", _uid, _originalSlot param [0, ""], backpack _unit, _reportedRestoreMatch, _serverMatch, _attempts], "WARNING"] call bn_koth_fnc_common_log;
            if (_attempts < 3 && {alive _unit}) then {
                _currentState set ["phase", "READY"];
                _states set [_uid, _currentState];
                missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
                sleep 0.5;
                [_uid, "RESTORE", "RESTORE_RETRY"] call bn_koth_fnc_airInsertion_cleanupBackpack;
            } else {
                _currentState set ["phase", "RESTORE_FAILED"];
                _states set [_uid, _currentState];
                missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
            };
        };
    };
};

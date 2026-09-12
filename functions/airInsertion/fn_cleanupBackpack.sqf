/*
    File: fn_cleanupBackpack.sqf
    Author: Legend
    Description: Restores or clears one server-owned temporary insertion backpack state at an existing lifecycle boundary.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: RESTORE or CLEAR <STRING>
        2: Cleanup reason <STRING>
    Returns: True when state existed <BOOL>
    Public: No
*/

params [["_uid", "", [""]], ["_mode", "CLEAR", [""]], ["_reason", "CLEANUP", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {false};

private _states = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
if (isNil {_states get _uid}) exitWith {false};
private _state = _states getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {false};

private _sessionId = _state getOrDefault ["sessionId", ""];
private _unit = _state getOrDefault ["unit", objNull];
private _record = (missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]) getOrDefault [_uid, createHashMap];
private _ownerId = if (_record isEqualType createHashMap) then {_record getOrDefault ["ownerId", -1]} else {-1};
private _currentUnit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};

if ((toUpper _mode) isEqualTo "RESTORE" && {(_state getOrDefault ["phase", ""]) isEqualTo "RESTORING"}) exitWith {true};

if ((toUpper _mode) isEqualTo "RESTORE" && {!isNull _unit} && {alive _unit} && {_unit isEqualTo _currentUnit} && {_ownerId > 0}) then {
    private _originalSlot = _state getOrDefault ["originalSlot", []];
    private _restoreAttempts = (_state getOrDefault ["restoreAttempts", 0]) + 1;
    _state set ["phase", "RESTORING"];
    _state set ["restoreAttempts", _restoreAttempts];
    _states set [_uid, _state];
    missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
    ["RESTORE", _sessionId, _originalSlot, _unit] remoteExec ["bn_koth_fnc_airInsertion_applyBackpack", _ownerId];
    [_uid, _sessionId, _restoreAttempts] spawn {
        params ["_uid", "_sessionId", "_attempt"];
        sleep 15;
        private _states = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
        private _state = _states getOrDefault [_uid, createHashMap];
        if !(_state isEqualType createHashMap
            && {(_state getOrDefault ["sessionId", ""]) isEqualTo _sessionId}
            && {(_state getOrDefault ["phase", ""]) isEqualTo "RESTORING"}
            && {(_state getOrDefault ["restoreAttempts", 0]) isEqualTo _attempt}) exitWith {};

        [format ["Air insertion backpack RESTORE FAILED uid=%1 reason=ACK_TIMEOUT attempt=%2", _uid, _attempt], "WARNING"] call bn_koth_fnc_common_log;
        if (_attempt < 3) then {
            _state set ["phase", "READY"];
            _states set [_uid, _state];
            missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
            [_uid, "RESTORE", "RESTORE_ACK_TIMEOUT_RETRY"] call bn_koth_fnc_airInsertion_cleanupBackpack;
        } else {
            _state set ["phase", "RESTORE_FAILED"];
            _states set [_uid, _state];
            missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
        };
    };
} else {
    if ((toUpper _mode) isEqualTo "RESTORE") then {
        [format ["Air insertion backpack restoration failed for an invalid representation or owner. uid=%1 reason=%2", _uid, _reason], "WARNING"] call bn_koth_fnc_common_log;
    };
    if (_ownerId > 0) then {
        ["CLEAR", _sessionId, [], objNull] remoteExec ["bn_koth_fnc_airInsertion_applyBackpack", _ownerId];
    };
    _states deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _states];
};
true

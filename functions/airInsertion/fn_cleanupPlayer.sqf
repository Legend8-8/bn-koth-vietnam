/*
    File: fn_cleanupPlayer.sqf
    Author: Legend
    Description: Removes one UID from insertion invitations or participation at an existing player lifecycle boundary.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Cleanup reason <STRING>
    Returns: Number of affected sessions <NUMBER>
    Public: No
*/

params [["_uid", "", [""]], ["_reason", "PLAYER_INVALID", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {0};

switch (toUpper _reason) do {
    case "PLAYER_DIED";
    case "PLAYER_DISCONNECTED";
    case "RETURNED_TO_LOBBY": {[_uid, "CLEAR", _reason] call bn_koth_fnc_airInsertion_cleanupBackpack};
    case "NORMAL_AIRCRAFT_EXIT": {[_uid, "RESTORE", _reason] call bn_koth_fnc_airInsertion_cleanupBackpack};
};

private _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
private _affected = 0;
{
    private _sessionId = _x;
    private _session = _sessions getOrDefault [_sessionId, createHashMap];
    if !(_session isEqualType createHashMap) then {continue};
    private _state = _session getOrDefault ["state", ""];
    private _passengers = +(_session getOrDefault ["passengerUids", []]);
    private _invited = +(_session getOrDefault ["invitedUids", []]);
    if !(_uid in _passengers || {_uid in _invited}) then {continue};
    _affected = _affected + 1;

    if (_uid isEqualTo (_session getOrDefault ["initiatorUid", ""]) && {_state in ["OPEN", "COMMITTING"]}) then {
        [_sessionId, _reason, if (_state isEqualTo "COMMITTING") then {"RETURN"} else {"NONE"}] call bn_koth_fnc_airInsertion_cleanupSession;
        _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
        continue;
    };

    _session set ["passengerUids", _passengers - [_uid]];
    _session set ["aboardUids", +(_session getOrDefault ["aboardUids", []]) - [_uid]];
    _session set ["invitedUids", _invited - [_uid]];
    _sessions set [_sessionId, _session];
    missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];
    private _playerSessions = missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
    if ((_playerSessions getOrDefault [_uid, ""]) isEqualTo _sessionId) then {_playerSessions deleteAt _uid};
    missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];
    private _record = (missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]) getOrDefault [_uid, createHashMap];
    if (_record isEqualType createHashMap && {(_record getOrDefault ["ownerId", -1]) > 0}) then {
        [createHashMap] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _record get "ownerId"];
    };

    if (_state isEqualTo "AIRBORNE" && {(_session getOrDefault ["aboardUids", []]) isEqualTo []}) then {
        [_sessionId, "NO_PASSENGERS_REMAIN", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
        _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
    } else {
        [_sessionId] call bn_koth_fnc_airInsertion_publishSession;
    };
} forEach +(keys _sessions);

_affected

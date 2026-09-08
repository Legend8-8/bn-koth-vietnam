/*
    File: fn_cleanupSession.sqf
    Author: Legend
    Description: Clears insertion membership/presentation and either terminates the aircraft or begins bounded empty-aircraft abandonment.
    Execution: Server
    Parameters:
        0: Session ID <STRING>
        1: Cleanup reason <STRING>
        2: Passenger disposition: NONE, RETURN, or native EJECT <STRING>
    Returns: True when a session was cleaned <BOOL>
    Public: No
*/

params [["_sessionId", "", [""]], ["_reason", "CLEANUP", [""]], ["_disposition", "NONE", [""]]];
if (!isServer || {_sessionId isEqualTo ""}) exitWith {false};

private _sessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
if (isNil {_sessions get _sessionId}) exitWith {false};
private _session = _sessions getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap) exitWith {false};
private _reasonUpper = toUpper _reason;

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _passengers = +(_session getOrDefault ["passengerUids", []]);
private _aboard = +(_session getOrDefault ["aboardUids", []]);
private _moveUids = if ((_session getOrDefault ["state", ""]) isEqualTo "COMMITTING") then {_passengers} else {_aboard};
private _recipients = (_passengers + (_session getOrDefault ["invitedUids", []])) arrayIntersect (_passengers + (_session getOrDefault ["invitedUids", []]));
private _aircraft = _session getOrDefault ["aircraft", objNull];
private _originalPositions = _session getOrDefault ["originalPositionsASL", createHashMap];
private _failureMessage = switch (_reasonUpper) do {
    case "PARACHUTE_PREPARATION_FAILED": {"Parachute preparation failed."};
    case "BOARDING_FAILED": {"Aircraft boarding failed."};
    case "CAPACITY_CHANGED";
    case "NO_PILOT_SEAT";
    case "AIRCRAFT_CREATE_FAILED";
    case "AIRCRAFT_CLASS_INVALID";
    case "TRANSFORM_FAILED": {"Air insertion is unavailable."};
    case "INITIATOR_INELIGIBLE";
    case "ROUND_OR_AO_INVALID";
    case "SERVICE_DISABLED": {"Air insertion is unavailable right now."};
    default {""};
};
if !(_failureMessage isEqualTo "") then {
    {
        private _record = _records getOrDefault [_x, createHashMap];
        if (_record isEqualType createHashMap) then {
            [_record getOrDefault ["ownerId", -1], _failureMessage] call bn_koth_fnc_teams_notifyPlayer;
        };
    } forEach _recipients;
};

if ((toUpper _disposition) isEqualTo "EJECT" && {!isNull _aircraft}) then {
    {
        private _record = _records getOrDefault [_x, createHashMap];
        private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
        if (!isNull _unit && {alive _unit} && {(vehicle _unit) isEqualTo _aircraft}) then {
            if (_reasonUpper isEqualTo "HARD_TIMEOUT") then {
                [_record getOrDefault ["ownerId", -1], "Air insertion time expired. Ejecting occupants."] call bn_koth_fnc_teams_notifyPlayer;
            };
            ["EJECT", _aircraft, [], _sessionId] remoteExecCall ["bn_koth_fnc_airInsertion_applyPassengerMove", owner _unit];
        };
    } forEach _moveUids;
};

if ((toUpper _disposition) isEqualTo "RETURN") then {
    {
        private _record = _records getOrDefault [_x, createHashMap];
        private _unit = if (_record isEqualType createHashMap) then {_record getOrDefault ["currentUnit", objNull]} else {objNull};
        private _returnPos = if (_originalPositions isEqualType createHashMap) then {_originalPositions getOrDefault [_x, []]} else {[]};
        if (!isNull _unit && {(count _returnPos) >= 3}) then {
            ["RETURN", _aircraft, _returnPos, _sessionId] remoteExecCall ["bn_koth_fnc_airInsertion_applyPassengerMove", owner _unit];
        };
        [_x, "RESTORE", _reason] call bn_koth_fnc_airInsertion_cleanupBackpack;
    } forEach _moveUids;
};

private _playerSessions = missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
{if ((_playerSessions getOrDefault [_x, ""]) isEqualTo _sessionId) then {_playerSessions deleteAt _x}} forEach _passengers;
missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _playerSessions];

{
    private _record = _records getOrDefault [_x, createHashMap];
    if (_record isEqualType createHashMap && {(_record getOrDefault ["ownerId", -1]) > 0}) then {
        [createHashMap] remoteExecCall ["bn_koth_fnc_airInsertion_receiveState", _record get "ownerId"];
    };
} forEach _recipients;

if (_reasonUpper isEqualTo "NO_PASSENGERS_REMAIN" && {!isNull _aircraft}) exitWith {
    _session set ["state", "ABANDONED"];
    _session set ["passengerUids", []];
    _session set ["aboardUids", []];
    _session set ["invitedUids", []];
    _sessions set [_sessionId, _session];
    missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

    private _grace = (getNumber (missionConfigFile >> "CfgBnKothAirInsertion" >> "abandonedCleanupDelay")) max 5;
    [_sessionId, _grace] spawn {
        params ["_sessionId", "_grace"];
        sleep _grace;
        [_sessionId, "ABANDONED_TIMEOUT", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession;
    };
    true
};

_sessions deleteAt _sessionId;
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _sessions];

private _deleteAircraft = {
    params ["_aircraft"];
    if (!isNull _aircraft) then {
        {if (!isPlayer _x) then {deleteVehicle _x}} forEach crew _aircraft;
        deleteVehicle _aircraft;
    };
};

if ((toUpper _disposition) in ["RETURN", "EJECT"]) then {
    [_aircraft, _deleteAircraft] spawn {
        params ["_aircraft", "_deleteAircraft"];
        sleep 2;
        [_aircraft] call _deleteAircraft;
    };
} else {
    [_aircraft] call _deleteAircraft;
};

if !(_reasonUpper in ["ABANDONED_TIMEOUT", "INITIATOR_CANCELLED"]) then {
    [format ["Air insertion cleaned id=%1 reason=%2 disposition=%3", _sessionId, _reasonUpper, toUpper _disposition]] call bn_koth_fnc_common_log;
};
true

/*
    File: fn_cancelService.sqf
    Author: Legend
    Description: Clears one server-owned personal vehicle service session and
        its requester-only presentation without charging the player.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: cancellation reason <STRING>
    Returns: True when a session was cleared <BOOL>
    Public: No
*/

params [["_uid", "", [""]], ["_reason", "CANCELLED", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {false};

private _sessions = missionNamespace getVariable ["BN_KOTH_vehicleServiceSessions", createHashMap];
private _session = _sessions getOrDefault [_uid, createHashMap];
if !(_session isEqualType createHashMap && {(count _session) > 0}) exitWith {false};

_sessions deleteAt _uid;
missionNamespace setVariable ["BN_KOTH_vehicleServiceSessions", _sessions];
private _vehicle = _session getOrDefault ["vehicle", objNull];
if (!isNull _vehicle) then {_vehicle setVariable ["BN_KOTH_personalServiceActive", false, true]};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
private _ownerId = if (_record isEqualType createHashMap) then {_record getOrDefault ["ownerId", -1]} else {-1};
private _purpose = _session getOrDefault ["purpose", "SERVICE"];
private _displayName = _session getOrDefault ["displayName", "Aircraft"];
if (_ownerId > 0) then {
    ["CLEAR", _session getOrDefault ["sessionId", ""], [], 0, 0, 0, _purpose, _displayName] remoteExecCall ["bn_koth_fnc_vehicles_setServicePresentation", _ownerId];
    private _title = if (_purpose isEqualTo "RETURN") then {
        if ((toUpper _reason) isEqualTo "TIMEOUT") then {"RETURN VEHICLE EXPIRED"} else {"RETURN VEHICLE CANCELLED"}
    } else {
        if ((toUpper _reason) isEqualTo "TIMEOUT") then {"REPAIR & REARM EXPIRED"} else {"REPAIR & REARM CANCELLED"}
    };
    private _body = if (_purpose isEqualTo "RETURN") then {
        switch (toUpper _reason) do {
            case "TIMEOUT": {format ["Return gate for %1 expired. The vehicle remains active.", _displayName]};
            case "PILOT_LEFT": {"Pilot role was left. The vehicle remains active."};
            case "AO_CHANGED": {"The active AO changed. The vehicle remains active."};
            case "VEHICLE_LOST": {"The vehicle was lost before it could be returned."};
            case "PLAYER_LOST": {"Player or pilot was lost. Return was cancelled."};
            default {"Vehicle return was cancelled. The vehicle remains active."};
        }
    } else {
        switch (toUpper _reason) do {
            case "PAYMENT_FAILED": {"Payment failed. No service was applied."};
            case "TIMEOUT": {"Service point expired. No charge."};
            case "PILOT_LEFT": {"Pilot role was left. No charge."};
            case "AO_CHANGED": {"The active AO changed. No charge."};
            case "VEHICLE_LOST": {"Vehicle lost. No charge."};
            case "PLAYER_LOST": {"Player or pilot was lost. No charge."};
            default {"Vehicle service was cancelled. No charge."};
        }
    };
    [_ownerId, createHashMapFromArray [["title", _title], ["body", _body], ["footer", ""]]] call bn_koth_fnc_teams_notifyPlayer;
};

[format [
    "Vehicle air operation CANCELLED UID=%1 purpose=%2 reason=%3 loadout=%4 class=%5 price=%6",
    _uid,
    _purpose,
    toUpper _reason,
    _session getOrDefault ["loadoutId", ""],
    _session getOrDefault ["vehicleClass", ""],
    _session getOrDefault ["price", -1]
], "INFO"] call bn_koth_fnc_common_log;
true

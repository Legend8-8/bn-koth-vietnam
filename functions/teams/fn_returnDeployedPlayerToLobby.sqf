/*
    File: fn_returnDeployedPlayerToLobby.sqf
    Author: Legend
    Description: Returns one currently-deployed (ACTIVE/DEPLOYING) player to the
        authoritative neutral lobby representation without disconnecting them.
        Ends an orphaned owned vehicle rental life through the existing rental
        owner rather than duplicating cleanup logic. Does not touch persistent
        progression, round stats, or weapon rental entitlement.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        True on success or already-lobby no-op, otherwise false <BOOL>
    Public: Yes
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
if (_ownerId <= 0) exitWith {
    [format ["returnDeployedPlayerToLobby rejected: invalid owner for UID=%1", _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

private _state = _record getOrDefault ["state", "LOBBY"];
if (_state isEqualTo "LOBBY") exitWith {
    [_ownerId, "You are already in the lobby."] call bn_koth_fnc_teams_notifyPlayer;
    true
};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState in ["PREPARING", "ACTIVE"]) exitWith {
    [_ownerId, "Return to lobby is not available during this round phase."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["returnDeployedPlayerToLobby rejected: round state=%1 UID=%2", _roundState, _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

if !(_state in ["ACTIVE", "DEPLOYING"]) exitWith {
    [_ownerId, "Return to lobby rejected: you are not currently deployed."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["returnDeployedPlayerToLobby rejected: invalid state=%1 UID=%2", _state, _uid], "WARN"] call bn_koth_fnc_common_log;
    false
};

// Vehicle rental is one-life-per-UID; end it through its existing owner instead of leaving it orphaned.
private _activeRentals = missionNamespace getVariable ["BN_KOTH_vehicleActiveRentals", createHashMap];
private _rentalRecord = _activeRentals getOrDefault [_uid, createHashMap];
private _rentedVehicle = _rentalRecord getOrDefault ["vehicle", objNull];
if (!isNull _rentedVehicle && {alive _rentedVehicle}) then {
    [_uid, _rentedVehicle, "RETURNED_TO_LOBBY"] call bn_koth_fnc_vehicles_endRentalLife;
    deleteVehicle _rentedVehicle;
};

private _lobbyOk = [_uid] call bn_koth_fnc_teams_assignLobbyRepresentation;
if (!_lobbyOk) exitWith {
    [_ownerId, "Return to lobby failed: lobby representation is not ready."] call bn_koth_fnc_teams_notifyPlayer;
    [format ["returnDeployedPlayerToLobby failed: lobby handoff UID=%1", _uid], "ERROR"] call bn_koth_fnc_common_log;
    false
};

[_uid] call bn_koth_fnc_loadouts_clearPlayerState;

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
_activeParticipants = _activeParticipants - [_uid];
["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;

_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

_record set ["assignedSide", sideUnknown];
_record set ["state", "LOBBY"];
_record set ["deployed", false];
_record set ["voteLocationId", ""];
_record set ["safeZoneProtected", false];
_record set ["enemySafeZoneIntruder", false];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

[] call bn_koth_fnc_round_updateVoteTotals;
[] call bn_koth_fnc_teams_publishState;

[_ownerId, "You returned to the lobby."] call bn_koth_fnc_teams_notifyPlayer;
[format ["Deployed player returned to lobby UID=%1", _uid], "INFO"] call bn_koth_fnc_common_log;
true

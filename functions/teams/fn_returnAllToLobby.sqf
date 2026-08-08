/*
    File: fn_returnAllToLobby.sqf
    Author: Legend
    Description: Ends gameplay participation and restores neutral lobby representation.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];

{
    private _uid = _x;
    private _record = _records get _uid;

    if !(_record isEqualType createHashMap) then {
        continue;
    };

    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) then {
        continue;
    };

    private _ownerPlayer = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (isNull _ownerPlayer) then {
        continue;
    };

    private _success = [_uid] call bn_koth_fnc_teams_assignLobbyRepresentation;
    if (!_success) then {
        [format ["Failed to restore neutral lobby representation for UID %1", _uid], "ERROR"] call bn_koth_fnc_common_log;
        continue;
    };

    _record = _records getOrDefault [_uid, createHashMap];
    if (_record isEqualType createHashMap) then {
        _record set ["assignedSide", sideUnknown];
        _record set ["voteLocationId", ""];
        _record set ["state", "LOBBY"];
        _records set [_uid, _record];
    };
} forEach (keys _records);

missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
["BN_KOTH_activeParticipants", []] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_round_updateVoteTotals;
[] call bn_koth_fnc_teams_publishState;

["All active gameplay participants returned to neutral lobby representation."] call bn_koth_fnc_common_log;

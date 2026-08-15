/*
    File: fn_removePlayer.sqf
    Author: Legend
    Edited: Mongo
    Description: Removes disconnected player from authoritative team and vote state.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        None
    Public: Yes
*/

params ["_uid"];

if (!isServer) exitWith {};
if (_uid isEqualTo "") exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];

if (_record isEqualType createHashMap) then {
    private _unit = _record getOrDefault ["currentUnit", objNull];
    if (!isNull _unit) then {
        _unit setVariable ["BN_KOTH_safeZoneProtected", false, true];
        _unit setVariable ["BN_KOTH_enemySafeZoneIntruder", false, true];

        if (!isPlayer _unit) then {
            deleteVehicle _unit;
        };
    };
};

_records deleteAt _uid;
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
_activeParticipants = _activeParticipants - [_uid];
["BN_KOTH_activeParticipants", _activeParticipants] call bn_koth_fnc_common_publicState;

private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if (_votesByUid isEqualType createHashMap) then {
    _votesByUid deleteAt _uid;
    ["BN_KOTH_votesByUid", _votesByUid] call bn_koth_fnc_common_publicState;
};

[] call bn_koth_fnc_round_updateVoteTotals;
[] call bn_koth_fnc_round_maybeShortenVoteDeadline;
[] call bn_koth_fnc_teams_publishState;

[format ["Removed disconnected player UID=%1 from lobby/team/vote state", _uid]] call bn_koth_fnc_common_log;

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

[_uid, "PLAYER_DISCONNECTED"] call bn_koth_fnc_airInsertion_cleanupPlayer;
[_uid] call bn_koth_fnc_progression_transport_cleanup;

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
private _groupImpact = [[_uid], []] call bn_koth_fnc_groups_capturePresentationImpact;
private _invalidatedInvites = [[_uid], [], [_uid], false] call bn_koth_fnc_groups_clearInvites;
_groupImpact set ["directUids", (_groupImpact getOrDefault ["directUids", []]) + _invalidatedInvites];
private _groupChanged = [_uid] call bn_koth_fnc_groups_removeMember;

[_uid] call bn_koth_fnc_career_accumulatePlaytime;
private _careerFlush = [_uid, "disconnect"] call bn_koth_fnc_career_flushPlayer;
if !(_careerFlush getOrDefault ["success", false]) then {
    [format ["Disconnect career flush failed UID=%1 code=%2", _uid, _careerFlush getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
};
private _careerSessions = missionNamespace getVariable ["BN_KOTH_careerSessions", createHashMap];
_careerSessions deleteAt _uid;
missionNamespace setVariable ["BN_KOTH_careerSessions", _careerSessions];

private _saveResult = [_uid, "disconnect"] call bn_koth_fnc_persistence_savePlayer;
if !(_saveResult getOrDefault ["success", false]) then {
    [format ["Disconnect persistence save failed UID=%1 code=%2", _uid, _saveResult getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
};

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

private _handoffs = missionNamespace getVariable ["BN_KOTH_transferHandoffPending", createHashMap];
if (_handoffs isEqualType createHashMap) then {
    _handoffs deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_transferHandoffPending", _handoffs];
};
private _returns = missionNamespace getVariable ["BN_KOTH_returnToLobbyPending", []];
missionNamespace setVariable ["BN_KOTH_returnToLobbyPending", _returns - [_uid]];

[_uid] call bn_koth_fnc_loadouts_clearPlayerState;

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
if (_groupChanged || {(count (_groupImpact getOrDefault ["inviteCandidateSides", []])) > 0} || {(count _invalidatedInvites) > 0}) then {
    private _groupIds = _groupImpact getOrDefault ["groupIds", []];
    if ((count _groupIds) > 0) then {
        [_groupIds] call bn_koth_fnc_groups_reconcile;
    };
    private _groupImpactAfter = [[], _groupIds] call bn_koth_fnc_groups_capturePresentationImpact;
    [[_groupImpact, _groupImpactAfter]] call bn_koth_fnc_groups_publishUpdate;
};
if (([] call bn_koth_fnc_round_getState) isEqualTo "WAITING") then {
    [count ([] call bn_koth_fnc_teams_getConnectedHumanUids)] call bn_koth_fnc_round_reconcileVoteCandidates;
};

[format ["Removed disconnected player UID=%1 from lobby/team/vote state", _uid]] call bn_koth_fnc_common_log;

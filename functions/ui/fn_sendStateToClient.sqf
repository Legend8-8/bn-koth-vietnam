/*
    File: fn_sendStateToClient.sqf
    Author: tylervip
    Edited: Legend
    Description: Sends a mission snapshot from server to one client.
    Execution: Server
    Parameters:
        0: Target player <OBJECT>
    Returns:
        None
    Public: Yes
*/

params ["_targetPlayer"];

if (!isServer) exitWith {};
if (isNull _targetPlayer) exitWith {};
if !(isPlayer _targetPlayer) exitWith {};
if ((owner _targetPlayer) <= 0) exitWith {};

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _payload = createHashMapFromArray [
    ["roundState", missionNamespace getVariable ["BN_KOTH_roundState", "WAITING"]],
    ["playerStates", missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap]],
    ["playerTeamAssignments", missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap]],
    ["playerNames", missionNamespace getVariable ["BN_KOTH_playerNames", createHashMap]],
    ["teamCounts", missionNamespace getVariable ["BN_KOTH_teamCounts", createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]]],
    ["activeParticipants", missionNamespace getVariable ["BN_KOTH_activeParticipants", []]],
    ["selectedLocationId", missionNamespace getVariable ["BN_KOTH_selectedLocationId", ""]],
    ["previousLocationId", missionNamespace getVariable ["BN_KOTH_previousLocationId", ""]],
    ["activeLocationId", missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]],
    ["activeZoneMarker", missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""]],
    ["activeRespawnWestMarker", missionNamespace getVariable ["BN_KOTH_activeRespawnWestMarker", ""]],
    ["activeRespawnEastMarker", missionNamespace getVariable ["BN_KOTH_activeRespawnEastMarker", ""]],
    ["voteOpen", missionNamespace getVariable ["BN_KOTH_voteOpen", false]],
    ["voteCandidates", missionNamespace getVariable ["BN_KOTH_voteCandidates", []]],
    ["voteTotals", missionNamespace getVariable ["BN_KOTH_voteTotals", createHashMap]],
    ["votesByUid", missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap]],
    ["voteEndAt", missionNamespace getVariable ["BN_KOTH_voteEndAt", -1]],
    ["zoneState", missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"]],
    ["zoneController", missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown]],
    ["zonePopulation", missionNamespace getVariable ["BN_KOTH_zonePopulation", [0, 0]]],
    ["scoreProgress", missionNamespace getVariable ["BN_KOTH_scoreProgress", createHashMap]],
    ["winningSide", missionNamespace getVariable ["BN_KOTH_winningSide", sideUnknown]],
    ["maxPlayers", missionNamespace getVariable ["BN_KOTH_maxPlayers", 100]],
    ["maxTeamPlayers", missionNamespace getVariable ["BN_KOTH_maxTeamPlayers", 50]],
    [
        "teamScores",
        missionNamespace getVariable [
            "BN_KOTH_teamScores",
            createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]
        ]
    ],
    ["scoreLimit", missionNamespace getVariable ["BN_KOTH_scoreLimit", 100]],
    ["prepareEndAt", missionNamespace getVariable ["BN_KOTH_prepareEndAt", -1]],
    ["endingEndAt", missionNamespace getVariable ["BN_KOTH_endingEndAt", -1]],
    ["resetEndAt", missionNamespace getVariable ["BN_KOTH_resetEndAt", -1]]
];

[_payload] remoteExecCall ["bn_koth_fnc_ui_receiveState", owner _targetPlayer];

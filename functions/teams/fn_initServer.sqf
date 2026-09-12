/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes server-owned lobby/team/player identity state.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _maxPlayers = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxPlayers")} else {100};
private _maxTeamPlayers = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxTeamPlayers")} else {50};

if (_maxPlayers < 1) then {
    _maxPlayers = 1;
};

if (_maxTeamPlayers < 1) then {
    _maxTeamPlayers = 1;
};

missionNamespace setVariable ["BN_KOTH_playerRecords", createHashMap];
missionNamespace setVariable ["BN_KOTH_transferHandoffPending", createHashMap];
missionNamespace setVariable ["BN_KOTH_returnToLobbyPending", []];
["BN_KOTH_maxPlayers", _maxPlayers] call bn_koth_fnc_common_publicState;
["BN_KOTH_maxTeamPlayers", _maxTeamPlayers] call bn_koth_fnc_common_publicState;
["BN_KOTH_playerStates", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_playerTeamAssignments", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_playerNames", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_playerLevels", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_teamCounts", createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]] call bn_koth_fnc_common_publicState;
["BN_KOTH_activeParticipants", []] call bn_koth_fnc_common_publicState;

["BN_KOTH_voteCandidates", []] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteTotals", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteOpen", false] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteEndAt", -1] call bn_koth_fnc_common_publicState;
["BN_KOTH_selectedLocationId", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_previousLocationId", ""] call bn_koth_fnc_common_publicState;

addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];

    [_uid] call bn_koth_fnc_teams_removePlayer;
    false
}];

/*
	File: fn_resetRound.sqf
	Author: tylervip
	Edited: Legend
	Edited: Mongo
	Description: Performs authoritative round reset and returns to WAITING.
	Execution: Server
	Parameters:
		None
	Returns:
		True when reset executed, otherwise false <BOOL>
	Public: Yes
*/

if (!isServer) exitWith {false};

private _state = [] call bn_koth_fnc_round_getState;
if !(_state isEqualTo "RESETTING") exitWith {
	[format ["Ignored reset outside RESETTING state (%1)", _state], "WARN"] call bn_koth_fnc_common_log;
	false
};

private _resetDuration = missionNamespace getVariable ["BN_KOTH_resetDuration", 5];
["BN_KOTH_resetEndAt", serverTime + _resetDuration] call bn_koth_fnc_common_publicState;
sleep _resetDuration;

private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
if !(_activeLocationId isEqualTo "") then {
	["BN_KOTH_previousLocationId", _activeLocationId] call bn_koth_fnc_common_publicState;
};

[] call bn_koth_fnc_teams_returnAllToLobby;
[] call bn_koth_fnc_zone_clearActiveLocation;
[] call bn_koth_fnc_scoring_resetProgress;

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

missionNamespace setVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]],
    true
];
["BN_KOTH_winningSide", sideUnknown] call bn_koth_fnc_common_publicState;
["BN_KOTH_zoneController", sideUnknown] call bn_koth_fnc_common_publicState;
["BN_KOTH_zoneState", "NEUTRAL"] call bn_koth_fnc_common_publicState;
["BN_KOTH_zonePopulation", createHashMapFromArray [
    ["raw", [0, 0]],
    ["weighted", [0, 0]],
    ["priority", [0, 0]]
]] call bn_koth_fnc_common_publicState;
["BN_KOTH_selectedLocationId", ""] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteCandidates", []] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteOpen", false] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteEndAt", -1] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_round_updateVoteTotals;

["WAITING"] call bn_koth_fnc_round_setState;
[] call bn_koth_fnc_round_prepareVoteCandidates;
true

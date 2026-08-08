/*
	File: fn_resetRound.sqf
	Author: Legend
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
["BN_KOTH_zonePopulation", [0, 0]] call bn_koth_fnc_common_publicState;

["WAITING"] call bn_koth_fnc_round_setState;
true

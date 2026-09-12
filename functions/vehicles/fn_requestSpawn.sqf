/*
	File: fn_requestSpawn.sqf
	Author: tylervip
	Description: Legacy request endpoint retained for compatibility; managed free vehicles auto-spawn server-side.
	Execution: Server
	Parameters:
		None
	Returns:
		False (manual request flow disabled) <BOOL>
	Public: Yes
*/

if (!isServer) exitWith {false};

["Vehicle spawn request ignored: managed free vehicle lifecycle is server-automatic.", "INFO"] call bn_koth_fnc_common_log;
false

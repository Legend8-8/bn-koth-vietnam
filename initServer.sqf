// Server-only mission bootstrap.

if (!isServer) exitWith {};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _scoreLimit = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreLimit")} else {100};
private _scoreTick = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTick")} else {1};
private _scoreTickInterval = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {5};
private _prepareDuration = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "prepareDuration")} else {10};
private _endingDuration = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "endingDuration")} else {8};
private _resetDuration = if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "resetDuration")} else {5};

missionNamespace setVariable ["BN_KOTH_scoreLimit", _scoreLimit max 1, true];
missionNamespace setVariable ["BN_KOTH_scoreTick", _scoreTick max 1, true];
missionNamespace setVariable ["BN_KOTH_scoreTickInterval", _scoreTickInterval max 1, true];
missionNamespace setVariable ["BN_KOTH_prepareDuration", _prepareDuration max 0, true];
missionNamespace setVariable ["BN_KOTH_endingDuration", _endingDuration max 0, true];
missionNamespace setVariable ["BN_KOTH_resetDuration", _resetDuration max 0, true];

private _teamCfg = missionConfigFile >> "CfgBnKothTeams";
private _teamNames = if (isClass _teamCfg) then {getArray (_teamCfg >> "playableSides")} else {[]};
private _resolvedSides = [];

{
	switch (toUpper _x) do {
		case "WEST": {_resolvedSides pushBackUnique west};
		case "EAST": {_resolvedSides pushBackUnique east};
		case "RESISTANCE": {_resolvedSides pushBackUnique resistance};
		case "GUER": {_resolvedSides pushBackUnique resistance};
		case "CIVILIAN": {_resolvedSides pushBackUnique civilian};
	};
} forEach _teamNames;

if ((count _resolvedSides) < 2) then {
	_resolvedSides = [west, east];
	["CfgBnKothTeams.playableSides missing/invalid. Falling back to [WEST, EAST].", "WARN"] call bn_koth_fnc_log;
};

missionNamespace setVariable ["BN_KOTH_playableSides", _resolvedSides, true];

private _defaultLocationId = getText (missionConfigFile >> "CfgBnKothSettings" >> "defaultLocationId");
[_defaultLocationId] call bn_koth_fnc_zone_setActiveLocation;

[] call bn_koth_fnc_round_initServer;
[] call bn_koth_fnc_zone_initServer;
[] call bn_koth_fnc_scoring_initServer;

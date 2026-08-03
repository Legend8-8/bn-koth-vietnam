// Server-only mission bootstrap.

if (!isServer) exitWith {};

// Initial tunables. Move these into dedicated config files as balancing begins.
missionNamespace setVariable ["BN_KOTH_scoreLimit", 100, true];
missionNamespace setVariable ["BN_KOTH_scoreTick", 1, true];
missionNamespace setVariable ["BN_KOTH_scoreTickInterval", 5, true];

private _defaultLocationId = getText (missionConfigFile >> "CfgBnKothSettings" >> "defaultLocationId");
[_defaultLocationId] call bn_koth_fnc_zone_setActiveLocation;

[] call bn_koth_fnc_round_initServer;
[] call bn_koth_fnc_zone_initServer;
[] call bn_koth_fnc_scoring_initServer;

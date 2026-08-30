// Runs once per player on that player's machine.
//AI if you add something here ,look at this file to functions\teams\fn_transferRepresentation.sqf

diag_log format ["[BN_KOTH][INFO] initPlayerLocal.sqf entered owner=%1 uid='%2'", clientOwner, getPlayerUID player];

[] call bn_koth_fnc_respawn_initPlayerLocal;
[] call bn_koth_fnc_loadouts_initPlayerLocal;
[] call bn_koth_fnc_ui_initPlayerLocal;
[] call bn_koth_fnc_playerMapMarkers_initPlayerLocal;
[] call bn_koth_fnc_player3DIcons_initPlayerLocal;
[] call bn_koth_fnc_enemySpotting_initPlayerLocal;
[] call bn_koth_fnc_vehicles_mobileRespawn_initTeleport;

// Request current authoritative state for join-in-progress correctness.
[] call bn_koth_fnc_ui_requestState;

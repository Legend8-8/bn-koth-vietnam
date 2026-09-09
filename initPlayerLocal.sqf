// Runs once per player on that player's machine.
// If you add local-only setup here, also check functions\teams\fn_transferRepresentation.sqf and re-run it after representation transfers.
// The new controlled unit can change, so unit-bound actions/handlers must be reattached on the transferred unit.

diag_log format ["[BN_KOTH][INFO] initPlayerLocal.sqf entered owner=%1 uid='%2'", clientOwner, getPlayerUID player];

[] call bn_koth_fnc_respawn_initPlayerLocal;
[] call bn_koth_fnc_loadouts_initPlayerLocal;
[] call bn_koth_fnc_magRepack_initPlayerLocal;
[] call bn_koth_fnc_traversal_initPlayerLocal;
[] call bn_koth_fnc_ui_initPlayerLocal;
[] call bn_koth_fnc_playerMapMarkers_initPlayerLocal;
[] call bn_koth_fnc_player3DIcons_initPlayerLocal;
[] call bn_koth_fnc_enemySpotting_initPlayerLocal;
[] call bn_koth_fnc_vehicles_mobileRespawn_initTeleport;

// Request current authoritative state for join-in-progress correctness.
[] call bn_koth_fnc_ui_requestState;

// Runs once per player on that player's machine.

diag_log format ["[BN_KOTH][INFO] initPlayerLocal.sqf entered owner=%1 uid='%2'", clientOwner, getPlayerUID player];

[] call bn_koth_fnc_ui_initPlayerLocal;

// Request current authoritative state for join-in-progress correctness.
[] call bn_koth_fnc_ui_requestState;

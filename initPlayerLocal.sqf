// Runs once per player on that player's machine.

[] call bn_koth_fnc_ui_initPlayerLocal;

// Request current authoritative state for join-in-progress correctness.
[] call bn_koth_fnc_ui_requestState;

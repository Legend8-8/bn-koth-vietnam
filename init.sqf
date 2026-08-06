// Shared mission init. Keep global side effects minimal.

// Disable Arma built-in mission save/resume on every machine.
enableSaving [false, false];

if (hasInterface) then {
    // Client-side setup is owned by initPlayerLocal.sqf.
};

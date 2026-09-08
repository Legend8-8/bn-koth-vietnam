class CfgBnKothRespawn
{
    // Local EHs handle the critical fire/damage/blocking checks, so the server can use
    // a slower authoritative tick without losing safety or gameplay correctness.
    safeZoneCheckIntervalSeconds = 5.0;
    blockedActionMessageCooldownSeconds = 1;
    friendlySafeZoneExitMessageSeconds = 5;
    corpseCleanupDelaySeconds = 300;

    // Call For Help presentation. The 3D marker is never rendered beyond this range.
    casualtyHelp3DMaxDistance = 50;

    // Playtest-only native hold-action probe. No consumption path exists until
    // a Resuscitate-specific start identity is proven from runtime evidence.
    experimentalHoldActionDiagnostics = 1;
    experimentalHoldActionDiagnosticSeconds = 7200;
    experimentalHoldActionDiagnosticInterval = 0.05;
};

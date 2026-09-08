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
    casualtyCameraOffset[] = {0, -3.25, 2.15};
    casualtyCameraTargetHeight = 0.45;
    casualtyCameraFov = 0.7;
};

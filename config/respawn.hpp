class CfgBnKothRespawn
{
    // Local EHs handle the critical fire/damage/blocking checks, so the server can use
    // a slower authoritative tick without losing safety or gameplay correctness.
    safeZoneCheckIntervalSeconds = 5.0;
    blockedActionMessageCooldownSeconds = 1;
    friendlySafeZoneExitMessageSeconds = 5;
    corpseCleanupDelaySeconds = 300;

    // Server validation bounds for native S.O.G. revive attribution.
    reviveRewardDistanceMeters = 4;
    reviveRewardCompletionWindowSeconds = 2;

    // Call For Help presentation. The 3D marker is never rendered beyond this range.
    casualtyHelp3DMaxDistance = 50;
};

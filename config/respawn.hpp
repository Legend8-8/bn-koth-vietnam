class CfgBnKothRespawn
{
    // Local EHs handle the critical fire/damage/blocking checks, so the server can use
    // a slower authoritative tick without losing safety or gameplay correctness.
    safeZoneCheckIntervalSeconds = 5.0;
    blockedActionMessageCooldownSeconds = 1;
    friendlySafeZoneExitMessageSeconds = 5;
    corpseCleanupDelaySeconds = 300;
};

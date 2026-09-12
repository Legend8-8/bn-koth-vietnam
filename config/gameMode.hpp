class Header
{
    gameType = "KOTH";
    minPlayers = 1;
    maxPlayers = 100;
};
author = "Bro-Nation";
onLoadName = "Bro-Nation KOTH Vietnam";
overviewText = "King of the Hill";
onLoadMission = "Server-authoritative persistent KOTH for S.O.G. Prairie Fire.";
loadScreen = "";

respawn = 3;
respawnDelay = 5;
respawnOnStart = -1;
disabledAI = 1;
// Player representation is owned by the BN KOTH team handoff system.
enableTeamSwitch = 0;

class CfgBnKothDebug
{
    // Debug presentation remains disabled for normal players by default.
    enabled = 0;
};

class CfgBnKothDeploymentTransition
{
    meltdownChance = 0.01;
};

class CfgBnKothInteractions
{
    // Shared authoritative tolerance for all active team-mapboard services.
    teamMapboardAccessDistance = 8;
};

class CfgBnKothGroups
{
    inviteExpirySeconds = 60;
    maxDisplayNameLength = 24;
};

class Header
{
    gameType = "KOTH";
    minPlayers = 1;
    maxPlayers = 100;
};
author = "Bro-Nation";
onLoadName = "Vietnam KOTH Test";
overviewText = "King of the Hill";
onLoadMission = "Server-authoritative KOTH prototype for S.O.G. Prairie Fire.";
loadScreen = "";

respawn = 3;
respawnDelay = 5;
respawnOnStart = -1;
disabledAI = 1;
// Player representation is owned by the BN KOTH team handoff system.
enableTeamSwitch = 0;

class CfgBnKothDebug
{
    // Development default for the current prototype cycle.
    enabled = 0;
};

class CfgBnKothDeploymentTransition
{
    meltdownChance = 0.01;
};

class CfgBnKothGroups
{
    inviteExpirySeconds = 60;
    maxDisplayNameLength = 24;
};

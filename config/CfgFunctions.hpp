class CfgFunctions
{
    class bn_koth
    {
        tag = "bn_koth";

        class common
        {
            file = "functions/common";
            class log {};
            class publicState {};
        };

        class round
        {
            file = "functions/round";
            class initServer {};
            class setState {};
            class getState {};
            class resetRound {};
        };

        class teams
        {
            file = "functions/teams";
            class validateSide {};
        };

        class zone
        {
            file = "functions/zone";
            class initServer {};
            class setActiveLocation {};
            class evaluateControl {};
        };

        class scoring
        {
            file = "functions/scoring";
            class initServer {};
            class awardControlTick {};
        };

        class respawn
        {
            file = "functions/respawn";
            class initPlayerServer {};
        };

        class loadouts
        {
            file = "functions/loadouts";
            class request {};
        };

        class vehicles
        {
            file = "functions/vehicles";
            class requestSpawn {};
        };

        class progression
        {
            file = "functions/progression";
            class addXp {};
        };

        class persistence
        {
            file = "functions/persistence";
            class savePlayer {};
        };

        class ui
        {
            file = "functions/ui";
            class initPlayerLocal {};
            class requestState {};
            class sendStateToClient {};
            class receiveState {};
        };
    };
};

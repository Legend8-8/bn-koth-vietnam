class CfgFunctions
{
    class bn_koth
    {
        tag = "bn_koth";

        class common
        {
            class common_log {file = "functions\common\fn_log.sqf";};
            class common_publicState {file = "functions\common\fn_publicState.sqf";};
        };

        class round
        {
            class round_initServer {file = "functions\round\fn_initServer.sqf";};
            class round_setState {file = "functions\round\fn_setState.sqf";};
            class round_getState {file = "functions\round\fn_getState.sqf";};
            class round_endWithWinner {file = "functions\round\fn_endWithWinner.sqf";};
            class round_resetRound {file = "functions\round\fn_resetRound.sqf";};
        };

        class teams
        {
            class teams_validateSide {file = "functions\teams\fn_validateSide.sqf";};
        };

        class zone
        {
            class zone_initServer {file = "functions\zone\fn_initServer.sqf";};
            class zone_setActiveLocation {file = "functions\zone\fn_setActiveLocation.sqf";};
            class zone_evaluateControl {file = "functions\zone\fn_evaluateControl.sqf";};
        };

        class scoring
        {
            class scoring_initServer {file = "functions\scoring\fn_initServer.sqf";};
            class scoring_awardControlTick {file = "functions\scoring\fn_awardControlTick.sqf";};
        };

        class respawn
        {
            class respawn_initPlayerServer {file = "functions\respawn\fn_initPlayerServer.sqf";};
        };

        class ui
        {
            class ui_initPlayerLocal {file = "functions\ui\fn_initPlayerLocal.sqf";};
            class ui_requestState {file = "functions\ui\fn_requestState.sqf";};
            class ui_sendStateToClient {file = "functions\ui\fn_sendStateToClient.sqf";};
            class ui_receiveState {file = "functions\ui\fn_receiveState.sqf";};
            class ui_toggleDebugDisplay {file = "functions\ui\fn_toggleDebugDisplay.sqf";};
            class ui_debugDisplayLoop {file = "functions\ui\fn_debugDisplayLoop.sqf";};
        };
    };
};

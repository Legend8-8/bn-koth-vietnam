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
            class round_openVote {file = "functions\round\fn_openVote.sqf";};
            class round_maybeShortenVoteDeadline {file = "functions\round\fn_maybeShortenVoteDeadline.sqf";};
            class round_prepareVoteCandidates {file = "functions\round\fn_prepareVoteCandidates.sqf";};
            class round_requestVote {file = "functions\round\fn_requestVote.sqf";};
            class round_resolveVote {file = "functions\round\fn_resolveVote.sqf";};
            class round_selectVoteCandidates {file = "functions\round\fn_selectVoteCandidates.sqf";};
            class round_updateVoteTotals {file = "functions\round\fn_updateVoteTotals.sqf";};
            class round_isLocationValid {file = "functions\round\fn_isLocationValid.sqf";};
        };

        class teams
        {
            class teams_validateSide {file = "functions\teams\fn_validateSide.sqf";};
            class teams_initServer {file = "functions\teams\fn_initServer.sqf";};
            class teams_registerPlayer {file = "functions\teams\fn_registerPlayer.sqf";};
            class teams_removePlayer {file = "functions\teams\fn_removePlayer.sqf";};
            class teams_requestSelection {file = "functions\teams\fn_requestSelection.sqf";};
            class teams_returnSelectedPlayerToLobby {file = "functions\teams\fn_returnSelectedPlayerToLobby.sqf";};
            class teams_publishState {file = "functions\teams\fn_publishState.sqf";};
            class teams_getEligibleSelectedUids {file = "functions\teams\fn_getEligibleSelectedUids.sqf";};
            class teams_getPlayerByOwner {file = "functions\teams\fn_getPlayerByOwner.sqf";};
            class teams_getDefaultUnitClass {file = "functions\teams\fn_getDefaultUnitClass.sqf";};
            class teams_transferRepresentation {file = "functions\teams\fn_transferRepresentation.sqf";};
            class teams_assignLobbyRepresentation {file = "functions\teams\fn_assignLobbyRepresentation.sqf";};
            class teams_deployRoundParticipants {file = "functions\teams\fn_deployRoundParticipants.sqf";};
            class teams_deploySelectedPlayer {file = "functions\teams\fn_deploySelectedPlayer.sqf";};
            class teams_returnAllToLobby {file = "functions\teams\fn_returnAllToLobby.sqf";};
            class teams_notifyPlayer {file = "functions\teams\fn_notifyPlayer.sqf";};
        };

        class zone
        {
            class zone_initServer {file = "functions\zone\fn_initServer.sqf";};
            class zone_setActiveLocation {file = "functions\zone\fn_setActiveLocation.sqf";};
            class zone_clearActiveLocation {file = "functions\zone\fn_clearActiveLocation.sqf";};
            class zone_cacheStaticObjects {file = "functions\zone\fn_cacheStaticObjects.sqf";};
            class zone_evaluateControl {file = "functions\zone\fn_evaluateControl.sqf";};
        };

        class scoring
        {
            class scoring_initServer {file = "functions\scoring\fn_initServer.sqf";};
            class scoring_resetProgress {file = "functions\scoring\fn_resetProgress.sqf";};
            class scoring_awardControlTick {file = "functions\scoring\fn_awardControlTick.sqf";};
        };

        class respawn
        {
            class respawn_initServer {file = "functions\respawn\fn_initServer.sqf";};
            class respawn_initPlayerServer {file = "functions\respawn\fn_initPlayerServer.sqf";};
            class respawn_handlePlayerDeath {file = "functions\respawn\fn_handlePlayerDeath.sqf";};
            class respawn_handlePlayerRespawn {file = "functions\respawn\fn_handlePlayerRespawn.sqf";};
        };

        class ui
        {
            class ui_initPlayerLocal {file = "functions\ui\fn_initPlayerLocal.sqf";};
            class ui_evaluateStateReadiness {file = "functions\ui\fn_evaluateStateReadiness.sqf";};
            class ui_updateHudLifecycle {file = "functions\ui\fn_updateHudLifecycle.sqf";};
            class ui_refreshHud {file = "functions\ui\fn_refreshHud.sqf";};
            class ui_updateLobbyBlackout {file = "functions\ui\fn_updateLobbyBlackout.sqf";};
            class ui_updateLobbyRepresentationContainment {file = "functions\ui\fn_updateLobbyRepresentationContainment.sqf";};
            class ui_handleLobbyKeyDown {file = "functions\ui\fn_handleLobbyKeyDown.sqf";};
            class ui_openLobby {file = "functions\ui\fn_openLobby.sqf";};
            class ui_closeLobby {file = "functions\ui\fn_closeLobby.sqf";};
            class ui_refreshLobby {file = "functions\ui\fn_refreshLobby.sqf";};
            class ui_refreshLobbyHeader {file = "functions\ui\fn_refreshLobbyHeader.sqf";};
            class ui_refreshLobbyTeams {file = "functions\ui\fn_refreshLobbyTeams.sqf";};
            class ui_refreshLobbyCenter {file = "functions\ui\fn_refreshLobbyCenter.sqf";};
            class ui_refreshLobbyVote {file = "functions\ui\fn_refreshLobbyVote.sqf";};
            class ui_updateLobbyLifecycle {file = "functions\ui\fn_updateLobbyLifecycle.sqf";};
            class ui_requestState {file = "functions\ui\fn_requestState.sqf";};
            class ui_sendStateToClient {file = "functions\ui\fn_sendStateToClient.sqf";};
            class ui_receiveState {file = "functions\ui\fn_receiveState.sqf";};
            class ui_toggleDebugDisplay {file = "functions\ui\fn_toggleDebugDisplay.sqf";};
            class ui_debugDisplayLoop {file = "functions\ui\fn_debugDisplayLoop.sqf";};
            class ui_selectControlledUnit {file = "functions\ui\fn_selectControlledUnit.sqf";};
            class ui_notify {file = "functions\ui\fn_notify.sqf";};
        };
    };
};

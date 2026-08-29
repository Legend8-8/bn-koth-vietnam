class CfgFunctions
{
    class bn_koth
    {
        tag = "bn_koth";

        class common
        {
            class common_log {file = "functions\common\fn_log.sqf";};
            class common_publicState {file = "functions\common\fn_publicState.sqf";};
            class common_resolvePlayerUid {file = "functions\common\fn_resolvePlayerUid.sqf";};
        };

        class combat
        {
            class combat_evaluateWeaponAttribution {file = "functions\combat\fn_evaluateWeaponAttribution.sqf";};
            class combat_evaluateKillAttributionEvidence {file = "functions\combat\fn_evaluateKillAttributionEvidence.sqf";};
            class combat_finalizeAttributionDiagnostic {file = "functions\combat\fn_finalizeAttributionDiagnostic.sqf";};
            class combat_handleKill {file = "functions\combat\fn_handleKill.sqf";};
            class combat_initAttributionDiagnostics {file = "functions\combat\fn_initAttributionDiagnostics.sqf";};
            class combat_publishKillFeed {file = "functions\combat\fn_publishKillFeed.sqf";};
            class combat_recordAttributionHit {file = "functions\combat\fn_recordAttributionHit.sqf";};
        };

        class curator
        {
            class curator_init {file = "functions\curator\fn_curator_init.sqf";};
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

        class roundStats
        {
            class roundStats_initServer {file = "functions\roundStats\fn_initServer.sqf";};
            class roundStats_reset {file = "functions\roundStats\fn_reset.sqf";};
            class roundStats_updateLeader {file = "functions\roundStats\fn_updateLeader.sqf";};
            class roundStats_recordKill {file = "functions\roundStats\fn_recordKill.sqf";};
            class roundStats_recordObjectiveTick {file = "functions\roundStats\fn_recordObjectiveTick.sqf";};
        };

        class teams
        {
            class teams_validateSide {file = "functions\teams\fn_validateSide.sqf";};
            class teams_initServer {file = "functions\teams\fn_initServer.sqf";};
            class teams_registerPlayer {file = "functions\teams\fn_registerPlayer.sqf";};
            class teams_removePlayer {file = "functions\teams\fn_removePlayer.sqf";};
            class teams_requestSelection {file = "functions\teams\fn_requestSelection.sqf";};
            class teams_returnSelectedPlayerToLobby {file = "functions\teams\fn_returnSelectedPlayerToLobby.sqf";};
            class teams_returnDeployedPlayerToLobby {file = "functions\teams\fn_returnDeployedPlayerToLobby.sqf";};
            class teams_requestReturnToLobby {file = "functions\teams\fn_requestReturnToLobby.sqf";};
            class teams_publishState {file = "functions\teams\fn_publishState.sqf";};
            class teams_getEligibleSelectedUids {file = "functions\teams\fn_getEligibleSelectedUids.sqf";};
            class teams_getPlayerByOwner {file = "functions\teams\fn_getPlayerByOwner.sqf";};
            class teams_getDefaultUnitClass {file = "functions\teams\fn_getDefaultUnitClass.sqf";};
            class teams_transferRepresentation {file = "functions\teams\fn_transferRepresentation.sqf";};
            class teams_receiveTransferHandoffAck {file = "functions\teams\fn_receiveTransferHandoffAck.sqf";};
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
            class zone_cleanupRuntimeObjects {file = "functions\zone\fn_cleanupRuntimeObjects.sqf";};
            class zone_cleanupBattlefieldPickups {file = "functions\zone\fn_cleanupBattlefieldPickups.sqf";};
            class zone_spawnBattlefieldPickups {file = "functions\zone\fn_spawnBattlefieldPickups.sqf";};
            class zone_evaluateControl {file = "functions\zone\fn_evaluateControl.sqf";};
            class zone_updatePriorityZone {file = "functions\zone\fn_updatePriorityZone.sqf";};
        };

        class scoring
        {
            class scoring_initServer {file = "functions\scoring\fn_initServer.sqf";};
            class scoring_resetProgress {file = "functions\scoring\fn_resetProgress.sqf";};
            class scoring_awardControlTick {file = "functions\scoring\fn_awardControlTick.sqf";};
        };

        class progression
        {
            class progression_xp_initServer {file = "functions\progression\xp\fn_initServer.sqf";};
            class progression_xp_getXpThresholdForLevel {file = "functions\progression\xp\fn_getXpThresholdForLevel.sqf";};
            class progression_xp_getLevel {file = "functions\progression\xp\fn_getLevel.sqf";};
            class progression_xp_getLevelProgress {file = "functions\progression\xp\fn_getLevelProgress.sqf";};
            class progression_xp_addXp {file = "functions\progression\xp\fn_addXp.sqf";};
            class progression_xp_awardControlTick {file = "functions\progression\xp\fn_awardControlTick.sqf";};
            class progression_xp_awardKill {file = "functions\progression\xp\fn_awardKill.sqf";};
            class progression_mastery_initPlayer {file = "functions\progression\mastery\fn_initPlayer.sqf";};
            class progression_mastery_awardKill {file = "functions\progression\mastery\fn_awardKill.sqf";};
            class progression_cash_initServer {file = "functions\progression\cash\fn_initServer.sqf";};
            class progression_cash_initPlayer {file = "functions\progression\cash\fn_initPlayer.sqf";};
            class progression_cash_getCash {file = "functions\progression\cash\fn_getCash.sqf";};
            class progression_cash_addCash {file = "functions\progression\cash\fn_addCash.sqf";};
            class progression_cash_spendCash {file = "functions\progression\cash\fn_spendCash.sqf";};
            class progression_acquisition_initPlayer {file = "functions\progression\acquisition\fn_initPlayer.sqf";};
            class progression_acquisition_evaluateRules {file = "functions\progression\acquisition\fn_evaluateRules.sqf";};
            class progression_acquisition_acquireWeapon {file = "functions\progression\acquisition\fn_acquireWeapon.sqf";};
            class progression_purchaseWeapon {file = "functions\progression\acquisition\fn_purchaseWeapon.sqf";};
            class progression_rentWeapon {file = "functions\progression\acquisition\fn_rentWeapon.sqf";};
            class progression_requestWeaponAcquisition {file = "functions\progression\acquisition\fn_requestWeapon.sqf";};
            class progression_publishUpdate {file = "functions\progression\fn_publishUpdate.sqf";};
            class progression_buildPresentationState {file = "functions\progression\fn_buildPresentationState.sqf";};
            class progression_resolveRankPresentation {file = "functions\progression\fn_resolveRankPresentation.sqf";};
            class progression_evaluateEquipmentSidePolicyRules {file = "functions\progression\fn_evaluateEquipmentSidePolicyRules.sqf";};
            class progression_evaluateWeaponEntitlement {file = "functions\progression\fn_evaluateWeaponEntitlement.sqf";};
            class progression_evaluateWeaponEntitlementRules {file = "functions\progression\fn_evaluateWeaponEntitlementRules.sqf";};
            class progression_evaluateAttachmentEntitlement {file = "functions\progression\fn_evaluateAttachmentEntitlement.sqf";};
            class progression_evaluateItemEntitlement {file = "functions\progression\fn_evaluateItemEntitlement.sqf";};
            class progression_evaluateItemEntitlementRules {file = "functions\progression\fn_evaluateItemEntitlementRules.sqf";};
            class progression_perks_getConfig {file = "functions\progression\perks\fn_getConfig.sqf";};
            class progression_perks_purchase {file = "functions\progression\perks\fn_purchase.sqf";};
            class progression_perks_setActive {file = "functions\progression\perks\fn_setActive.sqf";};
            class progression_perks_completeCleanup {file = "functions\progression\perks\fn_completeCleanup.sqf";};
            class progression_perks_ackCleanup {file = "functions\progression\perks\fn_ackCleanup.sqf";};
            class progression_perks_request {file = "functions\progression\perks\fn_request.sqf";};
            class progression_perks_isSuppressor {file = "functions\progression\perks\fn_isSuppressor.sqf";};
            class progression_perks_findRestrictedItems {file = "functions\progression\perks\fn_findRestrictedItems.sqf";};
            class progression_perks_findSuppressors {file = "functions\progression\perks\fn_findSuppressors.sqf";};
            class progression_perks_removeSuppressors {file = "functions\progression\perks\fn_removeSuppressors.sqf";};
            class progression_perks_test_perks {file = "functions\progression\perks\test_perks.sqf";};
        };

        class persistence
        {
            class persistence_initServer {file = "functions\persistence\fn_initServer.sqf";};
            class persistence_createDefaultState {file = "functions\persistence\fn_createDefaultState.sqf";};
            class persistence_normalizePlayerState {file = "functions\persistence\fn_normalizePlayerState.sqf";};
            class persistence_projectPlayerState {file = "functions\persistence\fn_projectPlayerState.sqf";};
            class persistence_serializeOwnedWeapons {file = "functions\persistence\fn_serializeOwnedWeapons.sqf";};
            class persistence_deserializeOwnedWeapons {file = "functions\persistence\fn_deserializeOwnedWeapons.sqf";};
            class persistence_serializePerkIds {file = "functions\persistence\fn_serializePerkIds.sqf";};
            class persistence_deserializePerkIds {file = "functions\persistence\fn_deserializePerkIds.sqf";};
            class persistence_serializeWeaponKills {file = "functions\persistence\fn_serializeWeaponKills.sqf";};
            class persistence_deserializeWeaponKills {file = "functions\persistence\fn_deserializeWeaponKills.sqf";};
            class persistence_parseExtdbResponse {file = "functions\persistence\fn_parseExtdbResponse.sqf";};
            class persistence_extdbCall {file = "functions\persistence\fn_extdbCall.sqf";};
            class persistence_extdbInitialize {file = "functions\persistence\fn_extdbInitialize.sqf";};
            class persistence_backendLoadPlayer {file = "functions\persistence\fn_backendLoadPlayer.sqf";};
            class persistence_backendSavePlayer {file = "functions\persistence\fn_backendSavePlayer.sqf";};
            class persistence_loadPlayer {file = "functions\persistence\fn_loadPlayer.sqf";};
            class persistence_markDirty {file = "functions\persistence\fn_markDirty.sqf";};
            class persistence_savePlayer {file = "functions\persistence\fn_savePlayer.sqf";};
            class persistence_saveAllDirty {file = "functions\persistence\fn_saveAllDirty.sqf";};
        };

        class respawn
        {
            class respawn_initServer {file = "functions\respawn\fn_initServer.sqf";};
            class respawn_initPlayerServer {file = "functions\respawn\fn_initPlayerServer.sqf";};
            class respawn_initPlayerLocal {file = "functions\respawn\fn_initPlayerLocal.sqf";};
            class respawn_getSafeZoneMembership {file = "functions\respawn\fn_getSafeZoneMembership.sqf";};
            class respawn_cleanupDeadBody {file = "functions\respawn\fn_cleanupDeadBody.sqf";};
            class respawn_cleanupSafeZoneEntity {file = "functions\respawn\fn_cleanupSafeZoneEntity.sqf";};
            class respawn_sweepSafeZoneGroundItems {file = "functions\respawn\fn_sweepSafeZoneGroundItems.sqf";};
            class respawn_monitorSafeZones {file = "functions\respawn\fn_monitorSafeZones.sqf";};
            class respawn_updatePlayerProtection {file = "functions\respawn\fn_updatePlayerProtection.sqf";};
            class respawn_handleDamage {file = "functions\respawn\fn_handleDamage.sqf";};
            class respawn_handleFired {file = "functions\respawn\fn_handleFired.sqf";};
            class respawn_forceExitVehicle {file = "functions\respawn\fn_forceExitVehicle.sqf";};
            class respawn_applyVehicleProtection {file = "functions\respawn\fn_applyVehicleProtection.sqf";};
            class respawn_handlePlayerDeath {file = "functions\respawn\fn_handlePlayerDeath.sqf";};
            class respawn_handlePlayerRespawn {file = "functions\respawn\fn_handlePlayerRespawn.sqf";};
        };

        class traversal
        {
            class traversal_initPlayerLocal {file = "functions\traversal\fn_initPlayerLocal.sqf";};
            class traversal_canTraverse {file = "functions\traversal\fn_canTraverse.sqf";};
            class traversal_request {file = "functions\traversal\fn_request.sqf";};
            class traversal_classify {file = "functions\traversal\fn_classify.sqf";};
            class traversal_probe {file = "functions\traversal\fn_probe.sqf";};
            class traversal_selectAnimation {file = "functions\traversal\fn_selectAnimation.sqf";};
            class traversal_execute {file = "functions\traversal\fn_execute.sqf";};
            class traversal_finish {file = "functions\traversal\fn_finish.sqf";};
            class traversal_cancel {file = "functions\traversal\fn_cancel.sqf";};
            class traversal_debugDraw {file = "functions\traversal\fn_debugDraw.sqf";};
            class traversal_log {file = "functions\traversal\fn_log.sqf";};
        };

        class loadouts
        {
            class loadouts_initServer {file = "functions\loadouts\fn_initServer.sqf";};
            class loadouts_initPlayerLocal {file = "functions\loadouts\fn_initPlayerLocal.sqf";};
            class loadouts_isInventoryLocked {file = "functions\loadouts\fn_isInventoryLocked.sqf";};
            class loadouts_forceCloseInventory {file = "functions\loadouts\fn_forceCloseInventory.sqf";};
            class loadouts_clearPlayerState {file = "functions\loadouts\fn_clearPlayerState.sqf";};
            class loadouts_getStarterLoadout {file = "functions\loadouts\fn_getStarterLoadout.sqf";};
            class loadouts_getWeaponMetadata {file = "functions\loadouts\fn_getWeaponMetadata.sqf";};
            class loadouts_getItemMetadata {file = "functions\loadouts\fn_getItemMetadata.sqf";};
            class loadouts_validateLoadout {file = "functions\loadouts\fn_validateLoadout.sqf";};
            class loadouts_validateMutation {file = "functions\loadouts\fn_validateMutation.sqf";};
            class loadouts_validateWeaponComposition {file = "functions\loadouts\fn_validateWeaponComposition.sqf";};
            class loadouts_validateAssignedItemSlot {file = "functions\loadouts\fn_validateAssignedItemSlot.sqf";};
            class loadouts_buildWeaponSlot {file = "functions\loadouts\fn_buildWeaponSlot.sqf";};
            class loadouts_buildValidatedLoadout {file = "functions\loadouts\fn_buildValidatedLoadout.sqf";};
            class loadouts_applyLoadout {file = "functions\loadouts\fn_applyLoadout.sqf";};
            class loadouts_request {file = "functions\loadouts\fn_request.sqf";};
            class loadouts_receiveValidatedLoadout {file = "functions\loadouts\fn_receiveValidatedLoadout.sqf";};
        };

        class playerMapMarkers
        {
            class playerMapMarkers_initPlayerLocal {file = "functions\playerIcons\playerMapMarkers\fn_initPlayerLocal.sqf";};
            class playerMapMarkers_initMicOverlay {file = "functions\playerIcons\playerMapMarkers\fn_initMicOverlay.sqf";};
            class playerMapMarkers_refresh {file = "functions\playerIcons\playerMapMarkers\fn_refresh.sqf";};
            class playerMapMarkers_setVoiceState {file = "functions\playerIcons\playerMapMarkers\fn_setVoiceState.sqf";};
        };

        class player3DIcons
        {
            class player3DIcons_initPlayerLocal {file = "functions\playerIcons\player3DIcons\fn_initPlayerLocal.sqf";};
            class player3DIcons_refresh {file = "functions\playerIcons\player3DIcons\fn_refresh.sqf";};
            class player3DIcons_draw {file = "functions\playerIcons\player3DIcons\fn_draw.sqf";};
        };

        class vehicles
        {
            class vehicles_addVehicleInventory {file = "functions\vehicles\fn_addVehicleInventory.sqf";};
            class vehicles_initServer {file = "functions\vehicles\fn_initServer.sqf";};
            class vehicles_buildActiveLocationSlots {file = "functions\vehicles\fn_buildActiveLocationSlots.sqf";};
            class vehicles_clearVehicleInventory {file = "functions\vehicles\fn_clearVehicleInventory.sqf";};
            class vehicles_isSpawnAreaClear {file = "functions\vehicles\fn_isSpawnAreaClear.sqf";};
            class vehicles_spawnManagedSlot {file = "functions\vehicles\fn_spawnManagedSlot.sqf";};
            class vehicles_cleanupManagedWrecks {file = "functions\vehicles\fn_cleanupManagedWrecks.sqf";};
            class vehicles_cleanupManagedVehicles {file = "functions\vehicles\fn_cleanupManagedVehicles.sqf";};
            class vehicles_monitorManagedVehicles {file = "functions\vehicles\fn_monitorManagedVehicles.sqf";};
            class vehicles_requestSpawn {file = "functions\vehicles\fn_requestSpawn.sqf";};
            class vehicles_getProgressionMetadata {file = "functions\vehicles\fn_getProgressionMetadata.sqf";};
            class vehicles_evaluateProgressionRules {file = "functions\vehicles\fn_evaluateProgressionRules.sqf";};
            class vehicles_getRentalState {file = "functions\vehicles\fn_getRentalState.sqf";};
            class vehicles_requestRental {file = "functions\vehicles\fn_requestRental.sqf";};
            class vehicles_rentVehicle {file = "functions\vehicles\fn_rentVehicle.sqf";};
            class vehicles_setRentalAccess {file = "functions\vehicles\fn_setRentalAccess.sqf";};
            class vehicles_endRentalLife {file = "functions\vehicles\fn_endRentalLife.sqf";};
            class vehicles_receiveRentalResult {file = "functions\vehicles\fn_receiveRentalResult.sqf";};
            class vehicles_forceOutRentalVehicle {file = "functions\vehicles\fn_forceOutRentalVehicle.sqf";};
            class vehicles_addRentalOwnerActions {file = "functions\vehicles\fn_addRentalOwnerActions.sqf";};
            class vehicles_mobileRespawn_init {file = "functions\vehicles\mobile_respawn\fn_init.sqf";};
            class vehicles_mobileRespawn_monitor {file = "functions\vehicles\mobile_respawn\fn_serverRespawnLoop.sqf";};
            class vehicles_mobileRespawn_initTeleport {file = "functions\vehicles\mobile_respawn\fn_initTeleport.sqf";};
            class vehicles_mobileRespawn_getVehicleForSide {file = "functions\vehicles\mobile_respawn\fn_getVehicleForSide.sqf";};
            class vehicles_mobileRespawn_isTentDeployed {file = "functions\vehicles\mobile_respawn\fn_isTentDeployed.sqf";};
            class vehicles_mobileRespawn_requestTeleport {file = "functions\vehicles\mobile_respawn\fn_requestTeleport.sqf";};
            class vehicles_mobileRespawn_executeTeleport {file = "functions\vehicles\mobile_respawn\fn_executeTeleport.sqf";};
        };

        class ui
        {
            class ui_initPlayerLocal {file = "functions\ui\fn_initPlayerLocal.sqf";};
            class ui_evaluateStateReadiness {file = "functions\ui\state\fn_evaluateStateReadiness.sqf";};
            class ui_updateHudLifecycle {file = "functions\ui\hud\fn_updateHudLifecycle.sqf";};
            class ui_refreshHud {file = "functions\ui\hud\fn_refreshHud.sqf";};
            class ui_updatePriorityTask {file = "functions\ui\hud\fn_updatePriorityTask.sqf";};
            class ui_updateLobbyBlackout {file = "functions\ui\lobby\fn_updateLobbyBlackout.sqf";};
            class ui_updateLobbyRepresentationContainment {file = "functions\ui\lobby\fn_updateLobbyRepresentationContainment.sqf";};
            class ui_handleLobbyKeyDown {file = "functions\ui\lobby\fn_handleLobbyKeyDown.sqf";};
            class ui_openLobby {file = "functions\ui\lobby\fn_openLobby.sqf";};
            class ui_closeLobby {file = "functions\ui\lobby\fn_closeLobby.sqf";};
            class ui_refreshLobby {file = "functions\ui\lobby\fn_refreshLobby.sqf";};
            class ui_refreshLobbyHeader {file = "functions\ui\lobby\fn_refreshLobbyHeader.sqf";};
            class ui_refreshLobbyTeams {file = "functions\ui\lobby\fn_refreshLobbyTeams.sqf";};
            class ui_fitLobbyName {file = "functions\ui\lobby\fn_fitLobbyName.sqf";};
            class ui_refreshLobbyCenter {file = "functions\ui\lobby\fn_refreshLobbyCenter.sqf";};
            class ui_refreshLobbyVote {file = "functions\ui\lobby\fn_refreshLobbyVote.sqf";};
            class ui_refreshLobbyLeaders {file = "functions\ui\lobby\fn_refreshLobbyLeaders.sqf";};
            class ui_updateLobbyLifecycle {file = "functions\ui\lobby\fn_updateLobbyLifecycle.sqf";};
            class ui_requestState {file = "functions\ui\state\fn_requestState.sqf";};
            class ui_sendStateToClient {file = "functions\ui\state\fn_sendStateToClient.sqf";};
            class ui_receiveState {file = "functions\ui\state\fn_receiveState.sqf";};
            class ui_receiveProgression {file = "functions\ui\state\fn_receiveProgression.sqf";};
            class ui_receiveWeaponAcquisitionResult {file = "functions\ui\state\fn_receiveWeaponAcquisitionResult.sqf";};
            class ui_receivePerkResult {file = "functions\ui\state\fn_receivePerkResult.sqf";};
            class ui_formatCash {file = "functions\ui\state\fn_formatCash.sqf";};
            class ui_toggleDebugDisplay {file = "functions\ui\debug\fn_toggleDebugDisplay.sqf";};
            class ui_debugDisplayLoop {file = "functions\ui\debug\fn_debugDisplayLoop.sqf";};
            class ui_selectControlledUnit {file = "functions\ui\state\fn_selectControlledUnit.sqf";};
            class ui_notify {file = "functions\ui\fn_notify.sqf";};
            class ui_addKillFeedEntry {file = "functions\ui\fn_addKillFeedEntry.sqf";};
            class escMenu_initPlayerLocal {file = "functions\ui\esc_menu\fn_initPlayerLocal.sqf";};
            class escMenu_installPauseButtons {file = "functions\ui\esc_menu\fn_installPauseButtons.sqf";};
            class escMenu_openKeybindings {file = "functions\ui\esc_menu\fn_openKeybindings.sqf";};
            class escMenu_openOptions {file = "functions\ui\esc_menu\fn_openOptions.sqf";};
            class escMenu_keybinds_getBind {file = "functions\ui\esc_menu\fn_keybinds_getBind.sqf";};
            class escMenu_keybinds_init {file = "functions\ui\esc_menu\fn_keybinds_init.sqf";};
            class escMenu_keybinds_changeBind {file = "functions\ui\esc_menu\fn_keybinds_changeBind.sqf";};
            class escMenu_keybinds_handleKeyDown {file = "functions\ui\esc_menu\fn_keybinds_handleKeyDown.sqf";};
            class escMenu_keybinds_handleKeyUp {file = "functions\ui\esc_menu\fn_keybinds_handleKeyUp.sqf";};
            class escMenu_keybindings_onLoad {file = "functions\ui\esc_menu\fn_keybindings_onLoad.sqf";};
            class escMenu_keybindings_captureInput {file = "functions\ui\esc_menu\fn_keybindings_captureInput.sqf";};
            class escMenu_keybindings_onUnload {file = "functions\ui\esc_menu\fn_keybindings_onUnload.sqf";};
            class escMenu_keybinds_reset {file = "functions\ui\esc_menu\fn_keybinds_reset.sqf";};
            class escMenu_options_init {file = "functions\ui\esc_menu\fn_options_init.sqf";};
            class escMenu_options_getValue {file = "functions\ui\esc_menu\fn_options_getValue.sqf";};
            class escMenu_options_setValue {file = "functions\ui\esc_menu\fn_options_setValue.sqf";};
            class escMenu_options_onSliderPosChanged {file = "functions\ui\esc_menu\fn_options_onSliderPosChanged.sqf";};
            class escMenu_options_onLoad {file = "functions\ui\esc_menu\fn_options_onLoad.sqf";};
            class escMenu_options_onUnload {file = "functions\ui\esc_menu\fn_options_onUnload.sqf";};
            class escMenu_earplugs_init {file = "functions\ui\esc_menu\earplugs\fn_earplugs_init.sqf";};
            class escMenu_earplugs_apply {file = "functions\ui\esc_menu\earplugs\fn_earplugs_apply.sqf";};
            class escMenu_earplugs_toggle {file = "functions\ui\esc_menu\earplugs\fn_earplugs_toggle.sqf";};
            class escMenu_earplugs_onVehicleChanged {file = "functions\ui\esc_menu\earplugs\fn_earplugs_onVehicleChanged.sqf";};
            class menu_open {file = "functions\ui\menu\fn_menu_open.sqf";};
            class menu_close {file = "functions\ui\menu\fn_menu_close.sqf";};
            class menu_startPlayerPreview {file = "functions\ui\menu\fn_menu_startPlayerPreview.sqf";};
            class menu_stopPlayerPreview {file = "functions\ui\menu\fn_menu_stopPlayerPreview.sqf";};
            class menu_refresh {file = "functions\ui\menu\fn_menu_refresh.sqf";};
            class menu_refreshProgressionHeader {file = "functions\ui\menu\fn_menu_refreshProgressionHeader.sqf";};
            class menu_refreshLoadout {file = "functions\ui\menu\fn_menu_refreshLoadout.sqf";};
            class menu_refreshStore {file = "functions\ui\menu\fn_menu_refreshStore.sqf";};
            class menu_refreshPerks {file = "functions\ui\menu\fn_menu_refreshPerks.sqf";};
            class menu_requestPerk {file = "functions\ui\menu\fn_menu_requestPerk.sqf";};
            class menu_buildStoreWeaponEntries {file = "functions\ui\menu\fn_menu_buildStoreWeaponEntries.sqf";};
            class menu_projectStoreWeaponState {file = "functions\ui\menu\fn_menu_projectStoreWeaponState.sqf";};
            class menu_buildStoreVehicleEntries {file = "functions\ui\menu\fn_menu_buildStoreVehicleEntries.sqf";};
            class menu_projectStoreVehicleState {file = "functions\ui\menu\fn_menu_projectStoreVehicleState.sqf";};
            class menu_layoutItemCards {file = "functions\ui\menu\fn_menu_layoutItemCards.sqf";};
            class menu_refreshBrowser {file = "functions\ui\menu\fn_menu_refreshBrowser.sqf";};
            class menu_refreshConfigure {file = "functions\ui\menu\fn_menu_refreshConfigure.sqf";};
            class menu_refreshConfigureAttachments {file = "functions\ui\menu\fn_menu_refreshConfigureAttachments.sqf";};
            class menu_evaluateWeaponComposition {file = "functions\ui\menu\fn_menu_evaluateWeaponComposition.sqf";};
            class menu_selectConfigureMagazine {file = "functions\ui\menu\fn_menu_selectConfigureMagazine.sqf";};
            class menu_selectConfigureAttachment {file = "functions\ui\menu\fn_menu_selectConfigureAttachment.sqf";};
            class menu_getItemCardControls {file = "functions\ui\menu\fn_menu_getItemCardControls.sqf";};
            class menu_buildBrowserWeaponEntries {file = "functions\ui\menu\fn_menu_buildBrowserWeaponEntries.sqf";};
            class menu_buildBrowserWearableEntries {file = "functions\ui\menu\fn_menu_buildBrowserWearableEntries.sqf";};
            class menu_refreshWearableBrowser {file = "functions\ui\menu\fn_menu_refreshWearableBrowser.sqf";};
            class menu_refreshAssignedBrowser {file = "functions\ui\menu\fn_menu_refreshAssignedBrowser.sqf";};
            class menu_refreshCargoBrowser {file = "functions\ui\menu\fn_menu_refreshCargoBrowser.sqf";};
            class menu_refreshSelector {file = "functions\ui\menu\fn_menu_refreshSelector.sqf";};
            class menu_buildWeaponEntries {file = "functions\ui\menu\fn_menu_buildWeaponEntries.sqf";};
            class menu_buildWearableEntries {file = "functions\ui\menu\fn_menu_buildWearableEntries.sqf";};
            class menu_buildAttachmentEntries {file = "functions\ui\menu\fn_menu_buildAttachmentEntries.sqf";};
            class menu_buildAssignedEntries {file = "functions\ui\menu\fn_menu_buildAssignedEntries.sqf";};
            class menu_buildCargoEntries {file = "functions\ui\menu\fn_menu_buildCargoEntries.sqf";};
            class menu_applyWeaponComposition {file = "functions\ui\menu\fn_menu_applyWeaponComposition.sqf";};
            class menu_applyPrimary {file = "functions\ui\menu\fn_menu_applyPrimary.sqf";};
            class menu_applyHandgun {file = "functions\ui\menu\fn_menu_applyHandgun.sqf";};
            class menu_applyLauncher {file = "functions\ui\menu\fn_menu_applyLauncher.sqf";};
            class menu_applyUniform {file = "functions\ui\menu\fn_menu_applyUniform.sqf";};
            class menu_applyWearable {file = "functions\ui\menu\fn_menu_applyWearable.sqf";};
            class menu_applyVest {file = "functions\ui\menu\fn_menu_applyVest.sqf";};
            class menu_applyBackpack {file = "functions\ui\menu\fn_menu_applyBackpack.sqf";};
            class menu_applyHeadgear {file = "functions\ui\menu\fn_menu_applyHeadgear.sqf";};
            class menu_applyFacewear {file = "functions\ui\menu\fn_menu_applyFacewear.sqf";};
            class menu_applyBinocular {file = "functions\ui\menu\fn_menu_applyBinocular.sqf";};
            class menu_applyAssigned {file = "functions\ui\menu\fn_menu_applyAssigned.sqf";};
            class menu_applyAttachment {file = "functions\ui\menu\fn_menu_applyAttachment.sqf";};
            class menu_applyCargo {file = "functions\ui\menu\fn_menu_applyCargo.sqf";};
            class menu_adjustCargo {file = "functions\ui\menu\fn_menu_adjustCargo.sqf";};
            class menu_saveSessionKit {file = "functions\ui\menu\fn_menu_saveSessionKit.sqf";};
            class menu_loadSessionKit {file = "functions\ui\menu\fn_menu_loadSessionKit.sqf";};
            class menu_deleteSessionKit {file = "functions\ui\menu\fn_menu_deleteSessionKit.sqf";};
            class menu_refreshSessionKits {file = "functions\ui\menu\fn_menu_refreshSessionKits.sqf";};
        };
    };
};

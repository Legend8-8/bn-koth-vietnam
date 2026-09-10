class CfgRemoteExec
{
    class Functions
    {
        mode = 1;
        jip = 1;

        class bn_koth_fnc_ui_requestState
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_teams_requestSelection
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_teams_requestReturnToLobby
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_groups_request
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_groupMenu_receiveState
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_groups_applyNativeLeadership
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_groups_prepareNativeCleanup
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_loadouts_request
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_progression_requestWeaponAcquisition
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_career_requestStats
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_menu_receiveStats
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_progression_perks_request
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_progression_perks_ackCleanup
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_requestRental
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_receiveRentalResult
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_forceOutRentalVehicle
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_addRentalOwnerActions
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_loadouts_receiveValidatedLoadout
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_round_requestVote
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_ui_receiveState
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_receiveProgression
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_receiveWeaponAcquisitionResult
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_receivePerkResult
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_selectControlledUnit
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_teams_receiveTransferHandoffAck
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_ui_notify
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_addKillFeedEntry
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_addRewardFeedEntry
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_magRepack_initPlayerLocal
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_playerMapMarkers_initPlayerLocal
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_player3DIcons_initPlayerLocal
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_enemySpotting_serverValidateAndMark
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_escMenu_initPlayerLocal
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_playerMapMarkers_setVoiceState
        {
            allowedTargets = 0;
            jip = 0;
        };

        class bn_koth_fnc_respawn_forceExitVehicle
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_respawn_applyVehicleProtection
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_respawn_requestCasualtyHelp
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_respawn_receiveCasualtyHelpState
        {
            allowedTargets = 1;
            jip = 0;
        };

        // S.O.G. Advanced Revive installs/removes casualty actions globally and persists them for JIP.
        class VN_fnc_revive_actions_local
        {
            allowedTargets = 0;
            jip = 1;
        };

        // S.O.G. revive conversations play transient local audio on each required machine.
        class VN_fnc_revive_dynamic_audio
        {
            allowedTargets = 1;
            jip = 0;
        };

        // S.O.G. drag/carry cleanup must run where the detached unit is local.
        class VN_fnc_revive_detachunit_local
        {
            allowedTargets = 1;
            jip = 0;
        };

        // S.O.G. owns the global drop-action phases and their detach cleanup.
        class VN_fnc_revive_action_dropplayer
        {
            allowedTargets = 0;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_mobileRespawn_requestTeleport
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_mobileRespawn_executeTeleport
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_airInsertion_request
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_airInsertion_receiveState
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_airInsertion_applyPassengerMove
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_airInsertion_applyBackpack
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_airInsertion_backpackRequest
        {
            allowedTargets = 2;
            jip = 0;
        };
    };

    class Commands
    {
        mode = 1;
        jip = 0;

        // S.O.G. synchronizes transient revive/drag/carry animations with this command.
        // This permits animation execution only; it grants no gameplay-state authority.
        class switchMove
        {
            allowedTargets = 0;
            jip = 0;
        };
    };
};

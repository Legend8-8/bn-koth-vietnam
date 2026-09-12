/*
    File: test_reviveReward.sqf
    Author: Legend
    Description: Focused source contracts for the production revive-reward path.
    Execution: Server test console
    Parameters: None
    Returns: Failure messages; empty means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Revive reward tests must run on the server."]};

private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _configSource = preprocessFileLineNumbers "config\scoring.hpp";
private _respawnConfigSource = preprocessFileLineNumbers "config\respawn.hpp";
private _functionsConfigSource = preprocessFileLineNumbers "config\CfgFunctions.hpp";
private _remoteConfigSource = preprocessFileLineNumbers "config\CfgRemoteExec.hpp";
private _xpInitSource = preprocessFileLineNumbers "functions\progression\xp\fn_initServer.sqf";
private _cashInitSource = preprocessFileLineNumbers "functions\progression\cash\fn_initServer.sqf";
private _cashMutationSource = preprocessFileLineNumbers "functions\progression\cash\fn_addCash.sqf";
private _ordinaryCashCallerSource = preprocessFileLineNumbers "functions\progression\xp\fn_awardKill.sqf"
    + preprocessFileLineNumbers "functions\progression\xp\fn_awardObjectiveTick.sqf"
    + preprocessFileLineNumbers "functions\progression\transport\fn_processZonePlayers.sqf"
    + preprocessFileLineNumbers "functions\roundStats\fn_finalize.sqf";
private _rewardSource = preprocessFileLineNumbers "functions\progression\xp\fn_awardRevive.sqf";
private _endpointSource = preprocessFileLineNumbers "functions\respawn\fn_reportReviveState.sqf";
private _wrapperSource = preprocessFileLineNumbers "functions\respawn\fn_initPlayerLocal.sqf";
private _presentationSource = preprocessFileLineNumbers "functions\respawn\fn_updateDownedPresentation.sqf";
private _respawnInitSource = preprocessFileLineNumbers "functions\respawn\fn_initServer.sqf";
private _cleanupSource = preprocessFileLineNumbers "functions\respawn\fn_clearReviveRewardCycle.sqf"
    + preprocessFileLineNumbers "functions\respawn\fn_handlePlayerDeath.sqf"
    + preprocessFileLineNumbers "functions\respawn\fn_handlePlayerRespawn.sqf"
    + preprocessFileLineNumbers "functions\teams\fn_transferRepresentation.sqf"
    + preprocessFileLineNumbers "functions\teams\fn_removePlayer.sqf"
    + preprocessFileLineNumbers "functions\round\fn_setState.sqf";
private _uiSource = preprocessFileLineNumbers "functions\ui\state\fn_receiveProgression.sqf";

[((_configSource find "xpPerRevive = 25") >= 0) && {(_xpInitSource find "BN_KOTH_xpPerRevive") >= 0}, "Configured revive XP is absent or not initialized by the XP owner"] call _check;
[((_configSource find "cashPerRevive = 25") >= 0) && {(_cashInitSource find "BN_KOTH_cashPerRevive") >= 0}, "Configured revive cash is absent or not initialized by the cash owner"] call _check;
[((_functionsConfigSource find "class respawn_reportReviveState") >= 0) && {(_remoteConfigSource find "class bn_koth_fnc_respawn_reportReviveState") >= 0} && {(_remoteConfigSource find "allowedTargets = 2") >= 0} && {(_remoteConfigSource find "jip = 0") >= 0}, "Casualty report endpoint is absent or not server-only/non-JIP"] call _check;
[((_endpointSource find "params [[""_casualty"", objNull, [objNull]]]") >= 0) && {(_endpointSource find "_phase") < 0}, "RemoteExec schema is not casualty-only"] call _check;
[((_endpointSource find "remoteExecutedOwner") >= 0) && {(_endpointSource find "bn_koth_fnc_teams_getPlayerByOwner") >= 0} && {(_endpointSource find "params [[""_reviverUid""") < 0}, "Reviver is not derived exclusively from the authenticated owner"] call _check;
[((_endpointSource find "BN_KOTH_reviveRewardCycleCounter") >= 0) && {(_endpointSource find "revive:%1:%2:%3") >= 0} && {(_endpointSource find "BN_KOTH_reviveRewardCycleServer") >= 0}, "Recovery-cycle identity is not minted and owned by the server"] call _check;
[((_endpointSource find "getOrDefault [""currentUnit"", objNull]") >= 0) && {(_endpointSource find "owner _sender") >= 0} && {(_endpointSource find "owner _casualty") >= 0}, "Current representation and owner validation is absent"] call _check;
[((_endpointSource find "assignedSide") >= 0) && {(_endpointSource find "bn_koth_fnc_teams_validateSide") >= 0}, "Authoritative same-team WEST/EAST validation is absent"] call _check;
[((_endpointSource find "_sender isEqualTo _casualty") >= 0) && {(_rewardSource find "_casualtyUid isEqualTo _reviverUid") >= 0}, "Self-recovery rejection is absent"] call _check;
[((_endpointSource find "isPlayer _sender") >= 0) && {(_endpointSource find "isPlayer _casualty") >= 0}, "Human-only validation is absent"] call _check;
[((_endpointSource find "getOrDefault [""state"", ""LOBBY""]") >= 0) && {(_endpointSource find "getOrDefault [""deployed"", false]") >= 0} && {(_endpointSource find "bn_koth_fnc_round_getState") >= 0}, "ACTIVE/deployed lifecycle validation is absent"] call _check;
[((count (_endpointSource regexFind ["bn_koth_fnc_respawn_isIncapacitated"])) >= 5), "Prior incapacitation and authoritative recovery are not both validated"] call _check;
[((_respawnConfigSource find "reviveRewardDistanceMeters = 4") >= 0) && {(_respawnConfigSource find "reviveRewardCompletionWindowSeconds = 2") >= 0} && {(_respawnInitSource find "BN_KOTH_reviveRewardDistanceMeters") >= 0} && {(_respawnInitSource find "BN_KOTH_reviveRewardCompletionWindowSeconds") >= 0}, "Revive distance/window bounds are not config-owned"] call _check;
[((_endpointSource find "distance _casualty) > _maximumDistance") >= 0) && {(_endpointSource find "recoveryReportedAt") >= 0} && {(_endpointSource find "_completionDeadline = serverTime + _completionWindow") >= 0} && {(_endpointSource find "uiSleep 0.1") >= 0}, "Strict distance or bounded dual recovery confirmation is absent"] call _check;
[((_endpointSource find "[""status"", ""ACTIVE""]") >= 0) && {(_endpointSource find "set [""status"", ""PENDING""]") >= 0} && {(_endpointSource find "set [""status"", ""CONSUMED""]") >= 0}, "Exactly-once ACTIVE/PENDING/CONSUMED transition is absent"] call _check;
[((_endpointSource find "if (!_cycleMatches) exitWith {false}") >= 0) && {(_rewardSource find "DUPLICATE_RECOVERY") >= 0}, "Replay and duplicate rejection is absent"] call _check;
[((_cleanupSource find "PLAYER_DIED") >= 0) && {(_cleanupSource find "PLAYER_RESPAWNED") >= 0} && {(_cleanupSource find "REPRESENTATION_TRANSFERRED") >= 0} && {(_cleanupSource find "PLAYER_DISCONNECTED") >= 0} && {(_cleanupSource find "ROUND_STATE_") >= 0}, "Death/respawn/handoff/disconnect/round cleanup is incomplete"] call _check;
[((_endpointSource find "RECOVERY_WITHOUT_COMPLETION") >= 0) && {(_endpointSource find "RECOVERY_CONFIRMATION_FAILED") >= 0}, "Recovery without a valid completion candidate is not cleared server-side"] call _check;
[((count (_presentationSource regexFind ["remoteExecCall \[""bn_koth_fnc_respawn_reportReviveState"", 2\]"])) isEqualTo 2) && {(_presentationSource find "BN_KOTH_reviveRewardNextReportAt") < 0} && {(_presentationSource find "diag_tickTime + 1") < 0}, "Revive lifecycle reporting is not transition-only"] call _check;
[((_wrapperSource find "_type isEqualTo 3") >= 0) && {(_wrapperSource find "_nativeActionId in _nativeActionIds") >= 0} && {(count (_wrapperSource regexFind ["_this call _nativeFunction"])) isEqualTo 1} && {(count (_wrapperSource regexFind ["bn_koth_fnc_respawn_reportReviveState"])) isEqualTo 1}, "Native completion observer is not narrowly scoped or does not preserve one original call/one signal"] call _check;
[((count (_wrapperSource regexFind ["BN_KOTH_reviveRewardObserverInstalledLocal"])) isEqualTo 2) && {(_wrapperSource find "BN_KOTH_nativeReviveActionReviveLocal") >= 0}, "Native completion observer is not single-install or does not preserve the original function"] call _check;
[((_wrapperSource find "removeItem") < 0) && {(_wrapperSource find "removeMagazine") < 0} && {(_wrapperSource find "setDamage") < 0} && {(_wrapperSource find "vn_revive_incapacitated") < 0}, "KOTH observer mutates native revive, damage or item state"] call _check;
[((count (_endpointSource regexFind ["bn_koth_fnc_progression_xp_awardRevive"])) isEqualTo 1) && {(_rewardSource find "remoteExecutedOwner") < 0} && {(_rewardSource find "remoteExec") < 0}, "Existing server-internal awardRevive is not the sole reward mutation owner"] call _check;
[((_rewardSource find "[_reviverUid, _xp, ""revive""] call bn_koth_fnc_progression_xp_addXp") >= 0) && {(_rewardSource find "[_reviverUid, _cash, ""revive"", _xp <= 0] call bn_koth_fnc_progression_cash_addCash") >= 0}, "Revive reward does not reuse XP/cash owners with reason revive"] call _check;
[((_cashMutationSource find "[""_publishReward"", true, [true]]") >= 0) && {(_cashMutationSource find "if (_publishReward) then") >= 0}, "Revive reward cannot suppress the duplicate cash feed while preserving cash mutation"] call _check;
[((_ordinaryCashCallerSource find """kill""] call bn_koth_fnc_progression_cash_addCash") >= 0) && {(_ordinaryCashCallerSource find "[_uid, _cash, _reason] call bn_koth_fnc_progression_cash_addCash") >= 0} && {(_ordinaryCashCallerSource find "[_pilotUid, _cash, ""transport""] call bn_koth_fnc_progression_cash_addCash") >= 0} && {(_ordinaryCashCallerSource find """round_participation""] call bn_koth_fnc_progression_cash_addCash") >= 0}, "Existing kill/objective/transport/round cash callers no longer use the backwards-compatible default"] call _check;
[((_uiSource find "case ""revive"": {""REVIVE""};") >= 0), "The existing reward feed does not present revive as REVIVE"] call _check;

diag_log format ["[BN_KOTH_TEST] Revive reward contracts: %1 failure(s): %2", count _failures, _failures];
_failures

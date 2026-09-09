/*
    File: test_reviveReward.sqf
    Author: Legend
    Description: Focused static contracts for dormant revive-reward infrastructure.
        It deliberately does not fabricate a trusted native completion.
    Execution: Server test console
    Parameters: None
    Returns: Failure messages; empty means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Revive reward tests must run on the server."]};

private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _configSource = preprocessFileLineNumbers "config\scoring.hpp";
private _xpInitSource = preprocessFileLineNumbers "functions\progression\xp\fn_initServer.sqf";
private _cashInitSource = preprocessFileLineNumbers "functions\progression\cash\fn_initServer.sqf";
private _rewardSource = preprocessFileLineNumbers "functions\progression\xp\fn_awardRevive.sqf";
private _uiSource = preprocessFileLineNumbers "functions\ui\state\fn_receiveProgression.sqf";
private _integrationSources = preprocessFileLineNumbers "functions\respawn\fn_initServer.sqf"
    + preprocessFileLineNumbers "functions\respawn\fn_initPlayerLocal.sqf"
    + preprocessFileLineNumbers "functions\respawn\fn_updateDownedPresentation.sqf";

[((_configSource find "xpPerRevive = 25") >= 0) && {(_xpInitSource find "BN_KOTH_xpPerRevive") >= 0}, "Configured revive XP is absent or not initialized by the XP owner"] call _check;
[((_configSource find "cashPerRevive = 25") >= 0) && {(_cashInitSource find "BN_KOTH_cashPerRevive") >= 0}, "Configured revive cash is absent or not initialized by the cash owner"] call _check;
[((_rewardSource find "if (!isServer) exitWith") >= 0) && {(_rewardSource find "remoteExecutedOwner") < 0} && {(_rewardSource find "remoteExec") < 0}, "Revive reward authority is not server-internal only"] call _check;
[((_rewardSource find "trustedNativeCompletion") >= 0) && {(_rewardSource find "wasIncapacitated") >= 0} && {(_rewardSource find "nativeRecoveryConfirmed") >= 0}, "Revive reward lacks the pending trusted native recovery contract"] call _check;
[((_rewardSource find "bn_koth_fnc_round_getState") >= 0) && {(_rewardSource find "getOrDefault [""state"", ""LOBBY""]") >= 0} && {(_rewardSource find "getOrDefault [""deployed"", false]") >= 0}, "Revive reward lacks ACTIVE/deployed lifecycle validation"] call _check;
[((_rewardSource find "getOrDefault [""currentUnit"", objNull]") >= 0) && {(_rewardSource find "owner _reviver") >= 0} && {(_rewardSource find "owner _casualty") >= 0}, "Revive reward lacks current representation/owner validation"] call _check;
[((_rewardSource find "isPlayer _casualty") >= 0), "Revive reward does not reject AI casualties"] call _check;
[((_rewardSource find "_casualtyUid isEqualTo _reviverUid") >= 0), "Revive reward does not reject self-revive"] call _check;
[((_rewardSource find "_reviverSide isEqualTo _casualtySide") >= 0), "Revive reward does not reject cross-team recovery"] call _check;
[((count (_rewardSource regexFind ["bn_koth_fnc_respawn_isIncapacitated"])) isEqualTo 2), "Revive reward does not validate current reviver/casualty consciousness"] call _check;
[((_rewardSource find "BN_KOTH_reviveRewardedCycleTokensServer") >= 0) && {(_rewardSource find "DUPLICATE_RECOVERY") >= 0} && {(_rewardSource find "_cycleToken in _rewardedTokens") >= 0}, "Revive reward lacks per-representation recovery-cycle dedupe"] call _check;
[((_rewardSource find "[_reviverUid, _xp, ""revive""] call bn_koth_fnc_progression_xp_addXp") >= 0) && {(_rewardSource find "[_reviverUid, _cash, ""revive""] call bn_koth_fnc_progression_cash_addCash") >= 0}, "Revive reward does not reuse the XP and cash owners"] call _check;
[((_uiSource find "case ""revive"": {""REVIVE""};") >= 0), "The existing reward feed does not present revive as REVIVE"] call _check;
[((_integrationSources find "progression_xp_awardRevive") < 0), "A production S.O.G. completion call was added before trusted attribution exists"] call _check;

diag_log format ["[BN_KOTH_TEST] Revive reward contracts: %1 failure(s): %2", count _failures, _failures];
_failures

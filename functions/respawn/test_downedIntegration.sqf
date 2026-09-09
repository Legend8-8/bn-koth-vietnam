/*
    File: test_downedIntegration.sqf
    Author: Legend
    Description: Focused static contract checks for KOTH downed-state integration.
    Execution: Server after mission function initialization
    Parameters: None
    Returns: Failure messages; empty means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Downed integration tests must run on the server."]};

private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};

private _predicateSource = preprocessFileLineNumbers "functions\respawn\fn_isIncapacitated.sqf";
private _damageSource = preprocessFileLineNumbers "functions\respawn\fn_handleDamage.sqf";
private _respawnConfigSource = preprocessFileLineNumbers "config\respawn.hpp";
private _respawnInitSource = preprocessFileLineNumbers "functions\respawn\fn_initPlayerLocal.sqf";
private _functionsSource = preprocessFileLineNumbers "config\CfgFunctions.hpp";
private _missionSource = preprocessFileLineNumbers "maps\cam_lao_nam\mission.sqm";
private _remoteExecSource = preprocessFileLineNumbers "config\CfgRemoteExec.hpp";
private _zoneSource = preprocessFileLineNumbers "functions\zone\fn_evaluateControl.sqf";
private _requestSource = preprocessFileLineNumbers "functions\respawn\fn_requestCasualtyHelp.sqf";
private _publishSource = preprocessFileLineNumbers "functions\respawn\fn_publishCasualtyHelpState.sqf";
private _reconcileSource = preprocessFileLineNumbers "functions\respawn\fn_reconcileCasualtyHelp.sqf";
private _receiveSource = preprocessFileLineNumbers "functions\respawn\fn_receiveCasualtyHelpState.sqf";
private _presentationSource = preprocessFileLineNumbers "functions\respawn\fn_updateDownedPresentation.sqf";
private _uiInitSource = preprocessFileLineNumbers "functions\ui\fn_initPlayerLocal.sqf";
private _mapSource = preprocessFileLineNumbers "functions\playerIcons\playerMapMarkers\fn_refresh.sqf";
private _mapInitSource = preprocessFileLineNumbers "functions\playerIcons\playerMapMarkers\fn_initPlayerLocal.sqf";
private _mapDrawSource = preprocessFileLineNumbers "functions\playerIcons\playerMapMarkers\fn_initMicOverlay.sqf";
private _iconsSource = preprocessFileLineNumbers "functions\playerIcons\player3DIcons\fn_refresh.sqf";
private _handoffSource = preprocessFileLineNumbers "functions\ui\state\fn_selectControlledUnit.sqf";
private _deathSource = preprocessFileLineNumbers "functions\respawn\fn_handlePlayerDeath.sqf";
private _respawnSource = preprocessFileLineNumbers "functions\respawn\fn_handlePlayerRespawn.sqf";
private _disconnectSource = preprocessFileLineNumbers "functions\teams\fn_removePlayer.sqf";
private _roundSource = preprocessFileLineNumbers "functions\round\fn_setState.sqf";

[!([objNull] call bn_koth_fnc_respawn_isIncapacitated), "objNull is not rejected by the incapacitation predicate"] call _check;
[((_predicateSource find "!alive _unit") >= 0), "Dead-unit rejection is absent from the incapacitation predicate"] call _check;
[((_predicateSource find "lifeState _unit") >= 0) && {(_predicateSource find "INCAPACITATED") >= 0}, "Engine lifeState fallback is absent"] call _check;
[((_predicateSource find "vn_revive_incapacitated") >= 0), "Replicated S.O.G. incapacitation signal is absent"] call _check;
[((_predicateSource find "VN_fnc_revive_incap") < 0), "Unproven S.O.G. function remains in the shared server/client predicate"] call _check;

[((_zoneSource find "bn_koth_fnc_respawn_isIncapacitated") >= 0), "Zone eligibility does not exclude incapacitated units"] call _check;
[((_zoneSource find "alive _x") >= 0), "Zone eligibility no longer explicitly rejects dead units"] call _check;
[((_zoneSource find "BN_KOTH_zoneEligibleSnapshot") >= 0), "Zone eligibility snapshot ownership is absent"] call _check;

[((_requestSource find "remoteExecutedOwner") >= 0), "Call For Help does not derive its remote caller"] call _check;
[((_requestSource find "params") < 0), "Call For Help accepts client-supplied parameters"] call _check;
[((_requestSource find "currentUnit") >= 0) && {(_requestSource find "assignedSide") >= 0} && {(_requestSource find "deployed") >= 0}, "Call For Help lacks authoritative representation/team/deployment validation"] call _check;
[((_requestSource find "bn_koth_fnc_respawn_isIncapacitated") >= 0), "Call For Help lacks authoritative incapacitation validation"] call _check;
[((_receiveSource find "!isRemoteExecuted") >= 0) && {(_receiveSource find "remoteExecutedOwner isNotEqualTo 2") >= 0}, "Client help-state receiver does not reject local/non-server senders"] call _check;
[((_publishSource find "_casualtySide isEqualTo _viewerSide") >= 0), "Server help projection lacks same-team filtering"] call _check;
[((_publishSource find "_viewerCanReceiveOwnRequest") >= 0) && {(_publishSource find "_casualty isEqualTo _viewer") >= 0}, "Approved requester cannot receive their own casualty projection"] call _check;
[((_publishSource find "_viewerCanReceiveIntel") >= 0) && {(_publishSource find "!([_viewer] call bn_koth_fnc_respawn_isIncapacitated)") >= 0}, "Incapacitated non-requesters can receive casualty intel"] call _check;
[((_publishSource find "(_viewerRecord getOrDefault [""state"", ""]) isEqualTo ""ACTIVE""") >= 0) && {(_publishSource find "_viewerRecord getOrDefault [""deployed"", false]") >= 0}, "Help projection lacks ACTIVE/deployed recipient validation"] call _check;
[((_mapSource find "_casualtySide isEqualTo _mySide") >= 0), "Map casualty rendering lacks client-side same-team validation"] call _check;
[((_mapSource find "private _isOwnCasualty = _casualtyUid isEqualTo _myUid && {_casualty isEqualTo player}") >= 0) && {(_mapSource find "if (_viewerIncapacitated) then") >= 0}, "Map/GPS rendering does not restrict an incapacitated viewer to their own approved casualty"] call _check;
[((_mapDrawSource find "findDisplay _mapDisplayId") >= 0) && {(_mapDrawSource find "ctrlAddEventHandler [""Draw""") >= 0}, "Casualty map rendering is not bound to the configured full-map control"] call _check;
[((_mapDrawSource find "RscCustomInfoMiniMap") >= 0) && {(_mapDrawSource find "RscCustomInfoAirborneMiniMap") >= 0} && {(_mapDrawSource find "IGUI_displays") >= 0} && {(_mapDrawSource find "displayCtrl 101") >= 0}, "Casualty map rendering is not bound to all normal NAV/GPS map controls"] call _check;
[((_mapDrawSource find "BN_KOTH_casualtyHelpMapDrawEntries") >= 0), "Full-map and NAV/GPS casualty rendering do not share the validated help projection"] call _check;
[((_mapInitSource find "visibleGPS") >= 0), "Visible NAV/GPS maps do not use the active map refresh cadence"] call _check;
[((_iconsSource find "_casualtySide isEqualTo _mySide") >= 0) && {(_iconsSource find "player distance _casualty <= _helpMaxDistance") >= 0}, "3D casualty rendering lacks same-team validation or its distance cap"] call _check;
[((_iconsSource find "_casualty isNotEqualTo player") >= 0), "Requester can receive their own 3D casualty marker"] call _check;

[((_presentationSource find "_shouldPresent = _deployedActive") >= 0) && {(_presentationSource find "bn_koth_fnc_respawn_isIncapacitated") >= 0}, "Downed presentation does not use deployed lifecycle plus centralized incapacitation detection"] call _check;
[((_presentationSource find "_unit addAction [") < 0), "KOTH casualty presentation still creates a plain addAction"] call _check;
[((count (_presentationSource regexFind ["call VN_fnc_holdActionAdd"])) isEqualTo 2), "Both KOTH casualty interactions do not use VN_fnc_holdActionAdd exactly once"] call _check;
[((_presentationSource find "_showWhileUnconscious = true") >= 0) && {(count (_presentationSource regexFind ["_showWhileUnconscious,"])) isEqualTo 2}, "Both KOTH casualty hold actions are not enabled while unconscious"] call _check;
[((_presentationSource find "_removeOnCompletion = true") >= 0) && {(count (_presentationSource regexFind ["_removeOnCompletion,"])) isEqualTo 2}, "KOTH casualty hold actions do not prevent duplicate completion"] call _check;
[((_presentationSource find "if (isNull _boundUnit) then") >= 0) && {(_presentationSource find "BN_KOTH_downedActionBinding") >= 0}, "Downed hold actions lack duplicate-safe unit binding"] call _check;
[((_presentationSource find "removeAction") >= 0) && {(_presentationSource find "removeAllActions") < 0}, "KOTH-owned hold-action cleanup is absent or removes unrelated actions"] call _check;
private _downedPresentationSources = _presentationSource + _uiInitSource + _respawnConfigSource;
[((_downedPresentationSources find "casualtyCamera") < 0) && {(_downedPresentationSources find "camCreate") < 0} && {(_downedPresentationSources find "cameraEffect") < 0} && {(_downedPresentationSources find "BN_KOTH_downedCamera") < 0} && {(_downedPresentationSources find "BN_KOTH_debugDisableDownedCamera") < 0}, "KOTH scripted casualty camera state, config or behavior remains"] call _check;
[((_presentationSource find "remoteExecCall [""bn_koth_fnc_respawn_requestCasualtyHelp"", 2]") >= 0), "Call For Help no longer uses the server request endpoint"] call _check;
[((_handoffSource find "[true] call bn_koth_fnc_respawn_updateDownedPresentation") >= 0), "Representation handoff does not tear down casualty presentation"] call _check;
[((_handoffSource find "private _switched = player isEqualTo _targetUnit;") >= 0), "Representation ACK no longer uses the proven selected-player identity contract"] call _check;
[((_handoffSource find "VN_fnc_revive_coreinit") < 0), "Representation handoff manually enters the S.O.G. casualty core loop"] call _check;
[((_handoffSource find "VN_fnc_revive_addEventHandlers") >= 0) && {(_handoffSource find "BN_KOTH_advancedReviveEventHandlersInitializedLocal") >= 0}, "Representation handoff lacks duplicate-safe S.O.G. event-handler installation"] call _check;
[((_damageSource find "if (_intruderCollision) exitWith {_damage};") < 0) && {(_damageSource find "if (_sourceBlocked) exitWith {_currentDamage};") >= 0}, "Safe-zone HandleDamage still overrides stacked handlers during ordinary damage"] call _check;
[((_presentationSource find "[player, 3] call VN_fnc_revive_action_respawn") >= 0), "Give Up does not use the supported S.O.G. completion path"] call _check;

[((_respawnConfigSource find "experimentalHoldActionDiagnostics") < 0)
    && {(_respawnInitSource find "startReviveHoldActionDiagnosticsLocal") < 0}
    && {(_functionsSource find "respawn_startReviveHoldActionDiagnosticsLocal") < 0},
    "The obsolete client hold-action diagnostic remains configured or registered"] call _check;
private _nativeRemovalPropertyAt = _missionSource find "property=""vn_module_revive_revive_item_remove"";";
private _nativeRemovalProperty = if (_nativeRemovalPropertyAt >= 0) then {_missionSource select [_nativeRemovalPropertyAt, 500]} else {""};
private _nativeItemsPropertyAt = _missionSource find "property=""vn_module_revive_revive_item"";";
private _nativeItemsProperty = if (_nativeItemsPropertyAt >= 0) then {_missionSource select [_nativeItemsPropertyAt, 700]} else {""};
private _nativeBleedoutPropertyAt = _missionSource find "property=""vn_module_revive_bleedout_time"";";
private _nativeBleedoutProperty = if (_nativeBleedoutPropertyAt >= 0) then {_missionSource select [_nativeBleedoutPropertyAt, 500]} else {""};
[((_missionSource find "type=""vn_module_advanced_revive"";") >= 0), "The Eden S.O.G. Advanced Revive module is absent"] call _check;
[(_nativeRemovalPropertyAt >= 0) && {(_nativeRemovalProperty find "value=1;") >= 0}, "Native successful-Resuscitate item removal is not enabled"] call _check;
[(_nativeItemsPropertyAt >= 0)
    && {(_nativeItemsProperty find "vn_b_item_firstaidkit") >= 0}
    && {(_nativeItemsProperty find "vn_o_item_firstaidkit") >= 0}
    && {(_nativeItemsProperty find "vn_b_item_medikit_01") >= 0},
    "Native Resuscitate items do not include both S.O.G. FAKs and the medikit"] call _check;
[(_nativeBleedoutPropertyAt >= 0)
    && {(_nativeBleedoutProperty find "value=600;") >= 0},
    "Native S.O.G. bleedout is not configured for the ten-minute duration"] call _check;
private _nativeActionsRemoteAt = _remoteExecSource find "class VN_fnc_revive_actions_local";
private _nativeActionsRemote = if (_nativeActionsRemoteAt >= 0) then {_remoteExecSource select [_nativeActionsRemoteAt, 240]} else {""};
[(_nativeActionsRemoteAt >= 0)
    && {(_nativeActionsRemote find "allowedTargets = 0") >= 0}
    && {(_nativeActionsRemote find "jip = 1") >= 0},
    "Native casualty action installation lacks its documented global/JIP RemoteExec allowance"] call _check;
{
    _x params ["_className", "_allowedTargets"];
    private _entryAt = _remoteExecSource find format ["class %1", _className];
    private _entry = if (_entryAt >= 0) then {_remoteExecSource select [_entryAt, 240]} else {""};
    [(_entryAt >= 0) && {(_entry find format ["allowedTargets = %1", _allowedTargets]) >= 0} && {(_entry find "jip = 0") >= 0}, format ["Required transient S.O.G. RemoteExec allowance has the wrong target/JIP scope: %1", _className]] call _check;
} forEach [
    ["VN_fnc_revive_dynamic_audio", 1],
    ["VN_fnc_revive_detachunit_local", 1],
    ["VN_fnc_revive_action_dropplayer", 0],
    ["switchMove", 0]
];

[((_reconcileSource find "bn_koth_fnc_respawn_isIncapacitated") >= 0), "Help reconciliation does not invalidate recovered casualties"] call _check;
[((_deathSource find "bn_koth_fnc_respawn_reconcileCasualtyHelp") >= 0), "Death does not reconcile help state"] call _check;
[((_respawnSource find "bn_koth_fnc_respawn_reconcileCasualtyHelp") >= 0), "Respawn does not reconcile help state"] call _check;
[((_disconnectSource find "bn_koth_fnc_respawn_reconcileCasualtyHelp") >= 0), "Disconnect does not reconcile help state"] call _check;
[((_roundSource find "bn_koth_fnc_respawn_reconcileCasualtyHelp") >= 0), "Round transition does not reconcile help state"] call _check;

private _productionSources = _predicateSource + _zoneSource + _requestSource + _publishSource + _reconcileSource
    + _receiveSource + _presentationSource + _mapSource + _mapInitSource + _mapDrawSource + _iconsSource + _handoffSource;
[((_productionSources find "VN_fnc_revive_handleDamage") < 0), "Forbidden manual VN_fnc_revive_handleDamage call exists"] call _check;
[((_productionSources find "VN_fnc_revive_actions_local") < 0), "Forbidden manual VN_fnc_revive_actions_local call exists"] call _check;

diag_log format ["[BN_KOTH_TEST] Downed integration: %1 failure(s): %2", count _failures, _failures];
_failures

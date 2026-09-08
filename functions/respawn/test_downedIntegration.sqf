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
private _zoneSource = preprocessFileLineNumbers "functions\zone\fn_evaluateControl.sqf";
private _requestSource = preprocessFileLineNumbers "functions\respawn\fn_requestCasualtyHelp.sqf";
private _publishSource = preprocessFileLineNumbers "functions\respawn\fn_publishCasualtyHelpState.sqf";
private _reconcileSource = preprocessFileLineNumbers "functions\respawn\fn_reconcileCasualtyHelp.sqf";
private _receiveSource = preprocessFileLineNumbers "functions\respawn\fn_receiveCasualtyHelpState.sqf";
private _presentationSource = preprocessFileLineNumbers "functions\respawn\fn_updateDownedPresentation.sqf";
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
[((_mapSource find "_casualtySide isEqualTo _mySide") >= 0), "Map casualty rendering lacks client-side same-team validation"] call _check;
[((_mapDrawSource find "findDisplay _mapDisplayId") >= 0) && {(_mapDrawSource find "ctrlAddEventHandler [""Draw""") >= 0}, "Casualty map rendering is not bound to the configured full-map control"] call _check;
[((_mapDrawSource find "RscCustomInfoMiniMap") >= 0) && {(_mapDrawSource find "RscCustomInfoAirborneMiniMap") >= 0} && {(_mapDrawSource find "IGUI_displays") >= 0} && {(_mapDrawSource find "displayCtrl 101") >= 0}, "Casualty map rendering is not bound to all normal NAV/GPS map controls"] call _check;
[((_mapDrawSource find "BN_KOTH_casualtyHelpMapDrawEntries") >= 0), "Full-map and NAV/GPS casualty rendering do not share the validated help projection"] call _check;
[((_mapInitSource find "visibleGPS") >= 0), "Visible NAV/GPS maps do not use the active map refresh cadence"] call _check;
[((_iconsSource find "_casualtySide isEqualTo _mySide") >= 0) && {(_iconsSource find "player distance _casualty <= _helpMaxDistance") >= 0}, "3D casualty rendering lacks same-team validation or its distance cap"] call _check;

[((_presentationSource find "attachTo [_unit, _offset]") >= 0) && {(_presentationSource find "camSetTarget") >= 0} && {(_presentationSource find "camSetFov") >= 0}, "Fixed attached casualty camera contract is absent"] call _check;
[((_presentationSource find "cameraEffect [""TERMINATE""") >= 0) && {(_presentationSource find "camDestroy") >= 0}, "Casualty camera teardown is absent"] call _check;
[((_handoffSource find "[true] call bn_koth_fnc_respawn_updateDownedPresentation") >= 0), "Representation handoff does not tear down casualty presentation"] call _check;
[((_handoffSource find "private _switched = player isEqualTo _targetUnit;") >= 0), "Representation ACK no longer uses the proven selected-player identity contract"] call _check;
[((_handoffSource find "VN_fnc_revive_coreinit") < 0), "Representation handoff manually enters the S.O.G. casualty core loop"] call _check;
[((_presentationSource find "[player, 3] call VN_fnc_revive_action_respawn") >= 0), "Give Up does not use the supported S.O.G. completion path"] call _check;

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

/*
    File: test_rental.sqf
    Author: Legend
    Description: Focused contracts for the shared personal paid-vehicle life,
        transaction ordering, cooldown, ownership, rental, and rollback paths.
    Execution: Hosted or dedicated server debug/test context
    Returns: Failed assertion labels <ARRAY>
*/
private _failures = [];
private _assert = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
[isServer, "Personal vehicle tests require server execution."] call _assert;
private _active = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", objNull];
private _cooldowns = missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", objNull];
[_active isEqualType createHashMap, "Shared active personal-vehicle map is not initialized."] call _assert;
[_cooldowns isEqualType createHashMap, "Shared personal-vehicle cooldown map is not initialized."] call _assert;
[isNil {missionNamespace getVariable "BN_KOTH_vehicleActiveRentals"}, "Legacy parallel active-rental map still exists."] call _assert;

private _source = preprocessFileLineNumbers "functions\vehicles\fn_rentVehicle.sqf";
private _monitor = preprocessFileLineNumbers "functions\vehicles\fn_monitorManagedVehicles.sqf";
private _lifeEndSource = preprocessFileLineNumbers "functions\vehicles\fn_endRentalLife.sqf";
private _cleanupSource = preprocessFileLineNumbers "functions\vehicles\fn_cleanupPersonalVehicles.sqf";
private _serviceRequestSource = preprocessFileLineNumbers "functions\vehicles\fn_requestService.sqf";
private _serviceMonitorSource = preprocessFileLineNumbers "functions\vehicles\fn_monitorServiceSessions.sqf";
private _servicePresentationSource = preprocessFileLineNumbers "functions\vehicles\fn_setServicePresentation.sqf";
private _serviceApplySource = preprocessFileLineNumbers "functions\vehicles\fn_applyServiceLocal.sqf";
private _ownerActionsSource = preprocessFileLineNumbers "functions\vehicles\fn_addRentalOwnerActions.sqf";
private _personalGuidanceSource = preprocessFileLineNumbers "functions\vehicles\fn_setPersonalGuidance.sqf";
private _rentalResultSource = preprocessFileLineNumbers "functions\vehicles\fn_receiveRentalResult.sqf";
private _serviceDiagnosticSource = preprocessFileLineNumbers "functions\vehicles\fn_debugReportServiceAction.sqf";
private _serviceRequiredSource = preprocessFileLineNumbers "functions\vehicles\fn_requiresService.sqf";
private _forceOutSource = preprocessFileLineNumbers "functions\vehicles\fn_forceOutRentalVehicle.sqf";
[(_source find 'switch (_operation)') >= 0 && {(_source find 'case "PURCHASE"') >= 0} && {(_source find 'case "SPAWN"') >= 0}, "Existing transaction owner does not support purchase/replacement modes."] call _assert;
[(_source find 'bn_koth_fnc_persistence_savePlayer') >= 0 && {(_source find 'PERSISTENCE_FAILED_ROLLED_BACK') >= 0} && {(_source find 'PERSISTENCE_ROLLBACK_FAILED') >= 0}, "Cash/ownership transaction lacks verified immediate persistence rollback outcomes."] call _assert;
[(_source find '[_progression, _metadata, true] call bn_koth_fnc_vehicles_evaluateLoadoutRules') >= 0 && {(_source find '[_progression, _metadata, false] call bn_koth_fnc_vehicles_evaluateLoadoutRules') >= 0}, "RENT and owned SPAWN do not share the prerequisite interpreter with distinct ownership policy."] call _assert;
[(_source find '_operation isEqualTo "RENT" && {!(_metadata getOrDefault ["rentable", false])}') >= 0 && {(_source find '_rentalLoadoutRules getOrDefault ["unlocked", false]') >= 0}, "Rental metadata/mastery enforcement is incomplete."] call _assert;
[(_source find 'vehicleFirstSpawnsUsed') >= 0 && {(_source find 'FIRST_SPAWN_STATE_INVALID') >= 0} && {(_source find 'Vehicle family purchased; first spawn included.') >= 0}, "Included first-spawn state is not committed or guarded exactly once."] call _assert;
[(_source find 'BN_KOTH_vehicleActivePersonal') >= 0 && {(_source find 'while {!isNull _vehicle') < 0}, "Personal lives do not share the one bounded manager."] call _assert;
[(_monitor find 'BN_KOTH_vehicleActivePersonal') >= 0 && {(_monitor find 'BN_KOTH_vehiclePersonalLastSweepAt') >= 0}, "Shared manager does not sweep personal paid vehicles."] call _assert;
[(_source find 'bn_koth_fnc_vehicles_applyVisualProfile') >= 0 && {(_source find 'setObjectTexture') < 0}, "Visual hook is missing or applies a texture in this release."] call _assert;

private _duplicateAt = _source find '_operation isEqualTo "PURCHASE" && {_owned}';
private _safeSpawnAt = _source find 'if ((count _spawnPos) isEqualTo 0) exitWith';
private _createAt = _source find 'private _vehicle = createVehicle';
private _visualAt = _source find 'bn_koth_fnc_vehicles_applyVisualProfile';
private _spendAt = _source find 'bn_koth_fnc_progression_cash_spendCash';
private _ownershipAt = _source find '_progression set ["ownedVehicleFamilies"';
private _saveAt = _source find 'private _save = [_uid';
private _activeCommitAt = _source find '_activeMap set [_uid';
[_duplicateAt >= 0 && {_duplicateAt < _safeSpawnAt}, "Duplicate purchase is not rejected before spawn work."] call _assert;
[_safeSpawnAt < _createAt && {_createAt < _visualAt} && {_visualAt < _spendAt}, "Blocked/create/visual failures are not ordered before cash spend."] call _assert;
[_spendAt < _ownershipAt && {_ownershipAt < _saveAt} && {_saveAt < _activeCommitAt}, "Purchase cash, ownership, persistence and active-life commit ordering changed."] call _assert;
[(_source find 'if !(_spent getOrDefault ["success", false]) exitWith {deleteVehicle _vehicle') >= 0, "Cash-spend failure does not delete the pre-created vehicle."] call _assert;
[(_source find '_progression set ["ownedVehicleFamilies", _oldOwned]') >= 0 && {(_source find '_progression set ["vehicleFirstSpawnsUsed", _oldUsed]') >= 0}, "Persistence failure does not restore pre-purchase ownership/first-spawn state."] call _assert;
[(_source find 'private _rollbackSaved = _rollbackSave getOrDefault ["success", false]') >= 0 && {(_source find 'Personal vehicle ROLLBACK FAILED UID=%1 operation=%2 family=%3 loadout=%4') >= 0}, "Compensating save failure is not checked and diagnosed."] call _assert;
[(_source find 'SESSION_FALLBACK') >= 0 && {(_source find 'PERSISTENCE_UNAVAILABLE') >= 0}, "Known write-blocked fallback sessions are not rejected before transaction work."] call _assert;
[(_lifeEndSource find '"VOLUNTARY_RETURN"') >= 0 && {(_lifeEndSource find 'private _startsCooldown=!(toUpper _reason in _forcedCleanupReasons)') >= 0}, "Forced/voluntary no-cooldown policy is not centralized in the life-end owner."] call _assert;
[(_cleanupSource find 'private _ended = [_uid, _vehicle, _reason] call bn_koth_fnc_vehicles_endRentalLife') >= 0, "Forced cleanup bypasses the life-end owner or skips null/stale active records."] call _assert;
[(_source find 'bn_koth_fnc_vehicles_findAirPosition') >= 0 && {(_source find 'setVelocityModelSpace') >= 0} && {(_source find '_spawnMode isEqualTo "AIRBORNE"') >= 0}, "Fixed-wing spawn does not use config-resolved airborne placement and speed."] call _assert;
[(_serviceRequestSource find 'params [["_vehicle", objNull') >= 0 && {(_serviceRequestSource find 'remoteExecutedOwner') >= 0} && {(_serviceRequestSource find 'BN_KOTH_vehicleActivePersonal') >= 0}, "Service request accepts more than vehicle intent or does not derive server identity/active ownership."] call _assert;
[(_serviceRequestSource find 'bn_koth_fnc_progression_cash_spendCash') >= 0 && {(_serviceRequestSource find 'setDamage 0') >= 0} && {(_serviceRequestSource find 'bn_koth_fnc_vehicles_applyServiceLocal') >= 0}, "Service-pad transaction does not charge before authoritative repair/rearm."] call _assert;
[(_serviceMonitorSource find '_session set ["state", "COMPLETING"]') >= 0 && {(_serviceMonitorSource find 'bn_koth_fnc_progression_cash_spendCash') >= 0} && {(_serviceMonitorSource find 'lastPositionASL') >= 0}, "Air-gate completion lacks idempotent state, server cash, or swept-position validation."] call _assert;
[(_monitor find 'bn_koth_fnc_vehicles_monitorServiceSessions') >= 0, "Air service does not reuse the shared vehicle manager."] call _assert;
[(_servicePresentationSource find 'createMarkerLocal') < 0 && {(_servicePresentationSource find 'triangle_ca.paa') >= 0} && {(_servicePresentationSource find '[1, [1, 0.92, 0.08, 1], 26]') >= 0} && {(_servicePresentationSource find 'createVehicle') < 0}, "Air-service gate presentation still creates a map marker, lacks high-contrast repeated elements, or creates a network object."] call _assert;
[(_serviceApplySource find '!isRemoteExecuted') >= 0 && {(_serviceApplySource find 'remoteExecutedOwner isNotEqualTo 2') >= 0} && {(_serviceApplySource find 'setVehicleAmmo 1') >= 0} && {(_serviceApplySource find 'setPylonLoadout') < 0}, "Local-turret rearm is not server-authorized refill-only behavior."] call _assert;
[(_ownerActionsSource find 'bn_koth_fnc_menu_close') >= 0 && {(_ownerActionsSource find 'bn_koth_fnc_menu_close') < (_ownerActionsSource find 'moveInDriver')}, "Successful airborne transfer does not close the central menu before moving the owner into the pilot seat."] call _assert;
[(_personalGuidanceSource find 'setMarkerShapeLocal "ELLIPSE"') >= 0 && {(_personalGuidanceSource find 'setMarkerSizeLocal [_serviceRadius, _serviceRadius]') >= 0} && {(_personalGuidanceSource find 'drawIcon3D') >= 0} && {(_personalGuidanceSource find 'createMarkerGlobal') < 0} && {(_personalGuidanceSource find 'setMarkerPos') < 0}, "Personal helicopter guidance does not project the configured owner-local service area."] call _assert;
[(_personalGuidanceSource find 'BN_KOTH_safeZoneProtected') >= 0 && {(_personalGuidanceSource find 'player distance2D _servicePosition') < 0}, "Rotary 3D service guidance is not restricted to the existing safe-zone state."] call _assert;
[(_personalGuidanceSource find 'uiSleep 300') >= 0 && {(_personalGuidanceSource find 'addEventHandler ["GetIn"') >= 0} && {(_personalGuidanceSource find 'addEventHandler ["Killed"') >= 0} && {(_personalGuidanceSource find 'addEventHandler ["Deleted"') >= 0}, "Personal helicopter spawn guidance lacks bounded entry/loss/timeout cleanup."] call _assert;
[(_rentalResultSource find 'VEHICLE_LIFE_ENDED') >= 0 && {(_rentalResultSource find 'bn_koth_fnc_vehicles_setPersonalGuidance') >= 0}, "Personal helicopter guidance is not cleared through the centralized life-end result."] call _assert;
[(_serviceDiagnosticSource find 'SERVICE ACTION:') >= 0 && {(_serviceDiagnosticSource find 'systemChat') >= 0} && {(_serviceDiagnosticSource find 'remoteExec') < 0}, "Service-action troubleshooting is not a bounded local diagnostic."] call _assert;
[(_serviceRequiredSource find 'getAllHitPointsDamage') >= 0 && {(_serviceRequiredSource find 'magazinesAllTurrets') >= 0} && {(_serviceRequiredSource find 'ammoOnPylon') >= 0}, "Service necessity does not compare damage, turret ammunition and pylon ammunition."] call _assert;
private _notRequiredAt = _serviceRequestSource find 'bn_koth_fnc_vehicles_requiresService';
private _serviceSpendAt = _serviceRequestSource find 'bn_koth_fnc_progression_cash_spendCash';
[_notRequiredAt >= 0 && {_notRequiredAt < _serviceSpendAt} && {(_serviceRequestSource find 'No repair or rearm is currently required.') >= 0}, "Pointless service is not rejected before payment."] call _assert;
[(_serviceRequestSource find '"VOLUNTARY_RETURN"') >= 0 && {(_serviceMonitorSource find '_purpose isEqualTo "RETURN"') >= 0} && {(_serviceMonitorSource find 'bn_koth_fnc_progression_cash_spendCash') > (_serviceMonitorSource find '_purpose isEqualTo "RETURN"')}, "Voluntary return does not reuse the service session/life-end owners or remains coupled to payment."] call _assert;
[(_ownerActionsSource find '["RETURN VEHICLE"') >= 0 && {(_ownerActionsSource find 'BN_KOTH_personalReturnMode') >= 0} && {(_ownerActionsSource find 'BN_KOTH_personalServiceAreaRadius') >= 0}, "Owner actions do not expose config-driven, physically bounded vehicle return."] call _assert;
[(_forceOutSource find 'remoteExecutedOwner != 2') >= 0 && {(_forceOutSource find 'setPosATL _returnPosition') >= 0}, "Successful airborne return does not reuse a server-authorized owner-local safe exit."] call _assert;
[(_source find 'Vehicle purchase: %1') >= 0 && {(_source find 'Vehicle rental: %1') >= 0} && {(_source find 'Vehicle replacement: %1') >= 0} && {(_serviceRequestSource find 'format ["Vehicle service: %1", _displayName]') >= 0}, "Player-facing vehicle cash events still use internal family/loadout identifiers."] call _assert;
private _remoteFunctions = missionConfigFile >> "CfgRemoteExec" >> "Functions";
[!(isClass (_remoteFunctions >> "bn_koth_fnc_vehicles_setPersonalGuidance")) && {!(isClass (_remoteFunctions >> "bn_koth_fnc_vehicles_debugReportServiceAction"))}, "Client-local vehicle presentation/diagnostic functions are exposed through RemoteExec."] call _assert;
[!(isClass (_remoteFunctions >> "bn_koth_fnc_vehicles_requiresService")), "Internal service-necessity evaluator is exposed through RemoteExec."] call _assert;

private _probeUid = "BN_KOTH_TEST_PERSONAL_ROLLBACK";
private _before = (missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap]) getOrDefault [_probeUid, -1];
private _probe = "Land_vn_helipadsquare_f" createVehicle [0,0,0];
private _ended = [_probeUid, _probe, "TEST_ROLLBACK"] call bn_koth_fnc_vehicles_endRentalLife;
deleteVehicle _probe;
[!_ended, "Uncommitted vehicle identity started a life-end transition."] call _assert;
[((missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap]) getOrDefault [_probeUid, -1]) isEqualTo _before, "Rejected life end changed cooldown state."] call _assert;

private _forcedUid = "BN_KOTH_TEST_PERSONAL_FORCED";
private _forcedVehicle = "Land_vn_helipadsquare_f" createVehicle [0,0,0];
private _activeForForced = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
_activeForForced set [_forcedUid, createHashMapFromArray [["vehicle", _forcedVehicle], ["lifeType", "SPAWN"], ["cooldownSeconds", 123]]];
missionNamespace setVariable ["BN_KOTH_vehicleActivePersonal", _activeForForced];
private _forcedEnded = [_forcedUid, _forcedVehicle, "AO_RESET"] call bn_koth_fnc_vehicles_endRentalLife;
private _cooldownsAfterForced = missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap];
[_forcedEnded && {isNil {_cooldownsAfterForced get _forcedUid}}, "AO reset cleanup incorrectly started a replacement cooldown."] call _assert;
deleteVehicle _forcedVehicle;

private _returnUid = "BN_KOTH_TEST_PERSONAL_RETURN";
private _returnVehicle = "Land_vn_helipadsquare_f" createVehicle [0,0,0];
private _activeForReturn = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
_activeForReturn set [_returnUid, createHashMapFromArray [["vehicle", _returnVehicle], ["lifeType", "SPAWN"], ["cooldownSeconds", 123]]];
missionNamespace setVariable ["BN_KOTH_vehicleActivePersonal", _activeForReturn];
private _returnEnded = [_returnUid, _returnVehicle, "VOLUNTARY_RETURN"] call bn_koth_fnc_vehicles_endRentalLife;
private _cooldownsAfterReturn = missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap];
[_returnEnded && {isNil {_cooldownsAfterReturn get _returnUid}}, "Voluntary return incorrectly started a replacement cooldown."] call _assert;
deleteVehicle _returnVehicle;

private _lossUid = "BN_KOTH_TEST_PERSONAL_LOSS";
private _lossVehicle = "Land_vn_helipadsquare_f" createVehicle [0,0,0];
private _activeForLoss = missionNamespace getVariable ["BN_KOTH_vehicleActivePersonal", createHashMap];
_activeForLoss set [_lossUid, createHashMapFromArray [["vehicle", _lossVehicle], ["lifeType", "RENT"], ["cooldownSeconds", 123]]];
missionNamespace setVariable ["BN_KOTH_vehicleActivePersonal", _activeForLoss];
private _lossEnded = [_lossUid, _lossVehicle, "ABANDONED"] call bn_koth_fnc_vehicles_endRentalLife;
private _cooldownsAfterLoss = missionNamespace getVariable ["BN_KOTH_vehiclePersonalCooldowns", createHashMap];
[_lossEnded && {(_cooldownsAfterLoss getOrDefault [_lossUid, 0]) >= (serverTime + 120)}, "Abandonment did not start the authored replacement cooldown."] call _assert;
_cooldownsAfterLoss deleteAt _lossUid;
missionNamespace setVariable ["BN_KOTH_vehiclePersonalCooldowns", _cooldownsAfterLoss];
deleteVehicle _lossVehicle;
_failures

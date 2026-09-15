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
[(_lifeEndSource find '["AO_RESET","ROUND_RESET","RETURNED_TO_LOBBY","MISSION_RESET","MISSION_END"]') >= 0 && {(_lifeEndSource find 'private _startsCooldown=!(toUpper _reason in _forcedCleanupReasons)') >= 0}, "Forced lifecycle cooldown policy is not centralized in the life-end owner."] call _assert;
[(_cleanupSource find 'private _ended = [_uid, _vehicle, _reason] call bn_koth_fnc_vehicles_endRentalLife') >= 0, "Forced cleanup bypasses the life-end owner or skips null/stale active records."] call _assert;

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

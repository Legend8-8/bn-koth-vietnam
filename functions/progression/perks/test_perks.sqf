/*
    File: test_perks.sqf
    Author: Legend
    Description: Focused server tests for perk state, transactions, and restricted managed-loadout handling.
    Execution: Server test console
    Returns: Failure messages; an empty array means pass.
*/
if (!isServer) exitWith {["Perk tests must run on the server."]};
private _failures = [];
private _assert = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _vars = ["BN_KOTH_playerProgression", "BN_KOTH_playerProgressionLocal", "BN_KOTH_playerLoadoutState", "BN_KOTH_playerRecords", "BN_KOTH_pendingPerkCleanup", "BN_KOTH_perkCleanupCounter", "BN_KOTH_persistenceDirtyPlayers", "BN_KOTH_persistenceScheduledSaves", "BN_KOTH_persistenceSaveDebounceSeconds"];
private _backup = createHashMap;
{
    _backup set [_x, if (isNil {missionNamespace getVariable _x}) then {[false, 0]} else {[true, missionNamespace getVariable _x]}];
} forEach _vars;
missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceSaveDebounceSeconds", 0];
private _uid = "PERK_TEST";
private _state = createHashMapFromArray [["uid", _uid], ["xp", 0], ["level", 1], ["cash", 10], ["ownedPerks", []], ["activePerks", []]];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMapFromArray [[_uid, _state]]];
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMap];
missionNamespace setVariable ["BN_KOTH_playerRecords", createHashMapFromArray [[_uid, createHashMapFromArray [["ownerId", 77]]]]];
missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];

private _config = ["suppressor"] call bn_koth_fnc_progression_perks_getConfig;
[_config getOrDefault ["success", false] && {(_config getOrDefault ["purchaseCost", -1]) isEqualTo 1} && {(_config getOrDefault ["maxActivePerks", -1]) isEqualTo 3}, "Suppressor config or active limit is incorrect."] call _assert;
["suppressor" in (_config getOrDefault ["restrictedTraits", []]), "Suppressor restriction trait is not config-authored."] call _assert;
private _cloakConfig = ["cloak"] call bn_koth_fnc_progression_perks_getConfig;
[_cloakConfig getOrDefault ["success", false]
    && {_cloakConfig getOrDefault ["available", false]}
    && {_cloakConfig getOrDefault ["purchasable", false]}
    && {(_cloakConfig getOrDefault ["purchaseCost", -1]) isEqualTo 1},
    "Cloak config is not available through the canonical perk catalogue."] call _assert;
private _medicConfig = ["medic"] call bn_koth_fnc_progression_perks_getConfig;
[_medicConfig getOrDefault ["success", false]
    && {_medicConfig getOrDefault ["available", false]}
    && {_medicConfig getOrDefault ["purchasable", false]}
    && {(_medicConfig getOrDefault ["purchaseCost", -1]) isEqualTo 1}
    && {"vn_b_item_medikit_01" in (_medicConfig getOrDefault ["restrictedClasses", []])},
    "MEDIC config is unavailable or does not own the medikit restriction."] call _assert;
[!((["field_medic_placeholder"] call bn_koth_fnc_progression_perks_getConfig) getOrDefault ["success", false]), "The retired field_medic_placeholder perk remains configured."] call _assert;

private _medikitMetadata = ["Consumables", "vn_b_item_medikit_01"] call bn_koth_fnc_loadouts_getItemMetadata;
[_medikitMetadata getOrDefault ["success", false]
    && {(_medikitMetadata getOrDefault ["allowedSides", []]) isEqualTo ["WEST", "EAST"]}
    && {(_medikitMetadata getOrDefault ["minLevel", -1]) isEqualTo 1}
    && {"medic" in (_medikitMetadata getOrDefault ["requiredPerks", []])},
    "Medikit metadata is missing its cross-team MEDIC entitlement."] call _assert;

private _westFakMetadata = ["Consumables", "vn_b_item_firstaidkit"] call bn_koth_fnc_loadouts_getItemMetadata;
private _eastFakMetadata = ["Consumables", "vn_o_item_firstaidkit"] call bn_koth_fnc_loadouts_getItemMetadata;
private _westFakForWest = ["WEST", _westFakMetadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
private _westFakForEast = ["EAST", _westFakMetadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
private _eastFakForEast = ["EAST", _eastFakMetadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
private _eastFakForWest = ["WEST", _eastFakMetadata, false] call bn_koth_fnc_progression_evaluateEquipmentSidePolicyRules;
[_westFakMetadata getOrDefault ["configured", false]
    && {(_westFakMetadata getOrDefault ["allowedSides", []]) isEqualTo ["WEST"]}
    && {_westFakForWest getOrDefault ["allowed", false]}
    && {!(_westFakForEast getOrDefault ["allowed", true])},
    "WEST FAK managed-acquisition policy is not WEST-only."] call _assert;
[_eastFakMetadata getOrDefault ["configured", false]
    && {(_eastFakMetadata getOrDefault ["allowedSides", []]) isEqualTo ["EAST"]}
    && {_eastFakForEast getOrDefault ["allowed", false]}
    && {!(_eastFakForWest getOrDefault ["allowed", true])},
    "EAST FAK managed-acquisition policy is not EAST-only."] call _assert;

private _inactiveMedicEntitlement = [_state, _medikitMetadata, "vn_b_item_medikit_01", "WEST", false] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
[!(_inactiveMedicEntitlement getOrDefault ["entitled", true])
    && {(_inactiveMedicEntitlement getOrDefault ["code", ""]) isEqualTo "LOCKED_PERK"}
    && {"medic" in (_inactiveMedicEntitlement getOrDefault ["missingPerks", []])},
    "Inactive MEDIC did not visibly lock medikit entitlement."] call _assert;

private _traitSource = preprocessFileLineNumbers "functions\progression\perks\fn_applyMedicTraitLocal.sqf";
private _progressionReceiveSource = preprocessFileLineNumbers "functions\ui\state\fn_receiveProgression.sqf";
private _stateReceiveSource = preprocessFileLineNumbers "functions\ui\state\fn_receiveState.sqf";
private _respawnInitSource = preprocessFileLineNumbers "functions\respawn\fn_initPlayerLocal.sqf";
private _handoffSource = preprocessFileLineNumbers "functions\ui\state\fn_selectControlledUnit.sqf";
private _cargoUiSource = preprocessFileLineNumbers "functions\ui\menu\fn_menu_refreshCargoBrowser.sqf";
private _validatorSource = preprocessFileLineNumbers "functions\loadouts\fn_validateLoadout.sqf";
[((_traitSource find "setUnitTrait [""Medic"", _enabled]") >= 0)
    && {(_traitSource find "BN_KOTH_playerProgressionLocal") >= 0}
    && {(_traitSource find "BN_KOTH_playerStates") >= 0}
    && {(_traitSource find "BN_KOTH_playableSides") >= 0}
    && {(_traitSource find "ACTIVE") >= 0}
    && {(_traitSource find "local _unit") >= 0},
    "MEDIC trait mirror is not derived locally from projected active/deployed state."] call _assert;
[((_progressionReceiveSource find "progression_perks_applyMedicTraitLocal") >= 0)
    && {(_stateReceiveSource find "progression_perks_applyMedicTraitLocal") >= 0}
    && {(_respawnInitSource find "progression_perks_applyMedicTraitLocal") >= 0}
    && {(_handoffSource find "setUnitTrait [""Medic"", false]") >= 0}
    && {(_handoffSource find "respawn_initPlayerLocal") >= 0},
    "MEDIC trait lifecycle is missing a progression, snapshot, respawn, or representation-handoff seam."] call _assert;
[((_cargoUiSource find "%1 PERK REQUIRED") >= 0)
    && {(_validatorSource find "BN_KOTH_playerProgression") >= 0}
    && {(_validatorSource find "progression_perks_findRestrictedItems") >= 0},
    "Medikit lock presentation or authoritative managed-loadout perk validation is not wired through the generic path."] call _assert;
[!([_uid, "cloak"] call bn_koth_fnc_progression_perks_isActive), "Unowned Cloak was reported active."] call _assert;
_state set ["activePerks", ["cloak"]];
[([_uid, "cloak"] call bn_koth_fnc_progression_perks_isActive), "Authoritative active Cloak was not detected."] call _assert;
missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", createHashMapFromArray [["activePerks", ["cloak"]]]];
_state set ["activePerks", []];
[!([_uid, "cloak"] call bn_koth_fnc_progression_perks_isActive), "Client presentation state granted authoritative Cloak."] call _assert;
[["vn_s_m1911"] call bn_koth_fnc_progression_perks_isSuppressor, "Generated suppressor classification failed."] call _assert;
[!(["vn_o_4x_m16"] call bn_koth_fnc_progression_perks_isSuppressor), "Non-suppressor was classified as suppressor."] call _assert;

private _purchase = [_uid, "suppressor"] call bn_koth_fnc_progression_perks_purchase;
[_purchase getOrDefault ["success", false] && {(_state getOrDefault ["cash", -1]) isEqualTo 9} && {"suppressor" in (_state getOrDefault ["ownedPerks", []])}, "Atomic Suppressor purchase failed."] call _assert;
private _duplicate = [_uid, "suppressor"] call bn_koth_fnc_progression_perks_purchase;
[!(_duplicate getOrDefault ["success", true]) && {(_state getOrDefault ["cash", -1]) isEqualTo 9}, "Duplicate purchase charged cash or succeeded."] call _assert;
private _activate = [_uid, "suppressor", "ACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[_activate getOrDefault ["success", false] && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Owned Suppressor did not activate."] call _assert;

private _loadout = [["vn_m1911", "vn_s_m1911", "", "", [], [], ""], [], [], ["u", [["vn_s_pm", 1]]], ["v", [["vn_s_m14", 1]]], ["b", [["vn_s_m16", 1]]], "", "", [], []];
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMapFromArray [[_uid, createHashMapFromArray [["intendedLoadout", _loadout], ["sideToken", "WEST"]]]]];
[((count ([_loadout] call bn_koth_fnc_progression_perks_findSuppressors)) isEqualTo 4), "Full managed loadout suppressor query missed attachment/cargo slots."] call _assert;
[((count ([_loadout, "suppressor"] call bn_koth_fnc_progression_perks_findRestrictedItems)) > 0), "Generic perk restriction hook did not find config-trait restricted items."] call _assert;
private _expectedClean = [_loadout] call bn_koth_fnc_progression_perks_removeSuppressors;
private _withoutPending = [_uid, "naked-finalize", objNull, _expectedClean] call bn_koth_fnc_progression_perks_completeCleanup;
[!(_withoutPending getOrDefault ["success", true]) && {(_withoutPending getOrDefault ["code", ""]) isEqualTo "NO_PENDING_CLEANUP"} && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Completion without a pending cleanup deactivated the perk."] call _assert;
private _warn = [_uid, "suppressor", "DEACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[(_warn getOrDefault ["code", ""]) isEqualTo "CONFIRMATION_REQUIRED" && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Deactivation did not require confirmation or changed active state early."] call _assert;
private _cleanup = [_uid, "suppressor", "DEACTIVATE_CONFIRM"] call bn_koth_fnc_progression_perks_setActive;
private _clean = (_cleanup getOrDefault ["cleanupValidation", createHashMap]) getOrDefault ["validatedLoadout", []];
private _token = _cleanup getOrDefault ["cleanupToken", ""];
[(_cleanup getOrDefault ["code", ""]) isEqualTo "SUPPRESSOR_CLEANUP_REQUIRED" && {(count ([_clean] call bn_koth_fnc_progression_perks_findSuppressors)) isEqualTo 0} && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Confirmed cleanup was unsafe or deactivated before application."] call _assert;
private _currentLoadoutState = (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap]) get _uid;
[(_currentLoadoutState get "intendedLoadout") isEqualTo _loadout, "Confirmation committed intendedLoadout before authoritative completion."] call _assert;

private _noPending = [_uid, "not-a-token", objNull, _clean] call bn_koth_fnc_progression_perks_completeCleanup;
[!(_noPending getOrDefault ["success", true]) && {(_noPending getOrDefault ["code", ""]) isEqualTo "STALE_CLEANUP"}, "Mismatched/finalize-style completion was accepted."] call _assert;

private _repeat = [_uid, "suppressor", "DEACTIVATE_CONFIRM"] call bn_koth_fnc_progression_perks_setActive;
[(_repeat getOrDefault ["cleanupToken", ""]) isEqualTo _token && {(count (keys (missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap]))) isEqualTo 1}, "Repeated confirmation created a conflicting cleanup transaction."] call _assert;

private _failed = [_uid, _token, objNull, _loadout] call bn_koth_fnc_progression_perks_completeCleanup;
_currentLoadoutState = (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap]) get _uid;
[!(_failed getOrDefault ["success", true]) && {(_currentLoadoutState get "intendedLoadout") isEqualTo _loadout} && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Failed cleanup changed intendedLoadout or deactivated the perk."] call _assert;

private _pending = missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];
private _pendingRecord = _pending get _uid;
_pendingRecord set ["expiresAt", serverTime - 1];
_pending set [_uid, _pendingRecord];
missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pending];
private _stale = [_uid, _token, objNull, _clean] call bn_koth_fnc_progression_perks_completeCleanup;
[!(_stale getOrDefault ["success", true]) && {(_stale getOrDefault ["code", ""]) isEqualTo "STALE_CLEANUP"} && {"suppressor" in (_state getOrDefault ["activePerks", []])}, "Expired cleanup completion deactivated the perk."] call _assert;

private _cleanup2 = [_uid, "suppressor", "DEACTIVATE_CONFIRM"] call bn_koth_fnc_progression_perks_setActive;
private _token2 = _cleanup2 getOrDefault ["cleanupToken", ""];
private _final = [_uid, _token2, objNull, _clean] call bn_koth_fnc_progression_perks_completeCleanup;
_currentLoadoutState = (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap]) get _uid;
[_final getOrDefault ["success", false] && {!("suppressor" in (_state getOrDefault ["activePerks", []]))} && {(_currentLoadoutState get "intendedLoadout") isEqualTo _clean}, "Successful authoritative cleanup did not commit intendedLoadout then deactivate."] call _assert;
private _replay = [_uid, _token2, objNull, _clean] call bn_koth_fnc_progression_perks_completeCleanup;
[!(_replay getOrDefault ["success", true]) && {(_replay getOrDefault ["code", ""]) isEqualTo "NO_PENDING_CLEANUP"}, "Replayed cleanup completion was accepted."] call _assert;

private _medicPurchase = [_uid, "medic"] call bn_koth_fnc_progression_perks_purchase;
private _medicActivate = [_uid, "medic", "ACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[_medicPurchase getOrDefault ["success", false]
    && {_medicActivate getOrDefault ["success", false]}
    && {"medic" in (_state getOrDefault ["activePerks", []])},
    "MEDIC purchase/activation did not use the existing authoritative perk path."] call _assert;
private _activeMedicEntitlement = [_state, _medikitMetadata, "vn_b_item_medikit_01", "EAST", false] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
[_activeMedicEntitlement getOrDefault ["entitled", false], "Active MEDIC did not grant EAST medikit entitlement."] call _assert;

missionNamespace setVariable ["BN_KOTH_playerProgressionLocal", createHashMapFromArray [["activePerks", ["medic"]]]];
_state set ["activePerks", []];
private _clientTraitBypass = [_state, _medikitMetadata, "vn_b_item_medikit_01", "WEST", false] call bn_koth_fnc_progression_evaluateItemEntitlementRules;
[!(_clientTraitBypass getOrDefault ["entitled", true]), "Client MEDIC presentation state bypassed authoritative medikit entitlement."] call _assert;
_state set ["activePerks", ["medic"]];

private _medicLoadout = [[], [], [], ["u", [["vn_b_item_medikit_01", 1], ["vn_b_item_firstaidkit", 2]]], ["v", []], ["b", []], "", "", [], []];
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMapFromArray [[_uid, createHashMapFromArray [["intendedLoadout", _medicLoadout], ["sideToken", "WEST"]]]]];
[((count ([_medicLoadout, "medic"] call bn_koth_fnc_progression_perks_findRestrictedItems)) isEqualTo 1), "Managed-loadout MEDIC restriction did not find the medikit."] call _assert;
private _medicWarning = [_uid, "medic", "DEACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[(_medicWarning getOrDefault ["code", ""]) isEqualTo "CONFIRMATION_REQUIRED" && {"medic" in (_state getOrDefault ["activePerks", []])}, "MEDIC deactivation did not require safe medikit cleanup."] call _assert;
private _medicCleanup = [_uid, "medic", "DEACTIVATE_CONFIRM"] call bn_koth_fnc_progression_perks_setActive;
private _medicClean = (_medicCleanup getOrDefault ["cleanupValidation", createHashMap]) getOrDefault ["validatedLoadout", []];
private _medicToken = _medicCleanup getOrDefault ["cleanupToken", ""];
[(_medicCleanup getOrDefault ["code", ""]) isEqualTo "PERK_CLEANUP_REQUIRED"
    && {(count ([_medicClean, "medic"] call bn_koth_fnc_progression_perks_findRestrictedItems)) isEqualTo 0}
    && {(str _medicClean find "vn_b_item_firstaidkit") >= 0}
    && {"medic" in (_state getOrDefault ["activePerks", []])},
    "MEDIC cleanup removed the wrong cargo or deactivated before physical application."] call _assert;
private _medicFinal = [_uid, _medicToken, objNull, _medicClean] call bn_koth_fnc_progression_perks_completeCleanup;
_currentLoadoutState = (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap]) get _uid;
[_medicFinal getOrDefault ["success", false]
    && {!("medic" in (_state getOrDefault ["activePerks", []]))}
    && {(_currentLoadoutState get "intendedLoadout") isEqualTo _medicClean}
    && {(count ([(_currentLoadoutState get "intendedLoadout"), "medic"] call bn_koth_fnc_progression_perks_findRestrictedItems)) isEqualTo 0},
    "Authoritative MEDIC cleanup did not sanitize intended loadout before deactivation."] call _assert;

_state set ["activePerks", ["one", "two", "three"]];
private _limit = [_uid, "suppressor", "ACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[(_limit getOrDefault ["code", ""]) isEqualTo "ACTIVE_PERK_LIMIT", "Configured active-perk maximum was not enforced."] call _assert;

{
    private _entry = _backup get _x;
    missionNamespace setVariable [_x, if (_entry select 0) then {_entry select 1} else {nil}];
} forEach _vars;
_failures

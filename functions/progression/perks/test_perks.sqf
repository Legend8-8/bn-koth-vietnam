/*
    File: test_perks.sqf
    Author: Legend
    Description: Focused server tests for perk state, transactions, and Suppressor managed-loadout handling.
    Execution: Server test console
    Returns: Failure messages; an empty array means pass.
*/
if (!isServer) exitWith {["Perk tests must run on the server."]};
private _failures = [];
private _assert = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _vars = ["BN_KOTH_playerProgression", "BN_KOTH_playerLoadoutState", "BN_KOTH_playerRecords", "BN_KOTH_pendingPerkCleanup", "BN_KOTH_perkCleanupCounter", "BN_KOTH_persistenceDirtyPlayers", "BN_KOTH_persistenceScheduledSaves", "BN_KOTH_persistenceSaveDebounceSeconds"];
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

_state set ["activePerks", ["one", "two", "three"]];
private _limit = [_uid, "suppressor", "ACTIVATE"] call bn_koth_fnc_progression_perks_setActive;
[(_limit getOrDefault ["code", ""]) isEqualTo "ACTIVE_PERK_LIMIT", "Configured active-perk maximum was not enforced."] call _assert;

{
    private _entry = _backup get _x;
    missionNamespace setVariable [_x, if (_entry select 0) then {_entry select 1} else {nil}];
} forEach _vars;
_failures

/*
    File: test_persistence.sqf
    Author: Legend
    Description: Focused in-engine tests for the server persistence service boundary.
    Execution: Server test console
    Returns: Failure messages; an empty array means pass.
*/

if (!isServer) exitWith {["Persistence tests must run on the server."]};

private _failures = [];
private _assert = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message};
};

private _variables = [
    "BN_KOTH_persistenceSchemaVersion", "BN_KOTH_persistenceBackend", "BN_KOTH_persistenceBackendReady",
    "BN_KOTH_persistenceSaveDebounceSeconds", "BN_KOTH_persistenceSessionFallback",
    "BN_KOTH_persistenceMemoryBackend", "BN_KOTH_persistenceDirtyPlayers",
    "BN_KOTH_persistenceScheduledSaves", "BN_KOTH_persistenceLoadedUids",
    "BN_KOTH_persistenceTestFailLoad", "BN_KOTH_persistenceTestFailSave",
    "BN_KOTH_playerProgression", "BN_KOTH_startingCash", "BN_KOTH_roundStats",
    "BN_KOTH_playerLoadoutState"
];
private _backup = createHashMap;
{
    if (isNil {missionNamespace getVariable _x}) then {
        _backup set [_x, nil]
    } else {
        _backup set [_x, missionNamespace getVariable _x]
    };
} forEach _variables;

missionNamespace setVariable ["BN_KOTH_persistenceSchemaVersion", 3];
missionNamespace setVariable ["BN_KOTH_persistenceBackend", "MEMORY"];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", true];
missionNamespace setVariable ["BN_KOTH_persistenceSaveDebounceSeconds", 0];
missionNamespace setVariable ["BN_KOTH_persistenceSessionFallback", true];
missionNamespace setVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMap];
missionNamespace setVariable ["BN_KOTH_startingCash", 1000];
missionNamespace setVariable ["BN_KOTH_roundStats", createHashMapFromArray [["roundOnly", 99]]];

private _firstUid = "PERSIST_FIRST_TIME";
private _first = [_firstUid] call bn_koth_fnc_persistence_loadPlayer;
[_first getOrDefault ["success", false] && {(_first getOrDefault ["code", ""]) isEqualTo "FIRST_TIME"}, "First-time UID did not create a state."] call _assert;
private _firstState = _first getOrDefault ["state", createHashMap];
[(_firstState getOrDefault ["xp", -1]) isEqualTo 0, "First-time XP was not zero."] call _assert;
[(_firstState getOrDefault ["cash", -1]) isEqualTo 1000, "First-time cash did not use authoritative starting cash."] call _assert;
[(count (_firstState getOrDefault ["ownedWeapons", ["bad"]])) isEqualTo 0, "First-time ownership was not empty."] call _assert;
[(count (_firstState getOrDefault ["ownedPerks", ["bad"]])) isEqualTo 0 && {(count (_firstState getOrDefault ["activePerks", ["bad"]])) isEqualTo 0}, "First-time perk state was not empty."] call _assert;

private _knownUid = "PERSIST_KNOWN";
private _rawKills = createHashMapFromArray [["VN_M1903", 7]];
private _raw = createHashMapFromArray [
    ["schemaVersion", 3], ["uid", _knownUid], ["xp", 12345], ["level", 999], ["cash", 4321],
    ["ownedWeapons", ["VN_M1903"]], ["rentedWeapons", ["vn_m1911"]], ["weaponKills", _rawKills],
    ["ownedPerks", ["SUPPRESSOR", "unknown", "suppressor"]], ["activePerks", ["suppressor", "unknown"]]
];
private _backend = missionNamespace getVariable ["BN_KOTH_persistenceMemoryBackend", createHashMap];
_backend set [_knownUid, _raw];
missionNamespace setVariable ["BN_KOTH_persistenceMemoryBackend", _backend];
private _known = [_knownUid] call bn_koth_fnc_persistence_loadPlayer;
private _knownState = _known getOrDefault ["state", createHashMap];
[(_knownState getOrDefault ["level", -1]) isEqualTo ([12345] call bn_koth_fnc_progression_xp_getLevel), "Loaded level was not derived from XP."] call _assert;
[(_knownState getOrDefault ["cash", -1]) isEqualTo 4321, "Known cash did not load."] call _assert;
["vn_m1903" in (_knownState getOrDefault ["ownedWeapons", []]), "Known ownership did not load/canonicalize case."] call _assert;
[((_knownState getOrDefault ["weaponKills", createHashMap]) getOrDefault ["vn_m1903", -1]) isEqualTo 7, "Known weapon mastery did not load."] call _assert;
[(count (_knownState getOrDefault ["rentedWeapons", ["bad"]])) isEqualTo 0, "Session rentals were loaded from persistence."] call _assert;
[(_knownState getOrDefault ["ownedPerks", []]) isEqualTo ["suppressor"] && {(_knownState getOrDefault ["activePerks", []]) isEqualTo ["suppressor"]}, "Known perk state did not normalize unknown/duplicate IDs."] call _assert;

_knownState set ["cash", 9999];
private _again = [_knownUid] call bn_koth_fnc_persistence_loadPlayer;
[((_again getOrDefault ["state", createHashMap]) getOrDefault ["cash", -1]) isEqualTo 9999, "Repeated registration overwrote active loaded state."] call _assert;

_knownState set ["currentWeapons", ["vn_pickup_test"]];
_knownState set ["currentLoadout", [["vn_pickup_test"]]];
_knownState set ["pickedUpWeapons", ["vn_pickup_test"]];
_knownState set ["transientArsenalState", createHashMapFromArray [["weapon", "vn_pickup_test"]]];
private _projection = [_knownUid, _knownState] call bn_koth_fnc_persistence_projectPlayerState;
[isNil {_projection get "level"}, "Save projection persisted derived level."] call _assert;
[isNil {_projection get "rentedWeapons"}, "Save projection persisted rentals."] call _assert;
[isNil {_projection get "roundOnly"}, "Save projection included round state."] call _assert;
[isNil {_projection get "currentWeapons"}, "Save projection persisted current physical weapons."] call _assert;
[isNil {_projection get "currentLoadout"}, "Save projection persisted current physical loadout."] call _assert;
[isNil {_projection get "pickedUpWeapons"}, "Save projection persisted battlefield pickup state."] call _assert;
[isNil {_projection get "transientArsenalState"}, "Save projection persisted transient Arsenal state."] call _assert;
[(_projection getOrDefault ["ownedWeapons", []]) isEqualTo ["vn_m1903"], "Save projection omitted persistent ownership."] call _assert;
[(_projection getOrDefault ["ownedPerks", []]) isEqualTo ["suppressor"] && {(_projection getOrDefault ["activePerks", []]) isEqualTo ["suppressor"]}, "Save projection omitted persistent perk state."] call _assert;
[((_projection getOrDefault ["weaponKills", createHashMap]) getOrDefault ["vn_m1903", -1]) isEqualTo 7, "Save projection omitted persistent weapon mastery."] call _assert;

private _savedLoadout = [[], [], [], [], [], [], "", "", [], []];
private _savedKits = [["kit_test", "TEST KIT", _savedLoadout]];
private _savedSerialized = [_savedKits, "kit_test"] call bn_koth_fnc_persistence_serializeSavedKits;
private _savedParsed = [_savedSerialized getOrDefault ["value", ""]] call bn_koth_fnc_persistence_deserializeSavedKits;
[_savedSerialized getOrDefault ["success", false]
    && {_savedParsed getOrDefault ["success", false]}
    && {(_savedParsed getOrDefault ["kits", []]) isEqualTo _savedKits}
    && {(_savedParsed getOrDefault ["preferredId", ""]) isEqualTo "kit_test"}, "Saved kits did not round-trip through the restricted codec."] call _assert;
[!((["001002bad"] call bn_koth_fnc_persistence_deserializeSavedKits) getOrDefault ["success", true]), "Malformed saved-kit text was accepted."] call _assert;
[!(([[["bad id", "BAD", _savedLoadout]], ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Malformed saved-kit ID was serialized."] call _assert;
private _emptySavedParsed = ["-"] call bn_koth_fnc_persistence_deserializeSavedKits;
[_emptySavedParsed getOrDefault ["success", false] && {(count (_emptySavedParsed getOrDefault ["kits", ["bad"]])) isEqualTo 0}, "Empty saved-kit storage marker did not decode safely."] call _assert;
private _uninitializedSaved = [[], "", false] call bn_koth_fnc_persistence_serializeSavedKits;
[_uninitializedSaved getOrDefault ["success", false]
    && {(_uninitializedSaved getOrDefault ["value", ""]) isEqualTo "-"},
    "Uninitialized saved-kit state did not preserve the one-time migration marker."] call _assert;
private _tooManyKits = [];
private _savedKitLimit = (getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxCount")) max 1;
for "_index" from 0 to _savedKitLimit do {_tooManyKits pushBack [format ["kit_%1", _index], format ["KIT %1", _index], +_savedLoadout]};
[!(([_tooManyKits, ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Excessive saved-kit entries were serialized."] call _assert;
[!(([[["kit_a", "DUPLICATE", _savedLoadout], ["kit_b", "duplicate", _savedLoadout]], ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Duplicate saved-kit names were serialized."] call _assert;
[!(([[["kit_bad_name", "", _savedLoadout]], ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Empty saved-kit name was serialized."] call _assert;
[!(([[["kit_short", "SHORT", [[], []]]], ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Malformed Unit Loadout array was serialized."] call _assert;
private _executableLoadout = +_savedLoadout;
_executableLoadout set [6, "call compile preprocessFileLineNumbers 'payload.sqf';"];
[!(([[["kit_payload", "PAYLOAD", _executableLoadout]], ""] call bn_koth_fnc_persistence_serializeSavedKits) getOrDefault ["success", true]), "Executable-looking saved-kit string payload was accepted."] call _assert;

private _schemaTwo = [_knownUid, createHashMapFromArray [
    ["schemaVersion", 2], ["uid", _knownUid], ["xp", 77], ["cash", 88],
    ["ownedWeapons", ["vn_m1903"]], ["weaponKills", createHashMap],
    ["ownedPerks", []], ["activePerks", []]
]] call bn_koth_fnc_persistence_normalizePlayerState;
private _schemaTwoState = _schemaTwo getOrDefault ["state", createHashMap];
[(_schemaTwo getOrDefault ["code", ""]) isEqualTo "NORMALIZED_LEGACY"
    && {(_schemaTwoState getOrDefault ["schemaVersion", -1]) isEqualTo 3}
    && {(count (_schemaTwoState getOrDefault ["savedKits", ["bad"]])) isEqualTo 0}
    && {(_schemaTwoState getOrDefault ["xp", -1]) isEqualTo 77}, "Schema v2 did not normalize to v3 without losing unrelated progression."] call _assert;

private _mixedSaved = [_knownUid, createHashMapFromArray [
    ["schemaVersion", 3], ["uid", _knownUid], ["xp", 91], ["cash", 92],
    ["savedKits", [["good", "GOOD", _savedLoadout], ["bad id", "BAD", _savedLoadout]]]
]] call bn_koth_fnc_persistence_normalizePlayerState;
private _mixedState = _mixedSaved getOrDefault ["state", createHashMap];
[(count (_mixedState getOrDefault ["savedKits", []])) isEqualTo 1
    && {(_mixedState getOrDefault ["xp", -1]) isEqualTo 91}
    && {(_mixedState getOrDefault ["cash", -1]) isEqualTo 92}, "Malformed saved-kit entry damaged unrelated progression during normalization."] call _assert;

// Exercise the real server CRUD owner. Client-supplied legacy loadouts may be
// migrated, but CREATE/UPDATE always capture current intendedLoadout.
private _crudUid = "PERSIST_SAVED_KIT_CRUD";
private _serverLoadoutOne = +_savedLoadout;
_serverLoadoutOne set [6, "vn_server_headgear_one"];
private _serverLoadoutTwo = +_savedLoadout;
_serverLoadoutTwo set [6, "vn_server_headgear_two"];
private _crudState = [_crudUid] call bn_koth_fnc_persistence_createDefaultState;
private _crudByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
_crudByUid set [_crudUid, _crudState];
missionNamespace setVariable ["BN_KOTH_playerProgression", _crudByUid];
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMapFromArray [[_crudUid, createHashMapFromArray [["intendedLoadout", _serverLoadoutOne]]]]];
private _legacyKit = ["legacy", "LEGACY", _savedLoadout];
private _createdKit = [_crudUid, "CREATE", "server", "SERVER", [_legacyKit], "legacy"] call bn_koth_fnc_loadouts_manageSavedKits;
private _createdKits = _createdKit getOrDefault ["savedKits", []];
[_createdKit getOrDefault ["success", false]
    && {(count _createdKits) isEqualTo 2}
    && {((_createdKits select 1) select 2) isEqualTo _serverLoadoutOne}, "Saved-kit CREATE did not migrate legacy intent and capture the canonical server loadout."] call _assert;
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", createHashMapFromArray [[_crudUid, createHashMapFromArray [["intendedLoadout", _serverLoadoutTwo]]]]];
private _updatedKit = [_crudUid, "UPDATE", "server", "", [], ""] call bn_koth_fnc_loadouts_manageSavedKits;
private _updatedKits = _updatedKit getOrDefault ["savedKits", []];
private _updatedIndex = _updatedKits findIf {(_x select 0) isEqualTo "server"};
[_updatedKit getOrDefault ["success", false]
    && {_updatedIndex >= 0}
    && {((_updatedKits select _updatedIndex) select 2) isEqualTo _serverLoadoutTwo}, "Saved-kit UPDATE did not capture the new canonical intended loadout."] call _assert;
private _duplicateRename = [_crudUid, "RENAME", "server", "LEGACY", [], ""] call bn_koth_fnc_loadouts_manageSavedKits;
[!(_duplicateRename getOrDefault ["success", true]), "Saved-kit duplicate-name rename was accepted."] call _assert;
private _deletedKit = [_crudUid, "DELETE", "server", "", [], ""] call bn_koth_fnc_loadouts_manageSavedKits;
[_deletedKit getOrDefault ["success", false]
    && {((_deletedKit getOrDefault ["savedKits", []]) findIf {(_x select 0) isEqualTo "server"}) < 0}, "Saved-kit DELETE did not remove the authoritative entry."] call _assert;
private _crudStateAfterDelete = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) getOrDefault [_crudUid, createHashMap];
_crudStateAfterDelete set ["savedKits", []];
_crudStateAfterDelete set ["savedKitsInitialized", true];
private _crudByUidAfterDelete = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
_crudByUidAfterDelete set [_crudUid, _crudStateAfterDelete];
missionNamespace setVariable ["BN_KOTH_playerProgression", _crudByUidAfterDelete];
private _staleLegacyReplay = [_crudUid, "DELETE", "missing", "", [_legacyKit], "legacy"] call bn_koth_fnc_loadouts_manageSavedKits;
[!(_staleLegacyReplay getOrDefault ["success", true])
    && {(count (_staleLegacyReplay getOrDefault ["savedKits", ["bad"]])) isEqualTo 0},
    "A stale legacy cache resurrected saved kits after durable deletion."] call _assert;

private _ownedSerialized = [["vn_m1911", "VN_M1903"]] call bn_koth_fnc_persistence_serializeOwnedWeapons;
[_ownedSerialized getOrDefault ["success", false] && {(_ownedSerialized getOrDefault ["value", ""]) isEqualTo "vn_m1903,vn_m1911"}, "Owned weapons did not serialize deterministically."] call _assert;
private _ownedParsed = [_ownedSerialized getOrDefault ["value", ""]] call bn_koth_fnc_persistence_deserializeOwnedWeapons;
[_ownedParsed getOrDefault ["success", false] && {(_ownedParsed getOrDefault ["value", []]) isEqualTo ["vn_m1903", "vn_m1911"]}, "Owned weapons did not round-trip."] call _assert;
[!((["vn_m1903,,vn_m1911"] call bn_koth_fnc_persistence_deserializeOwnedWeapons) getOrDefault ["success", true]), "Malformed owned-weapon text was accepted."] call _assert;

private _perksSerialized = [["suppressor"]] call bn_koth_fnc_persistence_serializePerkIds;
private _perksParsed = [_perksSerialized getOrDefault ["value", ""]] call bn_koth_fnc_persistence_deserializePerkIds;
[_perksSerialized getOrDefault ["success", false] && {_perksParsed getOrDefault ["success", false]} && {(_perksParsed getOrDefault ["value", []]) isEqualTo ["suppressor"]}, "Perk IDs did not round-trip."] call _assert;
[!((["suppressor,suppressor"] call bn_koth_fnc_persistence_deserializePerkIds) getOrDefault ["success", true]), "Duplicate persisted perk IDs were accepted by the restricted codec."] call _assert;

private _killsSerialized = [createHashMapFromArray [["vn_m1911", 2], ["vn_m1903", 7]]] call bn_koth_fnc_persistence_serializeWeaponKills;
[_killsSerialized getOrDefault ["success", false] && {(_killsSerialized getOrDefault ["value", ""]) isEqualTo "vn_m1903=7,vn_m1911=2"}, "Weapon kills did not serialize deterministically."] call _assert;
private _killsParsed = [_killsSerialized getOrDefault ["value", ""]] call bn_koth_fnc_persistence_deserializeWeaponKills;
private _roundTripKills = _killsParsed getOrDefault ["value", createHashMap];
[_killsParsed getOrDefault ["success", false] && {(_roundTripKills getOrDefault ["vn_m1903", -1]) isEqualTo 7} && {(_roundTripKills getOrDefault ["vn_m1911", -1]) isEqualTo 2}, "Weapon kills did not round-trip."] call _assert;
[!((["vn_m1903=-1"] call bn_koth_fnc_persistence_deserializeWeaponKills) getOrDefault ["success", true]), "Malformed weapon-kill text was accepted."] call _assert;

missionNamespace setVariable ["BN_KOTH_persistenceBackend", "EXTDB3"];
private _invalidNumericSave = ["76561198000000000", createHashMapFromArray [
    ["schemaVersion", 3], ["xp", "bad"], ["cash", 1000], ["ownedWeapons", []], ["weaponKills", createHashMap], ["ownedPerks", []], ["activePerks", []], ["savedKits", []]
]] call bn_koth_fnc_persistence_backendSavePlayer;
[!(_invalidNumericSave getOrDefault ["success", true]) && {(_invalidNumericSave getOrDefault ["code", ""]) isEqualTo "INVALID_PERSISTENT_NUMERIC_FIELDS"}, "Malformed persistent numeric fields reached extDB3."] call _assert;
missionNamespace setVariable ["BN_KOTH_persistenceBackend", "MEMORY"];

private _extdbValid = ["[1,[[""76561198000000000"",3,12,34,""vn_m1903"",""vn_m1903=7"",""suppressor"",""suppressor"",""-""]]]"] call bn_koth_fnc_persistence_parseExtdbResponse;
[_extdbValid getOrDefault ["success", false] && {(count (_extdbValid getOrDefault ["rows", []])) isEqualTo 1}, "Valid extDB3 response was rejected."] call _assert;
[!((["[0,""Error MariaDBQueryException Exception""]"] call bn_koth_fnc_persistence_parseExtdbResponse) getOrDefault ["success", true]), "extDB3 error response was accepted."] call _assert;
[!((["not an array"] call bn_koth_fnc_persistence_parseExtdbResponse) getOrDefault ["success", true]), "Malformed extDB3 response was accepted."] call _assert;

private _legacy = [_knownUid, createHashMapFromArray [["uid", _knownUid], ["xp", 5]]] call bn_koth_fnc_persistence_normalizePlayerState;
[(_legacy getOrDefault ["code", ""]) isEqualTo "NORMALIZED_LEGACY", "Missing schemaVersion was not handled as legacy."] call _assert;
private _future = [_knownUid, createHashMapFromArray [["schemaVersion", 4], ["uid", _knownUid]]] call bn_koth_fnc_persistence_normalizePlayerState;
[!(_future getOrDefault ["success", true]) && {(_future getOrDefault ["code", ""]) isEqualTo "UNSUPPORTED_FUTURE_SCHEMA"}, "Future schema did not fail closed."] call _assert;
private _malformed = [_knownUid, createHashMapFromArray [["schemaVersion", 1], ["uid", _knownUid], ["xp", "bad"], ["cash", -4], ["ownedWeapons", "bad"], ["weaponKills", []]]] call bn_koth_fnc_persistence_normalizePlayerState;
private _malformedState = _malformed getOrDefault ["state", createHashMap];
[_malformed getOrDefault ["success", false] && {(_malformedState getOrDefault ["xp", -1]) isEqualTo 0} && {(_malformedState getOrDefault ["cash", -1]) isEqualTo 1000}, "Malformed fields did not normalize safely."] call _assert;

private _loadedMarkers = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
_loadedMarkers set ["PERSIST_FALLBACK", "SESSION_FALLBACK"];
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", _loadedMarkers];
private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
_progressionByUid set ["PERSIST_FALLBACK", ["PERSIST_FALLBACK"] call bn_koth_fnc_persistence_createDefaultState];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];
private _blockedFallbackSave = ["PERSIST_FALLBACK", "test"] call bn_koth_fnc_persistence_savePlayer;
[!(_blockedFallbackSave getOrDefault ["success", true]) && {(_blockedFallbackSave getOrDefault ["code", ""]) isEqualTo "SESSION_FALLBACK_WRITE_BLOCKED"}, "Session fallback was allowed to overwrite durable state."] call _assert;

[_knownUid, "test"] call bn_koth_fnc_persistence_markDirty;
[!(isNil {(missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap]) get _knownUid}), "Mutation did not mark persistence dirty."] call _assert;
missionNamespace setVariable ["BN_KOTH_persistenceTestFailSave", true];
private _failedSave = [_knownUid, "test_failure"] call bn_koth_fnc_persistence_savePlayer;
[!(_failedSave getOrDefault ["success", true]) && {!(isNil {(missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap]) get _knownUid})}, "Failed save did not remain dirty."] call _assert;
missionNamespace setVariable ["BN_KOTH_persistenceTestFailSave", false];
private _saved = [_knownUid, "test_success"] call bn_koth_fnc_persistence_savePlayer;
[_saved getOrDefault ["success", false] && {isNil {(missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap]) get _knownUid}}, "Successful save did not clear dirty state."] call _assert;

private _remoteCfg = missionConfigFile >> "CfgRemoteExec" >> "Functions";
[!(isClass (_remoteCfg >> "bn_koth_fnc_persistence_loadPlayer")) && {!(isClass (_remoteCfg >> "bn_koth_fnc_persistence_savePlayer"))}, "Persistence functions were exposed to clients through CfgRemoteExec."] call _assert;
private _loadoutRequestSource = preprocessFileLineNumbers "functions\loadouts\fn_request.sqf";
private _stateReceiverSource = preprocessFileLineNumbers "functions\ui\state\fn_receiveState.sqf";
[(_loadoutRequestSource find 'uiNamespace getVariable ["BN_KOTH_savedKitsServerSynced"') >= 0
    && {(_stateReceiverSource find 'uiNamespace setVariable ["BN_KOTH_savedKitsServerSynced"') >= 0},
    "Saved-kit server synchronization was not scoped to the current mission connection."] call _assert;

{
    private _value = _backup get _x;
    if (isNil "_value") then {
        missionNamespace setVariable [_x, nil]
    } else {
        missionNamespace setVariable [_x, _value]
    };
} forEach _variables;

_failures

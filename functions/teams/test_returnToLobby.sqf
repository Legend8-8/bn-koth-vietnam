/*
    File: test_returnToLobby.sqf
    Author: Legend
    Description: Focused server-side debug checks for the RETURN TO LOBBY
        guard/rejection paths in fn_returnDeployedPlayerToLobby.sqf. These
        checks intentionally stay before the network representation handoff
        (fn_transferRepresentation.sqf waits on a real client's owner match),
        so the full success path is NOT exercised here and requires runtime
        dedicated/multiplayer acceptance testing instead of a unit test.
    Execution: Server (debug console / call compile preprocessFileLineNumbers)
    Parameters:
        None
    Returns:
        None
    Public: No
*/

if (!isServer) exitWith {["test_returnToLobby: server only", "ERROR"] call bn_koth_fnc_common_log};

private _failures = [];
private _assert = {
    params ["_condition", "_label"];
    if (!_condition) then {
        _failures pushBack _label;
        [format ["[FAIL] %1", _label], "ERROR"] call bn_koth_fnc_common_log;
    } else {
        [format ["[PASS] %1", _label]] call bn_koth_fnc_common_log;
    };
};

private _savedRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _savedParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _savedRoundState = [] call bn_koth_fnc_round_getState;

// 1. Unregistered/unknown UID must fail closed.
[
    ([""] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "Empty UID is rejected"
] call _assert;
[
    (["TEST_UID_NOT_REGISTERED_0001"] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "Unregistered UID is rejected"
] call _assert;

private _testUid = "TEST_UID_RETURN_TO_LOBBY_0001";
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];

// 2. Already-LOBBY state is an idempotent no-op success (repeat-click safety).
private _lobbyRecord = createHashMap;
_lobbyRecord set ["ownerId", 2];
_lobbyRecord set ["state", "LOBBY"];
_records set [_testUid, _lobbyRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[
    ([_testUid] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo true,
    "Already-LOBBY request is a safe no-op success"
] call _assert;
[
    ((missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]) get _testUid) get "state" isEqualTo "LOBBY",
    "Already-LOBBY request does not mutate state"
] call _assert;

// 3. TEAM_SELECTED must be rejected here (owned by fn_returnSelectedPlayerToLobby, not this function).
private _teamSelectedRecord = createHashMap;
_teamSelectedRecord set ["ownerId", 2];
_teamSelectedRecord set ["state", "TEAM_SELECTED"];
_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_records set [_testUid, _teamSelectedRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[
    ([_testUid] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "TEAM_SELECTED state is rejected (wrong owner path)"
] call _assert;

// 4. RESPAWNING must be rejected (dead/respawning edge case fails safely).
private _respawningRecord = createHashMap;
_respawningRecord set ["ownerId", 2];
_respawningRecord set ["state", "RESPAWNING"];
_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_records set [_testUid, _respawningRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[
    ([_testUid] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "RESPAWNING state is rejected"
] call _assert;

// 5. ACTIVE state is rejected outside PREPARING/ACTIVE round phases (e.g. WAITING/ENDING/RESETTING).
private _activeRecord = createHashMap;
_activeRecord set ["ownerId", 2];
_activeRecord set ["state", "ACTIVE"];
_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_records set [_testUid, _activeRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
if !(_savedRoundState isEqualTo "WAITING") then {
    ["BN_KOTH_roundState", "WAITING"] call bn_koth_fnc_common_publicState;
};
[
    ([_testUid] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "ACTIVE state is rejected during WAITING round phase"
] call _assert;

// 6. Invalid owner (<=0) fails closed even with an otherwise-valid deployed state.
private _noOwnerRecord = createHashMap;
_noOwnerRecord set ["ownerId", -1];
_noOwnerRecord set ["state", "ACTIVE"];
_records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
_records set [_testUid, _noOwnerRecord];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
[
    ([_testUid] call bn_koth_fnc_teams_returnDeployedPlayerToLobby) isEqualTo false,
    "Invalid owner is rejected"
] call _assert;

// Restore prior authoritative state so this debug script leaves no residue.
missionNamespace setVariable ["BN_KOTH_playerRecords", _savedRecords];
missionNamespace setVariable ["BN_KOTH_activeParticipants", _savedParticipants];
["BN_KOTH_roundState", _savedRoundState] call bn_koth_fnc_common_publicState;

if ((count _failures) isEqualTo 0) then {
    ["test_returnToLobby: ALL GUARD-PATH CHECKS PASSED"] call bn_koth_fnc_common_log;
} else {
    [format ["test_returnToLobby: %1 CHECK(S) FAILED: %2", count _failures, _failures], "ERROR"] call bn_koth_fnc_common_log;
};

[
    "test_returnToLobby: the ACTIVE-state success path (rental cleanup + assignLobbyRepresentation + activeParticipants removal) requires a connected client whose owner matches fn_transferRepresentation's waitUntil, and must be verified on a dedicated/hosted server with a real player, not this offline script."
] call bn_koth_fnc_common_log;

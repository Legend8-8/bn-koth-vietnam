/*
    File: fn_flushPlayer.sqf
    Author: Legend
    Description: Flushes queued career batches while preserving lifetime/hourly stage progress.
    Execution: Server
    Public: No
*/
params [["_uid", "", [""]], ["_reason", "flush", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_FLUSH"]]};
private _identities = missionNamespace getVariable ["BN_KOTH_careerIdentityPending", createHashMap];
private _identity = _identities getOrDefault [_uid, ""];
private _identityResult = createHashMapFromArray [["success", true], ["code", "IDENTITY_CLEAN"]];
if !(_identity isEqualTo "") then {
    _identityResult = ["upsertCareerIdentity", [_uid, _identity]] call bn_koth_fnc_persistence_extdbCall;
};
if !(_identityResult getOrDefault ["success", false]) exitWith {_identityResult};
if !(_identity isEqualTo "") then {_identities deleteAt _uid; missionNamespace setVariable ["BN_KOTH_careerIdentityPending", _identities]};
private _pending = missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap];
private _batches = _pending getOrDefault [_uid, []];
if ((count _batches) == 0) exitWith {createHashMapFromArray [["success", true], ["code", "NOT_DIRTY"]]};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {createHashMapFromArray [["success", false], ["code", "BACKEND_UNAVAILABLE"]]};

private _fields = ["kills", "deaths", "wins", "roundsPlayed", "objectiveContribution", "highestKillStreak", "totalXpEarned", "timePlayedSeconds"];
private _failed = createHashMap;
while {(count _batches) > 0 && {(count _failed) == 0}} do {
    private _batch = _batches select 0;
    private _d = _batch get "deltas";
    private _params = [_uid];
    {_params pushBack (_d getOrDefault [_x, 0])} forEach _fields;
    if ((_batch get "stage") isEqualTo "BOTH") then {
        private _lifetime = ["updateCareerTotals", _params] call bn_koth_fnc_persistence_extdbCall;
        if !(_lifetime getOrDefault ["success", false]) then {_failed = _lifetime} else {_batch set ["stage", "HOURLY"]};
    };
    if ((count _failed) == 0 && {(_batch get "stage") isEqualTo "HOURLY"}) then {
        private _hourly = ["updateCareerHourly", _params] call bn_koth_fnc_persistence_extdbCall;
        if !(_hourly getOrDefault ["success", false]) then {_failed = _hourly} else {_batches deleteAt 0};
    };
};
if ((count _batches) == 0) then {_pending deleteAt _uid} else {_pending set [_uid, _batches]};
missionNamespace setVariable ["BN_KOTH_careerPending", _pending];
if ((count _failed) > 0) exitWith {
    [format ["Career flush failed UID=%1 reason=%2 stage=%3 code=%4", _uid, _reason, (_batches select 0) getOrDefault ["stage", ""], _failed getOrDefault ["code", "UNKNOWN"]], "ERROR"] call bn_koth_fnc_common_log;
    createHashMapFromArray [["success", false], ["code", _failed getOrDefault ["code", "CAREER_FLUSH_FAILED"]]]
};
createHashMapFromArray [["success", true], ["code", "CAREER_FLUSHED"]]

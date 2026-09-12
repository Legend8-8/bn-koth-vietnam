/*
    File: fn_mutate.sqf
    Author: Legend
    Description: Queues one server-authoritative career delta batch for paired lifetime/hourly persistence.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: Career deltas <HASHMAP>, 2: Reason <STRING>
    Returns: Accepted result <HASHMAP>
    Public: Yes
*/
params [["_uid", "", [""]], ["_deltas", createHashMap, [createHashMap]], ["_reason", "", [""]]];
if (!isServer) exitWith {createHashMapFromArray [["success", false], ["code", "NOT_SERVER"]]};
if (_uid isEqualTo "" || {_reason isEqualTo ""}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_MUTATION"]]};

private _fields = ["kills", "deaths", "wins", "roundsPlayed", "objectiveContribution", "highestKillStreak", "totalXpEarned", "timePlayedSeconds"];
private _normalized = createHashMap;
private _hasDelta = false;
{
    private _value = _deltas getOrDefault [_x, 0];
    if !(_value isEqualType 0 && {finite _value} && {_value >= 0} && {_value isEqualTo floor _value}) exitWith {_normalized = createHashMap};
    _normalized set [_x, _value];
    if (_value > 0) then {_hasDelta = true};
} forEach _fields;
if ((count _normalized) != count _fields || {!_hasDelta}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_DELTAS"]]};

private _pending = missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap];
private _batches = _pending getOrDefault [_uid, []];
private _mergeIndex = _batches findIf {(_x getOrDefault ["stage", ""]) isEqualTo "BOTH"};
if (_mergeIndex < 0) then {
    _batches pushBack (createHashMapFromArray [["stage", "BOTH"], ["deltas", _normalized], ["reasons", [_reason]]]);
} else {
    private _batch = _batches select _mergeIndex;
    private _current = _batch get "deltas";
    {
        private _incoming = _normalized get _x;
        private _next = if (_x isEqualTo "highestKillStreak") then {(_current getOrDefault [_x, 0]) max _incoming} else {(_current getOrDefault [_x, 0]) + _incoming};
        _current set [_x, _next];
    } forEach _fields;
    (_batch get "reasons") pushBackUnique _reason;
};
_pending set [_uid, _batches];
missionNamespace setVariable ["BN_KOTH_careerPending", _pending];
createHashMapFromArray [["success", true], ["code", "CAREER_QUEUED"], ["uid", _uid]]

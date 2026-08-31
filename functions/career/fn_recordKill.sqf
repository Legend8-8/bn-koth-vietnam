/*
    File: fn_recordKill.sqf
    Author: Legend
    Description: Projects the already accepted canonical kill record and round streak into career deltas.
    Execution: Server
    Public: No
*/
params [["_killRecord", createHashMap, [createHashMap]]];
if (!isServer || {(count _killRecord) == 0} || {!(_killRecord getOrDefault ["roundActive", false])}) exitWith {false};
private _eventKey = _killRecord getOrDefault ["eventKey", ""];
if (_eventKey isEqualTo "") exitWith {false};
private _seen = missionNamespace getVariable ["BN_KOTH_careerSeenKillEvents", []];
if (_eventKey in _seen) exitWith {false};
_seen pushBack _eventKey;
if ((count _seen) > 1024) then {_seen deleteRange [0, (count _seen) - 1024]};
missionNamespace setVariable ["BN_KOTH_careerSeenKillEvents", _seen];
private _victimUid = _killRecord getOrDefault ["victimUid", ""];
if !(_victimUid isEqualTo "") then {[_victimUid, createHashMapFromArray [["deaths", 1]], "death"] call bn_koth_fnc_career_mutate};
if (_killRecord getOrDefault ["validPvp", false] && {!(_killRecord getOrDefault ["suicide", false])} && {!(_killRecord getOrDefault ["teamkill", false])}) then {
    private _killerUid = _killRecord getOrDefault ["killerUid", ""];
    if !(_killerUid isEqualTo "") then {
        private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
        private _killerStats = _stats getOrDefault [_killerUid, createHashMap];
        private _best = _killerStats getOrDefault ["bestStreak", 0];
        [_killerUid, createHashMapFromArray [["kills", 1], ["highestKillStreak", _best]], "valid_pvp_kill"] call bn_koth_fnc_career_mutate;
    };
};
true

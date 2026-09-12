/* File: fn_accumulatePlaytime.sqf | Author: Legend | Description: Converts connected session elapsed time into bounded career deltas. | Execution: Server | Public: No */
params [["_uid", "", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {0};
private _sessions = missionNamespace getVariable ["BN_KOTH_careerSessions", createHashMap];
private _last = _sessions getOrDefault [_uid, -1];
if (_last < 0) exitWith {0};
private _seconds = floor ((serverTime - _last) max 0);
if (_seconds <= 0) exitWith {0};
_sessions set [_uid, _last + _seconds];
missionNamespace setVariable ["BN_KOTH_careerSessions", _sessions];
[_uid, createHashMapFromArray [["timePlayedSeconds", _seconds]], "playtime"] call bn_koth_fnc_career_mutate;
_seconds

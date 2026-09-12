/* File: fn_flushAll.sqf | Author: Legend | Description: Flushes all bounded pending career batches. | Execution: Server | Public: No */
params [["_reason", "flush_all", [""]]];
if (!isServer) exitWith {[]};
private _pending = missionNamespace getVariable ["BN_KOTH_careerPending", createHashMap];
private _identities = missionNamespace getVariable ["BN_KOTH_careerIdentityPending", createHashMap];
private _results = [];
private _uids = +(keys _pending);
{_uids pushBackUnique _x} forEach +(keys _identities);
{_results pushBack ([_x, _reason] call bn_koth_fnc_career_flushPlayer)} forEach _uids;
_results

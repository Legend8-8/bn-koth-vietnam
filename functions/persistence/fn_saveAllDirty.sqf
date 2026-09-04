/*
    File: fn_saveAllDirty.sqf
    Author: Legend
    Description: Flushes the bounded set of dirty persistent player records.
    Execution: Server
    Public: No
*/

params [["_reason", "flush", [""]]];

if (!isServer) exitWith {[]};
private _dirty = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
if !(_dirty isEqualType createHashMap) exitWith {[]};

private _results = [];
{
    _results pushBack ([_x, _reason] call bn_koth_fnc_persistence_savePlayer);
} forEach +(keys _dirty);
_results

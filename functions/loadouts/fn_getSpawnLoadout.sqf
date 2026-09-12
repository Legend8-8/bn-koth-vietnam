/*
    File: fn_getSpawnLoadout.sqf
    Author: Legend
    Description: Revalidates the session spawn candidate through saved-kit LOAD,
        otherwise resolves the faction starter. Does not mutate intended state.
    Execution: Server (unscheduled; no client wait)
    Parameters: 0: Connected player object <OBJECT>
    Returns: Spawn result with success and loadout <HASHMAP>
    Public: No
*/
params [["_player", objNull, [objNull]]];
if (!isServer || {isNull _player}) exitWith {createHashMap};
private _uid = getPlayerUID _player;
private _record = (missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]) getOrDefault [_uid, createHashMap];
private _side = _record getOrDefault ["assignedSide", sideUnknown];
private _candidate = _record getOrDefault ["preferredSpawnCandidate", []];
private _result = createHashMap;
if ((_record getOrDefault ["ownerId", -1]) isEqualTo (owner _player) && {!(_candidate isEqualTo [])}) then {
    _result = [_player, createHashMapFromArray [["mutation", createHashMapFromArray [
        ["op", "load_local_kit"], ["savedLoadout", +_candidate]
    ]]]] call bn_koth_fnc_loadouts_validateLoadout;
};
if (_result getOrDefault ["success", false]) exitWith {
    _result set ["loadout", +(_result get "validatedLoadout")];
    _result
};
// A side/entitlement failure must not erase the preference or delay spawning.
[_side] call bn_koth_fnc_loadouts_getStarterLoadout

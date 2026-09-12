/*
    File: test_spawnPreference.sqf
    Author: Legend
    Description: Focused spawn selection checks using the real saved-kit validator.
        Run on an isolated test server with a connected WEST starter-entitled player.
        Restores the candidate and side; never equips or persists equipment.
    Execution: Server debug console (unscheduled)
    Parameters: 0: Connected WEST test player <OBJECT>
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/
params [["_player", objNull, [objNull]]];
if (!isServer || {isNull _player} || {!isPlayer _player}) exitWith {["Connected server test player required."]};
private _uid = getPlayerUID _player;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo west) exitWith {["WEST test player required."]};
private _failures = [];
private _check = {params ["_label", "_ok"]; if (!_ok) then {_failures pushBack _label}};
private _originalCandidate = _record getOrDefault ["preferredSpawnCandidate", []];
private _originalOwner = _record get "ownerId";
private _intended = str (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap]);
private _starter = ([west] call bn_koth_fnc_loadouts_getStarterLoadout) getOrDefault ["loadout", []];
private _saved = +_starter;
// Make the preferred kit observably different without granting extra equipment.
(_saved select 3) set [1, []];
(_saved select 4) set [1, []];
private _validation = [_player, createHashMapFromArray [["mutation", createHashMapFromArray [["op", "load_local_kit"], ["savedLoadout", _saved]]]]] call bn_koth_fnc_loadouts_validateLoadout;
["Test candidate passes the normal LOAD validator", _validation getOrDefault ["success", false]] call _check;
_record deleteAt "preferredSpawnCandidate";
["Absent preference selects starter", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _starter] call _check;
if (_validation getOrDefault ["success", false]) then {
    private _candidate = +(_validation get "validatedLoadout");
    _record set ["preferredSpawnCandidate", _candidate];
    ["Valid preference selected", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _candidate] call _check;
    _record set ["assignedSide", east];
    private _eastStarter = ([east] call bn_koth_fnc_loadouts_getStarterLoadout) getOrDefault ["loadout", []];
    ["Side change selects faction starter", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _eastStarter] call _check;
    ["Side failure preserves candidate", (_record get "preferredSpawnCandidate") isEqualTo _candidate] call _check;
    _record set ["assignedSide", west];
    ["Switching back revalidates candidate", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _candidate] call _check;
    private _invalid = +_candidate;
    (_invalid select 0) set [0, "bn_koth_nonexistent_weapon"];
    _record set ["preferredSpawnCandidate", _invalid];
    ["Invalid current candidate selects starter", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _starter] call _check;
    _record set ["preferredSpawnCandidate", _candidate];
    _record set ["ownerId", -1];
    ["Stale owner cannot use candidate", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _starter] call _check;
};
_record set ["ownerId", _originalOwner];
_record set ["assignedSide", west];
_record deleteAt "preferredSpawnCandidate";
["Cleared session requires resubmission", (([_player] call bn_koth_fnc_loadouts_getSpawnLoadout) getOrDefault ["loadout", []]) isEqualTo _starter] call _check;
["Selection never changes intended state", (str (missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap])) isEqualTo _intended] call _check;
if !(_originalCandidate isEqualTo []) then {_record set ["preferredSpawnCandidate", _originalCandidate]};
diag_log format ["[KOTH TEST] spawn preference failures: %1", _failures];
_failures

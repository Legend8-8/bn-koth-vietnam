/*
    File: fn_completeCleanup.sqf
    Author: Legend
    Description: Commits one server-derived perk cleanup only after the server
        observes the exact sanitized loadout on the currently owned player unit.
    Execution: Server
    Public: No
*/
params [
    ["_uid", "", [""]],
    ["_token", "", [""]],
    ["_playerObj", objNull, [objNull]],
    ["_observedOverride", [], [[]]]
];
private _result = {
    params ["_success", "_code", "_message"];
    createHashMapFromArray [["success", _success], ["code", _code], ["message", _message], ["perkId", "suppressor"], ["operation", "DEACTIVATE_CLEANUP"], ["committed", _success]]
};
if (!isServer) exitWith {[false, "NOT_SERVER", "Perk cleanup completion is server-authoritative."] call _result};
private _pendingByUid = missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];
if !(_pendingByUid isEqualType createHashMap) then {_pendingByUid = createHashMap};
private _pending = _pendingByUid getOrDefault [_uid, createHashMap];
if !(_pending isEqualType createHashMap && {(count _pending) > 0}) exitWith {[false, "NO_PENDING_CLEANUP", "No suppressor cleanup is pending; the perk remains active."] call _result};
if (_token isEqualTo "" || {!(_token isEqualTo (_pending getOrDefault ["token", ""]))}) exitWith {[false, "STALE_CLEANUP", "Suppressor cleanup acknowledgement is stale; the perk remains active."] call _result};
if (serverTime > (_pending getOrDefault ["expiresAt", -1])) exitWith {
    _pendingByUid deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pendingByUid];
    [false, "STALE_CLEANUP", "Suppressor cleanup acknowledgement expired; the perk remains active."] call _result
};
if (isNull _playerObj && {(count _observedOverride) isEqualTo 0}) exitWith {[false, "PLAYER_NOT_REGISTERED", "Player ownership is unavailable; the perk remains active."] call _result};
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if ((_record getOrDefault ["ownerId", -1]) isNotEqualTo (_pending getOrDefault ["ownerId", -2])) exitWith {[false, "STALE_CLEANUP", "Player ownership changed; the perk remains active."] call _result};

private _loadoutRegistry = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
private _loadoutState = _loadoutRegistry getOrDefault [_uid, createHashMap];
private _original = _pending getOrDefault ["originalIntendedLoadout", []];
private _sanitized = _pending getOrDefault ["sanitizedLoadout", []];
if !((_loadoutState getOrDefault ["intendedLoadout", []]) isEqualTo _original) exitWith {[false, "STALE_CLEANUP", "Managed loadout changed during cleanup; the perk remains active."] call _result};
private _observed = if ((count _observedOverride) > 0) then {+_observedOverride} else {getUnitLoadout _playerObj};
if !(_observed isEqualTo _sanitized) exitWith {[false, "CLEANUP_NOT_OBSERVED", "The server has not confirmed suppressor cleanup; the perk remains active."] call _result};
if ((count ([_observed] call bn_koth_fnc_progression_perks_findSuppressors)) > 0) exitWith {[false, "SUPPRESSOR_CLEANUP_INCOMPLETE", "Suppressors remain in the managed loadout; the perk remains active."] call _result};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _progression getOrDefault [_uid, createHashMap];
private _active = +(_state getOrDefault ["activePerks", []]);
if !("suppressor" in _active) exitWith {[false, "NOT_ACTIVE", "Suppressor is no longer active."] call _result};

_loadoutState set ["intendedLoadout", +_sanitized];
_loadoutRegistry set [_uid, _loadoutState];
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", _loadoutRegistry];
_active deleteAt (_active find "suppressor");
_state set ["activePerks", _active];
_progression set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progression];
_pendingByUid deleteAt _uid;
missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pendingByUid];
[_uid, "perk_activation"] call bn_koth_fnc_persistence_markDirty;
[_uid, "perk_activation", 0, "suppressor"] call bn_koth_fnc_progression_publishUpdate;
private _success = [true, "PERK_DEACTIVATED", "Suppressor cleanup was confirmed and the perk was deactivated."] call _result;
_success set ["managedLoadout", +_sanitized];
_success

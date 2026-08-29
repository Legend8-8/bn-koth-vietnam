/*
    File: fn_setActive.sqf
    Author: Legend
    Description: Validates and commits one authoritative perk activation/deactivation.
    Execution: Server
    Public: No
*/
params [["_uid", "", [""]], ["_perkId", "", [""]], ["_operation", "", [""]]];
private _id = toLower _perkId;
private _op = toUpper _operation;
private _reject = {
    params ["_code", "_message", ["_extra", createHashMap, [createHashMap]]];
    private _r = createHashMapFromArray [["success", false], ["code", _code], ["message", _message], ["perkId", _id], ["operation", _op], ["committed", false]];
    {_r set [_x, _extra get _x]} forEach keys _extra;
    _r
};
if (!isServer) exitWith {["NOT_SERVER", "Perk activation is server-authoritative."] call _reject};
if !(_op in ["ACTIVATE", "DEACTIVATE", "DEACTIVATE_CONFIRM"]) exitWith {["INVALID_OPERATION", "Perk operation is invalid."] call _reject};
private _metadata = [_id] call bn_koth_fnc_progression_perks_getConfig;
if !(_metadata getOrDefault ["success", false] && {_metadata getOrDefault ["available", false]}) exitWith {["UNKNOWN_PERK", "That perk is unavailable."] call _reject};
private _registry = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _registry getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE", "Player progression is unavailable."] call _reject};
private _owned = _state getOrDefault ["ownedPerks", []];
private _activeRaw = _state getOrDefault ["activePerks", []];
if !(_owned isEqualType [] && {_activeRaw isEqualType []}) exitWith {["PROGRESSION_INVALID", "Perk progression state is invalid."] call _reject};
private _active = +_activeRaw;
if !(_id in _owned) exitWith {["PERK_NOT_OWNED", "You do not own that perk."] call _reject};

if (_op isEqualTo "ACTIVATE") exitWith {
    if (_id in _active) exitWith {["ALREADY_ACTIVE", "That perk is already active."] call _reject};
    private _maximum = _metadata getOrDefault ["maxActivePerks", 3];
    if ((count _active) >= _maximum) exitWith {["ACTIVE_PERK_LIMIT", format ["Only %1 perks may be active.", _maximum]] call _reject};
    _active pushBack _id;
    _state set ["activePerks", _active];
    _registry set [_uid, _state];
    missionNamespace setVariable ["BN_KOTH_playerProgression", _registry];
    [_uid, "perk_activation"] call bn_koth_fnc_persistence_markDirty;
    [_uid, "perk_activation", 0, _id] call bn_koth_fnc_progression_publishUpdate;
    createHashMapFromArray [["success", true], ["code", "PERK_ACTIVATED"], ["message", "Perk activated."], ["perkId", _id], ["operation", _op], ["committed", true], ["activePerks", _active]]
};

if !(_id in _active) exitWith {["NOT_ACTIVE", "That perk is not active."] call _reject};
private _loadoutRegistry = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
private _loadoutState = _loadoutRegistry getOrDefault [_uid, createHashMap];
private _loadout = _loadoutState getOrDefault ["intendedLoadout", []];
private _suppressors = if (_id isEqualTo "suppressor") then {[_loadout] call bn_koth_fnc_progression_perks_findSuppressors} else {[]};

if ((_op isEqualTo "DEACTIVATE") && {(count _suppressors) > 0}) exitWith {
    ["CONFIRMATION_REQUIRED", "Suppressor perk is currently in use. Deactivating it will remove all suppressors from your equipped weapons and carried inventory. Continue?", createHashMapFromArray [["confirmationRequired", true], ["suppressors", _suppressors]]] call _reject
};
if ((_op isEqualTo "DEACTIVATE_CONFIRM") && {(count _suppressors) > 0}) exitWith {
    private _clean = [_loadout] call bn_koth_fnc_progression_perks_removeSuppressors;
    if ((count _clean) < 10 || {(count ([_clean] call bn_koth_fnc_progression_perks_findSuppressors)) > 0}) exitWith {["SUPPRESSOR_CLEANUP_FAILED", "Suppressors could not be removed safely; the perk remains active."] call _reject};

    private _pendingByUid = missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];
    if !(_pendingByUid isEqualType createHashMap) then {_pendingByUid = createHashMap};
    private _existing = _pendingByUid getOrDefault [_uid, createHashMap];
    private _now = serverTime;
    if (_existing isEqualType createHashMap && {(_existing getOrDefault ["expiresAt", -1]) >= _now}) exitWith {
        createHashMapFromArray [
            ["success", true], ["code", "SUPPRESSOR_CLEANUP_REQUIRED"],
            ["message", "Suppressor cleanup is already pending."], ["perkId", _id],
            ["operation", _op], ["committed", false],
            ["cleanupToken", _existing getOrDefault ["token", ""]],
            ["cleanupValidation", _existing getOrDefault ["validation", createHashMap]]
        ]
    };
    if (_existing isEqualType createHashMap) then {_pendingByUid deleteAt _uid};

    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    private _record = _records getOrDefault [_uid, createHashMap];
    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) exitWith {["PLAYER_NOT_REGISTERED", "Player ownership is unavailable; the perk remains active."] call _reject};

    private _counter = (missionNamespace getVariable ["BN_KOTH_perkCleanupCounter", 0]) + 1;
    missionNamespace setVariable ["BN_KOTH_perkCleanupCounter", _counter];
    private _token = format ["%1-%2-%3", _uid, _counter, floor (_now * 1000)];
    private _timeout = (getNumber (missionConfigFile >> "CfgBnKothPerks" >> "suppressorCleanupAckTimeoutSeconds")) max 1;
    private _validation = createHashMapFromArray [
        ["success", true], ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"],
        ["validatedLoadout", +_clean], ["loadoutId", "perk_suppressor_cleanup"]
    ];
    _pendingByUid set [_uid, createHashMapFromArray [
        ["token", _token], ["perkId", _id], ["ownerId", _ownerId],
        ["originalIntendedLoadout", +_loadout], ["sanitizedLoadout", +_clean],
        ["validation", _validation], ["expiresAt", _now + _timeout]
    ]];
    missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pendingByUid];
    createHashMapFromArray [
        ["success", true], ["code", "SUPPRESSOR_CLEANUP_REQUIRED"],
        ["message", "Applying suppressor cleanup before deactivation."], ["perkId", _id],
        ["operation", _op], ["committed", false], ["cleanupToken", _token],
        ["cleanupValidation", _validation]
    ]
};

_active deleteAt (_active find _id);
_state set ["activePerks", _active];
_registry set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _registry];
[_uid, "perk_activation"] call bn_koth_fnc_persistence_markDirty;
[_uid, "perk_activation", 0, _id] call bn_koth_fnc_progression_publishUpdate;
createHashMapFromArray [["success", true], ["code", "PERK_DEACTIVATED"], ["message", "Perk deactivated."], ["perkId", _id], ["operation", _op], ["committed", true], ["activePerks", _active]]

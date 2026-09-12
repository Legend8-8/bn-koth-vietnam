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
private _restrictedItems = [_loadout, _id] call bn_koth_fnc_progression_perks_findRestrictedItems;
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
private _currentUnit = _record getOrDefault ["currentUnit", objNull];
private _physicalLoadout = if (_id isEqualTo "medic" && {!isNull _currentUnit}) then {getUnitLoadout _currentUnit} else {[]};
{
    _restrictedItems pushBackUnique _x;
} forEach ([_physicalLoadout, _id] call bn_koth_fnc_progression_perks_findRestrictedItems);
private _displayName = _metadata getOrDefault ["displayName", _id];

if ((_op isEqualTo "DEACTIVATE") && {(count _restrictedItems) > 0}) exitWith {
    private _warningMessage = if (_id isEqualTo "suppressor") then {
        "Suppressor perk is currently in use. Deactivating it will remove all suppressors from your equipped weapons and carried inventory. Continue?"
    } else {
        format ["%1 is currently in use. Deactivating it will remove its restricted items from your equipped weapons and carried inventory. Continue?", _displayName]
    };
    [
        "CONFIRMATION_REQUIRED",
        _warningMessage,
        createHashMapFromArray [["confirmationRequired", true], ["restrictedItems", _restrictedItems]]
    ] call _reject
};
if ((_op isEqualTo "DEACTIVATE_CONFIRM") && {(count _restrictedItems) > 0}) exitWith {
    private _cleanIntended = if (_id isEqualTo "suppressor") then {
        [_loadout] call bn_koth_fnc_progression_perks_removeSuppressors
    } else {
        [_loadout, _id] call bn_koth_fnc_progression_perks_removeRestrictedItems
    };
    private _cleanApplied = if (_id isEqualTo "medic" && {(count _physicalLoadout) >= 10}) then {
        [_physicalLoadout, _id] call bn_koth_fnc_progression_perks_removeRestrictedItems
    } else {
        +_cleanIntended
    };
    if (
        (count _cleanIntended) < 10
        || {(count _cleanApplied) < 10}
        || {(count ([_cleanIntended, _id] call bn_koth_fnc_progression_perks_findRestrictedItems)) > 0}
        || {(count ([_cleanApplied, _id] call bn_koth_fnc_progression_perks_findRestrictedItems)) > 0}
    ) exitWith {
        private _failureCode = if (_id isEqualTo "suppressor") then {"SUPPRESSOR_CLEANUP_FAILED"} else {"PERK_CLEANUP_FAILED"};
        [_failureCode, format ["%1 restricted items could not be removed safely; the perk remains active.", _displayName]] call _reject
    };

    private _cleanupCode = if (_id isEqualTo "suppressor") then {"SUPPRESSOR_CLEANUP_REQUIRED"} else {"PERK_CLEANUP_REQUIRED"};

    private _pendingByUid = missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];
    if !(_pendingByUid isEqualType createHashMap) then {_pendingByUid = createHashMap};
    private _existing = _pendingByUid getOrDefault [_uid, createHashMap];
    private _now = serverTime;
    if (_existing isEqualType createHashMap && {(_existing getOrDefault ["expiresAt", -1]) >= _now}) exitWith {
        if ((_existing getOrDefault ["perkId", ""]) isNotEqualTo _id) then {
            ["CLEANUP_ALREADY_PENDING", "Another perk cleanup is already pending; no state was changed."] call _reject
        } else {
            createHashMapFromArray [
                ["success", true], ["code", _cleanupCode],
                ["message", format ["%1 cleanup is already pending.", _displayName]], ["perkId", _id],
                ["operation", _op], ["committed", false],
                ["cleanupToken", _existing getOrDefault ["token", ""]],
                ["cleanupValidation", _existing getOrDefault ["validation", createHashMap]]
            ]
        }
    };
    if (_existing isEqualType createHashMap) then {_pendingByUid deleteAt _uid};

    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) exitWith {["PLAYER_NOT_REGISTERED", "Player ownership is unavailable; the perk remains active."] call _reject};

    private _counter = (missionNamespace getVariable ["BN_KOTH_perkCleanupCounter", 0]) + 1;
    missionNamespace setVariable ["BN_KOTH_perkCleanupCounter", _counter];
    private _token = format ["%1-%2-%3", _uid, _counter, floor (_now * 1000)];
    private _timeout = (getNumber (missionConfigFile >> "CfgBnKothPerks" >> "suppressorCleanupAckTimeoutSeconds")) max 1;
    private _validation = createHashMapFromArray [
        ["success", true], ["validatedBy", "bn_koth_fnc_loadouts_validateLoadout"],
        ["validatedLoadout", +_cleanApplied], ["loadoutId", format ["perk_%1_cleanup", _id]]
    ];
    _pendingByUid set [_uid, createHashMapFromArray [
        ["token", _token], ["perkId", _id], ["ownerId", _ownerId],
        ["originalIntendedLoadout", +_loadout], ["sanitizedIntendedLoadout", +_cleanIntended],
        ["sanitizedLoadout", +_cleanApplied],
        ["validation", _validation], ["expiresAt", _now + _timeout]
    ]];
    missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pendingByUid];
    createHashMapFromArray [
        ["success", true], ["code", _cleanupCode],
        ["message", format ["Applying %1 cleanup before deactivation.", _displayName]], ["perkId", _id],
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

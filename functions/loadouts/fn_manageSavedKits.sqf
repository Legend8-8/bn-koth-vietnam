/*
    File: fn_manageSavedKits.sqf
    Author: Legend
    Description: Mutates bounded server-owned saved-loadout intent using the
        current authoritative intended loadout for create/update operations.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: Operation <STRING>, 2: Kit ID <STRING>, 3: Name <STRING>,
        4: Legacy local kits for one-time migration <ARRAY>, 5: Legacy preferred ID <STRING>
    Returns: Structured mutation result <HASHMAP>
    Public: No
*/

params [
    ["_uid", "", [""]], ["_operation", "", [""]], ["_kitId", "", [""]], ["_name", "", [""]],
    ["_legacyKits", [], [[]]], ["_legacyPreferred", "", [""]]
];
private _result = {
    params ["_success", "_code", "_message", "_kits", "_preferred"];
    createHashMapFromArray [
        ["success", _success], ["code", _code], ["message", _message],
        ["savedKitSync", true], ["savedKits", _kits], ["preferredSavedKitId", _preferred]
    ]
};
if (!isServer || {_uid isEqualTo ""}) exitWith {[false, "INVALID_REQUEST", "Saved-loadout request was invalid.", [], ""] call _result};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _byUid getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {[false, "STATE_UNAVAILABLE", "Saved-loadout state is unavailable.", [], ""] call _result};
private _kits = _state getOrDefault ["savedKits", []];
private _normalized = [_kits] call bn_koth_fnc_persistence_normalizeSavedKits;
_kits = _normalized getOrDefault ["value", []];
private _preferred = _state getOrDefault ["preferredSavedKitId", ""];
private _initialized = _state getOrDefault ["savedKitsInitialized", false];
if !(_initialized isEqualType true) then {_initialized = false};
private _persistenceCfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxKits = if (isNumber (_persistenceCfg >> "savedKitMaxCount")) then {(getNumber (_persistenceCfg >> "savedKitMaxCount")) max 1} else {12};
private _maxIdLength = if (isNumber (_persistenceCfg >> "savedKitMaxIdLength")) then {(getNumber (_persistenceCfg >> "savedKitMaxIdLength")) max 1} else {64};
private _maxNameLength = if (isNumber (_persistenceCfg >> "savedKitMaxNameLength")) then {(getNumber (_persistenceCfg >> "savedKitMaxNameLength")) max 1} else {32};
_operation = toUpper _operation;
if !(_operation in ["CREATE", "UPDATE", "RENAME", "DELETE"]) exitWith {
    [false, "INVALID_OPERATION", "Saved-loadout operation was invalid.", _kits, _preferred] call _result
};
private _changed = false;

// Existing profileNamespace kits are migrated only while the durable set is
// empty. They remain untrusted intent and gain no entitlement by being stored.
if (!_initialized && {(count _kits) isEqualTo 0} && {(count _legacyKits) > 0}) then {
    private _legacyNormalized = [_legacyKits] call bn_koth_fnc_persistence_normalizeSavedKits;
    _kits = _legacyNormalized getOrDefault ["value", []];
    if ((count _kits) > 0) then {
        if ((_kits findIf {(_x select 0) isEqualTo _legacyPreferred}) >= 0) then {_preferred = _legacyPreferred};
        _changed = true;
    };
};

private _validId = _kitId isEqualType "" && {!(_kitId isEqualTo "")} && {(count _kitId) <= _maxIdLength}
    && {({!(_x in toArray "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")} count (toArray _kitId)) isEqualTo 0};
if !(_validId) exitWith {[false, "INVALID_KIT_ID", "Saved-loadout ID was invalid.", _kits, _preferred] call _result};
private _index = _kits findIf {(_x select 0) isEqualTo _kitId};

switch (_operation) do {
    case "CREATE": {
        if ((count _kits) >= _maxKits && {_index < 0}) exitWith {};
        if !(_name isEqualType "" && {!(_name isEqualTo "")} && {(count _name) <= _maxNameLength}) exitWith {};
        if ((_kits findIf {(toLower (_x select 1)) isEqualTo (toLower _name) && {!((_x select 0) isEqualTo _kitId)}}) >= 0) exitWith {};
        private _loadoutStates = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
        private _loadoutState = _loadoutStates getOrDefault [_uid, createHashMap];
        private _loadout = _loadoutState getOrDefault ["intendedLoadout", []];
        if !(_loadout isEqualType [] && {(count _loadout) >= 10}) exitWith {};
        private _candidate = [[_kitId, _name, +_loadout]] call bn_koth_fnc_persistence_normalizeSavedKits;
        if ((count (_candidate getOrDefault ["value", []])) isEqualTo 1) then {
            if (_index < 0) then {
                _kits pushBack [_kitId, _name, +_loadout];
            } else {
                _kits set [_index, [_kitId, _name, +_loadout]];
            };
            _changed = true;
        };
    };
    case "UPDATE": {
        if (_index < 0) exitWith {};
        private _loadoutStates = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
        private _loadout = (_loadoutStates getOrDefault [_uid, createHashMap]) getOrDefault ["intendedLoadout", []];
        if (_loadout isEqualType [] && {(count _loadout) >= 10}) then {
            private _entry = +(_kits select _index);
            _entry set [2, +_loadout];
            _kits set [_index, _entry];
            _changed = true;
        };
    };
    case "RENAME": {
        if (_index < 0) exitWith {};
        if (_name isEqualType "" && {!(_name isEqualTo "")} && {(count _name) <= _maxNameLength}
            && {(_kits findIf {(toLower (_x select 1)) isEqualTo (toLower _name) && {!((_x select 0) isEqualTo _kitId)}}) < 0}) then {
            private _candidate = [[_kitId, _name, (_kits select _index) select 2]] call bn_koth_fnc_persistence_normalizeSavedKits;
            if ((count (_candidate getOrDefault ["value", []])) isEqualTo 1) then {
                private _entry = +(_kits select _index);
                _entry set [1, _name];
                _kits set [_index, _entry];
                _changed = true;
            };
        };
    };
    case "DELETE": {
        if (_index >= 0) then {
            _kits deleteAt _index;
            if (_preferred isEqualTo _kitId) then {_preferred = ""};
            _changed = true;
        };
    };
};

if (!_changed) exitWith {[false, "SAVED_KIT_REJECTED", "Saved-loadout change was rejected.", _kits, _preferred] call _result};
private _codecCheck = [_kits, _preferred] call bn_koth_fnc_persistence_serializeSavedKits;
if !(_codecCheck getOrDefault ["success", false]) exitWith {
    [false, _codecCheck getOrDefault ["code", "SAVED_KITS_TOO_LARGE"], "Saved-loadout data exceeds the persistence limit.", _state getOrDefault ["savedKits", []], _state getOrDefault ["preferredSavedKitId", ""]] call _result
};
_state set ["savedKits", _kits];
_state set ["preferredSavedKitId", _preferred];
_state set ["savedKitsInitialized", true];
_byUid set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
[_uid, "saved_kits"] call bn_koth_fnc_persistence_markDirty;
[true, "SAVED_KIT_UPDATED", "Saved loadouts synchronized with the server.", _kits, _preferred] call _result

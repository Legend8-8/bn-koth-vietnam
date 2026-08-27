/*
    File: fn_markDirty.sqf
    Author: Legend
    Description: Marks persistent state dirty and coalesces mutations into one delayed save.
    Execution: Server
    Public: Yes
*/

params [["_uid", "", [""]], ["_reason", "mutation", [""]]];

if (!isServer || {_uid isEqualTo ""}) exitWith {false};

private _dirty = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
if !(_dirty isEqualType createHashMap) then {_dirty = createHashMap};
private _entry = _dirty getOrDefault [_uid, createHashMap];
if !(_entry isEqualType createHashMap) then {_entry = createHashMap};
private _reasons = _entry getOrDefault ["reasons", []];
if !(_reasons isEqualType []) then {_reasons = []};
_reasons pushBackUnique _reason;
_entry set ["dirty", true];
_entry set ["reasons", _reasons];
_entry set ["markedAt", diag_tickTime];
_dirty set [_uid, _entry];
missionNamespace setVariable ["BN_KOTH_persistenceDirtyPlayers", _dirty];

private _delay = missionNamespace getVariable ["BN_KOTH_persistenceSaveDebounceSeconds", 15];
private _scheduled = missionNamespace getVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
if !(_scheduled isEqualType createHashMap) then {_scheduled = createHashMap};
if (_delay > 0 && {isNil {_scheduled get _uid}}) then {
    _scheduled set [_uid, true];
    missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", _scheduled];
    [_uid, _delay] spawn {
        params ["_scheduledUid", "_scheduledDelay"];
        uiSleep _scheduledDelay;
        private _pending = missionNamespace getVariable ["BN_KOTH_persistenceScheduledSaves", createHashMap];
        if (_pending isEqualType createHashMap) then {
            _pending deleteAt _scheduledUid;
            missionNamespace setVariable ["BN_KOTH_persistenceScheduledSaves", _pending];
        };
        private _dirtyNow = missionNamespace getVariable ["BN_KOTH_persistenceDirtyPlayers", createHashMap];
        if (_dirtyNow isEqualType createHashMap && {!(isNil {_dirtyNow get _scheduledUid})}) then {
            [_scheduledUid, "debounced_mutation"] call bn_koth_fnc_persistence_savePlayer;
        };
    };
};

true


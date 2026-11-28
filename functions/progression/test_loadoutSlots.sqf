/*
    File: test_loadoutSlots.sqf
    Author: Legend
    Description: Isolated server checks for slot charges, replay rejection and fallback.
        Stubs publication/save scheduling and restores all touched state.
    Execution: Server debug console (unscheduled; isolated test mission)
    Parameters: None
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/
if (!isServer) exitWith {["Server required."]};
private _failures = [];
private _check = {params ["_label", "_ok"]; if (!_ok) then {_failures pushBack _label}};
private _maximum = getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxCount");
private _prices = getArray (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitSlotPrices");
if !(_maximum isEqualTo 6 && {count _prices isEqualTo _maximum} && {(_prices select 0) isEqualTo 0}
    && {((_prices select [1]) findIf {!(_x isEqualType 0 && {finite _x} && {_x > 0} && {_x isEqualTo floor _x})}) < 0}) exitWith {
    ["Six slots require a free first slot and positive whole-dollar paid prices."]
};
private _totalCost = 0;
{_totalCost = _totalCost + _x} forEach _prices;
private _firstPrice = _prices select 1;
private _variables = ["BN_KOTH_playerProgression", "BN_KOTH_persistenceLoadedUids", "BN_KOTH_persistenceBackendReady"];
private _backup = _variables apply {missionNamespace getVariable _x};
private _oldDirty = bn_koth_fnc_persistence_markDirty;
private _oldPublish = bn_koth_fnc_progression_publishUpdate;
private _dirty = [];
private _publications = [];
bn_koth_fnc_persistence_markDirty = {_dirty pushBack +_this; true};
bn_koth_fnc_progression_publishUpdate = {_publications pushBack +_this; true};
private _uid = "SLOT_TEST";
private _state = createHashMapFromArray [["unlockedLoadoutSlots", 1], ["cash", _totalCost]];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMapFromArray [[_uid, _state]]];
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", createHashMapFromArray [[_uid, "LOADED"]]];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", true];
private _skip = [_uid, 3] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["Cannot skip the next slot", !(_skip getOrDefault ["success", true]) && {(_state get "cash") isEqualTo _totalCost}] call _check;
for "_slot" from 2 to _maximum do {
    private _before = _state get "cash";
    private _result = [_uid, _slot] call bn_koth_fnc_progression_purchaseLoadoutSlot;
    [format ["Slot %1 charged its authored price", _slot], (_result getOrDefault ["success", false]) && {(_state get "cash") isEqualTo (_before - (_prices select (_slot - 1)))}] call _check;
    private _after = _state get "cash";
    private _duplicate = [_uid, _slot] call bn_koth_fnc_progression_purchaseLoadoutSlot;
    ["Duplicate request cannot charge again", !(_duplicate getOrDefault ["success", true]) && {(_state get "cash") isEqualTo _after}] call _check;
};
["All slots consume exactly the configured total", (_state get "cash") isEqualTo 0 && {(_state get "unlockedLoadoutSlots") isEqualTo _maximum}] call _check;
["Only successful purchases publish and mark dirty", count _dirty isEqualTo (_maximum - 1) && {count _publications isEqualTo (_maximum - 1)}] call _check;
private _seventh = [_uid, _maximum + 1] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["Seventh slot is rejected", !(_seventh getOrDefault ["success", true])] call _check;
_state set ["unlockedLoadoutSlots", 1];
_state set ["cash", _firstPrice - 1];
private _poor = [_uid, 2] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["One dollar short changes neither balance nor slots", !(_poor getOrDefault ["success", true]) && {(_state get "cash") isEqualTo (_firstPrice - 1)} && {(_state get "unlockedLoadoutSlots") isEqualTo 1}] call _check;
_state set ["cash", _totalCost];
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", createHashMapFromArray [[_uid, "SESSION_FALLBACK"]]];
private _fallback = [_uid, 2] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["Fallback cannot buy permanent slots", !(_fallback getOrDefault ["success", true]) && {(_state get "cash") isEqualTo _totalCost}] call _check;
missionNamespace setVariable ["BN_KOTH_persistenceLoadedUids", createHashMapFromArray [[_uid, "FIRST_TIME"]]];
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", false];
private _offline = [_uid, 2] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["Unavailable backend cannot charge", !(_offline getOrDefault ["success", true]) && {(_state get "cash") isEqualTo _totalCost}] call _check;
missionNamespace setVariable ["BN_KOTH_persistenceBackendReady", true];
private _firstTime = [_uid, 2] call bn_koth_fnc_progression_purchaseLoadoutSlot;
["First-time durable session pays the configured price", _firstTime getOrDefault ["success", false] && {(_state get "cash") isEqualTo (_totalCost - _firstPrice)}] call _check;
private _projection = [_uid, _state] call bn_koth_fnc_persistence_projectPlayerState;
["Projection includes slot count", (_projection get "unlockedLoadoutSlots") isEqualTo 2] call _check;
bn_koth_fnc_persistence_markDirty = _oldDirty;
bn_koth_fnc_progression_publishUpdate = _oldPublish;
{missionNamespace setVariable [_x, _backup select _forEachIndex]} forEach _variables;
diag_log format ["[KOTH TEST] loadout slot failures: %1", _failures];
_failures

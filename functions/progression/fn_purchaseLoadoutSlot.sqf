/*
    File: fn_purchaseLoadoutSlot.sqf
    Author: Legend
    Description: Commits the next permanent loadout slot and its cash charge together.
        Called only after the loadout request owner validates mapboard access.
    Execution: Server (unscheduled)
    Parameters: 0: Server-derived UID <STRING>; 1: Requested slot number <NUMBER>
    Returns: Purchase result <HASHMAP>
    Public: No
*/
params [["_uid", "", [""]], ["_slot", -1, [0]]];
private _reject = {
    params ["_code", "_message"];
    createHashMapFromArray [["success", false], ["code", _code], ["message", _message], ["slotPurchase", true]]
};
if (!isServer || {_uid isEqualTo ""}) exitWith {["NOT_SERVER", "Slot purchases require server progression."] call _reject};
private _loaded = missionNamespace getVariable ["BN_KOTH_persistenceLoadedUids", createHashMap];
if !((_loaded getOrDefault [_uid, ""]) in ["LOADED", "FIRST_TIME"]) exitWith {
    ["PERSISTENCE_UNAVAILABLE", "Permanent slots cannot be purchased while persistent player data is unavailable."] call _reject
};
if !(missionNamespace getVariable ["BN_KOTH_persistenceBackendReady", false]) exitWith {
    ["PERSISTENCE_UNAVAILABLE", "Permanent slots cannot be purchased while persistence is unavailable."] call _reject
};
private _registry = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _registry getOrDefault [_uid, createHashMap];
private _owned = _state getOrDefault ["unlockedLoadoutSlots", -1];
if !(_owned isEqualType 0 && {finite _owned} && {_owned >= 1} && {_owned isEqualTo floor _owned}) exitWith {
    ["PROGRESSION_INVALID", "Loadout slot ownership is unavailable."] call _reject
};
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maximum = getNumber (_cfg >> "savedKitMaxCount");
private _prices = getArray (_cfg >> "savedKitSlotPrices");
if !(_maximum >= 1 && {_maximum isEqualTo floor _maximum} && {(count _prices) isEqualTo _maximum}) exitWith {
    ["INVALID_SLOT_CONFIG", "Loadout slot prices are not configured correctly."] call _reject
};
if !(finite _slot && {_slot isEqualTo (_owned + 1)} && {_slot <= _maximum}) exitWith {
    ["INVALID_SLOT", "Only the next locked loadout slot can be purchased."] call _reject
};
private _price = _prices select (_slot - 1);
if !(_price isEqualType 0 && {finite _price} && {_price > 0} && {_price isEqualTo floor _price}) exitWith {
    ["INVALID_SLOT_PRICE", "That loadout slot has no valid purchase price."] call _reject
};
private _cash = _state getOrDefault ["cash", -1];
if !(_cash isEqualType 0 && {finite _cash} && {_cash >= _price}) exitWith {
    ["INSUFFICIENT_CASH", "You do not have enough cash to unlock that slot."] call _reject
};
_state set ["cash", _cash - _price];
_state set ["unlockedLoadoutSlots", _slot];
_registry set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _registry];
[_uid, "loadout_slot_purchase"] call bn_koth_fnc_persistence_markDirty;
[_uid, "cash", -_price, "loadout_slot_purchase"] call bn_koth_fnc_progression_publishUpdate;
createHashMapFromArray [
    ["success", true], ["code", "LOADOUT_SLOT_PURCHASED"], ["slotPurchase", true],
    ["message", format ["LOADOUT SLOT %1 UNLOCKED FOR BOTH TEAMS.", _slot]]
]

/*
    File: fn_purchase.sqf
    Author: Legend
    Description: Atomically purchases one configured perk in authoritative progression state.
    Execution: Server
    Public: No
*/
params [["_uid", "", [""]], ["_perkId", "", [""]]];
private _reject = {
    params ["_code", "_message"];
    createHashMapFromArray [["success", false], ["code", _code], ["message", _message], ["perkId", toLower _perkId], ["committed", false], ["charged", 0]]
};
if (!isServer) exitWith {["NOT_SERVER", "Perk purchases are server-authoritative."] call _reject};
private _metadata = [_perkId] call bn_koth_fnc_progression_perks_getConfig;
if !(_metadata getOrDefault ["success", false]) exitWith {["UNKNOWN_PERK", "That perk is not configured."] call _reject};
if !(_metadata getOrDefault ["available", false] && {_metadata getOrDefault ["purchasable", false]}) exitWith {["PERK_UNAVAILABLE", "That perk is not available for purchase."] call _reject};
private _cost = _metadata getOrDefault ["purchaseCost", -1];
if !(_cost isEqualType 0 && {finite _cost} && {_cost >= 0}) exitWith {["INVALID_PERK_COST", "The configured perk cost is invalid."] call _reject};
private _registry = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _registry getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE", "Player progression is unavailable."] call _reject};
private _ownedRaw = _state getOrDefault ["ownedPerks", []];
if !(_ownedRaw isEqualType []) exitWith {["PROGRESSION_INVALID", "Perk ownership state is invalid."] call _reject};
private _owned = +_ownedRaw;
private _id = toLower _perkId;
if (_id in _owned) exitWith {["ALREADY_OWNED", "That perk is already owned."] call _reject};
private _cash = _state getOrDefault ["cash", 0];
if !(_cash isEqualType 0 && {finite _cash} && {_cash >= _cost}) exitWith {["INSUFFICIENT_CASH", "You do not have enough cash."] call _reject};
_owned pushBack _id;
_state set ["cash", _cash - _cost];
_state set ["ownedPerks", _owned];
_registry set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _registry];
[_uid, "perk_purchase"] call bn_koth_fnc_persistence_markDirty;
[_uid, "perk_purchase", 0, _id] call bn_koth_fnc_progression_publishUpdate;
[format ["Perk purchase committed UID=%1 perk=%2 charged=%3", _uid, _id, _cost]] call bn_koth_fnc_common_log;
createHashMapFromArray [["success", true], ["code", "PERK_PURCHASED"], ["message", "Perk purchased."], ["perkId", _id], ["committed", true], ["charged", _cost]]

/*
    File: fn_evaluateItemEntitlement.sqf
    Author: Legend
    Description: Gathers server-owned progression and evaluates wearable or
        consumable entitlement through the shared pure interpreter.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Metadata group (Wearables|Consumables) <STRING>
        2: Item classname <STRING>
    Returns: Entitlement result <HASHMAP>
    Public: No
*/

params [["_uid", "", [""]], ["_metadataGroup", "", [""]], ["_itemClass", "", [""]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_NOT_SERVER"], ["message", "Item entitlement must run on server."]]};
if (_uid isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_INVALID_PLAYER"], ["message", "Item entitlement requires a player UID."]]};

private _metadata = [_metadataGroup, _itemClass] call bn_koth_fnc_loadouts_getItemMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {
    createHashMapFromArray [["success", false], ["entitled", false], ["code", _metadata getOrDefault ["code", "ERR_ITEM_METADATA"]], ["message", "Item metadata lookup failed."]]
};

private _progression = createHashMap;
if (_metadata getOrDefault ["configured", false]) then {
    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    if !(_records isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_PLAYER_REGISTRY"], ["message", "Server player registry is unavailable."]]};
    if !((_records getOrDefault [_uid, objNull]) isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_INVALID_PLAYER"], ["message", "Player is not present in the authoritative registry."]]};
    private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
    if !(_byUid isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_PROGRESSION_STATE"], ["message", "Authoritative progression state is unavailable."]]};
    _progression = _byUid getOrDefault [_uid, createHashMap];
    if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
};

[_progression, _metadata, _itemClass] call bn_koth_fnc_progression_evaluateItemEntitlementRules

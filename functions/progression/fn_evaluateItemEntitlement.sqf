/*
    File: fn_evaluateItemEntitlement.sqf
    Author: Legend
    Description: Gathers server-owned side/progression state and evaluates
        attachment, wearable, or consumable entitlement through the shared
        pure interpreter.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Metadata group (Attachments|Wearables|Consumables) <STRING>
        2: Item classname <STRING>
        3: Whether appearance identity is mandatory <BOOL>
    Returns: Entitlement result <HASHMAP>
    Public: No
*/

params [["_uid", "", [""]], ["_metadataGroup", "", [""]], ["_itemClass", "", [""]], ["_requireAppearance", false, [false]]];

if (!isServer) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_NOT_SERVER"], ["message", "Item entitlement must run on server."]]};
if (_uid isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_INVALID_PLAYER"], ["message", "Item entitlement requires a player UID."]]};

private _metadata = [_metadataGroup, _itemClass] call bn_koth_fnc_loadouts_getItemMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {
    createHashMapFromArray [["success", false], ["entitled", false], ["code", _metadata getOrDefault ["code", "ERR_ITEM_METADATA"]], ["message", "Item metadata lookup failed."]]
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_PLAYER_REGISTRY"], ["message", "Server player registry is unavailable."]]};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_INVALID_PLAYER"], ["message", "Player is not present in the authoritative registry."]]};

private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_ASSIGNED_SIDE_INVALID"], ["message", "Player does not have a valid authoritative side."]]};
private _sideToken = if (_assignedSide isEqualTo west) then {"WEST"} else {"EAST"};

private _progression = createHashMap;
if (_metadata getOrDefault ["configured", false]) then {
    private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
    if !(_byUid isEqualType createHashMap) exitWith {createHashMapFromArray [["success", false], ["entitled", false], ["code", "ERR_PROGRESSION_STATE"], ["message", "Authoritative progression state is unavailable."]]};
    _progression = _byUid getOrDefault [_uid, createHashMap];
    if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
};

[_progression, _metadata, _itemClass, _sideToken, _requireAppearance] call bn_koth_fnc_progression_evaluateItemEntitlementRules

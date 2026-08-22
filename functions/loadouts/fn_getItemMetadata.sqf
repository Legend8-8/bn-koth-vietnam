/*
    File: fn_getItemMetadata.sqf
    Author: Legend
    Description: Reads normalized human-authored entitlement metadata for a
        wearable or consumable. Factual class validity is owned elsewhere.
    Execution: Any
    Parameters:
        0: Metadata group (Wearables|Consumables) <STRING>
        1: Item classname <STRING>
    Returns: Metadata result <HASHMAP>
    Public: No
*/

params [
    ["_metadataGroup", "", [""]],
    ["_itemClass", "", [""]]
];

private _group = toLower _metadataGroup;
private _class = toLower _itemClass;
private _groupConfigName = switch (_group) do {
    case "wearables": {"Wearables"};
    case "consumables": {"Consumables"};
    default {""};
};

if (_groupConfigName isEqualTo "") exitWith {
    createHashMapFromArray [["success", false], ["code", "ERR_METADATA_GROUP"], ["configured", false]]
};
if (_class isEqualTo "") exitWith {
    createHashMapFromArray [["success", false], ["code", "ERR_ITEM_CLASS_EMPTY"], ["configured", false]]
};

private _cfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> _groupConfigName >> _class;
private _configured = isClass _cfg;
private _minLevel = 1;
private _requiredPerks = [];

if (_configured) then {
    if (isNumber (_cfg >> "minLevel")) then {
        _minLevel = (getNumber (_cfg >> "minLevel")) max 1;
    };
    if (isArray (_cfg >> "requiredPerks")) then {
        _requiredPerks = getArray (_cfg >> "requiredPerks");
    };
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["metadataGroup", _groupConfigName],
    ["itemClass", _class],
    ["configured", _configured],
    ["minLevel", _minLevel],
    ["requiredPerks", _requiredPerks]
]

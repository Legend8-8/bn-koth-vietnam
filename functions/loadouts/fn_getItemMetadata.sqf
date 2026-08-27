/*
    File: fn_getItemMetadata.sqf
    Author: Legend
    Description: Reads normalized human-authored entitlement metadata for an
        attachment, wearable, or consumable. Factual class validity is owned elsewhere.
    Execution: Any
    Parameters:
        0: Metadata group (Attachments|Wearables|Consumables) <STRING>
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
    case "attachments": {"Attachments"};
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
private _allowedSides = [];
private _appearanceSide = "";

if (_configured) then {
    if (isNumber (_cfg >> "minLevel")) then {
        _minLevel = (getNumber (_cfg >> "minLevel")) max 1;
    };
    if (isArray (_cfg >> "requiredPerks")) then {
        _requiredPerks = getArray (_cfg >> "requiredPerks");
    };
    if (isArray (_cfg >> "allowedSides")) then {
        _allowedSides = (getArray (_cfg >> "allowedSides")) apply {toUpper _x};
    };
    _appearanceSide = toUpper (getText (_cfg >> "appearanceSide"));
};

createHashMapFromArray [
    ["success", true],
    ["code", "OK"],
    ["metadataGroup", _groupConfigName],
    ["itemClass", _class],
    ["configured", _configured],
    ["allowedSides", _allowedSides],
    ["appearanceSide", _appearanceSide],
    ["minLevel", _minLevel],
    ["requiredPerks", _requiredPerks]
]

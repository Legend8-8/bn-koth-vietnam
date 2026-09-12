/*
    File: fn_validateAssignedItemSlot.sqf
    Author: Legend
    Description: Validates one assigned-item classname against its fixed Arma Unit Loadout slot.
    Execution: Any
    Parameters:
        0: Assigned item index (0 map, 1 GPS/terminal, 2 radio, 3 compass, 4 watch, 5 NVG) <NUMBER>
        1: Item classname, or an empty string to clear the slot <STRING>
        2: Generated SourceItems config class <CONFIG>
    Returns:
        Validation result <HASHMAP>
    Public: No
*/

params ["_assignedIndex", "_itemClass", "_sourceItemsCfg"];

private _fail = {
    params ["_code", "_message"];
    createHashMapFromArray [
        ["success", false],
        ["code", _code],
        ["message", _message]
    ]
};

if !(_assignedIndex isEqualType 0) exitWith {
    ["ERR_ASSIGNED_INDEX_TYPE", "Assigned item index must be numeric."] call _fail
};
if !(_itemClass isEqualType "") exitWith {
    ["ERR_ASSIGNED_ITEM_CLASS_TYPE", "Assigned item classname must be a string."] call _fail
};
if !(_sourceItemsCfg isEqualType configNull && {isClass _sourceItemsCfg}) exitWith {
    ["ERR_COMPATIBILITY_MISSING", "SourceItems compatibility data is missing."] call _fail
};

_itemClass = toLower _itemClass;
if (_itemClass isEqualTo "") exitWith {
    createHashMapFromArray [["success", true], ["code", "OK"], ["message", "Assigned slot clear intent accepted."]]
};

if !(isClass (_sourceItemsCfg >> _itemClass)) exitWith {
    ["ERR_ASSIGNED_ITEM_UNKNOWN", format ["Assigned item '%1' is missing from canonical SourceItems.", _itemClass]] call _fail
};
if !(isClass (configFile >> "CfgWeapons" >> _itemClass)) exitWith {
    ["ERR_ASSIGNED_ITEM_CONFIG_MISSING", format ["Assigned item '%1' is missing from CfgWeapons.", _itemClass]] call _fail
};

private _itemType = [_itemClass] call BIS_fnc_itemType;
if !(_itemType isEqualType [] && {(count _itemType) >= 2}) exitWith {
    ["ERR_ASSIGNED_ITEM_TYPE_UNKNOWN", format ["Assigned item '%1' type could not be resolved.", _itemClass]] call _fail
};

private _subType = toLower (_itemType select 1);
private _allowed = switch (_assignedIndex) do {
    case 0: {_subType isEqualTo "map"};
    case 1: {(_subType isEqualTo "gps") || {_subType find "uav" >= 0}};
    case 2: {_subType isEqualTo "radio"};
    case 3: {_subType isEqualTo "compass"};
    case 4: {_subType isEqualTo "watch"};
    case 5: {_subType find "nvg" >= 0};
    default {false};
};

if (!_allowed) exitWith {
    [
        "ERR_ASSIGNED_ITEM_SLOT_MISMATCH",
        format ["Assigned item '%1' subtype '%2' is not valid for assigned slot index %3.", _itemClass, _subType, _assignedIndex]
    ] call _fail
};

createHashMapFromArray [["success", true], ["code", "OK"], ["message", "Assigned slot item validated."]]

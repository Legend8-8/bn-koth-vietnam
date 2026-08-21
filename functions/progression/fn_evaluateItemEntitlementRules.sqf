/*
    File: fn_evaluateItemEntitlementRules.sqf
    Author: Legend
    Description: Pure wearable/consumable entitlement interpreter shared by
        server validation and client presentation. Reads no mission state.
    Execution: Any
    Parameters:
        0: Progression state <HASHMAP>
        1: Item metadata <HASHMAP>
        2: Item classname <STRING>
    Returns: Entitlement result <HASHMAP>
    Public: No
*/

params [
    ["_progression", createHashMap, [createHashMap]],
    ["_metadata", createHashMap, [createHashMap]],
    ["_itemClass", "", [""]]
];

private _class = toLower _itemClass;
private _configured = _metadata getOrDefault ["configured", false];
private _finish = {
    params ["_success", "_entitled", "_code", "_message", ["_extra", createHashMap, [createHashMap]]];
    private _result = createHashMapFromArray [
        ["success", _success], ["entitled", _entitled], ["code", _code],
        ["message", _message], ["itemClass", _class], ["configured", _configured]
    ];
    {_result set [_x, _extra get _x];} forEach (keys _extra);
    _result
};

if !(_metadata getOrDefault ["success", false]) exitWith {
    [false, false, "LOCKED_STATE", "Item metadata is unavailable."] call _finish
};
if (!_configured) exitWith {
    [true, true, "ENTITLED_UNCONTROLLED", "Item has no KOTH entitlement metadata.",
        createHashMapFromArray [["accessType", "UNCONTROLLED"], ["minLevel", 1], ["missingPerks", []]]] call _finish
};

private _playerLevel = (_progression getOrDefault ["level", 1]) max 1;
private _minLevel = (_metadata getOrDefault ["minLevel", 1]) max 1;
if (_playerLevel < _minLevel) exitWith {
    [false, false, "LOCKED_LEVEL", format ["Requires level %1.", _minLevel],
        createHashMapFromArray [["accessType", "NONE"], ["playerLevel", _playerLevel], ["minLevel", _minLevel], ["missingPerks", []]]] call _finish
};

private _requiredPerks = _metadata getOrDefault ["requiredPerks", []];
if !(_requiredPerks isEqualType []) then {_requiredPerks = []};
private _playerPerks = _progression getOrDefault ["perks", []];
if !(_playerPerks isEqualType []) then {_playerPerks = []};
private _normalizedPerks = _playerPerks apply {toLower _x};
private _missingPerks = [];
{
    if !((toLower _x) in _normalizedPerks) then {_missingPerks pushBack _x;};
} forEach _requiredPerks;

if ((count _missingPerks) > 0) exitWith {
    [false, false, "LOCKED_PERK", "Required perk entitlement is incomplete.",
        createHashMapFromArray [["accessType", "NONE"], ["playerLevel", _playerLevel], ["minLevel", _minLevel], ["missingPerks", _missingPerks]]] call _finish
};

[true, true, "ENTITLED", "Item entitlement is valid.",
    createHashMapFromArray [["accessType", "UNCONTROLLED"], ["playerLevel", _playerLevel], ["minLevel", _minLevel], ["missingPerks", []]]] call _finish

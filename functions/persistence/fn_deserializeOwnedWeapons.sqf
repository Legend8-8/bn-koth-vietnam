/*
    File: fn_deserializeOwnedWeapons.sqf
    Author: Legend
    Description: Parses restricted owned-weapon text without evaluating code.
    Execution: Server
    Public: No
*/

params [["_serialized", "", [""]]];

if (_serialized isEqualTo "-") exitWith {createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", []]]};
if (_serialized isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_OWNED_WEAPONS"], ["value", []]]};
if ((_serialized select [0, 1]) isEqualTo "," || {(_serialized select [(count _serialized) - 1, 1]) isEqualTo ","} || {(_serialized find ",,") >= 0}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_OWNED_WEAPONS"], ["value", []]]};

private _allowed = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
private _items = _serialized splitString ",";
private _value = [];
private _invalid = false;
{
    private _item = toLower _x;
    if (_item isEqualTo "" || {({!(_x in _allowed)} count (toArray _item)) > 0} || {_item in _value}) then {
        _invalid = true;
    } else {
        _value pushBack _item;
    };
} forEach _items;

if (_invalid) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_OWNED_WEAPONS"], ["value", []]]};
_value sort true;
createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", _value]]

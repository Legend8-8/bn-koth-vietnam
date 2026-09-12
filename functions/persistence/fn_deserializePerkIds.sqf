/*
    File: fn_deserializePerkIds.sqf
    Author: Legend
    Description: Parses restricted perk ID text without evaluating code.
    Execution: Server
    Public: No
*/
params [["_serialized", "", [""]]];
if (_serialized isEqualTo "-") exitWith {createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", []]]};
if (_serialized isEqualTo "" || {(_serialized select [0, 1]) isEqualTo ","} || {(_serialized select [(count _serialized) - 1, 1]) isEqualTo ","} || {(_serialized find ",,") >= 0}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_PERK_IDS"], ["value", []]]};
private _allowed = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
private _value = [];
private _invalid = false;
{
    private _id = toLower _x;
    if (_id isEqualTo "" || {({!(_x in _allowed)} count toArray _id) > 0} || {_id in _value}) then {_invalid = true} else {_value pushBack _id};
} forEach (_serialized splitString ",");
if (_invalid) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_PERK_IDS"], ["value", []]]};
_value sort true;
createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", _value]]

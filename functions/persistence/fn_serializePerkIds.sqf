/*
    File: fn_serializePerkIds.sqf
    Author: Legend
    Description: Serializes normalized stable perk IDs as restricted deterministic text.
    Execution: Server
    Public: No
*/
params [["_perkIds", [], [[]]]];
private _allowed = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
private _normalized = [];
private _invalid = false;
{
    if !(_x isEqualType "" && {!(_x isEqualTo "")} && {({!(_x in _allowed)} count toArray (toLower _x)) isEqualTo 0}) then {
        _invalid = true;
    } else {
        _normalized pushBackUnique (toLower _x);
    };
} forEach _perkIds;
if (_invalid || {(count _normalized) != (count _perkIds)}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_PERK_ID"], ["value", ""]]};
_normalized sort true;
createHashMapFromArray [["success", true], ["code", "SERIALIZED"], ["value", if ((count _normalized) isEqualTo 0) then {"-"} else {_normalized joinString ","}]]

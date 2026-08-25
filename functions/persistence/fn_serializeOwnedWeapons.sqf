/*
    File: fn_serializeOwnedWeapons.sqf
    Author: Legend
    Description: Serializes canonical owned-weapon classnames into deterministic restricted text.
    Execution: Server
    Public: No
*/

params [["_ownedWeapons", [], [[]]]];

private _validToken = {
    params ["_value"];
    if !(_value isEqualType "" && {!(_value isEqualTo "")}) exitWith {false};
    private _allowed = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
    ({!(_x in _allowed)} count (toArray (toLower _value))) isEqualTo 0
};

private _normalized = [];
{
    if !([_x] call _validToken) exitWith {};
    _normalized pushBackUnique (toLower _x);
} forEach _ownedWeapons;

if ((count _normalized) != (count _ownedWeapons)) exitWith {
    createHashMapFromArray [["success", false], ["code", "INVALID_OWNED_WEAPON_TOKEN"], ["value", ""]]
};

_normalized sort true;
createHashMapFromArray [["success", true], ["code", "SERIALIZED"], ["value", if ((count _normalized) isEqualTo 0) then {"-"} else {_normalized joinString ","}]]

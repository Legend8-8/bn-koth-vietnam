/*
    File: fn_serializeWeaponKills.sqf
    Author: Legend
    Description: Serializes canonical weapon kill counts into deterministic restricted text.
    Execution: Server
    Public: No
*/

params [["_weaponKills", createHashMap, [createHashMap]]];

private _allowed = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
private _keys = keys _weaponKills;
_keys sort true;
private _entries = [];
private _invalid = false;
{
    private _key = toLower _x;
    private _count = _weaponKills get _x;
    if (_key isEqualTo "" || {({!(_x in _allowed)} count (toArray _key)) > 0} || {!(_count isEqualType 0 && {finite _count} && {_count >= 0} && {_count isEqualTo floor _count})}) then {
        _invalid = true;
    } else {
        _entries pushBack format ["%1=%2", _key, floor _count];
    };
} forEach _keys;

if (_invalid) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_WEAPON_KILLS"], ["value", ""]]};
createHashMapFromArray [["success", true], ["code", "SERIALIZED"], ["value", if ((count _entries) isEqualTo 0) then {"-"} else {_entries joinString ","}]]

/*
    File: fn_deserializeWeaponKills.sqf
    Author: Legend
    Description: Parses restricted canonical weapon kill text without evaluating code.
    Execution: Server
    Public: No
*/

params [["_serialized", "", [""]]];

if (_serialized isEqualTo "-") exitWith {createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", createHashMap]]};
if (_serialized isEqualTo "") exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_WEAPON_KILLS"], ["value", createHashMap]]};
if ((_serialized select [0, 1]) isEqualTo "," || {(_serialized select [(count _serialized) - 1, 1]) isEqualTo ","} || {(_serialized find ",,") >= 0}) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_WEAPON_KILLS"], ["value", createHashMap]]};

private _allowedName = toArray "abcdefghijklmnopqrstuvwxyz0123456789_";
private _allowedNumber = toArray "0123456789";
private _value = createHashMap;
private _invalid = false;
{
    if (({_x isEqualTo 61} count (toArray _x)) != 1) then {_invalid = true};
    private _parts = _x splitString "=";
    if ((count _parts) != 2) then {
        _invalid = true;
    } else {
        private _key = toLower (_parts select 0);
        private _numberText = _parts select 1;
        if (_key isEqualTo "" || {_numberText isEqualTo ""} || {({!(_x in _allowedName)} count (toArray _key)) > 0} || {({!(_x in _allowedNumber)} count (toArray _numberText)) > 0} || {!(isNil {_value get _key})}) then {
            _invalid = true;
        } else {
            private _count = parseNumber _numberText;
            if (!finite _count || {_count < 0} || {_count != floor _count}) then {_invalid = true} else {_value set [_key, floor _count]};
        };
    };
} forEach (_serialized splitString ",");

if (_invalid) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_WEAPON_KILLS"], ["value", createHashMap]]};
createHashMapFromArray [["success", true], ["code", "PARSED"], ["value", _value]]

/*
    File: fn_normalizeSavedKits.sqf
    Author: Legend
    Description: Normalizes persisted saved-loadout intent into the bounded schema.
        This proves structure only; entitlement is always revalidated on use.
    Execution: Server
    Parameters: 0: Saved kits <ARRAY>
    Returns: Structured normalization result <HASHMAP>
    Public: No
*/

params [["_rawKits", [], [[]]]];
private _kits = [];
private _warnings = [];
private _allowedId = toArray "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-";
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxKits = if (isNumber (_cfg >> "savedKitMaxCount")) then {(getNumber (_cfg >> "savedKitMaxCount")) max 1} else {12};
private _maxIdLength = if (isNumber (_cfg >> "savedKitMaxIdLength")) then {(getNumber (_cfg >> "savedKitMaxIdLength")) max 1} else {64};
private _maxNameLength = if (isNumber (_cfg >> "savedKitMaxNameLength")) then {(getNumber (_cfg >> "savedKitMaxNameLength")) max 1} else {32};
private _maxLoadoutCharacters = if (isNumber (_cfg >> "savedKitMaxLoadoutCharacters")) then {(getNumber (_cfg >> "savedKitMaxLoadoutCharacters")) max 1000} else {60000};
private _isSimpleValue = {};
_isSimpleValue = {
    params ["_value", ["_depth", 0, [0]]];
    if (_depth > 12) exitWith {false};
    if (_value isEqualType "") exitWith {
        (count _value) <= 256
            && {({(_x < 32) || {_x > 126} || {_x in (toArray ";{}()")}} count (toArray _value)) isEqualTo 0}
    };
    if (_value isEqualType true) exitWith {true};
    if (_value isEqualType 0) exitWith {finite _value};
    if (_value isEqualType []) exitWith {
        (count _value) <= 64 && {({!([_x, _depth + 1] call _isSimpleValue)} count _value) isEqualTo 0}
    };
    false
};

{
    if ((count _kits) >= _maxKits) exitWith {_warnings pushBackUnique "SAVED_KIT_LIMIT"};
    if !(_x isEqualType [] && {(count _x) isEqualTo 3}) then {
        _warnings pushBackUnique "MALFORMED_SAVED_KIT";
        continue;
    };
    _x params ["_id", "_name", "_loadout"];
    private _validId = _id isEqualType "" && {!(_id isEqualTo "")} && {(count _id) <= _maxIdLength}
        && {({!(_x in _allowedId)} count (toArray _id)) isEqualTo 0};
    private _validName = _name isEqualType "" && {!(_name isEqualTo "")} && {(count _name) <= _maxNameLength}
        && {({(_x < 32) || {_x > 126}} count (toArray _name)) isEqualTo 0};
    private _validLoadout = _loadout isEqualType [] && {(count _loadout) >= 10} && {(count (str _loadout)) <= _maxLoadoutCharacters} && {[_loadout] call _isSimpleValue};
    if (_validId && {_validName} && {_validLoadout}
        && {(_kits findIf {(_x select 0) isEqualTo _id}) < 0}
        && {(_kits findIf {(toLower (_x select 1)) isEqualTo (toLower _name)}) < 0}) then {
        _kits pushBack [_id, _name, +_loadout];
    } else {
        _warnings pushBackUnique "MALFORMED_SAVED_KIT";
    };
} forEach _rawKits;

createHashMapFromArray [["success", true], ["value", _kits], ["warnings", _warnings]]

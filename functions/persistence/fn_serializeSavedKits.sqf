/*
    File: fn_serializeSavedKits.sqf
    Author: Legend
    Description: Serializes saved-kit intent as fixed-width decimal bytes safe for extDB3 restricted input.
    Execution: Server
    Parameters: 0: Saved kits <ARRAY>, 1: Preferred kit ID <STRING>,
        2: Durable saved-kit state has been initialized <BOOL>
    Returns: Structured codec result <HASHMAP>
    Public: No
*/

params [["_kits", [], [[]]], ["_preferredId", "", [""]], ["_initialized", true, [true]]];
if (!_initialized) exitWith {
    createHashMapFromArray [["success", true], ["code", "UNINITIALIZED"], ["value", "-"]]
};
private _normalized = [_kits] call bn_koth_fnc_persistence_normalizeSavedKits;
private _value = _normalized getOrDefault ["value", []];
if ((count _value) != (count _kits)) exitWith {
    createHashMapFromArray [["success", false], ["code", "INVALID_SAVED_KITS"], ["value", ""]]
};
if !(_preferredId isEqualTo "" || {(_value findIf {(_x select 0) isEqualTo _preferredId}) >= 0}) then {_preferredId = ""};
private _plain = str [_preferredId, _value];
private _encoded = "";
{
    if (_x > 999) exitWith {_encoded = ""};
    _encoded = _encoded + (if (_x < 10) then {format ["00%1", _x]} else {if (_x < 100) then {format ["0%1", _x]} else {str _x}});
} forEach (toArray _plain);
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxSerialized = if (isNumber (_cfg >> "savedKitMaxSerializedCharacters")) then {(getNumber (_cfg >> "savedKitMaxSerializedCharacters")) max 3000} else {500000};
if (_encoded isEqualTo "" || {(count _encoded) > _maxSerialized}) exitWith {
    createHashMapFromArray [["success", false], ["code", "SAVED_KITS_TOO_LARGE"], ["value", ""]]
};
createHashMapFromArray [["success", true], ["code", "SERIALIZED"], ["value", _encoded]]

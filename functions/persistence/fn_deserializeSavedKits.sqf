/*
    File: fn_deserializeSavedKits.sqf
    Author: Legend
    Description: Decodes restricted saved-kit text without compiling executable code.
    Execution: Server
    Parameters: 0: Encoded saved-kit text <STRING>
    Returns: Structured codec result <HASHMAP>
    Public: No
*/

params [["_encoded", "", [""]]];
private _empty = createHashMapFromArray [["success", true], ["code", "PARSED"], ["kits", []], ["preferredId", ""]];
if (_encoded isEqualTo "-") exitWith {_empty};
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxSerialized = if (isNumber (_cfg >> "savedKitMaxSerializedCharacters")) then {(getNumber (_cfg >> "savedKitMaxSerializedCharacters")) max 3000} else {500000};
if (_encoded isEqualTo "" || {(count _encoded) > _maxSerialized} || {((count _encoded) mod 3) != 0}) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]
};
private _digits = toArray "0123456789";
if (({!(_x in _digits)} count (toArray _encoded)) > 0) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]
};
private _bytes = [];
for "_offset" from 0 to ((count _encoded) - 3) step 3 do {
    private _value = parseNumber (_encoded select [_offset, 3]);
    if (_value < 0 || {_value > 255}) exitWith {_bytes = []};
    _bytes pushBack _value;
};
if ((count _bytes) isEqualTo 0) exitWith {createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]};
private _decoded = parseSimpleArray (toString _bytes);
if !(_decoded isEqualType [] && {(count _decoded) isEqualTo 2}) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]
};
_decoded params ["_preferredId", "_kits"];
if !(_preferredId isEqualType "" && {_kits isEqualType []}) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]
};
private _normalized = [_kits] call bn_koth_fnc_persistence_normalizeSavedKits;
private _value = _normalized getOrDefault ["value", []];
if ((count _value) != (count _kits)) exitWith {
    createHashMapFromArray [["success", false], ["code", "MALFORMED_SAVED_KITS"]]
};
if !(_preferredId isEqualTo "" || {(_value findIf {(_x select 0) isEqualTo _preferredId}) >= 0}) then {_preferredId = ""};
createHashMapFromArray [["success", true], ["code", "PARSED"], ["kits", _value], ["preferredId", _preferredId]]

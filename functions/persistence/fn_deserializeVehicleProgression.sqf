/*
    File: fn_deserializeVehicleProgression.sqf
    Author: Legend
    Description: Parses the restricted vehicle progression array shape. No code
        is compiled or executed from persistence text.
    Execution: Server
    Parameters: 0: serialized text <STRING>
    Returns: Codec result <HASHMAP>
    Public: No
*/
params [["_text", "", [""]]];
private _fail = {params ["_code"]; createHashMapFromArray [["success", false], ["code", _code]]};
if (_text isEqualTo "" || {_text isEqualTo "-"}) exitWith {createHashMapFromArray [["success", true], ["code", "EMPTY"], ["owned", []], ["used", []], ["mastery", createHashMap]]};
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxSerialized = if (isNumber (_cfg >> "vehicleProgressionMaxSerializedCharacters")) then {(getNumber (_cfg >> "vehicleProgressionMaxSerializedCharacters")) max 3000} else {250000};
if ((count _text) > _maxSerialized || {((count _text) mod 3) isNotEqualTo 0}) exitWith {["VEHICLE_PROGRESSION_TOO_LARGE"] call _fail};
private _digits = toArray "0123456789";
if (({!(_x in _digits)} count (toArray _text)) > 0) exitWith {["MALFORMED_VEHICLE_PROGRESSION"] call _fail};
private _bytes = [];
for "_offset" from 0 to ((count _text) - 3) step 3 do {
    private _value = parseNumber (_text select [_offset, 3]);
    if (_value < 0 || {_value > 255}) exitWith {_bytes = []};
    _bytes pushBack _value;
};
if ((count _bytes) isEqualTo 0) exitWith {["MALFORMED_VEHICLE_PROGRESSION"] call _fail};
private _parsed = [];
private _parseFailed = false;
try {
    _parsed = parseSimpleArray (toString _bytes);
} catch {
    _parseFailed = true;
};
if (_parseFailed) exitWith {["MALFORMED_VEHICLE_PROGRESSION"] call _fail};
if !(_parsed isEqualType [] && {(count _parsed) isEqualTo 3}) exitWith {["MALFORMED_VEHICLE_PROGRESSION"] call _fail};
_parsed params ["_owned", "_used", "_rows"];
if !(_owned isEqualType [] && {_used isEqualType []} && {_rows isEqualType []}) exitWith {["MALFORMED_VEHICLE_PROGRESSION"] call _fail};
private _state = createHashMapFromArray [["ownedVehicleFamilies", _owned], ["vehicleFirstSpawnsUsed", _used], ["vehicleMastery", createHashMap]];
// Validate mastery rows before using the common serializer for canonical shape.
private _mastery = createHashMap;
private _valid = true;
{
    if !(_x isEqualType [] && {(count _x) isEqualTo 2}) then {_valid = false; continue};
    _x params ["_familyId", "_counterRows"];
    if !(_familyId isEqualType "" && {_counterRows isEqualType []} && {isNil {_mastery get _familyId}}) then {_valid = false; continue};
    private _counters = createHashMap;
    {
        if !(_x isEqualType [] && {(count _x) isEqualTo 2}) then {_valid = false; continue};
        _x params ["_counter", "_value"];
        if !(_counter isEqualType "" && {_value isEqualType 0} && {finite _value} && {_value >= 0} && {isNil {_counters get _counter}}) then {_valid = false; continue};
        _counters set [_counter, floor _value];
    } forEach _counterRows;
    _mastery set [_familyId, _counters];
} forEach _rows;
if (!_valid) exitWith {["MALFORMED_VEHICLE_MASTERY"] call _fail};
_state set ["vehicleMastery", _mastery];
private _validated = [_state] call bn_koth_fnc_persistence_serializeVehicleProgression;
if !(_validated getOrDefault ["success", false]) exitWith {[_validated getOrDefault ["code", "MALFORMED_VEHICLE_PROGRESSION"]] call _fail};
_owned = _owned arrayIntersect _owned;
_owned sort true;
_used = (_used arrayIntersect _used) select {_x in _owned};
_used sort true;
createHashMapFromArray [["success", true], ["code", "PARSED"], ["owned", _owned], ["used", _used], ["mastery", _mastery]]

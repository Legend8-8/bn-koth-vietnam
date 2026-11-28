/*
    File: fn_serializeVehicleProgression.sqf
    Author: Legend
    Description: Serializes bounded logical vehicle ownership, first-spawn use,
        and family mastery without serializing physical class or object identity.
    Execution: Server
    Parameters: 0: progression state <HASHMAP>
    Returns: Codec result <HASHMAP>
    Public: No
*/
params [["_state", createHashMap, [createHashMap]]];
private _fail = {params ["_code"]; createHashMapFromArray [["success", false], ["code", _code]]};
private _validId = {params ["_value"]; _value isEqualType "" && {!(_value isEqualTo "")} && {(toArray _value findIf {!(_x in (toArray "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"))}) < 0}};
private _validCounters = ["infantryKills", "vehicleKills", "assists", "insertions", "passengersDelivered", "transportDistance", "operatorSeconds", "objectiveSupport", "masteryScore", "masteryTier"];
private _owned = +(_state getOrDefault ["ownedVehicleFamilies", []]);
private _used = +(_state getOrDefault ["vehicleFirstSpawnsUsed", []]);
private _mastery = _state getOrDefault ["vehicleMastery", createHashMap];
if !(_owned isEqualType [] && {_used isEqualType []} && {_mastery isEqualType createHashMap}) exitWith {["INVALID_VEHICLE_PROGRESSION"] call _fail};
if ((count _owned) > 128 || {(count _used) > 128} || {_owned findIf {!([_x] call _validId)} >= 0} || {_used findIf {!([_x] call _validId)} >= 0}) exitWith {["INVALID_VEHICLE_FAMILIES"] call _fail};
_owned = _owned arrayIntersect _owned; _owned sort true;
_used = (_used arrayIntersect _used) select {_x in _owned}; _used sort true;
private _rows = [];
private _valid = true;
{
    private _familyId = _x;
    private _counters = _mastery get _familyId;
    if !([_familyId] call _validId && {_counters isEqualType createHashMap}) then {_valid = false; continue};
    private _counterRows = [];
    {
        private _value = _counters get _x;
        if !(_x in _validCounters && {_value isEqualType 0} && {finite _value} && {_value >= 0}) then {_valid = false; continue};
        _counterRows pushBack [_x, floor _value];
    } forEach (keys _counters);
    _counterRows sort true;
    _rows pushBack [_familyId, _counterRows];
} forEach (keys _mastery);
if (!_valid) exitWith {["INVALID_VEHICLE_MASTERY"] call _fail};
_rows sort true;
private _plain = str [_owned, _used, _rows];
private _encoded = "";
{
    if (_x > 255) exitWith {_encoded = ""};
    _encoded = _encoded + (if (_x < 10) then {format ["00%1", _x]} else {if (_x < 100) then {format ["0%1", _x]} else {str _x}});
} forEach (toArray _plain);
private _cfg = missionConfigFile >> "CfgBnKothPersistence";
private _maxSerialized = if (isNumber (_cfg >> "vehicleProgressionMaxSerializedCharacters")) then {(getNumber (_cfg >> "vehicleProgressionMaxSerializedCharacters")) max 3000} else {250000};
if (_encoded isEqualTo "" || {(count _encoded) > _maxSerialized}) exitWith {["VEHICLE_PROGRESSION_TOO_LARGE"] call _fail};
createHashMapFromArray [["success", true], ["code", "SERIALIZED"], ["value", _encoded]]

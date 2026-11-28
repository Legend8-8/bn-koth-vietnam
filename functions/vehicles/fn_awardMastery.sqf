/*
    File: fn_awardMastery.sqf
    Author: Legend
    Description: Adds one server-evidenced contribution to a persistent logical
        vehicle family. This is the sole vehicle-mastery mutation owner.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: family ID <STRING>, 2: counter <STRING>,
        3: positive amount <NUMBER>, 4: evidence reason <STRING>
    Returns: Operation result <HASHMAP>
    Public: No
*/
params ["_uid", "_familyId", "_counter", ["_amount", 1, [0]], ["_reason", "", [""]]];
private _fail = {params ["_code"]; createHashMapFromArray [["success", false], ["code", _code]]};
if (!isServer) exitWith {["NOT_SERVER"] call _fail};
_familyId = toUpper _familyId;
if (_uid isEqualTo "" || {_familyId isEqualTo ""} || {_reason isEqualTo ""}) exitWith {["INVALID_REQUEST"] call _fail};
if !(_counter in ["infantryKills", "vehicleKills", "assists", "insertions", "passengersDelivered", "transportDistance", "operatorSeconds", "objectiveSupport", "masteryScore", "masteryTier"]) exitWith {["INVALID_COUNTER"] call _fail};
if !(_amount isEqualType 0 && {finite _amount} && {_amount > 0}) exitWith {["INVALID_AMOUNT"] call _fail};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _state = _byUid getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {["PROGRESSION_UNAVAILABLE"] call _fail};
private _mastery = _state getOrDefault ["vehicleMastery", createHashMap];
if !(_mastery isEqualType createHashMap) then {_mastery = createHashMap};
private _family = _mastery getOrDefault [_familyId, createHashMap];
if !(_family isEqualType createHashMap) then {_family = createHashMap};
private _next = (_family getOrDefault [_counter, 0]) + (floor _amount);
if !(finite _next) exitWith {["INVALID_RESULT"] call _fail};
_family set [_counter, _next];
_mastery set [_familyId, _family];
_state set ["vehicleMastery", _mastery];
_byUid set [_uid, _state];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
[_uid, format ["vehicle_mastery:%1:%2", _familyId, _counter]] call bn_koth_fnc_persistence_markDirty;
[format ["Vehicle mastery UID=%1 family=%2 counter=%3 amount=%4 total=%5 reason=%6", _uid, _familyId, _counter, floor _amount, _next, _reason], "INFO"] call bn_koth_fnc_common_log;
createHashMapFromArray [["success", true], ["code", "MASTERY_AWARDED"], ["total", _next]]

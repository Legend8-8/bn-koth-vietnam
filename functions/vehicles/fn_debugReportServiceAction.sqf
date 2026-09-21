/*
    File: fn_debugReportServiceAction.sqf
    Author: Legend
    Description: Emits one client-local diagnostic snapshot explaining the
        personal vehicle repair/rearm action's current visibility inputs.
    Execution: Client debug console only
    Parameters: 0: Vehicle to inspect; defaults to player's vehicle/cursor <OBJECT>
    Returns: Diagnostic state <HASHMAP>
    Public: No
*/

params [["_vehicle", objNull, [objNull]]];
if (!hasInterface) exitWith {createHashMapFromArray [["success", false], ["code", "NO_INTERFACE"]]};
if (isNull _vehicle) then {_vehicle = vehicle player};
if (_vehicle isEqualTo player) then {_vehicle = cursorObject};

private _vehicleValid = !isNull _vehicle;
private _owner = _vehicleValid && {(getPlayerUID player) isEqualTo (_vehicle getVariable ["BN_KOTH_personalOwnerUid", ""])};
private _pilot = _vehicleValid && {player isEqualTo driver _vehicle};
private _managed = _vehicleValid && {_vehicle getVariable ["BN_KOTH_isPersonalPaidVehicle", false]};
private _alive = _vehicleValid && {alive _vehicle};
private _enabled = _vehicleValid && {_vehicle getVariable ["BN_KOTH_personalServiceEnabled", false]};
private _mode = if (_vehicleValid) then {_vehicle getVariable ["BN_KOTH_personalServiceMode", "NONE"]} else {"NONE"};
private _sessionActive = _vehicleValid && {_vehicle getVariable ["BN_KOTH_personalServiceActive", false]};
private _roundValid = (missionNamespace getVariable ["BN_KOTH_roundState", ""]) isEqualTo "ACTIVE";
private _pad = if (_vehicleValid) then {_vehicle getVariable ["BN_KOTH_personalServicePadPosition", []]} else {[]};
private _insidePad = _mode isNotEqualTo "SERVICE_PAD" || {(count _pad) >= 2 && {_vehicle distance2D _pad <= (_vehicle getVariable ["BN_KOTH_personalServiceAreaRadius", 35])}};
private _speedOk = _mode isNotEqualTo "SERVICE_PAD" || {abs speed _vehicle <= (_vehicle getVariable ["BN_KOTH_personalServiceMaxSpeed", 5])};
private _engineOk = _mode isNotEqualTo "SERVICE_PAD" || {!(_vehicle getVariable ["BN_KOTH_personalServiceRequireEngineOff", false]) || {!isEngineOn _vehicle}};
private _price = if (_vehicleValid) then {_vehicle getVariable ["BN_KOTH_personalServicePrice", -1]} else {-1};
private _cash = (missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap]) getOrDefault ["cash", -1];
private _result = createHashMapFromArray [
    ["success", true], ["vehicleValid", _vehicleValid], ["owner", _owner], ["pilot", _pilot],
    ["managed", _managed], ["alive", _alive], ["serviceEnabled", _enabled], ["serviceMode", _mode],
    ["sessionActive", _sessionActive], ["roundValid", _roundValid], ["insidePad", _insidePad],
    ["speedOk", _speedOk], ["engineOk", _engineOk], ["price", _price], ["cash", _cash],
    ["cashEnough", _cash >= _price && {_price > 0}],
    ["actionVisible", _owner && {_pilot} && {_managed} && {_alive} && {_enabled} && {_price > 0} && {!_sessionActive} && {_roundValid} && {_insidePad} && {_speedOk} && {_engineOk}]
];
diag_log format ["[BN_KOTH][VEHICLES][DEBUG] SERVICE ACTION: %1", _result];
systemChat format ["SERVICE ACTION: %1", _result];
_result

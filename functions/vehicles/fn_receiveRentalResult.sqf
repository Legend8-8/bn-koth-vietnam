/*
    File: fn_receiveRentalResult.sqf
    Author: Legend
    Description: Receives one requester-only personal vehicle result, exposes
        it to the open Store, and invalidates cached vehicle presentation.
    Execution: Client
    Parameters: 0: Structured vehicle transaction result <HASHMAP>
    Returns: None
    Public: Yes
*/
params [["_result", createHashMap, [createHashMap]]];
if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

missionNamespace setVariable ["BN_KOTH_vehiclePersonalStateLocal", _result getOrDefault ["personalVehicleState", createHashMap]];
uiNamespace setVariable ["BN_KOTH_menuVehicleTransactionResult", _result];
uiNamespace setVariable ["BN_KOTH_menuStoreEntriesRoute", ""];

private _message = _result getOrDefault ["message", "Vehicle request completed."];
private _operation = toUpper (_result getOrDefault ["operation", "VEHICLE"]);
private _success = _result getOrDefault ["success", false];
private _title = _result getOrDefault ["title", ""];
if (_title isEqualTo "") then {_title = format ["VEHICLE %1 %2", _operation, if (_success) then {"COMPLETE"} else {"FAILED"}]};
if ((_result getOrDefault ["code", ""]) isEqualTo "VEHICLE_LIFE_ENDED") then {
    ["CLEAR"] call bn_koth_fnc_vehicles_setPersonalGuidance;
};
[createHashMapFromArray [
    ["title", _title],
    ["body", _message],
    ["footer", ""]
]] call bn_koth_fnc_ui_notify;

diag_log format ["[BN_KOTH][VEHICLE_STORE] Client result operation=%1 class=%2 success=%3 code=%4", _operation, _result getOrDefault ["vehicleClass", ""], _success, _result getOrDefault ["code", "UNKNOWN"]];
private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _display) then {[] call bn_koth_fnc_menu_refresh};

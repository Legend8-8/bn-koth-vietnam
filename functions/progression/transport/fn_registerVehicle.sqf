/*
    File: fn_registerVehicle.sqf
    Author: Legend
    Description: Installs insertion lifecycle handlers on one explicitly
        configured eligible transport vehicle.
    Execution: Server
    Parameters: 0: Vehicle <OBJECT>
    Returns: True when eligible and registered <BOOL>
    Public: No
*/

params [["_vehicle", objNull, [objNull]]];
if (!isServer || {isNull _vehicle} || {_vehicle isKindOf "Man"}) exitWith {false};
if (_vehicle getVariable ["BN_KOTH_transportInsertionRegistered", false]) exitWith {true};

private _metadata = [typeOf _vehicle] call bn_koth_fnc_vehicles_getProgressionMetadata;
if !(_metadata getOrDefault ["success", false]) exitWith {false};
private _categories = missionNamespace getVariable ["BN_KOTH_transportEligibleCategories", ["ROTARY"]];
private _roles = missionNamespace getVariable ["BN_KOTH_transportEligibleRoles", ["TRANSPORT"]];
if !((_metadata getOrDefault ["storeCategory", ""]) in _categories) exitWith {false};
if !((_metadata getOrDefault ["vehicleRole", ""]) in _roles) exitWith {false};

_vehicle setVariable ["BN_KOTH_transportInsertionRegistered", true, false];
_vehicle addEventHandler ["GetIn", {
    _this call bn_koth_fnc_progression_transport_handleGetIn;
}];
_vehicle addEventHandler ["GetOut", {
    _this call bn_koth_fnc_progression_transport_handleGetOut;
}];
_vehicle addEventHandler ["ControlsShifted", {
    params ["_vehicle"];
    ["", _vehicle, "BOARDED"] call bn_koth_fnc_progression_transport_cleanup;
}];
_vehicle addEventHandler ["SeatSwitched", {
    params ["_vehicle"];
    ["", _vehicle, "BOARDED"] call bn_koth_fnc_progression_transport_cleanup;
}];
_vehicle addEventHandler ["Killed", {
    params ["_vehicle"];
    ["", _vehicle] call bn_koth_fnc_progression_transport_cleanup;
}];
_vehicle addEventHandler ["Deleted", {
    params ["_vehicle"];
    ["", _vehicle] call bn_koth_fnc_progression_transport_cleanup;
}];
true

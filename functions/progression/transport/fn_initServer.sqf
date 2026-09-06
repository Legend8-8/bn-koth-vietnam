/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes bounded server-authoritative transport insertion
        reward state and installs event-driven vehicle discovery.
    Execution: Server
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

private _cfg = missionConfigFile >> "CfgBnKothScoring" >> "progression" >> "transportInsertion";
private _readNumber = {
    params ["_name", "_fallback"];
    if (isNumber (_cfg >> _name)) then {getNumber (_cfg >> _name)} else {_fallback}
};

missionNamespace setVariable ["BN_KOTH_transportInsertionXp", (["xpPerPassenger", 25] call _readNumber) max 0];
missionNamespace setVariable ["BN_KOTH_transportMinimumSeconds", (["minimumTransportSeconds", 20] call _readNumber) max 0];
missionNamespace setVariable ["BN_KOTH_transportMinimumDistance", (["minimumTransportDistance", 500] call _readNumber) max 0];
missionNamespace setVariable ["BN_KOTH_transportConfirmationWindow", (["confirmationWindowSeconds", 30] call _readNumber) max 1];
missionNamespace setVariable ["BN_KOTH_transportMaximumBoardedSeconds", (["maximumBoardedSeconds", 900] call _readNumber) max 1];
missionNamespace setVariable ["BN_KOTH_transportPairCooldown", (["samePairCooldownSeconds", 600] call _readNumber) max 0];
missionNamespace setVariable ["BN_KOTH_transportEligibleCategories", if (isArray (_cfg >> "eligibleStoreCategories")) then {(getArray (_cfg >> "eligibleStoreCategories")) apply {toUpper _x}} else {["ROTARY"]}];
missionNamespace setVariable ["BN_KOTH_transportEligibleRoles", if (isArray (_cfg >> "eligibleVehicleRoles")) then {(getArray (_cfg >> "eligibleVehicleRoles")) apply {toUpper _x}} else {["TRANSPORT"]}];
private _economyCfg = missionConfigFile >> "CfgBnKothScoring" >> "economy";
missionNamespace setVariable ["BN_KOTH_transportInsertionCash", if (isNumber (_economyCfg >> "cashPerTransportPassenger")) then {(getNumber (_economyCfg >> "cashPerTransportPassenger")) max 0} else {25}];
missionNamespace setVariable ["BN_KOTH_transportCandidates", createHashMap];
missionNamespace setVariable ["BN_KOTH_transportPairCooldowns", createHashMap];

{
    [_x] call bn_koth_fnc_progression_transport_registerVehicle;
} forEach vehicles;

private _oldEh = missionNamespace getVariable ["BN_KOTH_transportEntityCreatedEh", -1];
if (_oldEh >= 0) then {removeMissionEventHandler ["EntityCreated", _oldEh]};
private _eh = addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    [_entity] call bn_koth_fnc_progression_transport_registerVehicle;
}];
missionNamespace setVariable ["BN_KOTH_transportEntityCreatedEh", _eh];

["Transport insertion rewards initialized (server, event-driven).", "INFO"] call bn_koth_fnc_common_log;

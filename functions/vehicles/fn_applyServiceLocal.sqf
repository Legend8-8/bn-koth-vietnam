/*
    File: fn_applyServiceLocal.sqf
    Author: Legend
    Description: Refills the current vehicle weapon/magazine configuration on
        each machine so every locally-owned turret is covered. It does not edit
        pylons, magazines, weapons, or loadout selection.
    Execution: Server and clients, server-authorized
    Parameters: 0: Serviced vehicle <OBJECT>
    Returns: None
    Public: Yes
*/

params [["_vehicle", objNull, [objNull]]];
if (!isRemoteExecuted || {remoteExecutedOwner isNotEqualTo 2}) exitWith {};
if (isNull _vehicle || {!alive _vehicle} || {!(_vehicle getVariable ["BN_KOTH_isPersonalPaidVehicle", false])}) exitWith {};
_vehicle setVehicleAmmo 1;

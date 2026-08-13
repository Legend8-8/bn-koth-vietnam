/*
    File: fn_clearVehicleInventory.sqf
    Author: tylervip
    Description: Removes transport inventory from a spawned vehicle.
    Execution: Server
    Parameters:
        0: Vehicle to clear <OBJECT>
    Returns:
        True when inventory was cleared, otherwise false <BOOL>
    Public: Yes
*/

params [["_vehicle", objNull, [objNull]]];

if (!isServer) exitWith {false};
if (isNull _vehicle) exitWith {false};

clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

true
/*
    File: fn_executeTeleport.sqf
    Author: tylervip
    Description: Client-side execution for validated teleport into command vehicle cargo.
    Execution: Client
    Parameters:
        0: Destination command vehicle <OBJECT>
    Returns:
        None
    Public: Yes
*/

params [["_vehicle", objNull, [objNull]]];

if (!hasInterface) exitWith {};
if (isNull _vehicle || {!alive _vehicle}) exitWith {
    ["Command vehicle is unavailable."] call bn_koth_fnc_ui_notify;
};

if (!local player) exitWith {};

player moveInCargo _vehicle;

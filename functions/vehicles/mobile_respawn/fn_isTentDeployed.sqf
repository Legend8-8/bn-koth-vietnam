/*
    File: fn_isTentDeployed.sqf
    Author: tylervip
    Description: Returns whether command vehicle tent is deployed.
    Execution: Any
    Parameters:
        0: Vehicle to check <OBJECT>
    Returns:
        True when deployed, else false <BOOL>
    Public: Yes
*/

params ["_vehicle"];

if (isNull _vehicle) exitWith {false};

// hide_tent: 0 = deployed, 1 = stowed
(_vehicle animationPhase "hide_tent") < 0.01

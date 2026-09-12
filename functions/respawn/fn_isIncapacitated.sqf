/*
    File: fn_isIncapacitated.sqf
    Author: Legend
    Description: Derives whether a living unit is currently incapacitated from
        engine state and S.O.G.'s replicated incapacitation variable.
    Execution: Any
    Parameters:
        0: Unit <OBJECT>
    Returns:
        True when the living unit is incapacitated <BOOL>
    Public: Yes
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!alive _unit}) exitWith {false};
if !(_unit isKindOf "Man") exitWith {false};
if ((lifeState _unit) isEqualTo "INCAPACITATED") exitWith {true};
(_unit getVariable ["vn_revive_incapacitated", false]) isEqualTo true

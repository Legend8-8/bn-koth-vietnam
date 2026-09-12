/*
    File: fn_isInventoryLocked.sqf
    Author: Mongo
    Description: Checks whether physical inventory access crosses either active safe-zone boundary.
    Execution: Client
    Parameters:
        0: Local player unit <OBJECT>
        1: Primary inventory container <OBJECT>
        2: Secondary inventory container <OBJECT>
    Returns:
        True when physical inventory access must be blocked <BOOL>
    Public: No
*/

params [
    ["_unit", objNull, [objNull]],
    ["_primaryContainer", objNull, [objNull]],
    ["_secondaryContainer", objNull, [objNull]]
];

if (!hasInterface || {isNull _unit}) exitWith {false};

private _roundState = [] call bn_koth_fnc_round_getState;
private _systemActive = _roundState in ["PREPARING", "ACTIVE"];
if (!_systemActive) exitWith {false};

private _locked = false;
{
    if (!isNull _x) then {
        private _membership = [_x, true] call bn_koth_fnc_respawn_getSafeZoneMembership;
        if ((_membership select 0) || {_membership select 1}) exitWith {
            _locked = true;
        };
    };
} forEach [_unit, _primaryContainer, _secondaryContainer];

_locked

/*
    File: fn_cleanupDeadBody.sqf
    Author: tylervip
    Description: Deletes a dead player body after a short delay when it is outside active safe zones.
    Execution: Server (scheduled)
    Parameters:
        0: Dead player body <OBJECT>
    Returns:
        True when a body was deleted, otherwise false <BOOL>
    Public: Yes
*/

params [["_unit", objNull, [objNull]]];

if (!isServer || {isNull _unit}) exitWith {false};
if !(_unit isKindOf "Man") exitWith {false};
if (alive _unit) exitWith {false};
if !(isPlayer _unit) exitWith {false};

private _roundState = [] call bn_koth_fnc_round_getState;
private _systemActive = _roundState in ["PREPARING", "ACTIVE"];
private _membership = [_unit, _systemActive] call bn_koth_fnc_respawn_getSafeZoneMembership;
private _insideSafeZone = (_membership select 0) || {_membership select 1};

if (_insideSafeZone) exitWith {
    deleteVehicle _unit;
    true
};

private _cfg = missionConfigFile >> "CfgBnKothRespawn";
private _delaySeconds = if (isNumber (_cfg >> "corpseCleanupDelaySeconds")) then {
    getNumber (_cfg >> "corpseCleanupDelaySeconds")
} else {
    15
};

sleep (_delaySeconds max 0);

if (!isNull _unit && {(_unit isKindOf "Man") && {!alive _unit}}) then {
    private _postMembership = [_unit, _systemActive] call bn_koth_fnc_respawn_getSafeZoneMembership;
    private _stillInsideSafeZone = (_postMembership select 0) || {_postMembership select 1};

    if (_stillInsideSafeZone) exitWith {
        false
    };

    deleteVehicle _unit;
    true
} else {
    false
};

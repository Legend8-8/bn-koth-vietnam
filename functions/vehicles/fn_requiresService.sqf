/*
    File: fn_requiresService.sqf
    Author: Legend
    Description: Compares a personal vehicle's current damage and ammunition
        with its server-captured post-spawn baseline.
    Execution: Server
    Parameters: 0: Personal vehicle <OBJECT>
    Returns: True when repair or ammunition refill is required <BOOL>
    Public: No
*/

params [["_vehicle", objNull, [objNull]]];
if (!isServer || {isNull _vehicle} || {!alive _vehicle}) exitWith {false};

private _hitpointDamage = (getAllHitPointsDamage _vehicle) param [2, []];
if ((damage _vehicle) > 0.001 || {_hitpointDamage findIf {_x > 0.001} >= 0}) exitWith {true};

private _baseline = _vehicle getVariable ["BN_KOTH_personalServiceAmmoBaseline", []];
private _currentTotals = createHashMap;
{
    private _key = format ["%1|%2", toLower (_x select 0), _x select 1];
    _currentTotals set [_key, (_currentTotals getOrDefault [_key, 0]) + (_x select 2)];
} forEach (magazinesAllTurrets _vehicle);
if (_baseline findIf {
    _x params ["_key", "_amount"];
    (_currentTotals getOrDefault [_key, 0]) < _amount
} >= 0) exitWith {true};

private _pylonBaseline = _vehicle getVariable ["BN_KOTH_personalServicePylonBaseline", []];
if (_pylonBaseline findIf {
    _x params ["_index", "_amount"];
    (_vehicle ammoOnPylon _index) < _amount
} >= 0) exitWith {true};

false

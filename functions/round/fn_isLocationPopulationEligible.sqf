/*
    File: fn_isLocationPopulationEligible.sqf
    Author: Legend
    Description: Evaluates one configured AO's inclusive connected-human population range.
    Execution: Server/Client (pure)
    Parameters:
        0: Location ID or resolved location data <STRING/HASHMAP>
        1: Connected-human population <NUMBER>
    Returns: True when population is inside the authored range <BOOL>
    Public: Yes
*/

params ["_location", ["_population", 0, [0]]];

private _data = if (_location isEqualType "") then {
    [_location] call bn_koth_fnc_zone_getLocationData
} else {
    _location
};
if !(_data isEqualType createHashMap) exitWith {false};
if ((count _data) <= 0) exitWith {false};

private _minimum = floor ((_data getOrDefault ["minPlayers", 0]) max 0);
private _maximum = floor (_data getOrDefault ["maxPlayers", -1]);
if (_maximum < -1) then {_maximum = -1};
if (_maximum >= 0 && {_maximum < _minimum}) exitWith {false};

_population >= _minimum && {(_maximum < 0) || {_population <= _maximum}}

/*
    File: fn_findAirPosition.sqf
    Author: Legend
    Description: Finds a terrain-relative, world-bounded airborne position
        around the active AO for personal jet spawn and service-gate use.
    Execution: Server/Any test context
    Parameters:
        0: AO centre ATL/2D position <ARRAY>
        1: Minimum AO offset metres <NUMBER>
        2: Maximum AO offset metres <NUMBER>
        3: Altitude above terrain metres <NUMBER>
        4: Required aircraft clearance metres <NUMBER> (optional)
    Returns: Position/heading data, or an empty hash map <HASHMAP>
    Public: No
*/

params [
    ["_aoPosition", [], [[]]],
    ["_minimumDistance", 0, [0]],
    ["_maximumDistance", 0, [0]],
    ["_altitudeAgl", 0, [0]],
    ["_aircraftClearance", 0, [0]]
];

if ((count _aoPosition) < 2 || {_minimumDistance <= 0} || {_maximumDistance < _minimumDistance} || {_altitudeAgl < 50}) exitWith {createHashMap};

private _cfg = missionConfigFile >> "CfgBnKothVehicles";
private _attempts = ((getNumber (_cfg >> "airbornePlacementAttempts")) max 1) min 100;
private _worldMargin = (getNumber (_cfg >> "airborneWorldEdgeMarginMeters")) max 0;
private _mapSize = worldSize;
private _result = createHashMap;

for "_attempt" from 1 to _attempts do {
    private _bearing = random 360;
    private _distance = _minimumDistance + random (_maximumDistance - _minimumDistance);
    private _candidate2d = [
        (_aoPosition select 0) + (sin _bearing * _distance),
        (_aoPosition select 1) + (cos _bearing * _distance)
    ];
    private _insideWorld = (_candidate2d select 0) >= _worldMargin
        && {(_candidate2d select 1) >= _worldMargin}
        && {(_candidate2d select 0) <= (_mapSize - _worldMargin)}
        && {(_candidate2d select 1) <= (_mapSize - _worldMargin)};
    if (!_insideWorld) then {continue};
    if (_aircraftClearance > 0 && {(count (nearestObjects [_candidate2d, ["Air"], _aircraftClearance])) > 0}) then {continue};

    private _terrainAsl = getTerrainHeightASL _candidate2d;
    private _positionAsl = [_candidate2d select 0, _candidate2d select 1, _terrainAsl + _altitudeAgl];
    _result = createHashMapFromArray [
        ["positionASL", _positionAsl],
        ["heading", _candidate2d getDir _aoPosition],
        ["bearing", _bearing],
        ["distance", _distance],
        ["terrainASL", _terrainAsl],
        ["altitudeAGL", _altitudeAgl]
    ];
    if ((count _result) > 0) exitWith {};
};

_result

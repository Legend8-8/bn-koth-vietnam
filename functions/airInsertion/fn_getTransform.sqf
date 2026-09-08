/*
    File: fn_getTransform.sqf
    Author: Legend
    Description: Derives a terrain-aware randomized inbound aircraft transform.
    Execution: Server/Any test context
    Parameters:
        0: AO centre ATL/2D position <ARRAY>
        1: Insertion bearing from AO <NUMBER> (optional, random)
        2: Insertion distance <NUMBER> (optional, config-randomized)
    Returns: Transform data <HASHMAP>
    Public: No
*/

params [
    ["_aoPosition", [], [[]]],
    ["_bearing", random 360, [0]],
    ["_distance", -1, [0]]
];

private _cfg = missionConfigFile >> "CfgBnKothAirInsertion";
private _minDistance = (getNumber (_cfg >> "minDistance")) max 1;
private _maxDistance = (getNumber (_cfg >> "maxDistance")) max _minDistance;
private _altitudeAgl = (getNumber (_cfg >> "altitudeAGL")) max 50;
if (_distance < 0) then {_distance = _minDistance + random (_maxDistance - _minDistance)};
_distance = (_distance max _minDistance) min _maxDistance;

if ((count _aoPosition) < 2) exitWith {createHashMap};

private _offset = [sin _bearing * _distance, cos _bearing * _distance];
private _spawn2d = [(_aoPosition select 0) + (_offset select 0), (_aoPosition select 1) + (_offset select 1)];
private _spawnAsl = [_spawn2d select 0, _spawn2d select 1, (getTerrainHeightASL _spawn2d) + _altitudeAgl];
private _heading = _spawn2d getDir _aoPosition;

createHashMapFromArray [
    ["spawnASL", _spawnAsl],
    ["heading", _heading],
    ["distance", _distance],
    ["bearing", _bearing],
    ["terrainASL", getTerrainHeightASL _spawn2d],
    ["altitudeAGL", _altitudeAgl]
]

/*
    File: fn_snapshotTerrain.sqf
    Author: Legend
    Description: Retains original restorable AO terrain in the active capture marker before deployment.
    Execution: Server
    Parameters:
        0: Active location ID <STRING>
        1: Active capture marker <STRING>
    Returns:
        True when a snapshot exists for this AO, otherwise false <BOOL>
    Public: No
*/

params [["_locationId", "", [""]], ["_marker", "", [""]]];
if (!isServer) exitWith {false};

private _previous = missionNamespace getVariable ["BN_KOTH_terrainSnapshot", createHashMap];
if (_previous isEqualType createHashMap && {(count _previous) > 0}) exitWith {
    private _same = (_previous getOrDefault ["locationId", ""]) isEqualTo _locationId
        && {(_previous getOrDefault ["marker", ""]) isEqualTo _marker};
    if (!_same) then {
        [format ["Terrain snapshot rejected for %1: snapshot for %2 remains", _locationId, _previous getOrDefault ["locationId", ""]], "ERROR"] call bn_koth_fnc_common_log;
    };
    _same
};

if (_locationId isEqualTo "" || {_marker isEqualTo ""} || {(markerShape _marker) isEqualTo ""}) exitWith {
    [format ["Terrain snapshot rejected for %1: capture marker %2 is unavailable", _locationId, _marker], "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _size = markerSize _marker;
if !((markerShape _marker) in ["RECTANGLE", "ELLIPSE"] && {(_size select 0) > 0} && {(_size select 1) > 0}) exitWith {
    [format ["Terrain snapshot rejected for %1: capture marker %2 has no supported area", _locationId, _marker], "ERROR"] call bn_koth_fnc_common_log;
    false
};
private _radius = sqrt (((_size select 0) * (_size select 0)) + ((_size select 1) * (_size select 1)));
private _types = [
    "BUILDING", "BUNKER", "BUSH", "BUSSTOP", "CHAPEL", "CHURCH", "CROSS",
    "FENCE", "FORTRESS", "FOUNTAIN", "FUELSTATION", "HOSPITAL",
    "HOUSE", "LIGHTHOUSE", "POWER LINES", "POWERSOLAR", "POWERWAVE",
    "POWERWIND", "QUAY", "SHIPWRECK", "SMALL TREE", "STACK", "TOURISM",
    "TRANSMITTER", "TREE", "VIEW-TOWER", "WALL", "WATERTOWER"
];
private _entries = [];
{
    if (!isNull _x && {!isObjectHidden _x} && {!(_x isKindOf "Ruins")} && {_x inArea _marker}) then {
        _entries pushBack [_x, getPosATL _x, vectorDir _x, vectorUp _x];
    };
} forEach (nearestTerrainObjects [markerPos _marker, _types, _radius, false, true]);

missionNamespace setVariable ["BN_KOTH_terrainSnapshot", createHashMapFromArray [
    ["locationId", _locationId], ["marker", _marker], ["entries", _entries]
]];
[format ["Terrain snapshot AO=%1 marker=%2 retained=%3", _locationId, _marker, count _entries], "INFO"] call bn_koth_fnc_common_log;
true

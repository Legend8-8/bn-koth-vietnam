/*
    File: fn_resolveVerticalPriorityGeometry.sqf
    Author: Legend
    Description: Resolves and validates authored vertical Priority floors and footprint.
    Execution: Server
    Parameters: 0: Resolved location data <HASHMAP>
    Returns: Geometry with marker and [label, anchor ASL, lower ASL, upper ASL] floors, or empty map <HASHMAP>
    Public: No
*/

params [["_locationData", createHashMap, [createHashMap]]];
if (!isServer) exitWith {createHashMap};

private _locationId = _locationData getOrDefault ["id", ""];
private _marker = _locationData getOrDefault ["priorityFootprintMarker", ""];
private _anchors = _locationData getOrDefault ["priorityFloorAnchors", []];
private _labels = _locationData getOrDefault ["priorityFloorLabels", []];
private _size = markerSize _marker;
if (_marker isEqualTo "" || {(markerShape _marker) isNotEqualTo "RECTANGLE"} || {(markerAlpha _marker) > 0} || {(count _size) < 2} || {(_size select 0) <= 0} || {(_size select 1) <= 0}) exitWith {
    [format ["Vertical Priority '%1': missing or invalid rectangular footprint '%2'.", _locationId, _marker], "ERROR"] call bn_koth_fnc_common_log;
    createHashMap
};
if ((count _anchors) < 2 || {(count _labels) isNotEqualTo (count _anchors)}) exitWith {
    [format ["Vertical Priority '%1': floor anchors and labels are missing or mismatched.", _locationId], "ERROR"] call bn_koth_fnc_common_log;
    createHashMap
};

private _heights = [];
private _invalid = false;
{
    private _name = _x;
    if (!(_name isEqualType "") || {_name isEqualTo ""} || {!((_labels select _forEachIndex) isEqualType "")} || {(_labels select _forEachIndex) isEqualTo ""}) exitWith {
        [format ["Vertical Priority '%1': invalid floor anchor or label at index %2.", _locationId, _forEachIndex], "ERROR"] call bn_koth_fnc_common_log;
        _invalid = true;
    };
    private _anchor = missionNamespace getVariable [_name, objNull];
    if (!(_anchor isEqualType objNull) || {isNull _anchor} || {!(_anchor isKindOf "Logic")}) exitWith {
        [format ["Vertical Priority '%1': floor Logic '%2' is missing or malformed.", _locationId, _name], "ERROR"] call bn_koth_fnc_common_log;
        _invalid = true;
    };
    private _height = (getPosWorld _anchor) select 2;
    if ((count _heights) > 0 && {_height - (_heights select ((count _heights) - 1)) < 1}) exitWith {
        [format ["Vertical Priority '%1': floor Logic '%2' is not at least 1m above the preceding anchor.", _locationId, _name], "ERROR"] call bn_koth_fnc_common_log;
        _invalid = true;
    };
    _heights pushBack _height;
} forEach _anchors;
if (_invalid) exitWith {createHashMap};

private _floors = [];
private _surfaceTolerance = ((_locationData getOrDefault ["priorityFloorSurfaceTolerance", 0.35]) max 0) min 0.75;
{
    private _index = _forEachIndex;
    private _height = _x;
    // Each Logic marks the walkable floor surface. A small foot-position margin
    // keeps a player standing on it inside the volume; the next midpoint caps it.
    private _lower = _height - _surfaceTolerance;
    private _upper = if (_index isEqualTo ((count _heights) - 1)) then {
        _height + (_height - (_heights select (_index - 1))) / 2
    } else {
        (_height + (_heights select (_index + 1))) / 2
    };
    _floors pushBack [_labels select _index, _height, _lower, _upper];
} forEach _heights;

createHashMapFromArray [["marker", _marker], ["floors", _floors]]

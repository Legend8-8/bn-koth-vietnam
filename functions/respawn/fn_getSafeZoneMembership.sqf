/*
    File: fn_getSafeZoneMembership.sqf
    Author: Mongo
    Description: Resolves whether an object or position is inside either active base safe zone.
    Execution: Any
    Parameters:
        0: Object or position to test <OBJECT|ARRAY>
        1: Safe-zone system active <BOOL> (default: true)
        2: WEST safe-zone marker <STRING> (default: published active marker)
        3: EAST safe-zone marker <STRING> (default: published active marker)
    Returns:
        [inside WEST safe zone, inside EAST safe zone] <ARRAY>
    Public: Yes
*/

params [
    ["_subject", objNull, [objNull, []]],
    ["_systemActive", true, [true]],
    ["_westMarker", missionNamespace getVariable ["BN_KOTH_activeWestBaseZoneMarker", ""], [""]],
    ["_eastMarker", missionNamespace getVariable ["BN_KOTH_activeEastBaseZoneMarker", ""], [""]]
];

if (!_systemActive) exitWith {[false, false]};
if (_subject isEqualType objNull && {isNull _subject}) exitWith {[false, false]};
if (_subject isEqualType [] && {(count _subject) < 2}) exitWith {[false, false]};

private _markersValid = !(_westMarker isEqualTo "")
    && {!(_eastMarker isEqualTo "")}
    && {!((markerShape _westMarker) isEqualTo "")}
    && {!((markerShape _eastMarker) isEqualTo "")};
if (!_markersValid) exitWith {[false, false]};

private _position = if (_subject isEqualType objNull) then {
    getPosWorld _subject
} else {
    _subject
};

[
    _position inArea _westMarker,
    _position inArea _eastMarker
]

/*
    File: fn_registerObject.sqf
    Author: tylervip
    Description: Registers a player-built object in the server side build tracking array.
    Execution: Server
    Parameters:
        0: Object <OBJECT>
    Returns: <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

params [
    ["_object", objNull, [objNull]]
];

if (isNull _object) exitWith {false};

private _tracked = missionNamespace getVariable ["BN_KOTH_buildObjects", []];
if !(_tracked isEqualType []) then {
    _tracked = [];
};

if !(_object in _tracked) then {
    _tracked pushBack _object;
};

missionNamespace setVariable ["BN_KOTH_buildObjects", _tracked];
true

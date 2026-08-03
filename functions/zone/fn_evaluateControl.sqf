/*
    File: fn_evaluateControl.sqf
    Description: Computes zone population and controlling side.
    Execution: Server
*/

if (!isServer) exitWith {sideUnknown};

private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", "saigon_zone"];
if (_marker isEqualTo "") exitWith {sideUnknown};

private _players = allPlayers select {
    alive _x
    && {!(_x getVariable ["BIS_revive_incapacitated", false])}
    && {((side group _x) in [west, east])}
    && {_x inArea _marker}
};

private _westCount = {side group _x == west} count _players;
private _eastCount = {side group _x == east} count _players;

private _controller = sideUnknown;
private _zoneState = "NEUTRAL";

if ((_westCount > 0) || (_eastCount > 0)) then {
    if (_westCount == _eastCount) then {
        _zoneState = "CONTESTED";
    } else {
        if (_westCount > _eastCount) then {
            _controller = west;
        } else {
            _controller = east;
        };
        _zoneState = "CONTROLLED";
    };
};

private _previousController = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
private _previousState = missionNamespace getVariable ["BN_KOTH_zoneState", "NEUTRAL"];

if (!(_previousController isEqualTo _controller)) then {
    [format ["Zone controller changed to %1", _controller]] call bn_koth_fnc_log;
};

if !(_previousState isEqualTo _zoneState) then {
    [format ["Zone state changed to %1", _zoneState]] call bn_koth_fnc_log;
};

["BN_KOTH_zoneController", _controller] call bn_koth_fnc_publicState;
["BN_KOTH_zoneState", _zoneState] call bn_koth_fnc_publicState;
["BN_KOTH_zonePopulation", [_westCount, _eastCount]] call bn_koth_fnc_publicState;

_controller

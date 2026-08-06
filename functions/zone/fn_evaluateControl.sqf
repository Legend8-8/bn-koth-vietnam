/*
    File: fn_evaluateControl.sqf
    Author: tylervip
    Description: Computes zone population and controlling side.
    Execution: Server
    Parameters:
        None
    Returns:
        Controlling side or sideUnknown <SIDE>
    Public: Yes
*/

if (!isServer) exitWith {sideUnknown};

private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
if (_marker isEqualTo "") exitWith {
    if !(missionNamespace getVariable ["BN_KOTH_warnedMissingZoneMarker", false]) then {
        missionNamespace setVariable ["BN_KOTH_warnedMissingZoneMarker", true];
        ["Zone evaluation skipped: BN_KOTH_activeZoneMarker is empty.", "WARN"] call bn_koth_fnc_log;
    };
    sideUnknown
};

missionNamespace setVariable ["BN_KOTH_warnedMissingZoneMarker", false];

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _sideA = _playableSides select 0;
private _sideB = _playableSides select 1;

private _players = allPlayers select {
    alive _x
    && {!(_x getVariable ["BIS_revive_incapacitated", false])}
    && {[(side group _x)] call bn_koth_fnc_teams_validateSide}
    && {_x inArea _marker}
};

private _sideACount = {side group _x == _sideA} count _players;
private _sideBCount = {side group _x == _sideB} count _players;

private _controller = sideUnknown;
private _zoneState = "NEUTRAL";

if ((_sideACount > 0) || (_sideBCount > 0)) then {
    if (_sideACount == _sideBCount) then {
        _zoneState = "CONTESTED";
    } else {
        if (_sideACount > _sideBCount) then {
            _controller = _sideA;
        } else {
            _controller = _sideB;
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
["BN_KOTH_zonePopulation", [_sideACount, _sideBCount]] call bn_koth_fnc_publicState;

_controller

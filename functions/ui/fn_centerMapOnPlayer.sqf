/*
    File: fn_centerMapOnPlayer.sqf
    Author: tylervip
    Description: Centers the map on the local player once when the map opens.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!hasInterface) exitWith {};
if !(missionNamespace getVariable ["BN_KOTH_centerMapOnOpen", true]) exitWith {};
if !(visibleMap) exitWith {};

private _zoom = 0.08;
private _position = getPos player;

private _mapDisplay = findDisplay 12;
private _mapControl = if (isNull _mapDisplay) then {controlNull} else {_mapDisplay displayCtrl 51};
if (isNull _mapControl) exitWith {};

_mapControl ctrlMapAnimAdd [0.2, _zoom, _position];
ctrlMapAnimCommit _mapControl;

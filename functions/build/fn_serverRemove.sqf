/*
    File: fn_serverRemove.sqf
    Author: tylervip
    Description: Optional server-side removal of a player-owned build object.
    Execution: Server
    Parameters:
        0: Object <OBJECT>
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

params [["_object", objNull, [objNull]]];
if (isNull _object) exitWith {};

private _buildCfg = missionConfigFile >> "CfgBnKothBuild";
if !(isClass _buildCfg) exitWith {};
if ((getNumber (_buildCfg >> "allowDeleteOwn")) <= 0) exitWith {};

private _tracked = missionNamespace getVariable ["BN_KOTH_buildObjects", []];
if !(_tracked isEqualType []) exitWith {};
if !(_object in _tracked) exitWith {};

private _owner = _object getVariable ["bn_koth_build_owner", ""];
if (_owner isEqualTo "") exitWith {};

private _player = [_owner] call BIS_fnc_getUnitByUID;
if (isNull _player) exitWith {};

if (remoteExecutedOwner != owner _player) exitWith {};

_tracked = _tracked - [_object];
missionNamespace setVariable ["BN_KOTH_buildObjects", _tracked];

deleteVehicle _object;

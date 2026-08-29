/*
    File: fn_ackCleanup.sqf
    Author: Legend
    Description: Resolves a cleanup acknowledgement from its remote owner and
        asks the server to verify the server-stored transaction and unit loadout.
    Execution: Server (remote endpoint)
    Public: Yes
*/
params [["_token", "", [""]]];
if (!isServer) exitWith {};
private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {};
private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {};
private _uid = getPlayerUID _playerObj;
private _result = [_uid, _token, _playerObj] call bn_koth_fnc_progression_perks_completeCleanup;
[_result] remoteExecCall ["bn_koth_fnc_ui_receivePerkResult", _ownerId];

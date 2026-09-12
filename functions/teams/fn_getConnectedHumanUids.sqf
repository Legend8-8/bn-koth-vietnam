/*
    File: fn_getConnectedHumanUids.sqf
    Author: Legend
    Description: Returns registered, currently connected human player UIDs for AO population sizing.
    Execution: Server
    Parameters: None
    Returns: Connected human player UIDs <ARRAY>
    Public: Yes
*/

if (!isServer) exitWith {[]};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {[]};

private _connected = [];
{
    private _uid = _x;
    private _record = _records getOrDefault [_uid, createHashMap];
    if (_uid isEqualTo "" || {!(_record isEqualType createHashMap)}) then {continue};
    if !((_record getOrDefault ["uid", ""]) isEqualTo _uid) then {continue};

    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) then {continue};

    private _player = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (isNull _player || {!isPlayer _player}) then {continue};
    if !((getPlayerUID _player) isEqualTo _uid) then {continue};

    _connected pushBack _uid;
} forEach (keys _records);

_connected sort true;
_connected

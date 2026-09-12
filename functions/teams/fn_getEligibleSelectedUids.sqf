/*
    File: fn_getEligibleSelectedUids.sqf
    Author: Legend
    Description: Returns connected team-selected player UIDs eligible for next-round WAITING vote/deploy flow.
    Execution: Server
    Parameters:
        None
    Returns:
        Eligible player UIDs <ARRAY>
    Public: Yes
*/

if (!isServer) exitWith {[]};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {[]};

private _eligible = [];

{
    private _uid = _x;
    private _record = _records get _uid;

    if !(_record isEqualType createHashMap) then {
        continue;
    };

    private _state = _record getOrDefault ["state", "LOBBY"];
    private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
    private _ownerId = _record getOrDefault ["ownerId", -1];

    if !(_state isEqualTo "TEAM_SELECTED") then {
        continue;
    };

    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
        continue;
    };

    if (_ownerId <= 0) then {
        continue;
    };

    private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (isNull _playerObj) then {
        continue;
    };

    _eligible pushBackUnique _uid;
} forEach (keys _records);

_eligible

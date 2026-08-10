/*
    File: fn_maybeShortenVoteDeadline.sqf
    Author: Legend
    Description: Shortens an open authoritative vote deadline once every connected pre-round lobby player has selected a team and cast a valid vote.
    Execution: Server
    Parameters:
        None
    Returns:
        True when the deadline was shortened, otherwise false <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

private _roundState = [] call bn_koth_fnc_round_getState;
if !(_roundState isEqualTo "WAITING") exitWith {false};

if !(missionNamespace getVariable ["BN_KOTH_voteOpen", false]) exitWith {false};

private _voteEndAt = missionNamespace getVariable ["BN_KOTH_voteEndAt", -1];
if (_voteEndAt <= -1) exitWith {false};

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _gracePeriod = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "earlyVoteGracePeriod")} else {5};
if (_gracePeriod < 1) then {
    _gracePeriod = 1;
};

private _remaining = _voteEndAt - serverTime;
if (_remaining <= _gracePeriod) exitWith {false};

private _candidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
if ((count _candidates) <= 0) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {false};

private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if !(_votesByUid isEqualType createHashMap) then {
    _votesByUid = createHashMap;
};

private _connectedCount = 0;
private _allSelectedAndVoted = true;

{
    private _uid = _x;
    private _record = _records get _uid;

    if !(_record isEqualType createHashMap) then {
        continue;
    };

    private _ownerId = _record getOrDefault ["ownerId", -1];
    if (_ownerId <= 0) then {
        continue;
    };

    private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
    if (isNull _playerObj) then {
        continue;
    };

    _connectedCount = _connectedCount + 1;

    private _state = _record getOrDefault ["state", "LOBBY"];
    private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];
    private _voteLocationId = _votesByUid getOrDefault [_uid, ""];

    if !(_state isEqualTo "TEAM_SELECTED") exitWith {
        _allSelectedAndVoted = false;
    };

    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {
        _allSelectedAndVoted = false;
    };

    if !(_voteLocationId in _candidates) exitWith {
        _allSelectedAndVoted = false;
    };
} forEach (keys _records);

if (_connectedCount <= 0) exitWith {false};
if (!_allSelectedAndVoted) exitWith {false};

private _shortenedEndAt = serverTime + _gracePeriod;
["BN_KOTH_voteEndAt", _shortenedEndAt] call bn_koth_fnc_common_publicState;

[format [
    "Vote deadline shortened from %1 to %2 after %3 connected pre-round players selected teams and voted.",
    _voteEndAt,
    _shortenedEndAt,
    _connectedCount
], "INFO"] call bn_koth_fnc_common_log;

true
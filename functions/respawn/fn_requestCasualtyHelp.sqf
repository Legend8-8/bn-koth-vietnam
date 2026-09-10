/*
    File: fn_requestCasualtyHelp.sqf
    Author: Legend
    Description: Validates client Call For Help intent and records one request for the current casualty representation.
    Execution: Server, client-to-server RemoteExec
    Parameters: None; caller identity is derived from remoteExecutedOwner
    Returns:
        True when a new request was accepted <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {false};

private _unit = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _unit || {!isPlayer _unit} || {!alive _unit}) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {false};
private _uid = [_unit, _records] call bn_koth_fnc_common_resolvePlayerUid;
private _record = _records getOrDefault [_uid, createHashMap];
if (_uid isEqualTo "" || {!(_record isEqualType createHashMap)}) exitWith {false};

private _side = _record getOrDefault ["assignedSide", sideUnknown];
if (
    !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE")
    || {!((_record getOrDefault ["ownerId", -1]) isEqualTo _ownerId)}
    || {!((_record getOrDefault ["currentUnit", objNull]) isEqualTo _unit)}
    || {!((_record getOrDefault ["state", ""]) isEqualTo "ACTIVE")}
    || {!(_record getOrDefault ["deployed", false])}
    || {!([_side] call bn_koth_fnc_teams_validateSide)}
    || {!([_unit] call bn_koth_fnc_respawn_isIncapacitated)}
) exitWith {false};

private _requests = missionNamespace getVariable ["BN_KOTH_casualtyHelpRequests", createHashMap];
if !(_requests isEqualType createHashMap) then {_requests = createHashMap};
if (_uid in (keys _requests)) exitWith {false};

_requests set [_uid, [_unit, _side]];
missionNamespace setVariable ["BN_KOTH_casualtyHelpRequests", _requests];
[] call bn_koth_fnc_respawn_publishCasualtyHelpState;
true

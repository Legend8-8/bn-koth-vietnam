/*
    File: fn_serverValidateAndMark.sqf
    Author: tylervip
    Description: Validates a team enemy spot request and authoritatively marks the target unit.
    Execution: Server
    Parameters:
        0: Target enemy unit <OBJECT>
    Returns: True when the mark was accepted <BOOL>
    Public: Yes
*/

params ["_targetUnit"];

if (!isServer) exitWith {false};
if (isNull _targetUnit || {!alive _targetUnit} || {!(_targetUnit isKindOf "Man")}) exitWith {false};

private _ownerId = remoteExecutedOwner;
private _requester = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _requester) exitWith {false};
if (!alive _requester) exitWith {false};

private _requesterUid = getPlayerUID _requester;
private _targetUid = getPlayerUID _targetUnit;
if (_requesterUid isEqualTo "" || {_targetUid isEqualTo ""}) exitWith {false};

private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_playerAssignments isEqualType createHashMap) then {
    _playerAssignments = createHashMap;
};

private _requesterSide = _playerAssignments getOrDefault [_requesterUid, side group _requester];
private _targetSide = _playerAssignments getOrDefault [_targetUid, side group _targetUnit];

if !([_requesterSide] call bn_koth_fnc_teams_validateSide) exitWith {false};
if !([_targetSide] call bn_koth_fnc_teams_validateSide) exitWith {false};
if (_requesterSide isEqualTo _targetSide) exitWith {false};

private _maxDistance = getNumber (missionConfigFile >> "CfgBnKothPlayer3DIcons" >> "enemyMarkMaxDistance");
if (_maxDistance <= 0) then {_maxDistance = 400;};
if (_requester distance2D _targetUnit > _maxDistance) exitWith {false};

private _lastSpotTime = _requester getVariable ["BN_KOTH_enemySpottingLastMarkTime", -9999];
if ((time - _lastSpotTime) < 2.5) exitWith {false};
_requester setVariable ["BN_KOTH_enemySpottingLastMarkTime", time, false];

private _duration = getNumber (missionConfigFile >> "CfgBnKothPlayer3DIcons" >> "temporaryEnemyMarkDuration");
if (_duration <= 0) then {_duration = 5;};
private _expireTime = time + _duration;

private _spotMap = missionNamespace getVariable ["BN_KOTH_enemySpots", createHashMap];
if !(_spotMap isEqualType createHashMap) then {
    _spotMap = createHashMap;
};
_spotMap set [_targetUid, [_expireTime, _requesterUid, _requesterSide]];
missionNamespace setVariable ["BN_KOTH_enemySpots", _spotMap];

_targetUnit setVariable ["BN_KOTH_spottedUntil", _expireTime, true];
_targetUnit setVariable ["BN_KOTH_spottedBySide", _requesterSide, true];

true

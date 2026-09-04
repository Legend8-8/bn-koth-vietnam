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

params ["_targetObject"];

if (!isServer) exitWith {false};
if (isNull _targetObject || {!alive _targetObject}) exitWith {false};

private _ownerId = remoteExecutedOwner;
private _requester = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _requester) exitWith {false};
if (!alive _requester) exitWith {false};

private _requesterUid = getPlayerUID _requester;
if (_requesterUid isEqualTo "") exitWith {false};

private _silentSpot = [_requesterUid, "cloak"] call bn_koth_fnc_progression_perks_isActive;

private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_playerAssignments isEqualType createHashMap) then {
    _playerAssignments = createHashMap;
};

private _requesterSide = _playerAssignments getOrDefault [_requesterUid, side group _requester];
if !([_requesterSide] call bn_koth_fnc_teams_validateSide) exitWith {false};

private _maxDistance = getNumber (missionConfigFile >> "CfgBnKothPlayer3DIcons" >> "enemyMarkMaxDistance");
if (_maxDistance <= 0) then {_maxDistance = 400;};

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

private _targets = [];
if (_targetObject isKindOf "Man") then {
    _targets = [_targetObject];
} else {
    if !(_targetObject isKindOf "AllVehicles") exitWith {false};
    _targets = (crew _targetObject) select {
        !isNull _x && {alive _x} && {_x isKindOf "Man"}
    };
};

if (_targets isEqualTo []) exitWith {false};

private _contextDistance = if (_targetObject isKindOf "Man") then {_targetObject} else {_targetObject};
if (_requester distance2D _contextDistance > _maxDistance) exitWith {false};

{
    private _targetUnit = _x;
    private _targetUid = getPlayerUID _targetUnit;
    if (_targetUid isEqualTo "") then {
        continue;
    };

    private _targetSide = _playerAssignments getOrDefault [_targetUid, side group _targetUnit];
    if !([_targetSide] call bn_koth_fnc_teams_validateSide) then {
        continue;
    };
    if (_requesterSide isEqualTo _targetSide) then {
        continue;
    };

    _spotMap set [_targetUid, [_expireTime, _requesterUid, _requesterSide]];
    _targetUnit setVariable ["BN_KOTH_spottedUntil", _expireTime, true];
    _targetUnit setVariable ["BN_KOTH_spottedBySide", _requesterSide, true];
    if (!_silentSpot) then {
        _targetUnit setVariable ["BN_KOTH_spottedWarningUntil", _expireTime, true];
        _targetUnit setVariable ["BN_KOTH_spottedWarningBySide", _requesterSide, true];
    };
} forEach _targets;

missionNamespace setVariable ["BN_KOTH_enemySpots", _spotMap];

true

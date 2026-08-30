/*
    File: fn_serverExpireMarks.sqf
    Author: tylervip
    Description: Removes expired enemy spot marks and clears public state for dead or disconnected units.
    Execution: Server
    Parameters: None
    Returns: Number of remaining spots <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _spotMap = missionNamespace getVariable ["BN_KOTH_enemySpots", createHashMap];
if !(_spotMap isEqualType createHashMap) then {
    _spotMap = createHashMap;
};

private _activeMap = createHashMap;
{
    private _uid = _x;
    private _entry = _spotMap getOrDefault [_uid, []];
    if !(_entry isEqualType []) then {
        continue;
    };

    _entry params ["_expireTime", "_spotterUid", "_spotterSide"];

    private _targetUnit = objNull;
    {
        if (getPlayerUID _x isEqualTo _uid) exitWith {
            _targetUnit = _x;
        };
    } forEach allPlayers;

    if (_expireTime <= time || {isNull _targetUnit} || {!alive _targetUnit} || {!([_spotterSide] call bn_koth_fnc_teams_validateSide)}) then {
        if (!isNull _targetUnit) then {
            _targetUnit setVariable ["BN_KOTH_spottedUntil", nil, true];
            _targetUnit setVariable ["BN_KOTH_spottedBySide", nil, true];
        };
        continue;
    };

    _activeMap set [_uid, _entry];
} forEach keys _spotMap;

missionNamespace setVariable ["BN_KOTH_enemySpots", _activeMap];
count _activeMap

/*
    File: fn_selectVoteCandidates.sqf
    Author: Legend
    Description: Selects vote candidates from valid map-configured AO locations.
    Execution: Server
    Parameters:
        None
    Returns:
        Candidate location IDs <ARRAY>
    Public: Yes
*/

if (!isServer) exitWith {[]};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {[]};

private _valid = [];
{
    private _id = configName _x;
    if ([_id] call bn_koth_fnc_round_isLocationValid) then {
        _valid pushBack _id;
    };
} forEach ("true" configClasses _locationsCfg);

if ((count _valid) <= 0) exitWith {[]};

private _previousLocationId = missionNamespace getVariable ["BN_KOTH_previousLocationId", ""];
private _pool = +_valid;
if ((count _pool) > 1 && {_previousLocationId in _pool}) then {
    _pool = _pool - [_previousLocationId];
};
if ((count _pool) <= 0) then {
    _pool = +_valid;
};

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _candidateCount = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "candidateCount")} else {3};
if (_candidateCount < 1) then {
    _candidateCount = 1;
};

if ((count _pool) <= _candidateCount) exitWith {_pool};

private _selected = [];
private _working = +_pool;
while {(count _selected) < _candidateCount && {(count _working) > 0}} do {
    private _index = floor (random (count _working));
    _selected pushBack (_working select _index);
    _working deleteAt _index;
};

_selected

/*
    File: fn_selectVoteCandidates.sqf
    Author: Legend
    Description: Selects vote candidates from valid map-configured AO locations.
    Execution: Server
    Parameters:
        0: Connected-human population, or -1 to resolve it server-side <NUMBER>
        1: Log use of deterministic population fallback <BOOL>
    Returns:
        Candidate location IDs <ARRAY>
    Public: Yes
*/

params [["_population", -1, [0]], ["_logFallback", true, [true]]];

if (!isServer) exitWith {[]};
if (_population < 0) then {
    _population = count ([] call bn_koth_fnc_teams_getConnectedHumanUids);
};

private _locationsCfg = missionConfigFile >> "CfgBnKothLocations";
if !(isClass _locationsCfg) exitWith {[]};

private _valid = [];
private _eligible = [];
{
    private _id = configName _x;
    if ([_id] call bn_koth_fnc_round_isLocationValid) then {
        _valid pushBack _id;
        if ([_id, _population] call bn_koth_fnc_round_isLocationPopulationEligible) then {
            _eligible pushBack _id;
        };
    };
} forEach ("true" configClasses _locationsCfg);

if ((count _valid) <= 0) exitWith {[]};

private _usedPopulationFallback = false;
if ((count _eligible) <= 0) then {
    _usedPopulationFallback = true;
    private _nearestDistance = 1e9;
    private _nearest = [];
    private _ordered = +_valid;
    _ordered sort true;

    {
        private _data = [_x] call bn_koth_fnc_zone_getLocationData;
        private _minimum = floor ((_data getOrDefault ["minPlayers", 0]) max 0);
        private _maximum = floor (_data getOrDefault ["maxPlayers", -1]);
        private _distance = if (_population < _minimum) then {
            _minimum - _population
        } else {
            if (_maximum >= 0 && {_population > _maximum}) then {_population - _maximum} else {0}
        };

        if (_distance < _nearestDistance) then {
            _nearestDistance = _distance;
            _nearest = [_x];
        } else {
            if (_distance isEqualTo _nearestDistance) then {_nearest pushBack _x};
        };
    } forEach _ordered;
    _eligible = _nearest;

    if (_logFallback) then {
        [format [
            "No AO matches connected-human population %1; deterministic nearest-range fallback candidates=%2 distance=%3.",
            _population,
            _eligible,
            _nearestDistance
        ], "WARN"] call bn_koth_fnc_common_log;
    };
};

private _previousLocationId = missionNamespace getVariable ["BN_KOTH_previousLocationId", ""];
private _pool = +_eligible;
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

if (_usedPopulationFallback) exitWith {_pool select [0, _candidateCount]};

private _selected = [];
private _working = +_pool;
while {(count _selected) < _candidateCount && {(count _working) > 0}} do {
    private _index = floor (random (count _working));
    _selected pushBack (_working select _index);
    _working deleteAt _index;
};

_selected

/*
    File: fn_reconcileVoteCandidates.sqf
    Author: Legend
    Description: Reconciles published AO vote candidates with current connected-human population.
    Execution: Server
    Parameters:
        0: Connected-human population, or -1 to resolve it server-side <NUMBER>
    Returns: Reconciliation state <HASHMAP>
    Public: Yes
*/

params [["_population", -1, [0]]];

private _result = createHashMapFromArray [["changed", false], ["population", _population], ["candidates", []]];
if (!isServer) exitWith {_result};
if (_population < 0) then {_population = count ([] call bn_koth_fnc_teams_getConnectedHumanUids)};
_result set ["population", _population];

private _current = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
if !(_current isEqualType []) then {_current = []};
private _invalid = _current select {!([_x, _population] call bn_koth_fnc_round_isLocationPopulationEligible)};
if ((count _current) > 0 && {(count _invalid) <= 0}) exitWith {
    _result set ["candidates", _current];
    _result
};

private _replacement = [_population, (count _current) <= 0] call bn_koth_fnc_round_selectVoteCandidates;
if ((count _replacement) <= 0) exitWith {
    [format ["AO vote candidate reconciliation failed at population %1: no configured fallback locations.", _population], "ERROR"] call bn_koth_fnc_common_log;
    _result
};
if (_replacement isEqualTo _current) exitWith {
    // The deterministic nearest-range fallback is stable even though its
    // candidates are intentionally outside their normal authored ranges.
    _result set ["candidates", _current];
    _result
};

private _votes = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if !(_votes isEqualType createHashMap) then {_votes = createHashMap};
{
    if !((_votes get _x) in _replacement) then {_votes deleteAt _x};
} forEach +(keys _votes);

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if (_records isEqualType createHashMap) then {
    {
        private _record = _records get _x;
        if (_record isEqualType createHashMap && {!((_record getOrDefault ["voteLocationId", ""]) in _replacement)}) then {
            _record set ["voteLocationId", ""];
            _records set [_x, _record];
        };
    } forEach (keys _records);
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
};

["BN_KOTH_voteCandidates", _replacement] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", _votes] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_round_updateVoteTotals;

if (missionNamespace getVariable ["BN_KOTH_voteOpen", false]) then {
    private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
    private _grace = if (isClass _lobbyCfg) then {(getNumber (_lobbyCfg >> "earlyVoteGracePeriod")) max 1} else {5};
    private _endAt = missionNamespace getVariable ["BN_KOTH_voteEndAt", -1];
    if (_endAt < (serverTime + _grace)) then {
        ["BN_KOTH_voteEndAt", serverTime + _grace] call bn_koth_fnc_common_publicState;
    };
};

[format [
    "AO vote candidates reconciled for connected-human population %1: removed=%2 replacement=%3 retainedVotes=%4.",
    _population,
    _invalid,
    _replacement,
    count (keys _votes)
], "INFO"] call bn_koth_fnc_common_log;

_result set ["changed", true];
_result set ["candidates", _replacement];
_result

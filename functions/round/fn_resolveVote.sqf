/*
    File: fn_resolveVote.sqf
    Author: Legend
    Description: Resolves current AO vote with tie and zero-vote fallback logic.
    Execution: Server
    Parameters:
        None
    Returns:
        Selected location ID or empty string <STRING>
    Public: Yes
*/

if (!isServer) exitWith {""};

private _population = count ([] call bn_koth_fnc_teams_getConnectedHumanUids);
private _reconciliation = [_population] call bn_koth_fnc_round_reconcileVoteCandidates;
if (_reconciliation getOrDefault ["changed", false]) exitWith {
    [format ["Vote resolution deferred after population reconciliation (%1 connected humans).", _population], "INFO"] call bn_koth_fnc_common_log;
    ""
};

private _candidates = _reconciliation getOrDefault ["candidates", []];
if ((count _candidates) <= 0) exitWith {
    ["Vote resolution failed: no candidates.", "ERROR"] call bn_koth_fnc_common_log;
    ""
};

private _totals = [] call bn_koth_fnc_round_updateVoteTotals;
private _maxVotes = -1;
private _leaders = [];
private _sumVotes = 0;

{
    private _locationId = _x;
    private _count = _totals getOrDefault [_locationId, 0];

    _sumVotes = _sumVotes + _count;

    if (_count > _maxVotes) then {
        _maxVotes = _count;
        _leaders = [_locationId];
    } else {
        if (_count isEqualTo _maxVotes) then {
            _leaders pushBack _locationId;
        };
    };
} forEach _candidates;

private _selected = "";
if (_sumVotes <= 0) then {
    _selected = selectRandom _candidates;
    [format ["Vote ended with zero votes; random fallback selected AO=%1", _selected], "WARN"] call bn_koth_fnc_common_log;
} else {
    if ((count _leaders) > 1) then {
        _selected = selectRandom _leaders;
        [format ["Vote tie between %1; random tie-break selected AO=%2", _leaders, _selected], "INFO"] call bn_koth_fnc_common_log;
    } else {
        _selected = _leaders select 0;
    };
};

["BN_KOTH_selectedLocationId", _selected] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteOpen", false] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteEndAt", -1] call bn_koth_fnc_common_publicState;

[format ["Vote winner AO=%1 totals=%2", _selected, _totals]] call bn_koth_fnc_common_log;
_selected

/*
    File: fn_prepareVoteCandidates.sqf
    Author: Legend
    Description: Prepares and publishes upcoming AO vote candidates while vote remains closed.
    Execution: Server
    Parameters:
        None
    Returns:
        Prepared candidate location IDs <ARRAY>
    Public: Yes
*/

if (!isServer) exitWith {[]};

private _population = count ([] call bn_koth_fnc_teams_getConnectedHumanUids);
private _reconciliation = [_population] call bn_koth_fnc_round_reconcileVoteCandidates;
private _candidates = _reconciliation getOrDefault ["candidates", []];
if ((count _candidates) <= 0) exitWith {
    ["Cannot prepare AO vote candidates: no valid locations available.", "ERROR"] call bn_koth_fnc_common_log;
    []
};
_candidates

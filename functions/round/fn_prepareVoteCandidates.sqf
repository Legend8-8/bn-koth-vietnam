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

if (missionNamespace getVariable ["BN_KOTH_voteOpen", false]) exitWith {
    missionNamespace getVariable ["BN_KOTH_voteCandidates", []]
};

private _existing = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
if ((count _existing) > 0) exitWith {
    _existing
};

private _candidates = [] call bn_koth_fnc_round_selectVoteCandidates;
if ((count _candidates) <= 0) exitWith {
    ["Cannot prepare AO vote candidates: no valid locations available.", "ERROR"] call bn_koth_fnc_common_log;
    []
};

["BN_KOTH_voteCandidates", _candidates] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_round_updateVoteTotals;

[format ["Prepared upcoming AO vote candidates: %1", _candidates], "INFO"] call bn_koth_fnc_common_log;
_candidates

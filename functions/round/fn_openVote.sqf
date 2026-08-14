/*
    File: fn_openVote.sqf
    Author: Legend
    Description: Opens an authoritative AO vote window with generated candidates.
    Execution: Server
    Parameters:
        None
    Returns:
        True on success, otherwise false <BOOL>
    Public: Yes
*/

if (!isServer) exitWith {false};

if (missionNamespace getVariable ["BN_KOTH_voteOpen", false]) exitWith {
    ["Ignored openVote call: vote already open.", "INFO"] call bn_koth_fnc_common_log;
    false
};

private _candidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
if ((count _candidates) <= 0) then {
    _candidates = [] call bn_koth_fnc_round_prepareVoteCandidates;
};

if ((count _candidates) <= 0) exitWith {
    ["Cannot open vote: no valid AO candidates.", "ERROR"] call bn_koth_fnc_common_log;
    false
};

private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";
private _voteDuration = if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "voteDuration")} else {30};
if (_voteDuration < 5) then {
    _voteDuration = 5;
};

["BN_KOTH_voteCandidates", _candidates] call bn_koth_fnc_common_publicState;
["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteOpen", true] call bn_koth_fnc_common_publicState;
["BN_KOTH_voteEndAt", serverTime + _voteDuration] call bn_koth_fnc_common_publicState;
["BN_KOTH_selectedLocationId", ""] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_round_updateVoteTotals;

[format ["AO vote opened: candidates=%1 duration=%2", _candidates, _voteDuration]] call bn_koth_fnc_common_log;
true

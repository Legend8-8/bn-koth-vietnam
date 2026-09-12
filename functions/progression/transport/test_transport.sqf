/*
    File: test_transport.sqf
    Author: Legend
    Description: Focused server-side state-cleanup checks for transport
        insertion candidates and pair cooldown retention.
    Execution: Server debug/test context
    Parameters: None
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["SERVER_CONTEXT_REQUIRED"]};

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};
private _savedCandidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
private _savedCooldowns = missionNamespace getVariable ["BN_KOTH_transportPairCooldowns", createHashMap];
private _makeCandidate = {
    params ["_phase", "_pilotUid", "_passengerUid"];
    createHashMapFromArray [
        ["phase", _phase],
        ["pilotUid", _pilotUid],
        ["passengerUid", _passengerUid],
        ["vehicle", objNull]
    ]
};

missionNamespace setVariable ["BN_KOTH_transportCandidates", createHashMapFromArray [
    ["passenger-a", ["BOARDED", "pilot-a", "passenger-a"] call _makeCandidate],
    ["passenger-b", ["AWAITING_AO", "pilot-b", "passenger-b"] call _makeCandidate]
]];
missionNamespace setVariable ["BN_KOTH_transportPairCooldowns", createHashMapFromArray [["pilot-a|passenger-a", serverTime + 600]]];

["passenger-a"] call bn_koth_fnc_progression_transport_cleanup;
private _candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
["Passenger cleanup removes its matching candidate", isNil {_candidates get "passenger-a"}] call _check;
["Passenger cleanup preserves unrelated candidates", !isNil {_candidates get "passenger-b"}] call _check;
["Player cleanup preserves pair cooldown history", !isNil {(missionNamespace getVariable ["BN_KOTH_transportPairCooldowns", createHashMap]) get "pilot-a|passenger-a"}] call _check;

[] call bn_koth_fnc_progression_transport_cleanup;
_candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
["Ordinary full cleanup removes every candidate", (count _candidates) isEqualTo 0] call _check;
["Ordinary full cleanup preserves pair cooldown history", !isNil {(missionNamespace getVariable ["BN_KOTH_transportPairCooldowns", createHashMap]) get "pilot-a|passenger-a"}] call _check;

missionNamespace setVariable ["BN_KOTH_transportCandidates", createHashMapFromArray [
    ["passenger-c", ["BOARDED", "pilot-c", "passenger-c"] call _makeCandidate],
    ["passenger-d", ["AWAITING_AO", "pilot-c", "passenger-d"] call _makeCandidate]
]];
["", objNull, "BOARDED"] call bn_koth_fnc_progression_transport_cleanup;
_candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
["BOARDED-only invalidation removes boarded candidates", isNil {_candidates get "passenger-c"}] call _check;
["BOARDED-only invalidation preserves AWAITING_AO candidates", !isNil {_candidates get "passenger-d"}] call _check;

missionNamespace setVariable ["BN_KOTH_transportCandidates", _savedCandidates];
missionNamespace setVariable ["BN_KOTH_transportPairCooldowns", _savedCooldowns];

diag_log format ["[BN_KOTH_TEST] Transport insertion: %1 failure(s): %2", count _failures, _failures];
_failures

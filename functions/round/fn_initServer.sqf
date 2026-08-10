/*
    File: fn_initServer.sqf
    Author: tylervip
    Edited: Legend
    Description: Initializes authoritative round state and starts the lifecycle manager.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_roundManagerRunning", false]) exitWith {
    ["Round manager already running.", "WARN"] call bn_koth_fnc_common_log;
};

missionNamespace setVariable ["BN_KOTH_roundManagerRunning", true];

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

missionNamespace setVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]],
    true
];
["BN_KOTH_winningSide", sideUnknown] call bn_koth_fnc_common_publicState;
[
    "BN_KOTH_teamScores",
    missionNamespace getVariable ["BN_KOTH_teamScores", createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]]]
] call bn_koth_fnc_common_publicState;

["BN_KOTH_roundState", "WAITING"] call bn_koth_fnc_common_publicState;
["BN_KOTH_zoneState", "NEUTRAL"] call bn_koth_fnc_common_publicState;
["BN_KOTH_zoneController", sideUnknown] call bn_koth_fnc_common_publicState;
[] call bn_koth_fnc_zone_clearActiveLocation;

[] spawn {
    while {true} do {
        private _roundState = [] call bn_koth_fnc_round_getState;

        if (_roundState isEqualTo "WAITING") then {
            private _eligibleUids = [] call bn_koth_fnc_teams_getEligibleSelectedUids;
            private _eligibleCount = count _eligibleUids;
            private _requiredEligible = 1;
            private _voteOpen = missionNamespace getVariable ["BN_KOTH_voteOpen", false];

            if (_eligibleCount < _requiredEligible) then {
                missionNamespace setVariable ["BN_KOTH_waitingEligibleLogged", false];

                if !(missionNamespace getVariable ["BN_KOTH_waitingDormantLogged", false]) then {
                    missionNamespace setVariable ["BN_KOTH_waitingDormantLogged", true];
                    ["WAITING dormant: zero eligible team-selected participants.", "INFO"] call bn_koth_fnc_common_log;
                };

                if (_voteOpen) then {
                    ["BN_KOTH_voteOpen", false] call bn_koth_fnc_common_publicState;
                    ["BN_KOTH_voteEndAt", -1] call bn_koth_fnc_common_publicState;
                    ["BN_KOTH_voteCandidates", []] call bn_koth_fnc_common_publicState;
                    ["BN_KOTH_votesByUid", createHashMap] call bn_koth_fnc_common_publicState;
                    [] call bn_koth_fnc_round_updateVoteTotals;
                    [] call bn_koth_fnc_round_prepareVoteCandidates;
                    ["Lobby vote cancelled: eligible team-selected participant count dropped to zero.", "WARN"] call bn_koth_fnc_common_log;
                } else {
                    [] call bn_koth_fnc_round_prepareVoteCandidates;
                };
            } else {
                missionNamespace setVariable ["BN_KOTH_waitingDormantLogged", false];

                if (!_voteOpen) then {
                    [] call bn_koth_fnc_round_prepareVoteCandidates;

                    if !(missionNamespace getVariable ["BN_KOTH_waitingEligibleLogged", false]) then {
                        missionNamespace setVariable ["BN_KOTH_waitingEligibleLogged", true];
                        [format ["WAITING eligible threshold reached (%1); opening vote.", _eligibleCount], "INFO"] call bn_koth_fnc_common_log;
                    };

                    [] call bn_koth_fnc_round_openVote;
                } else {
                    missionNamespace setVariable ["BN_KOTH_waitingEligibleLogged", false];
                    private _voteEndAt = missionNamespace getVariable ["BN_KOTH_voteEndAt", -1];
                    if (_voteEndAt > -1 && {serverTime >= _voteEndAt} && {(missionNamespace getVariable ["BN_KOTH_voteOpen", false])}) then {
                        private _selected = [] call bn_koth_fnc_round_resolveVote;
                        if !(_selected isEqualTo "") then {
                            ["PREPARING"] call bn_koth_fnc_round_setState;
                        };
                    };
                };
            };
        };

        sleep 1;
    };
};

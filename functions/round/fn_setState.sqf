/*
    File: fn_setState.sqf
    Author: tylervip
    Edited: Legend
    Description: Validates and sets authoritative round state transitions.
    Execution: Server
    Parameters:
        0: New round state <STRING>
    Returns:
        None
    Public: Yes
*/

params ["_newState"];

if (!isServer) exitWith {};

private _validStates = ["WAITING", "PREPARING", "ACTIVE", "ENDING", "RESETTING"];
if !(_newState in _validStates) exitWith {
    [format ["Rejected invalid round state: %1", _newState], "ERROR"] call bn_koth_fnc_common_log;
};

private _previousState = [] call bn_koth_fnc_round_getState;
if (_previousState isEqualTo _newState) exitWith {
    [format ["Round state unchanged: %1", _newState], "INFO"] call bn_koth_fnc_common_log;
};

private _allowedTransitions = createHashMapFromArray [
    ["WAITING", ["PREPARING"]],
    ["PREPARING", ["ACTIVE", "WAITING"]],
    ["ACTIVE", ["ENDING"]],
    ["ENDING", ["RESETTING"]],
    ["RESETTING", ["WAITING"]]
];

private _allowedNext = _allowedTransitions getOrDefault [_previousState, []];
if !(_newState in _allowedNext) exitWith {
    [format ["Rejected invalid transition: %1 -> %2", _previousState, _newState], "ERROR"] call bn_koth_fnc_common_log;
};

["BN_KOTH_roundState", _newState] call bn_koth_fnc_common_publicState;
[format ["Round state -> %1", _newState]] call bn_koth_fnc_common_log;

if (_newState in ["PREPARING", "ENDING", "RESETTING"]) then {
    [] call bn_koth_fnc_scoring_resetProgress;
};

switch (_newState) do {
    case "WAITING": {
        [] call bn_koth_fnc_vehicles_cleanupManagedVehicles;
    };

    case "PREPARING": {
        ["BN_KOTH_voteOpen", false] call bn_koth_fnc_common_publicState;

        private _selectedLocationId = missionNamespace getVariable ["BN_KOTH_selectedLocationId", ""];
        if (_selectedLocationId isEqualTo "") then {
            private _fallbackCandidates = [count ([] call bn_koth_fnc_teams_getConnectedHumanUids)] call bn_koth_fnc_round_selectVoteCandidates;
            if ((count _fallbackCandidates) > 0) then {
                _selectedLocationId = selectRandom _fallbackCandidates;
                ["BN_KOTH_selectedLocationId", _selectedLocationId] call bn_koth_fnc_common_publicState;
                [format ["No selected AO found at PREPARING; random fallback chose '%1'", _selectedLocationId], "WARN"] call bn_koth_fnc_common_log;
            };
        };

        if !([_selectedLocationId] call bn_koth_fnc_round_isLocationValid) exitWith {
            [format ["PREPARING aborted: invalid selected AO '%1'", _selectedLocationId], "ERROR"] call bn_koth_fnc_common_log;
            [] call bn_koth_fnc_zone_clearActiveLocation;
            ["WAITING"] call bn_koth_fnc_round_setState;
        };

        [_selectedLocationId] call bn_koth_fnc_zone_setActiveLocation;

        private _deployedCount = [] call bn_koth_fnc_teams_deployRoundParticipants;
        if (_deployedCount <= 0) exitWith {
            ["PREPARING aborted: no deployable team-selected players.", "WARN"] call bn_koth_fnc_common_log;
            [] call bn_koth_fnc_zone_clearActiveLocation;
            ["WAITING"] call bn_koth_fnc_round_setState;
        };

        private _prepareDuration = missionNamespace getVariable ["BN_KOTH_prepareDuration", 10];
        ["BN_KOTH_prepareEndAt", serverTime + _prepareDuration] call bn_koth_fnc_common_publicState;

        [_prepareDuration] spawn {
            params ["_delay"];
            sleep _delay;

            if (([] call bn_koth_fnc_round_getState) isEqualTo "PREPARING") then {
                ["ACTIVE"] call bn_koth_fnc_round_setState;
            };
        };
    };

    case "ENDING": {
        [] call bn_koth_fnc_vehicles_cleanupManagedVehicles;

        private _endingDuration = missionNamespace getVariable ["BN_KOTH_endingDuration", 8];
        ["BN_KOTH_endingEndAt", serverTime + _endingDuration] call bn_koth_fnc_common_publicState;

        [_endingDuration] spawn {
            params ["_delay"];
            sleep _delay;

            if (([] call bn_koth_fnc_round_getState) isEqualTo "ENDING") then {
                ["RESETTING"] call bn_koth_fnc_round_setState;
            };
        };
    };

    case "ACTIVE": {
        // Round-only stats reset on entry to ACTIVE so completed leaders remain
        // visible through ENDING, RESETTING, WAITING and the next map vote.
        [] call bn_koth_fnc_roundStats_reset;

        private _slotIds = missionNamespace getVariable ["BN_KOTH_vehicleManagedSlotIds", []];
        if ((count _slotIds) <= 0) then {
            [] call bn_koth_fnc_vehicles_buildActiveLocationSlots;
        };

        private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
        private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];

        {
            private _uid = _x;
            private _record = _records getOrDefault [_uid, createHashMap];

            if (_record isEqualType createHashMap) then {
                _record set ["state", "ACTIVE"];
                _record set ["deployed", true];
                _records set [_uid, _record];
            };
        } forEach _activeParticipants;

        missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
        [] call bn_koth_fnc_teams_publishState;
    };

    case "RESETTING": {
        [] call bn_koth_fnc_vehicles_cleanupManagedVehicles;

        [] spawn {
            [] call bn_koth_fnc_round_resetRound;
        };
    };
};

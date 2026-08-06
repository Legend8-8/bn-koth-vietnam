/*
    File: fn_setState.sqf
    Author: Legend
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
    ["PREPARING", ["ACTIVE"]],
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

switch (_newState) do {
    case "PREPARING": {
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

    case "RESETTING": {
        [] spawn {
            [] call bn_koth_fnc_round_resetRound;
        };
    };
};

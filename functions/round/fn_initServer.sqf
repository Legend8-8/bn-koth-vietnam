/*
    File: fn_initServer.sqf
    Author: tylervip
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
    ["Round manager already running.", "WARN"] call bn_koth_fnc_log;
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
["BN_KOTH_winningSide", sideUnknown] call bn_koth_fnc_publicState;

["BN_KOTH_roundState", "WAITING"] call bn_koth_fnc_publicState;
["BN_KOTH_zoneState", "NEUTRAL"] call bn_koth_fnc_publicState;
["BN_KOTH_zoneController", sideUnknown] call bn_koth_fnc_publicState;

[] spawn {
    while {true} do {
        private _roundState = [] call bn_koth_fnc_round_getState;

        if (_roundState isEqualTo "WAITING") then {
            private _minPlayers = getNumber (missionConfigFile >> "Header" >> "minPlayers");
            if (_minPlayers < 1) then {
                _minPlayers = 1;
            };

            private _playerCount = count (allPlayers select {!isNull _x});
            if (_playerCount >= _minPlayers) then {
                ["PREPARING"] call bn_koth_fnc_round_setState;
            };
        };

        sleep 1;
    };
};

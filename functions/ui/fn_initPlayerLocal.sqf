/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Edited: Legend
    Description: Initializes local UI hooks.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

private _debugCfg = missionConfigFile >> "CfgBnKothDebug";
private _debugEnabled = if (isClass _debugCfg) then {(getNumber (_debugCfg >> "enabled")) > 0} else {false};

missionNamespace setVariable ["BN_KOTH_debugEnabled", _debugEnabled];

[_debugEnabled] call bn_koth_fnc_ui_toggleDebugDisplay;

[] spawn {
    while {hasInterface} do {
        if (isNil {player getVariable "BN_KOTH_lobbyActionsAdded"}) then {
            player setVariable ["BN_KOTH_lobbyActionsAdded", true];

            player addAction [
                "KOTH: Request WEST Team",
                {
                    ["WEST"] call bn_koth_fnc_teams_requestSelection;
                }
            ];

            player addAction [
                "KOTH: Request EAST Team",
                {
                    ["EAST"] call bn_koth_fnc_teams_requestSelection;
                }
            ];

            player addAction [
                "KOTH: Vote Candidate 1",
                {
                    [0] call bn_koth_fnc_round_requestVote;
                }
            ];

            player addAction [
                "KOTH: Vote Candidate 2",
                {
                    [1] call bn_koth_fnc_round_requestVote;
                }
            ];

            player addAction [
                "KOTH: Vote Candidate 3",
                {
                    [2] call bn_koth_fnc_round_requestVote;
                }
            ];

            player addAction [
                "KOTH: Request State Snapshot",
                {
                    [] call bn_koth_fnc_ui_requestState;
                }
            ];
        };

        sleep 1;
    };
};

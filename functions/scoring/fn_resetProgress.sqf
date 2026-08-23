/*
    File: fn_resetProgress.sqf
    Author: Legend
    Description: Publishes a cleared authoritative score-progress state.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _duration = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {15}];
if (_duration < 1) then {
    _duration = 1;
};

private _progress = createHashMapFromArray [
    ["side", sideUnknown],
    ["base", 0],
    ["startedAt", -1],
    ["active", false],
    ["duration", _duration]
];

["BN_KOTH_scoreProgress", _progress] call bn_koth_fnc_common_publicState;
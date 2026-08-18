/*
    File: fn_initServer.sqf
    Author: Tylervip
    Description: Initializes server-owned round XP configuration and state.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _xpPerControlTick = if (isNumber (_progressionCfg >> "xpPerControlTick")) then {
    getNumber (_progressionCfg >> "xpPerControlTick")
} else {
    10
};
private _xpPerKill = if (isNumber (_progressionCfg >> "xpPerKill")) then {
    getNumber (_progressionCfg >> "xpPerKill")
} else {
    100
};
private _xpPerPriorityTick = if (isNumber (_progressionCfg >> "xpPerPriorityTick")) then {
    getNumber (_progressionCfg >> "xpPerPriorityTick")
} else {
    25
};
private _xpLevelBase = if (isNumber (_progressionCfg >> "xpLevelBase")) then {
    getNumber (_progressionCfg >> "xpLevelBase")
} else {
    100
};
private _xpLevelStep = if (isNumber (_progressionCfg >> "xpLevelStep")) then {
    getNumber (_progressionCfg >> "xpLevelStep")
} else {
    50
};
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {
    getNumber (_progressionCfg >> "maxLevel")
} else {
    270
};

missionNamespace setVariable ["BN_KOTH_xpPerControlTick", _xpPerControlTick max 0];
missionNamespace setVariable ["BN_KOTH_xpPerKill", _xpPerKill max 0];
missionNamespace setVariable ["BN_KOTH_xpPerPriorityTick", _xpPerPriorityTick max 0];
missionNamespace setVariable ["BN_KOTH_xpLevelBase", _xpLevelBase max 1];
missionNamespace setVariable ["BN_KOTH_xpLevelStep", _xpLevelStep max 0];
missionNamespace setVariable ["BN_KOTH_xpMaxLevel", _maxLevel max 1];

[] call bn_koth_fnc_progression_xp_resetRound;

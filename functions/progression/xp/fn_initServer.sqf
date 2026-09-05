/*
    File: fn_initServer.sqf
    Author: Tylervip
    Description: Initializes server-owned session progression configuration and state.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _xpPerParticipationTick = if (isNumber (_progressionCfg >> "xpPerParticipationTick")) then {
    getNumber (_progressionCfg >> "xpPerParticipationTick")
} else {
    5
};
missionNamespace setVariable ["BN_KOTH_xpPerParticipationTick", _xpPerParticipationTick max 0];
private _xpPerControlBonus = if (isNumber (_progressionCfg >> "xpPerControlBonus")) then {
    getNumber (_progressionCfg >> "xpPerControlBonus")
} else {
    5
};
private _xpPerKill = if (isNumber (_progressionCfg >> "xpPerKill")) then {
    getNumber (_progressionCfg >> "xpPerKill")
} else {
    25
};
private _xpPerPriorityBonus = if (isNumber (_progressionCfg >> "xpPerPriorityBonus")) then {
    getNumber (_progressionCfg >> "xpPerPriorityBonus")
} else {
    20
};
missionNamespace setVariable ["BN_KOTH_xpPerControlBonus", _xpPerControlBonus max 0];
missionNamespace setVariable ["BN_KOTH_xpPerKill", _xpPerKill max 0];
missionNamespace setVariable ["BN_KOTH_xpPerPriorityBonus", _xpPerPriorityBonus max 0];

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) then {
    _progressionByUid = createHashMap;
};
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];

["Session progression initialized", "INFO"] call bn_koth_fnc_common_log;

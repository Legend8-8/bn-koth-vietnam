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
missionNamespace setVariable ["BN_KOTH_stateReady", false];

[_debugEnabled] call bn_koth_fnc_ui_toggleDebugDisplay;

if (isNil {missionNamespace getVariable "BN_KOTH_lifecycleHooksInstalled"}) then {
    missionNamespace setVariable ["BN_KOTH_lifecycleHooksInstalled", true];

    "BN_KOTH_playerStates" addPublicVariableEventHandler {
        [] call bn_koth_fnc_ui_evaluateStateReadiness;
        [] call bn_koth_fnc_ui_updateLobbyLifecycle;
        [] call bn_koth_fnc_ui_refreshLobby;
    };

    "BN_KOTH_activeParticipants" addPublicVariableEventHandler {
        [] call bn_koth_fnc_ui_updateLobbyLifecycle;
        [] call bn_koth_fnc_ui_refreshLobby;
    };
};

private _existingLifecycleLoop = missionNamespace getVariable ["BN_KOTH_lobbyLifecycleLoopHandle", scriptNull];
if (_existingLifecycleLoop isEqualTo scriptNull || {scriptDone _existingLifecycleLoop}) then {
    private _lifecycleHandle = [] spawn {
        while {hasInterface} do {
            [] call bn_koth_fnc_ui_updateLobbyLifecycle;
            sleep 1;
        };

        missionNamespace setVariable ["BN_KOTH_lobbyLifecycleLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_lobbyLifecycleLoopHandle", _lifecycleHandle];
};

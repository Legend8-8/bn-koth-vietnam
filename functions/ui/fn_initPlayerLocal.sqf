/*
    File: fn_initPlayerLocal.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Initializes local UI hooks.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};
disableSerialization;

missionNamespace setVariable ["BN_KOTH_spawnKitResponse", [0, "", false]];
missionNamespace setVariable ["BN_KOTH_groupStateLocal", createHashMap];
missionNamespace setVariable ["BN_KOTH_airInsertionLocalState", createHashMap];
missionNamespace setVariable ["BN_KOTH_casualtyHelpStateLocal", []];

uiNamespace setVariable ["BN_KOTH_initialPreloadFinished", false];
uiNamespace setVariable ["BN_KOTH_groupMenuDisplay", displayNull];
uiNamespace setVariable ["BN_KOTH_airInsertionActionBinding", [objNull, []]];
uiNamespace setVariable ["BN_KOTH_airInsertionBackpackBinding", [objNull, -1, ""]];
uiNamespace setVariable ["BN_KOTH_downedActionBinding", [objNull, []]];
uiNamespace setVariable ["BN_KOTH_casualtyHelpOwnRequestActive", false];
uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPending", false];
uiNamespace setVariable ["BN_KOTH_casualtyHelpRequestPendingAt", -1];

addMissionEventHandler [
    "PreloadFinished",
    {
        if (uiNamespace getVariable ["BN_KOTH_initialPreloadFinished", false]) exitWith {
            removeMissionEventHandler ["PreloadFinished", _thisEventHandler];
        };

        uiNamespace setVariable ["BN_KOTH_initialPreloadFinished", true];
        removeMissionEventHandler ["PreloadFinished", _thisEventHandler];
        [] call bn_koth_fnc_ui_transition_update;
        [] call bn_koth_fnc_ui_updateLobbyLifecycle;
    }
];

private _debugCfg = missionConfigFile >> "CfgBnKothDebug";
private _debugEnabled = if (isClass _debugCfg) then {(getNumber (_debugCfg >> "enabled")) > 0} else {false};

missionNamespace setVariable ["BN_KOTH_debugEnabled", _debugEnabled];
missionNamespace setVariable ["BN_KOTH_stateReady", false];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuSuppressed", false];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", false];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", false];
uiNamespace setVariable ["BN_KOTH_lobbyBlackoutVisible", false];
uiNamespace setVariable ["BN_KOTH_transitionDisplay", displayNull];
uiNamespace setVariable ["BN_KOTH_transitionVisible", false];
uiNamespace setVariable ["BN_KOTH_transitionPresentationFinished", false];
uiNamespace setVariable ["BN_KOTH_transitionServerReady", false];
uiNamespace setVariable ["BN_KOTH_transitionLifecycleToken", 0];
uiNamespace setVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
uiNamespace setVariable ["BN_KOTH_transitionInputBlocked", false];
uiNamespace setVariable ["BN_KOTH_resultsDisplay", displayNull];
uiNamespace setVariable ["BN_KOTH_resultsVisible", false];
uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", false];
uiNamespace setVariable ["BN_KOTH_resultsLifecycleToken", 0];
uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
uiNamespace setVariable ["BN_KOTH_resultsInputBlocked", false];
uiNamespace setVariable ["BN_KOTH_resultsSnapshot", createHashMap];
uiNamespace setVariable ["BN_KOTH_lobbyContainedUnit", objNull];
uiNamespace setVariable ["BN_KOTH_lobbyContainmentApplied", false];
uiNamespace setVariable ["BN_KOTH_hudVisible", false];
uiNamespace setVariable ["BN_KOTH_hudDisplay", displayNull];
// uiNamespace outlives a mission. Discard card controls and scheduler closures
// from the previous run before the first state snapshot can enqueue new cards.
{
    private _ctrl = _x select 0;
    if (!isNull _ctrl) then {ctrlDelete _ctrl};
} forEach (uiNamespace getVariable ["BN_KOTH_notificationVisible", []]);
{
    private _ctrl = if (_x isEqualType createHashMap) then {_x getOrDefault ["control", controlNull]} else {_x select 0};
    if (!isNull _ctrl) then {ctrlDelete _ctrl};
} forEach (uiNamespace getVariable ["BN_KOTH_rewardFeedEntries", []]);
uiNamespace setVariable ["BN_KOTH_menuDisplay", displayNull];
uiNamespace setVariable ["BN_KOTH_rewardFeedDisplay", displayNull];
uiNamespace setVariable ["BN_KOTH_notificationQueue", []];
uiNamespace setVariable ["BN_KOTH_notificationVisible", []];
uiNamespace setVariable ["BN_KOTH_notificationPump", nil];
uiNamespace setVariable ["BN_KOTH_rewardFeedEntries", []];
if (isNil {uiNamespace getVariable "BN_KOTH_mapInitialFocusNeeded"}) then {uiNamespace setVariable ["BN_KOTH_mapInitialFocusNeeded", false]};
if (isNil {uiNamespace getVariable "BN_KOTH_mapLifecycleWasDeployed"}) then {uiNamespace setVariable ["BN_KOTH_mapLifecycleWasDeployed", false]};

[_debugEnabled] call bn_koth_fnc_ui_toggleDebugDisplay;
[] call bn_koth_fnc_ui_updateLobbyBlackout;
[] call bn_koth_fnc_ui_updateLobbyRepresentationContainment;
[] call bn_koth_fnc_escMenu_initPlayerLocal;

if (isNil {missionNamespace getVariable "BN_KOTH_lifecycleHooksInstalled"}) then {
    missionNamespace setVariable ["BN_KOTH_lifecycleHooksInstalled", true];

    "BN_KOTH_playerStates" addPublicVariableEventHandler {
        [] call bn_koth_fnc_ui_evaluateStateReadiness;
        [] call bn_koth_fnc_ui_transition_update;
        [] call bn_koth_fnc_ui_updateLobbyLifecycle;
        [] call bn_koth_fnc_ui_refreshLobby;
    };

    "BN_KOTH_activeParticipants" addPublicVariableEventHandler {
        [] call bn_koth_fnc_ui_transition_update;
        [] call bn_koth_fnc_ui_updateLobbyLifecycle;
        [] call bn_koth_fnc_ui_refreshLobby;
    };

    "BN_KOTH_playerLevels" addPublicVariableEventHandler {
        [] call bn_koth_fnc_ui_refreshLobby;
    };
};

"BN_KOTH_scoreProgress" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

"BN_KOTH_teamScores" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

"BN_KOTH_zoneState" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

"BN_KOTH_zoneController" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

"BN_KOTH_zonePopulation" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

"BN_KOTH_scoreLimit" addPublicVariableEventHandler {
    [] call bn_koth_fnc_ui_refreshHud;
};

private _existingLifecycleLoop = missionNamespace getVariable ["BN_KOTH_lobbyLifecycleLoopHandle", scriptNull];
if (_existingLifecycleLoop isEqualTo scriptNull || {scriptDone _existingLifecycleLoop}) then {
    private _lifecycleHandle = [] spawn {
        while {hasInterface} do {
            [] call bn_koth_fnc_respawn_updateDownedPresentation;
            [] call bn_koth_fnc_ui_updateLobbyLifecycle;
            call (uiNamespace getVariable ["BN_KOTH_notificationPump", {}]);
            sleep 0.25;
        };

        missionNamespace setVariable ["BN_KOTH_lobbyLifecycleLoopHandle", scriptNull];
    };

    missionNamespace setVariable ["BN_KOTH_lobbyLifecycleLoopHandle", _lifecycleHandle];
};

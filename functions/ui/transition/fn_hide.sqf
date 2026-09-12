/*
    File: fn_hide.sqf
    Author: Legend
    Description: Cancels and removes the owned deployment transition without affecting other UI layers.
    Execution: Client
    Parameters:
        0: Remove immediately rather than fading <BOOL> (default: false)
    Returns:
        None
    Public: No
*/

params [["_immediate", false, [true]]];

if (!hasInterface) exitWith {};

private _handle = uiNamespace getVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
if (_handle isEqualType scriptNull && {!scriptDone _handle}) then {
    terminate _handle;
};

private _token = (uiNamespace getVariable ["BN_KOTH_transitionLifecycleToken", 0]) + 1;
uiNamespace setVariable ["BN_KOTH_transitionLifecycleToken", _token];
uiNamespace setVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
uiNamespace setVariable ["BN_KOTH_transitionPresentationFinished", false];
uiNamespace setVariable ["BN_KOTH_transitionServerReady", false];

private _layer = "BN_KOTH_DeploymentTransition" call BIS_fnc_rscLayer;
if (_immediate) exitWith {
    uiNamespace setVariable ["BN_KOTH_transitionVisible", false];
    if (uiNamespace getVariable ["BN_KOTH_transitionInputBlocked", false]) then {
        disableUserInput false;
        uiNamespace setVariable ["BN_KOTH_transitionInputBlocked", false];
    };
    _layer cutText ["", "PLAIN", 0];
    uiNamespace setVariable ["BN_KOTH_transitionDisplay", displayNull];
};

private _display = uiNamespace getVariable ["BN_KOTH_transitionDisplay", displayNull];
if (isNull _display) exitWith {
    uiNamespace setVariable ["BN_KOTH_transitionVisible", false];
    if (uiNamespace getVariable ["BN_KOTH_transitionInputBlocked", false]) then {
        disableUserInput false;
        uiNamespace setVariable ["BN_KOTH_transitionInputBlocked", false];
    };
    _layer cutText ["", "PLAIN", 0];
    uiNamespace setVariable ["BN_KOTH_transitionDisplay", displayNull];
};

{
    _x ctrlSetFade 1;
    _x ctrlCommit 0.65;
} forEach (allControls _display);

[_token] spawn {
    params ["_token"];
    uiSleep 0.7;
    if !((uiNamespace getVariable ["BN_KOTH_transitionLifecycleToken", -1]) isEqualTo _token) exitWith {};

    uiNamespace setVariable ["BN_KOTH_transitionVisible", false];
    if (uiNamespace getVariable ["BN_KOTH_transitionInputBlocked", false]) then {
        disableUserInput false;
        uiNamespace setVariable ["BN_KOTH_transitionInputBlocked", false];
    };

    private _layer = "BN_KOTH_DeploymentTransition" call BIS_fnc_rscLayer;
    _layer cutText ["", "PLAIN", 0];
    uiNamespace setVariable ["BN_KOTH_transitionDisplay", displayNull];
    [] call bn_koth_fnc_ui_updateLobbyLifecycle;
};

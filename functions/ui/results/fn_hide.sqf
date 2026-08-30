/*
    File: fn_hide.sqf
    Author: Legend
    Description: Removes the owned results layer and safely returns presentation ownership to the lobby.
    Execution: Client
    Parameters:
        0: Remove immediately rather than fading <BOOL> (default: false)
    Returns:
        None
    Public: No
*/

params [["_immediate", false, [true]]];

if (!hasInterface) exitWith {};

private _handle = uiNamespace getVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
if (_handle isEqualType scriptNull && {!scriptDone _handle}) then {terminate _handle};

private _token = (uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", 0]) + 1;
uiNamespace setVariable ["BN_KOTH_resultsLifecycleToken", _token];
uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", false];

private _finish = {
    uiNamespace setVariable ["BN_KOTH_resultsVisible", false];
    uiNamespace setVariable ["BN_KOTH_resultsSnapshot", createHashMap];
    if (uiNamespace getVariable ["BN_KOTH_resultsInputBlocked", false]) then {
        disableUserInput false;
        uiNamespace setVariable ["BN_KOTH_resultsInputBlocked", false];
    };
    private _layer = "BN_KOTH_RoundResults" call BIS_fnc_rscLayer;
    _layer cutText ["", "PLAIN", 0];
    uiNamespace setVariable ["BN_KOTH_resultsDisplay", displayNull];
};

if (_immediate) exitWith {
    call _finish;
    [] call bn_koth_fnc_ui_updateLobbyLifecycle;
};

private _display = uiNamespace getVariable ["BN_KOTH_resultsDisplay", displayNull];
if (isNull _display) exitWith {
    call _finish;
    [] call bn_koth_fnc_ui_updateLobbyLifecycle;
};

{_x ctrlSetFade 1; _x ctrlCommit 0.75} forEach (allControls _display);

[_token] spawn {
    params ["_token"];
    uiSleep 0.8;
    if !((uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", -1]) isEqualTo _token) exitWith {};

    uiNamespace setVariable ["BN_KOTH_resultsVisible", false];
    uiNamespace setVariable ["BN_KOTH_resultsSnapshot", createHashMap];
    if (uiNamespace getVariable ["BN_KOTH_resultsInputBlocked", false]) then {
        disableUserInput false;
        uiNamespace setVariable ["BN_KOTH_resultsInputBlocked", false];
    };
    private _layer = "BN_KOTH_RoundResults" call BIS_fnc_rscLayer;
    _layer cutText ["", "PLAIN", 0];
    uiNamespace setVariable ["BN_KOTH_resultsDisplay", displayNull];
    [] call bn_koth_fnc_ui_updateLobbyLifecycle;
};

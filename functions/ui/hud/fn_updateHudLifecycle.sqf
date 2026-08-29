/*
    File: fn_updateHudLifecycle.sqf
    Author: Legend
    Description: Shows or hides the local in-game HUD from the gameplay-ready
        result already owned by the client UI lifecycle.
    Execution: Client
    Parameters:
        0: Gameplay ready / deployed <BOOL>
    Returns:
        Whether the HUD should be visible <BOOL>
    Public: No
*/

params [["_shouldShow", false, [false]]];

if (!hasInterface) exitWith {false};

private _visible = uiNamespace getVariable ["BN_KOTH_hudVisible", false];
private _layer = "BN_KOTH_HUD" call BIS_fnc_rscLayer;

if (_shouldShow) then {
    if (!_visible) then {
        _layer cutRsc ["BN_KOTH_RscHud", "PLAIN", 0, false];
        uiNamespace setVariable ["BN_KOTH_hudVisible", true];

        private _loopHandle = uiNamespace getVariable ["BN_KOTH_hudAnimatorHandle", scriptNull];
        if (_loopHandle isEqualTo scriptNull || {scriptDone _loopHandle}) then {
            _loopHandle = [] spawn {
                while {hasInterface && {uiNamespace getVariable ["BN_KOTH_hudVisible", false]}} do {
                    [] call bn_koth_fnc_ui_refreshHud;
                    uiSleep 0.05;
                };

                uiNamespace setVariable ["BN_KOTH_hudAnimatorHandle", scriptNull];
            };

            uiNamespace setVariable ["BN_KOTH_hudAnimatorHandle", _loopHandle];
        };

        [] call bn_koth_fnc_ui_refreshHud;
    };
} else {
    if (_visible) then {
        _layer cutFadeOut 0;
        uiNamespace setVariable ["BN_KOTH_hudVisible", false];
        uiNamespace setVariable ["BN_KOTH_hudDisplay", displayNull];
        [] call bn_koth_fnc_ui_updatePriorityTask;

        private _loopHandle = uiNamespace getVariable ["BN_KOTH_hudAnimatorHandle", scriptNull];
        if !(_loopHandle isEqualTo scriptNull) then {
            terminate _loopHandle;
            uiNamespace setVariable ["BN_KOTH_hudAnimatorHandle", scriptNull];
        };
    };
};

_shouldShow

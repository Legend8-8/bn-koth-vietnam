/*
    File: pauseOnLoad.sqf
    Author: Legend
    Description: Native pause-menu hook entrypoint used by description.ext onPauseScript.
    Execution: Client
*/

if (!hasInterface) exitWith {};

private _pauseDisplay = _this param [0, displayNull];

if (isNull _pauseDisplay) then {
    _pauseDisplay = findDisplay 49;
};

uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuSuppressed", true];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", true];
uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", false];

if (!isNull _pauseDisplay) then {
    private _existingEhId = _pauseDisplay getVariable ["BN_KOTH_pauseUnloadEhId", -1];
    if (_existingEhId < 0) then {
        private _ehId = _pauseDisplay displayAddEventHandler ["Unload", {
            uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", false];
            uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", true];
        }];

        _pauseDisplay setVariable ["BN_KOTH_pauseUnloadEhId", _ehId];
    };
};

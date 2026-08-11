/*
    File: fn_openLobby.sqf
	Author: Legend
    Description: Opens the production KOTH lobby dialog on the local client.
    Execution: Client
    Parameters:
        None
    Returns:
        True when open, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _startRefreshLoop = {
    private _existingLoop = uiNamespace getVariable ["BN_KOTH_lobbyRefreshLoop", scriptNull];
    if (_existingLoop isEqualTo scriptNull || {scriptDone _existingLoop}) then {
        private _loopHandle = [] spawn {
            while {hasInterface} do {
                private _display = uiNamespace getVariable ["BN_KOTH_lobbyDisplay", displayNull];
                if (isNull _display) exitWith {};

                [] call bn_koth_fnc_ui_refreshLobby;
                sleep 1;
            };

            uiNamespace setVariable ["BN_KOTH_lobbyRefreshLoop", scriptNull];
        };

        uiNamespace setVariable ["BN_KOTH_lobbyRefreshLoop", _loopHandle];
    };
};

private _existing = uiNamespace getVariable ["BN_KOTH_lobbyDisplay", displayNull];
if (!isNull _existing) exitWith {
    [] call bn_koth_fnc_ui_refreshLobby;
    [] call _startRefreshLoop;
    true
};

private _opened = createDialog "BN_KOTH_RscLobby";

if (_opened) then {
    [] call bn_koth_fnc_ui_refreshLobby;
    [] call _startRefreshLoop;
};

_opened

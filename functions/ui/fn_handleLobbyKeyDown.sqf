/*
    File: fn_handleLobbyKeyDown.sqf
    Author: Legend
    Description: Handles lobby ESC by opening the native pause menu for undeployed players.
    Execution: Client
    Parameters:
        0: Display or control <DISPLAY/CONTROL>
        1: Key code <NUMBER>
        2: Shift pressed <BOOL>
        3: Ctrl pressed <BOOL>
        4: Alt pressed <BOOL>
    Returns:
        True when ESC is consumed for undeployed lobby pause flow, otherwise false <BOOL>
    Public: Yes
*/

params ["_display", "_key", ["_shift", false, [false]], ["_ctrl", false, [false]], ["_alt", false, [false]]];

if (!hasInterface) exitWith {false};

if (_key isEqualTo 1) then {
    private _uid = getPlayerUID player;
    private _stateReady = missionNamespace getVariable ["BN_KOTH_stateReady", false];
    private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
    private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];

    private _isDeployed = false;
    if (_stateReady && {!(_uid isEqualTo "")} && {_playerStates isEqualType createHashMap} && {_uid in (keys _playerStates)}) then {
        private _myState = _playerStates getOrDefault [_uid, "LOBBY"];
        _isDeployed = (_uid in _activeParticipants) || {_myState in ["ACTIVE", "RESPAWNING"]};
    };

    if (_isDeployed) exitWith {false};

    uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuSuppressed", true];
    uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuActive", false];
    uiNamespace setVariable ["BN_KOTH_lobbyNativeMenuRestorePending", false];

    [] call bn_koth_fnc_ui_updateLobbyBlackout;
    closeDialog 2;

    [] spawn {
        uiSleep 0;

        private _gameDisplay = findDisplay 46;
        if (!isNull _gameDisplay) then {
            _gameDisplay createDisplay "RscDisplayInterrupt";
        };
    };

    true
};

false
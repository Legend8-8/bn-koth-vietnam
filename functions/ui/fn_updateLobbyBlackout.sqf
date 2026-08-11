/*
    File: fn_updateLobbyBlackout.sqf
    Author: Legend
    Description: Shows or hides the local lobby black curtain from replicated player and UI state.
    Execution: Client
    Parameters:
        None
    Returns:
        True when the blackout should be visible, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _uid = getPlayerUID player;
private _stateReady = missionNamespace getVariable ["BN_KOTH_stateReady", false];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _initialPreloadFinished = uiNamespace getVariable ["BN_KOTH_initialPreloadFinished", false];

private _isDeployed = false;
if (_stateReady && {!(_uid isEqualTo "")}) then {
    if (_playerStates isEqualType createHashMap && {_uid in (keys _playerStates)}) then {
        private _myState = _playerStates getOrDefault [_uid, "LOBBY"];
        _isDeployed = (_uid in _activeParticipants) || {_myState in ["ACTIVE", "DEPLOYING", "RETURNING", "RESPAWNING"]};
    };
};

private _shouldShowBlackout = _initialPreloadFinished && {!_isDeployed};
private _layer = "BN_KOTH_LobbyBlackout" call BIS_fnc_rscLayer;
private _isVisible = uiNamespace getVariable ["BN_KOTH_lobbyBlackoutVisible", false];

if (_shouldShowBlackout) then {
    if (!_isVisible) then {
        _layer cutText ["", "BLACK FADED", 999999];
        uiNamespace setVariable ["BN_KOTH_lobbyBlackoutVisible", true];
    };
} else {
    if (_isVisible) then {
        _layer cutText ["", "BLACK IN", 0];
        uiNamespace setVariable ["BN_KOTH_lobbyBlackoutVisible", false];
    };
};

_shouldShowBlackout
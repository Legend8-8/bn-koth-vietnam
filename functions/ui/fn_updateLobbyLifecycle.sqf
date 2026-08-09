/*
    File: fn_updateLobbyLifecycle.sqf
    Author: Legend
    Description: Applies lobby open/close behavior from authoritative replicated player and round state.
    Execution: Client
    Parameters:
        None
    Returns:
        True when lobby should be visible, otherwise false <BOOL>
    Public: Yes
*/

#include "..\..\ui\lobby\idcs.hpp"

if (!hasInterface) exitWith {false};

private _stateReady = missionNamespace getVariable ["BN_KOTH_stateReady", false];
if (!_stateReady) exitWith {false};

private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", ""];
if !(_roundState in ["WAITING", "PREPARING", "ACTIVE", "ENDING", "RESETTING"]) exitWith {false};

private _uid = getPlayerUID player;
if (_uid isEqualTo "") exitWith {false};

private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];

if !(_playerStates isEqualType createHashMap) exitWith {false};
if !(_uid in (keys _playerStates)) exitWith {false};

private _myState = _playerStates getOrDefault [_uid, "LOBBY"];

private _isDeployed = (_uid in _activeParticipants) || {_myState in ["ACTIVE", "DEPLOYING", "RETURNING"]};
private _shouldOpen = !_isDeployed;

private _display = uiNamespace getVariable ["BN_KOTH_lobbyDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_LOBBY;
};

if (_shouldOpen) then {
    if (isNull _display && {!isNull (findDisplay 46)}) then {
        [] call bn_koth_fnc_ui_openLobby;
    };
} else {
    if (!isNull _display) then {
        [] call bn_koth_fnc_ui_closeLobby;
    };
};

_shouldOpen

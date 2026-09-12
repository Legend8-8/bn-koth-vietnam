/*
    File: fn_evaluateStateReadiness.sqf
    Author: Legend
    Description: Evaluates whether the local client has enough authoritative state to use the lobby.
    Execution: Client
    Parameters:
        None
    Returns:
        True when state readiness is established, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

if (missionNamespace getVariable ["BN_KOTH_stateReady", false]) exitWith {true};

private _uid = getPlayerUID player;
if (_uid isEqualTo "") exitWith {false};

private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
if !(_playerStates isEqualType createHashMap) exitWith {false};
if !(_uid in (keys _playerStates)) exitWith {false};

missionNamespace setVariable ["BN_KOTH_stateReady", true];
[] call bn_koth_fnc_ui_updateLobbyLifecycle;

true

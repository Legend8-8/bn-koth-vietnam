/*
    File: fn_updateLobbyRepresentationContainment.sqf
    Author: Legend
    Description: Applies local simulation containment to undeployed lobby representations.
    Execution: Client
    Parameters:
        None
    Returns:
        True when containment should be active, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _uid = getPlayerUID player;
private _stateReady = missionNamespace getVariable ["BN_KOTH_stateReady", false];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];

private _myState = "LOBBY";
private _isReady = false;
if (_stateReady && {!(_uid isEqualTo "")} && {_playerStates isEqualType createHashMap} && {_uid in (keys _playerStates)}) then {
    _myState = _playerStates getOrDefault [_uid, "LOBBY"];
    _isReady = true;
};

private _gameplayReady = (_uid in _activeParticipants) || {_myState isEqualTo "ACTIVE"};
private _shouldContain = _isReady && {!_gameplayReady} && {_myState in ["LOBBY", "TEAM_SELECTED", "DEPLOYING"]};

private _previousUnit = uiNamespace getVariable ["BN_KOTH_lobbyContainedUnit", objNull];
private _previousApplied = uiNamespace getVariable ["BN_KOTH_lobbyContainmentApplied", false];
private _currentUnit = player;

if (_previousApplied && {!isNull _previousUnit} && {!(_previousUnit isEqualTo _currentUnit)}) then {
    _previousUnit enableSimulation true;
    uiNamespace setVariable ["BN_KOTH_lobbyContainmentApplied", false];
};

if (_shouldContain) then {
    if (!_previousApplied || {isNull _previousUnit} || {!(_previousUnit isEqualTo _currentUnit)}) then {
        _currentUnit enableSimulation false;
        uiNamespace setVariable ["BN_KOTH_lobbyContainedUnit", _currentUnit];
        uiNamespace setVariable ["BN_KOTH_lobbyContainmentApplied", true];
    };
} else {
    private _releaseUnit = uiNamespace getVariable ["BN_KOTH_lobbyContainedUnit", objNull];
    if (_previousApplied && {!isNull _releaseUnit}) then {
        _releaseUnit enableSimulation true;
    };

    uiNamespace setVariable ["BN_KOTH_lobbyContainedUnit", objNull];
    uiNamespace setVariable ["BN_KOTH_lobbyContainmentApplied", false];
};

_shouldContain
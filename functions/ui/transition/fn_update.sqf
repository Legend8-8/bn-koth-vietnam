/*
    File: fn_update.sqf
    Author: Legend
    Description: Owns the client-local deployment transition from replicated round and player state.
    Execution: Client
    Parameters:
        None
    Returns:
        True while the deployment transition is owned, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _visible = uiNamespace getVariable ["BN_KOTH_transitionVisible", false];
private _stateReady = missionNamespace getVariable ["BN_KOTH_stateReady", false];
private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", ""];
private _uid = getPlayerUID player;
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];

private _myState = "LOBBY";
private _knownPlayer = _stateReady
    && {!(_uid isEqualTo "")}
    && {_playerStates isEqualType createHashMap}
    && {_uid in (keys _playerStates)};
if (_knownPlayer) then {
    _myState = _playerStates getOrDefault [_uid, "LOBBY"];
};

private _participating = _knownPlayer && {
    (_uid in _activeParticipants) || {_myState in ["TEAM_SELECTED", "DEPLOYING", "ACTIVE", "RESPAWNING"]}
};

private _startTransition = {
    params ["_serverReady"];

    private _oldHandle = uiNamespace getVariable ["BN_KOTH_transitionTypewriterHandle", scriptNull];
    if (_oldHandle isEqualType scriptNull && {!scriptDone _oldHandle}) then {
        terminate _oldHandle;
    };

    private _token = (uiNamespace getVariable ["BN_KOTH_transitionLifecycleToken", 0]) + 1;
    uiNamespace setVariable ["BN_KOTH_transitionLifecycleToken", _token];
    uiNamespace setVariable ["BN_KOTH_transitionVisible", true];
    uiNamespace setVariable ["BN_KOTH_transitionPresentationFinished", false];
    uiNamespace setVariable ["BN_KOTH_transitionServerReady", _serverReady];

    disableUserInput true;
    uiNamespace setVariable ["BN_KOTH_transitionInputBlocked", true];

    private _layer = "BN_KOTH_DeploymentTransition" call BIS_fnc_rscLayer;
    _layer cutRsc ["BN_KOTH_RscTransition", "PLAIN", 0, false];

    private _locationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
    if (_locationId isEqualTo "") then {
        _locationId = missionNamespace getVariable ["BN_KOTH_selectedLocationId", ""];
    };

    private _locationCfg = missionConfigFile >> "CfgBnKothLocations" >> _locationId;
    private _locationName = if (isClass _locationCfg) then {getText (_locationCfg >> "displayName")} else {""};
    if (_locationName isEqualTo "") then {_locationName = toUpper _locationId};
    if (_locationName isEqualTo "") then {_locationName = "AWAITING ORDERS"};

    private _worldCfg = configFile >> "CfgWorlds" >> worldName;
    private _theatreName = if (isClass _worldCfg) then {getText (_worldCfg >> "description")} else {""};
    if (_theatreName isEqualTo "") then {_theatreName = toUpper worldName};

    private _handle = [_token, _theatreName, _locationName] spawn bn_koth_fnc_ui_transition_runTypewriter;
    uiNamespace setVariable ["BN_KOTH_transitionTypewriterHandle", _handle];
};

if (_roundState isEqualTo "PREPARING" && {_participating}) then {
    private _display = uiNamespace getVariable ["BN_KOTH_transitionDisplay", displayNull];
    if (!_visible || {isNull _display}) then {
        [false] call _startTransition;
    };

    true
} else {
    if (_roundState isEqualTo "ACTIVE" && {_visible} && {_participating}) then {
        private _display = uiNamespace getVariable ["BN_KOTH_transitionDisplay", displayNull];
        if (isNull _display) then {
            [true] call _startTransition;
        };
        uiNamespace setVariable ["BN_KOTH_transitionServerReady", true];
        if (uiNamespace getVariable ["BN_KOTH_transitionPresentationFinished", false]) then {
            [false] call bn_koth_fnc_ui_transition_hide;
        };
        true
    } else {
        if (_visible) then {
            [true] call bn_koth_fnc_ui_transition_hide;
        };
        false
    };
};

/*
    File: fn_update.sqf
    Author: Legend
    Description: Owns the client-local round-results presentation from replicated authoritative state.
    Execution: Client
    Parameters:
        None
    Returns:
        True while the results presentation is owned, otherwise false <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};

private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", ""];
private _visible = uiNamespace getVariable ["BN_KOTH_resultsVisible", false];

private _startResults = {
    if (uiNamespace getVariable ["BN_KOTH_transitionVisible", false]) then {
        [true] call bn_koth_fnc_ui_transition_hide;
    };

    private _menuDisplay = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
    if (!isNull _menuDisplay) then {
        [] call bn_koth_fnc_menu_close;
    };

    private _scores = missionNamespace getVariable ["BN_KOTH_teamScores", createHashMap];
    if !(_scores isEqualType createHashMap) then {_scores = createHashMap};

    private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
    if ((count _playableSides) < 2) then {_playableSides = [west, east]};
    private _leftSide = _playableSides select 0;
    private _rightSide = _playableSides select 1;

    private _leaders = missionNamespace getVariable ["BN_KOTH_liveLeaders", createHashMap];
    if !(_leaders isEqualType createHashMap) then {_leaders = createHashMap};
    private _leaderSnapshot = createHashMap;
    {
        private _entry = _leaders getOrDefault [_x, createHashMap];
        if !(_entry isEqualType createHashMap) then {_entry = createHashMap};
        _leaderSnapshot set [_x, createHashMapFromArray [
            ["name", _entry getOrDefault ["name", ""]],
            ["value", _entry getOrDefault ["value", 0]]
        ]];
    } forEach ["mostDeadly", "objective", "bestStreak"];

    private _snapshot = createHashMapFromArray [
        ["winner", missionNamespace getVariable ["BN_KOTH_winningSide", sideUnknown]],
        ["leftSide", _leftSide],
        ["rightSide", _rightSide],
        ["leftScore", _scores getOrDefault [_leftSide, 0]],
        ["rightScore", _scores getOrDefault [_rightSide, 0]],
        ["leaders", _leaderSnapshot]
    ];

    private _oldHandle = uiNamespace getVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
    if (_oldHandle isEqualType scriptNull && {!scriptDone _oldHandle}) then {terminate _oldHandle};

    private _token = (uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", 0]) + 1;
    uiNamespace setVariable ["BN_KOTH_resultsLifecycleToken", _token];
    uiNamespace setVariable ["BN_KOTH_resultsSnapshot", _snapshot];
    uiNamespace setVariable ["BN_KOTH_resultsVisible", true];
    uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", false];

    disableUserInput true;
    uiNamespace setVariable ["BN_KOTH_resultsInputBlocked", true];

    private _layer = "BN_KOTH_RoundResults" call BIS_fnc_rscLayer;
    _layer cutRsc ["BN_KOTH_RscResults", "PLAIN", 0, false];

    private _handle = [_token, _snapshot] spawn bn_koth_fnc_ui_results_runPresentation;
    uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", _handle];
};

if (!_visible && {_roundState in ["ENDING", "RESETTING"]}) then {
    call _startResults;
    _visible = true;
};

if (_visible) then {
    private _display = uiNamespace getVariable ["BN_KOTH_resultsDisplay", displayNull];
    private _presentationHandle = uiNamespace getVariable ["BN_KOTH_resultsPresentationHandle", scriptNull];
    private _presentationRunning = _presentationHandle isEqualType scriptNull && {!scriptDone _presentationHandle};
    if (isNull _display && {!_presentationRunning} && {_roundState in ["ENDING", "RESETTING", "WAITING"]}) then {
        private _snapshot = uiNamespace getVariable ["BN_KOTH_resultsSnapshot", createHashMap];
        private _token = (uiNamespace getVariable ["BN_KOTH_resultsLifecycleToken", 0]) + 1;
        uiNamespace setVariable ["BN_KOTH_resultsLifecycleToken", _token];
        uiNamespace setVariable ["BN_KOTH_resultsPresentationFinished", false];
        private _layer = "BN_KOTH_RoundResults" call BIS_fnc_rscLayer;
        _layer cutRsc ["BN_KOTH_RscResults", "PLAIN", 0, false];
        private _handle = [_token, _snapshot] spawn bn_koth_fnc_ui_results_runPresentation;
        uiNamespace setVariable ["BN_KOTH_resultsPresentationHandle", _handle];
    };

    private _uid = getPlayerUID player;
    private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
    private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
    private _myState = if (_playerStates isEqualType createHashMap) then {
        _playerStates getOrDefault [_uid, "LOBBY"]
    } else {
        "LOBBY"
    };
    private _lobbyReady = _roundState isEqualTo "WAITING"
        && {!(_uid in _activeParticipants)}
        && {!(_myState in ["DEPLOYING", "ACTIVE", "RESPAWNING", "RETURNING"])};

    if (_lobbyReady && {uiNamespace getVariable ["BN_KOTH_resultsPresentationFinished", false]}) then {
        [false] call bn_koth_fnc_ui_results_hide;
    };

    if !(_roundState in ["ENDING", "RESETTING", "WAITING"]) then {
        [true] call bn_koth_fnc_ui_results_hide;
    };
};

uiNamespace getVariable ["BN_KOTH_resultsVisible", false]

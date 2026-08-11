/*
    File: fn_refreshLobby.sqf
    Author: Legend
    Description: Renders the authoritative lobby state into the polished production lobby.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

#include "..\..\ui\lobby\idcs.hpp"

if (!hasInterface) exitWith {};

private _display = uiNamespace getVariable ["BN_KOTH_lobbyDisplay", displayNull];
if (isNull _display) then {
    _display = findDisplay BN_KOTH_IDD_LOBBY;
};
if (isNull _display) exitWith {};

private _scoringCfg = missionConfigFile >> "CfgBnKothScoring";
private _headerCfg = missionConfigFile >> "Header";
private _lobbyCfg = missionConfigFile >> "CfgBnKothLobby";

private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", "WAITING"];
private _voteOpen = missionNamespace getVariable ["BN_KOTH_voteOpen", false];
private _voteEndAt = missionNamespace getVariable ["BN_KOTH_voteEndAt", -1];
private _selectedLocationId = missionNamespace getVariable ["BN_KOTH_selectedLocationId", ""];
private _previousLocationId = missionNamespace getVariable ["BN_KOTH_previousLocationId", ""];
private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];

private _teamCounts = missionNamespace getVariable ["BN_KOTH_teamCounts", createHashMapFromArray [[west, 0], [east, 0]]];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
private _playerNames = missionNamespace getVariable ["BN_KOTH_playerNames", createHashMap];
private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _voteCandidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
private _voteTotals = missionNamespace getVariable ["BN_KOTH_voteTotals", createHashMap];
private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
private _teamScores = missionNamespace getVariable [
    "BN_KOTH_teamScores",
    createHashMapFromArray [[west, 0], [east, 0]]
];
private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreLimit")} else {100}];
private _scoreTick = missionNamespace getVariable ["BN_KOTH_scoreTick", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTick")} else {1}];
private _scoreTickInterval = missionNamespace getVariable ["BN_KOTH_scoreTickInterval", if (isClass _scoringCfg) then {getNumber (_scoringCfg >> "scoreTickInterval")} else {5}];
private _maxPlayers = missionNamespace getVariable [
    "BN_KOTH_maxPlayers",
    if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxPlayers")} else {
        if (isClass _headerCfg) then {getNumber (_headerCfg >> "maxPlayers")} else {100}
    }
];
private _teamCap = missionNamespace getVariable [
    "BN_KOTH_maxTeamPlayers",
    if (isClass _lobbyCfg) then {getNumber (_lobbyCfg >> "maxTeamPlayers")} else {50}
];

if (_maxPlayers < 1) then {
    _maxPlayers = 1;
};

if (_teamCap < 1) then {
    _teamCap = 1;
};

if (_scoreLimit < 1) then {
    _scoreLimit = 1;
};

if (_scoreTick < 0) then {
    _scoreTick = 0;
};

if (_scoreTickInterval < 1) then {
    _scoreTickInterval = 1;
};

private _westCount = 0;
private _eastCount = 0;
if (_teamCounts isEqualType createHashMap) then {
    _westCount = _teamCounts getOrDefault [west, 0];
    _eastCount = _teamCounts getOrDefault [east, 0];
};

private _westScore = 0;
private _eastScore = 0;
if (_teamScores isEqualType createHashMap) then {
    _westScore = _teamScores getOrDefault [west, 0];
    _eastScore = _teamScores getOrDefault [east, 0];
};

private _allSelected = _westCount + _eastCount;
private _currentPlayerCount = if (_playerNames isEqualType createHashMap) then {count (keys _playerNames)} else {_allSelected};

private _myUid = getPlayerUID player;
private _myAssignedSide = sideUnknown;
if (_playerAssignments isEqualType createHashMap) then {
    _myAssignedSide = _playerAssignments getOrDefault [_myUid, sideUnknown];
};

private _mySelectionValid = [_myAssignedSide] call bn_koth_fnc_teams_validateSide;

private _myState = "LOBBY";
if (_playerStates isEqualType createHashMap) then {
    _myState = _playerStates getOrDefault [_myUid, "LOBBY"];
};

private _isDeployed = _myUid in _activeParticipants;

private _resolveLocationName = {
    params ["_locationId"];

    if (_locationId isEqualTo "") exitWith {"NONE"};

    private _cfg = missionConfigFile >> "CfgBnKothLocations" >> _locationId;
    if (isClass _cfg) exitWith {
        private _displayName = getText (_cfg >> "displayName");
        if (_displayName isEqualTo "") then {
            toUpper _locationId
        } else {
            _displayName
        }
    };

    toUpper _locationId
};

private _resolveLocationMeta = {
    params ["_locationId"];

    if (_locationId isEqualTo "") exitWith {
        ["NONE", "", ""]
    };

    private _cfg = missionConfigFile >> "CfgBnKothLocations" >> _locationId;
    if !(isClass _cfg) exitWith {
        [toUpper _locationId, "", ""]
    };

    private _name = [_locationId] call _resolveLocationName;
    private _description = getText (_cfg >> "description");
    private _image = getText (_cfg >> "image");

    [_name, _description, _image]
};

private _describePlayerState = {
    params ["_state"];

    switch (_state) do {
        case "TEAM_SELECTED": {"READY"};
        case "DEPLOYING": {"DEPLOYING"};
        case "ACTIVE": {"DEPLOYED"};
        case "RETURNING": {"RETURNING"};
        default {_state};
    };
};

private _statusTitle = "LOBBY";
private _statusSubtitle = "Waiting for mission state";
private _headerRightTitle = "ROUND STATUS";
private _headerRightValue = "WAITING FOR TEAMS";

switch (_roundState) do {
    case "WAITING": {
        if (_voteOpen) then {
            _statusTitle = "MAP VOTE";
            _statusSubtitle = "SELECT NEXT OBJECTIVE";
            _headerRightTitle = "NEXT ROUND";
            _headerRightValue = "VOTE IN PROGRESS";
        } else {
            if (_myAssignedSide isEqualTo sideUnknown) then {
                _statusTitle = "LOBBY";
                _statusSubtitle = "WAITING FOR PLAYERS TO JOIN";
                _headerRightTitle = "ROUND STATUS";
                _headerRightValue = "WAITING FOR TEAMS";
            } else {
                _statusTitle = "LOBBY";
                _statusSubtitle = "WAITING FOR PLAYERS TO JOIN";
                _headerRightTitle = "ROUND STATUS";
                _headerRightValue = "TEAM SELECTED";
            };
        };
    };

    case "PREPARING": {
        _statusTitle = "PREPARING";
        _statusSubtitle = "PREPARING ROUND";
        _headerRightTitle = "OBJECTIVE";
        _headerRightValue = toUpper ([_selectedLocationId] call _resolveLocationName);
    };

    case "ACTIVE": {
        _statusTitle = "ROUND ACTIVE";
        _statusSubtitle = if (_isDeployed) then {
            format ["CURRENT AO: %1", toUpper ([_activeLocationId] call _resolveLocationName)]
        } else {
            "CHOOSE A TEAM TO DEPLOY"
        };
        _headerRightTitle = "ACTIVE AO";
        _headerRightValue = toUpper ([_activeLocationId] call _resolveLocationName);
    };

    case "ENDING": {
        _statusTitle = "ROUND COMPLETE";
        _statusSubtitle = "AWAITING RESET";
        _headerRightTitle = "ROUND STATUS";
        _headerRightValue = "COMPLETE";
    };

    case "RESETTING": {
        _statusTitle = "RETURNING";
        _statusSubtitle = "RESETTING ROUND STATE";
        _headerRightTitle = "ROUND STATUS";
        _headerRightValue = "RESETTING";
    };
};

private _westRows = [];
private _eastRows = [];

if (_playerAssignments isEqualType createHashMap) then {
    {
        private _uid = _x;
        private _assigned = _playerAssignments get _uid;

        if (_assigned in [west, east]) then {
            private _displayName = if (_playerNames isEqualType createHashMap) then {
                _playerNames getOrDefault [_uid, _uid]
            } else {
                _uid
            };

            private _state = if (_playerStates isEqualType createHashMap) then {
                _playerStates getOrDefault [_uid, "LOBBY"]
            } else {
                "LOBBY"
            };

            private _labelPrefix = if (_uid isEqualTo _myUid) then {"[YOU] "} else {""};
            private _stateText = [_state] call _describePlayerState;
            private _row = [format ["%1%2 - %3", _labelPrefix, _displayName, _stateText], _uid isEqualTo _myUid];

            if (_assigned isEqualTo west) then {
                _westRows pushBack _row;
            } else {
                _eastRows pushBack _row;
            };
        };
    } forEach (keys _playerAssignments);
};

if ((count _westRows) <= 0) then {
    _westRows pushBack ["No selected WEST players", false];
};

if ((count _eastRows) <= 0) then {
    _eastRows pushBack ["No selected EAST players", false];
};

private _selectionLocked = _roundState in ["PREPARING", "ENDING", "RESETTING"];
if (_isDeployed) then {
    _selectionLocked = true;
};

private _myVoteLocationId = "";
if (_votesByUid isEqualType createHashMap) then {
    _myVoteLocationId = _votesByUid getOrDefault [_myUid, ""];
};

private _voteAllowed = (
    _roundState isEqualTo "WAITING"
    && {_voteOpen}
    && {!_isDeployed}
    && {_myState isEqualTo "TEAM_SELECTED"}
    && {_mySelectionValid}
);

private _voteEntries = [];
for "_i" from 0 to 2 do {
    if (_i < count _voteCandidates) then {
        private _locationId = _voteCandidates select _i;
        private _meta = [_locationId] call _resolveLocationMeta;
        private _locationName = _meta select 0;
        private _locationDescription = _meta select 1;
        private _locationImage = _meta select 2;
        private _votes = if (_voteTotals isEqualType createHashMap) then {
            _voteTotals getOrDefault [_locationId, 0]
        } else {
            0
        };

        _voteEntries pushBack [_locationName, _locationDescription, _locationImage, _votes, _myVoteLocationId isEqualTo _locationId];
    };
};

private _previousMeta = [_previousLocationId] call _resolveLocationMeta;

private _voteTimerText = "VOTE CLOSED";
if (_voteOpen) then {
    if (_voteEndAt > -1) then {
        private _remaining = (_voteEndAt - serverTime) max 0;
        private _remainingInt = floor _remaining;
        private _minutes = floor (_remainingInt / 60);
        private _seconds = _remainingInt mod 60;
        private _secondsText = if (_seconds < 10) then {
            format ["0%1", _seconds]
        } else {
            str _seconds
        };
        _voteTimerText = format ["%1:%2", _minutes, _secondsText];
    } else {
        _voteTimerText = "--:--";
    };
} else {
    if (_roundState isEqualTo "PREPARING") then {
        _voteTimerText = "SELECTED";
    } else {
        _voteTimerText = "CLOSED";
    };
};

private _headerView = createHashMapFromArray [
    ["statusTitle", _statusTitle],
    ["statusSubtitle", _statusSubtitle],
    ["rightStatusTitle", _headerRightTitle],
    ["rightStatusValue", _headerRightValue],
    ["playerCount", _currentPlayerCount],
    ["maxPlayers", _maxPlayers],
    ["headerInfo", format ["Capture and hold the objective to earn score. First team to reach %1 wins the round.", _scoreLimit]],
    ["scoreLimit", _scoreLimit],
    ["scoreTick", _scoreTick],
    ["scoreTickInterval", _scoreTickInterval]
];

private _teamView = createHashMapFromArray [
    ["westCount", _westCount],
    ["eastCount", _eastCount],
    ["teamCap", _teamCap],
    ["westRows", _westRows],
    ["eastRows", _eastRows],
    ["myAssignedSide", _myAssignedSide],
    ["selectionLocked", _selectionLocked]
];

private _centerView = createHashMapFromArray [
    ["scoreLimit", _scoreLimit],
    ["westScore", _westScore],
    ["eastScore", _eastScore],
    ["roundTimeLimitText", "NONE"],
    ["vehiclesText", "SERVER RULES"],
    ["friendlyFireText", "SERVER RULES"],
    ["thirdPersonText", "SERVER RULES"]
];

private _voteHelpText = if (_voteOpen) then {
    if (_voteAllowed) then {
        "Vote for the next objective location."
    } else {
        "Join a team to vote for the next objective location."
    }
} else {
    if (_roundState isEqualTo "PREPARING") then {
        "Objective selected. Deployment in progress."
    } else {
        "Vote will open when enough players are ready."
    }
};

private _voteView = createHashMapFromArray [
    ["previousLocationName", _previousMeta select 0],
    ["previousLocationImage", _previousMeta select 2],
    ["voteEntries", _voteEntries],
    ["voteAllowed", _voteAllowed],
    ["voteTimerText", _voteTimerText],
    ["voteHelpText", _voteHelpText]
];
[_display, _headerView] call bn_koth_fnc_ui_refreshLobbyHeader;
[_display, _teamView] call bn_koth_fnc_ui_refreshLobbyTeams;
[_display, _centerView] call bn_koth_fnc_ui_refreshLobbyCenter;
[_display, _voteView] call bn_koth_fnc_ui_refreshLobbyVote;

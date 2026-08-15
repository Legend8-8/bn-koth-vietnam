/*
    File: fn_debugDisplayLoop.sqf
    Author: tylervip
    Edited: Legend
    Edited: Mongo
    Description: Renders a lightweight local debug display from replicated client state.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

while {missionNamespace getVariable ["BN_KOTH_debugEnabled", false]} do {
    private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", "UNKNOWN"];
    if (_roundState isEqualTo "") then {
        _roundState = "UNKNOWN";
    };

    private _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", "NONE"];
    if (_activeLocationId isEqualTo "") then {
        _activeLocationId = "NONE";
    };

    private _selectedLocationId = missionNamespace getVariable ["BN_KOTH_selectedLocationId", "NONE"];
    if (_selectedLocationId isEqualTo "") then {
        _selectedLocationId = "NONE";
    };

    private _previousLocationId = missionNamespace getVariable ["BN_KOTH_previousLocationId", "NONE"];
    if (_previousLocationId isEqualTo "") then {
        _previousLocationId = "NONE";
    };

    private _activeZoneMarker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", "NONE"];
    if (_activeZoneMarker isEqualTo "") then {
        _activeZoneMarker = "NONE";
    };

    private _zoneState = missionNamespace getVariable ["BN_KOTH_zoneState", "UNKNOWN"];
    if (_zoneState isEqualTo "") then {
        _zoneState = "UNKNOWN";
    };

    private _controller = missionNamespace getVariable ["BN_KOTH_zoneController", sideUnknown];
    private _controllerText = if (_controller isEqualTo sideUnknown) then {"NONE"} else {str _controller};

    private _zonePopulation = missionNamespace getVariable ["BN_KOTH_zonePopulation", createHashMap];
    private _weightedPopulation = if (_zonePopulation isEqualType createHashMap) then {
        _zonePopulation getOrDefault ["weighted", [0, 0]]
    } else {
        // Compatibility with snapshots produced before the structured population state.
        _zonePopulation
    };
    private _sideACount = if ((count _weightedPopulation) > 0) then {_weightedPopulation select 0} else {0};
    private _sideBCount = if ((count _weightedPopulation) > 1) then {_weightedPopulation select 1} else {0};

    private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
    if ((count _playableSides) < 2) then {
        _playableSides = [west, east];
    };

    private _sideA = _playableSides select 0;
    private _sideB = _playableSides select 1;

    private _westPopulation = 0;
    private _eastPopulation = 0;

    if (_sideA isEqualTo west) then {_westPopulation = _sideACount;};
    if (_sideB isEqualTo west) then {_westPopulation = _sideBCount;};
    if (_sideA isEqualTo east) then {_eastPopulation = _sideACount;};
    if (_sideB isEqualTo east) then {_eastPopulation = _sideBCount;};

    private _scores = missionNamespace getVariable [
        "BN_KOTH_teamScores",
        createHashMapFromArray [[west, 0], [east, 0]]
    ];

    if !(_scores isEqualType createHashMap) then {
        _scores = createHashMapFromArray [[west, 0], [east, 0]];
    };

    private _westScore = _scores getOrDefault [west, 0];
    private _eastScore = _scores getOrDefault [east, 0];
    private _scoreLimit = missionNamespace getVariable ["BN_KOTH_scoreLimit", 0];

    private _uid = getPlayerUID player;
    private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
    private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
    private _myState = if (_playerStates isEqualType createHashMap) then {_playerStates getOrDefault [_uid, "UNKNOWN"]} else {"UNKNOWN"};
    private _myAssignedSide = if (_playerAssignments isEqualType createHashMap) then {_playerAssignments getOrDefault [_uid, sideUnknown]} else {sideUnknown};
    private _myAssignedSideText = if (_myAssignedSide isEqualTo sideUnknown) then {"NONE"} else {str _myAssignedSide};

    private _teamCounts = missionNamespace getVariable ["BN_KOTH_teamCounts", createHashMapFromArray [[west, 0], [east, 0]]];
    private _westTeamCount = if (_teamCounts isEqualType createHashMap) then {_teamCounts getOrDefault [west, 0]} else {0};
    private _eastTeamCount = if (_teamCounts isEqualType createHashMap) then {_teamCounts getOrDefault [east, 0]} else {0};

    private _voteOpen = missionNamespace getVariable ["BN_KOTH_voteOpen", false];
    private _voteEndAt = missionNamespace getVariable ["BN_KOTH_voteEndAt", -1];
    private _voteRemaining = if (_voteOpen && {_voteEndAt > 0}) then {(_voteEndAt - serverTime) max 0} else {-1};
    private _voteCandidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
    private _voteTotals = missionNamespace getVariable ["BN_KOTH_voteTotals", createHashMap];
    private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
    private _myVote = if (_votesByUid isEqualType createHashMap) then {_votesByUid getOrDefault [_uid, "NONE"]} else {"NONE"};

    private _candidate1 = if ((count _voteCandidates) > 0) then {_voteCandidates select 0} else {"-"};
    private _candidate2 = if ((count _voteCandidates) > 1) then {_voteCandidates select 1} else {"-"};
    private _candidate3 = if ((count _voteCandidates) > 2) then {_voteCandidates select 2} else {"-"};

    private _candidate1Votes = if (_voteTotals isEqualType createHashMap) then {_voteTotals getOrDefault [_candidate1, 0]} else {0};
    private _candidate2Votes = if (_voteTotals isEqualType createHashMap) then {_voteTotals getOrDefault [_candidate2, 0]} else {0};
    private _candidate3Votes = if (_voteTotals isEqualType createHashMap) then {_voteTotals getOrDefault [_candidate3, 0]} else {0};

    private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
    private _isDeployed = _uid in _activeParticipants;

    private _controlledSideText = str (side group player);
    private _controlledClass = typeOf player;

    hintSilent format [
        "KOTH DEV DEBUG: ENABLED\nRound: %1\nLogical State: %2\nAssigned Side: %3\nDeployed: %4\nControlled Unit Side: %5\nControlled Unit Class: %6\n\nTeam Selected Counts W/E: %7 / %8\nEligible Zone W/E: %9 / %10\n\nVote Open: %11\nVote Remaining: %12\nMy Vote: %13\nC1: %14 (%15)\nC2: %16 (%17)\nC3: %18 (%19)\n\nSelected AO: %20\nPrevious AO: %21\nActive AO: %22\nZone Marker: %23\nZone State: %24\nController: %25\n\nWEST Score: %26\nEAST Score: %27\nScore Limit: %28",
        _roundState,
        _myState,
        _myAssignedSideText,
        _isDeployed,
        _controlledSideText,
        _controlledClass,
        _westTeamCount,
        _eastTeamCount,
        _westPopulation,
        _eastPopulation,
        _voteOpen,
        _voteRemaining,
        _myVote,
        _candidate1,
        _candidate1Votes,
        _candidate2,
        _candidate2Votes,
        _candidate3,
        _candidate3Votes,
        _selectedLocationId,
        _previousLocationId,
        _activeLocationId,
        _activeZoneMarker,
        _zoneState,
        _controllerText,
        _westScore,
        _eastScore,
        _scoreLimit
    ];

    sleep 1;
};

hintSilent "";
missionNamespace setVariable ["BN_KOTH_debugLoopRunning", false];
missionNamespace setVariable ["BN_KOTH_debugLoopHandle", scriptNull];

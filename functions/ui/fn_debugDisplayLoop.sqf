/*
    File: fn_debugDisplayLoop.sqf
    Author: Legend
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

    private _zonePopulation = missionNamespace getVariable ["BN_KOTH_zonePopulation", [0, 0]];
    private _sideACount = if ((count _zonePopulation) > 0) then {_zonePopulation select 0} else {0};
    private _sideBCount = if ((count _zonePopulation) > 1) then {_zonePopulation select 1} else {0};

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

    hintSilent format [
        "KOTH DEV DEBUG: ENABLED\nRound: %1\nAO: %2\nZone Marker: %3\nZone State: %4\nController: %5\nEligible WEST: %6\nEligible EAST: %7\nWEST Score: %8\nEAST Score: %9\nScore Limit: %10",
        _roundState,
        _activeLocationId,
        _activeZoneMarker,
        _zoneState,
        _controllerText,
        _westPopulation,
        _eastPopulation,
        _westScore,
        _eastScore,
        _scoreLimit
    ];

    sleep 1;
};

hintSilent "";
missionNamespace setVariable ["BN_KOTH_debugLoopRunning", false];
missionNamespace setVariable ["BN_KOTH_debugLoopHandle", scriptNull];

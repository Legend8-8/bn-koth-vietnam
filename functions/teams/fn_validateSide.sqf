/*
    File: fn_validateSide.sqf
    Author: tylervip
    Description: Returns true if side is currently playable.
    Execution: Any
    Parameters:
        0: Side to validate <SIDE>
    Returns:
        True when side is playable <BOOL>
    Public: Yes
*/

params ["_side"];

private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", []];

if (_playableSides isEqualTo []) then {
    private _teamCfg = missionConfigFile >> "CfgBnKothTeams";
    private _teamNames = if (isClass _teamCfg) then {getArray (_teamCfg >> "playableSides")} else {[]};
    private _resolvedSides = [];

    {
        switch (toUpper _x) do {
            case "WEST": {_resolvedSides pushBackUnique west};
            case "EAST": {_resolvedSides pushBackUnique east};
            case "RESISTANCE": {_resolvedSides pushBackUnique resistance};
            case "GUER": {_resolvedSides pushBackUnique resistance};
            case "CIVILIAN": {_resolvedSides pushBackUnique civilian};
        };
    } forEach _teamNames;

    if ((count _resolvedSides) < 2) then {
        _resolvedSides = [west, east];
    };

    missionNamespace setVariable ["BN_KOTH_playableSides", _resolvedSides];
    _playableSides = _resolvedSides;
};

_side in _playableSides

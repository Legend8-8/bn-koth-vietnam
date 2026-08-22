/*
    File: fn_isScoreBelowSwitchThreshold.sqf
    Author: tylervip
    Description: Checks whether the leading team's score is still below the configured
                 percentage of scoreLimit at which mid-round team switching locks.
    Execution: Any
    Parameters:
        None
    Returns:
        True when switching is still allowed, otherwise false <BOOL>
    Public: Yes
*/

private _teamScores = missionNamespace getVariable ["BN_KOTH_teamScores", createHashMap];
if !(_teamScores isEqualType createHashMap) exitWith {true};

private _scoreLimit = (missionNamespace getVariable ["BN_KOTH_scoreLimit", 100]) max 1;
private _teamsCfg = missionConfigFile >> "CfgBnKothTeams";
private _limitPercent = if (isClass _teamsCfg) then {getNumber (_teamsCfg >> "switchTeamScoreLimitPercent")} else {60};

private _westScore = _teamScores getOrDefault [west, 0];
private _eastScore = _teamScores getOrDefault [east, 0];
private _leadingScore = _westScore max _eastScore;

_leadingScore < (_scoreLimit * (_limitPercent / 100))

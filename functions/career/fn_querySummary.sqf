/*
    File: fn_querySummary.sqf
    Author: Legend
    Description: Reads and projects one persisted lifetime career row through the semantic SQL_CUSTOM contract.
    Execution: Server
    Parameters: Server-derived player UID <STRING>
    Returns: Semantic career summary result <HASHMAP>
    Public: No
*/
params [["_uid", "", [""]]];
private _emptyStats = {
    createHashMapFromArray [
        ["kills",0], ["deaths",0], ["wins",0], ["roundsPlayed",0],
        ["objectiveContribution",0], ["highestKillStreak",0],
        ["totalXpEarned",0], ["timePlayedSeconds",0]
    ]
};
if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMapFromArray [["success",false],["code","CAREER_UNAVAILABLE"],["stats",createHashMap]]};

private _result = ["loadCareerSummary", [_uid]] call bn_koth_fnc_persistence_extdbCall;
if !(_result getOrDefault ["success", false]) exitWith {
    createHashMapFromArray [["success",false],["code","CAREER_UNAVAILABLE"],["stats",createHashMap]]
};
private _rows = _result getOrDefault ["rows", []];
if ((count _rows) isEqualTo 0) exitWith {
    createHashMapFromArray [["success",true],["code","CAREER_NEW"],["stats",call _emptyStats]]
};
if ((count _rows) isNotEqualTo 1) exitWith {
    createHashMapFromArray [["success",false],["code","CAREER_UNAVAILABLE"],["stats",createHashMap]]
};
private _row = _rows select 0;
if !(_row isEqualType [] && {(count _row) isEqualTo 8}) exitWith {
    createHashMapFromArray [["success",false],["code","CAREER_UNAVAILABLE"],["stats",createHashMap]]
};
if ((_row findIf {!(_x isEqualType 0 && {finite _x} && {_x >= 0} && {_x isEqualTo floor _x})}) >= 0) exitWith {
    createHashMapFromArray [["success",false],["code","CAREER_UNAVAILABLE"],["stats",createHashMap]]
};
createHashMapFromArray [
    ["success",true], ["code","CAREER_OK"],
    ["stats",createHashMapFromArray [
        ["kills",_row select 0], ["deaths",_row select 1],
        ["wins",_row select 2], ["roundsPlayed",_row select 3],
        ["objectiveContribution",_row select 4], ["highestKillStreak",_row select 5],
        ["totalXpEarned",_row select 6], ["timePlayedSeconds",_row select 7]
    ]]
]

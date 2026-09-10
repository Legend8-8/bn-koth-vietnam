/*
    File: test_assists.sqf
    Author: Legend
    Description: Focused server tests for assist finalization boundaries and cleanup.
    Execution: Server test console
    Returns: Failure messages; an empty array means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Assist tests must run on the server."]};
private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _backupRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _backupEnabled = missionNamespace getVariable ["BN_KOTH_assistsEnabled", false];
private _backupWindow = missionNamespace getVariable ["BN_KOTH_assistWindowSeconds", 15];
private _backupMinimum = missionNamespace getVariable ["BN_KOTH_assistMinimumDamage", 0.2];
private _backupVictims = missionNamespace getVariable ["BN_KOTH_combatAssistVictims", []];

private _victim = createVehicle ["C_man_1", [0, 0, 0], [], 0, "NONE"];
private _assistant = createVehicle ["C_man_1", [2, 0, 0], [], 0, "NONE"];
private _teammate = createVehicle ["C_man_1", [4, 0, 0], [], 0, "NONE"];
private _records = createHashMapFromArray [
    ["ASSIST", createHashMapFromArray [["currentUnit", _assistant], ["assignedSide", west], ["deployed", true]]],
    ["TEAMMATE", createHashMapFromArray [["currentUnit", _teammate], ["assignedSide", east], ["deployed", true]]],
    ["VICTIM", createHashMapFromArray [["currentUnit", _victim], ["assignedSide", east], ["deployed", true]]]
];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
missionNamespace setVariable ["BN_KOTH_assistsEnabled", true];
missionNamespace setVariable ["BN_KOTH_assistWindowSeconds", 15];
missionNamespace setVariable ["BN_KOTH_assistMinimumDamage", 0.2];
missionNamespace setVariable ["BN_KOTH_combatAssistVictims", [_victim]];
_victim setVariable ["BN_KOTH_assistContributors", createHashMapFromArray [
    ["ASSIST", [0.4, diag_tickTime]], ["TEAMMATE", [0.8, diag_tickTime]],
    ["KILLER", [0.8, diag_tickTime]], ["STALE", [0.8, diag_tickTime - 30]],
    ["LOW", [0.1, diag_tickTime]]
], false];
private _kill = createHashMapFromArray [
    ["roundActive", true], ["validPvp", true], ["killerUid", "KILLER"], ["victimSide", east]
];
private _result = [_victim, _kill] call bn_koth_fnc_combat_finalizeAssists;
[_result isEqualTo ["ASSIST"], "Assist finalizer did not exclude killer, teammate, stale, malformed and below-threshold entries."] call _check;
[(count (_victim getVariable ["BN_KOTH_assistContributors", createHashMap])) isEqualTo 0, "Victim contribution state was not consumed."] call _check;

deleteVehicle _victim;
deleteVehicle _assistant;
deleteVehicle _teammate;
missionNamespace setVariable ["BN_KOTH_playerRecords", _backupRecords];
missionNamespace setVariable ["BN_KOTH_assistsEnabled", _backupEnabled];
missionNamespace setVariable ["BN_KOTH_assistWindowSeconds", _backupWindow];
missionNamespace setVariable ["BN_KOTH_assistMinimumDamage", _backupMinimum];
missionNamespace setVariable ["BN_KOTH_combatAssistVictims", _backupVictims];
_failures

/*
    File: test_weaponMastery.sqf
    Author: Legend
    Description: Focused hosted/dedicated checks for fail-closed canonical
        weapon mastery awards. Not registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

if (!isServer) exitWith {["Weapon mastery tests require server execution"]};

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};
private _uid = "BN_KOTH_TEST_MASTERY_KILLER";
private _victimUid = "BN_KOTH_TEST_MASTERY_VICTIM";
private _progressionBackup = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _recordsBackup = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _processedBackup = missionNamespace getVariable ["BN_KOTH_weaponMasteryProcessedKills", createHashMap];

missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMapFromArray [[_uid, createHashMap]]];
missionNamespace setVariable ["BN_KOTH_playerRecords", createHashMapFromArray [[_uid, createHashMapFromArray [["state", "ACTIVE"], ["deployed", true]]]]];
missionNamespace setVariable ["BN_KOTH_weaponMasteryProcessedKills", createHashMap];
[_uid] call bn_koth_fnc_progression_mastery_initPlayer;

private _attributed = createHashMapFromArray [
    ["result", "ATTRIBUTED"], ["canonicalCandidates", ["vn_m16"]],
    ["projectiles", ["test_projectile_1"]]
];
private _kill = createHashMapFromArray [
    ["roundActive", true], ["validPvp", true], ["suicide", false], ["teamkill", false],
    ["killerUid", _uid], ["victimUid", _victimUid], ["weaponAttribution", _attributed]
];
private _result = [_kill] call bn_koth_fnc_progression_mastery_awardKill;
["Valid attributed PvP kill awards", _result getOrDefault ["awarded", false]] call _check;
private _state = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) get _uid;
["Attributed structural evidence increments canonical root", ((_state get "weaponKills") getOrDefault ["vn_m16", 0]) isEqualTo 1] call _check;
_result = [_kill] call bn_koth_fnc_progression_mastery_awardKill;
_state = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) get _uid;
["One kill event cannot double increment", (_result getOrDefault ["code", ""]) isEqualTo "DUPLICATE_KILL_EVENT" && {((_state get "weaponKills") get "vn_m16") isEqualTo 1}] call _check;

{
    _x params ["_label", "_attributionResult"];
    private _testKill = createHashMapFromArray ((keys _kill) apply {[_x, _kill get _x]});
    _testKill set ["weaponAttribution", _attributionResult];
    private _testResult = [_testKill] call bn_koth_fnc_progression_mastery_awardKill;
    [_label, !(_testResult getOrDefault ["awarded", false])] call _check;
} forEach [
    ["UNKNOWN attribution does not award", createHashMapFromArray [["result", "UNKNOWN"], ["canonicalCandidates", []]]],
    ["AMBIGUOUS attribution does not award", createHashMapFromArray [["result", "AMBIGUOUS"], ["canonicalCandidates", ["vn_m16", "vn_m1911"]]]],
    ["Non-infantry attribution does not award", createHashMapFromArray [["result", "UNKNOWN"], ["reason", "NON_INFANTRY_SOURCE"], ["canonicalCandidates", []]]]
];

private _invalidKill = createHashMapFromArray ((keys _kill) apply {[_x, _kill get _x]});
_invalidKill set ["validPvp", false];
_invalidKill set ["weaponAttribution", createHashMapFromArray [["result", "ATTRIBUTED"], ["canonicalCandidates", ["vn_m1911"]], ["projectiles", ["test_projectile_2"]]]];
_result = [_invalidKill] call bn_koth_fnc_progression_mastery_awardKill;
["Invalid PvP kill does not award", !(_result getOrDefault ["awarded", false])] call _check;

[_uid] call bn_koth_fnc_progression_mastery_initPlayer;
[_uid] call bn_koth_fnc_progression_mastery_initPlayer;
_state = (missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap]) get _uid;
["Repeated initialization preserves mastery", ((_state get "weaponKills") getOrDefault ["vn_m16", 0]) isEqualTo 1] call _check;

private _payload = [_uid, _state] call bn_koth_fnc_progression_buildPresentationState;
["Progression presentation preserves mastery", ((_payload get "weaponKills") getOrDefault ["vn_m16", 0]) isEqualTo 1] call _check;

missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionBackup];
missionNamespace setVariable ["BN_KOTH_playerRecords", _recordsBackup];
missionNamespace setVariable ["BN_KOTH_weaponMasteryProcessedKills", _processedBackup];
diag_log format ["[BN_KOTH_TEST] Weapon mastery: %1 failure(s): %2", count _failures, _failures];
_failures

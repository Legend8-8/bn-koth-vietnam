/*
    File: test_cash.sqf
    Author: Legend
    Description: Focused in-engine checks for server-owned session cash state.
        This file is not registered as a runtime function.
    Execution: Hosted or dedicated server debug/test context
    Returns: Array of failed assertion labels <ARRAY>
*/

if (!isServer) exitWith {["Cash tests require server execution"]};

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _uid = "BN_KOTH_TEST_CASH_UID";
private _progressionBackup = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _recordsBackup = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _startingCashBackup = missionNamespace getVariable ["BN_KOTH_startingCash", 1000];

missionNamespace setVariable ["BN_KOTH_startingCash", 1000];
missionNamespace setVariable ["BN_KOTH_playerProgression", createHashMap];
missionNamespace setVariable [
    "BN_KOTH_playerRecords",
    createHashMapFromArray [[_uid, createHashMapFromArray [["ownerId", -1]]]]
];

[_uid] call bn_koth_fnc_progression_cash_initPlayer;
["Starting cash initializes once", ([_uid] call bn_koth_fnc_progression_cash_getCash) isEqualTo 1000] call _check;

[_uid, 250, "test_award"] call bn_koth_fnc_progression_cash_addCash;
["Positive cash award updates total", ([_uid] call bn_koth_fnc_progression_cash_getCash) isEqualTo 1250] call _check;

[_uid] call bn_koth_fnc_progression_cash_initPlayer;
["Repeated initialization preserves cash", ([_uid] call bn_koth_fnc_progression_cash_getCash) isEqualTo 1250] call _check;

private _spend = [_uid, 200, "test_spend"] call bn_koth_fnc_progression_cash_spendCash;
["Affordable spend succeeds", (_spend getOrDefault ["success", false]) && {(_spend getOrDefault ["cash", -1]) isEqualTo 1050}] call _check;

private _insufficient = [_uid, 2000, "test_spend"] call bn_koth_fnc_progression_cash_spendCash;
["Insufficient spend is rejected atomically",
    !(_insufficient getOrDefault ["success", true]) &&
    {(_insufficient getOrDefault ["code", ""]) isEqualTo "INSUFFICIENT_CASH"} &&
    {([_uid] call bn_koth_fnc_progression_cash_getCash) isEqualTo 1050}] call _check;

private _invalidAdd = [_uid, -1, "test_award"] call bn_koth_fnc_progression_cash_addCash;
["Non-positive award is rejected",
    !(_invalidAdd getOrDefault ["success", true]) &&
    {([_uid] call bn_koth_fnc_progression_cash_getCash) isEqualTo 1050}] call _check;

private _presentationByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
private _presentationState = [_uid, _presentationByUid get _uid] call bn_koth_fnc_progression_buildPresentationState;
["Presentation payload includes authoritative cash", (_presentationState getOrDefault ["cash", -1]) isEqualTo 1050] call _check;

missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionBackup];
missionNamespace setVariable ["BN_KOTH_playerRecords", _recordsBackup];
missionNamespace setVariable ["BN_KOTH_startingCash", _startingCashBackup];

diag_log format ["[BN_KOTH_TEST] Cash: %1 failure(s): %2", count _failures, _failures];
_failures

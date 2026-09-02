/*
    File: test_progressionMasteryUi.sqf
    Author: Legend
    Description: Focused in-engine checks for the weapon mastery catalogue and
        presentation projection consumed by the deployed Progression page.
        This file is not runtime-registered.
    Execution: Client debug/test context
    Returns: Failed assertion labels <ARRAY>
*/

#include "..\..\..\ui\menu\idcs.hpp"

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _weaponsCfg = missionConfigFile >> "CfgBnKothArsenal" >> "Equipment" >> "Metadata" >> "Weapons";
private _entries = [];
{
    private _weaponClass = toLower (configName _x);
    private _metadata = [_weaponClass] call bn_koth_fnc_loadouts_getWeaponMetadata;
    private _required = floor ((_metadata getOrDefault ["masteryKillsRequired", 0]) max 0);
    if (
        (_metadata getOrDefault ["success", false])
        && {_metadata getOrDefault ["configured", false]}
        && {_required > 0}
    ) then {
        _entries pushBack createHashMapFromArray [
            ["weaponClass", _weaponClass],
            ["canonicalClass", _metadata getOrDefault ["canonicalClass", ""]],
            ["required", _required]
        ];
    };
} forEach ("true" configClasses _weaponsCfg);

private _classes = _entries apply {_x getOrDefault ["weaponClass", ""]};
["Mastery catalogue has at least one authored weapon", (count _entries) > 0] call _check;
["Mastery catalogue classnames are unique", (count _classes) isEqualTo (count (_classes arrayIntersect _classes))] call _check;
["Every mastery entry is its canonical weapon root", (_entries findIf {
    !((_x getOrDefault ["weaponClass", ""]) isEqualTo (_x getOrDefault ["canonicalClass", "missing"]))
}) < 0] call _check;
["Every mastery requirement is positive", (_entries findIf {(_x getOrDefault ["required", 0]) <= 0}) < 0] call _check;

private _testCatalogue = [
    createHashMapFromArray [["weaponClass", "test_zero"], ["displayName", "Zero"], ["picture", "zero.paa"], ["required", 10]],
    createHashMapFromArray [["weaponClass", "test_partial"], ["displayName", "Zulu"], ["picture", "partial.paa"], ["required", 10]],
    createHashMapFromArray [["weaponClass", "test_tie_b"], ["displayName", "Alpha"], ["picture", ""], ["required", 20]],
    createHashMapFromArray [["weaponClass", "test_tie_a"], ["displayName", "Alpha"], ["picture", ""], ["required", 20]],
    createHashMapFromArray [["weaponClass", "test_complete"], ["displayName", "Complete"], ["picture", "complete.paa"], ["required", 10]],
    createHashMapFromArray [["weaponClass", "test_over"], ["displayName", "Over"], ["picture", "over.paa"], ["required", 10]],
    createHashMapFromArray [["weaponClass", "test_invalid"], ["displayName", "Invalid"], ["picture", ""], ["required", 10]],
    createHashMapFromArray [["weaponClass", "test_negative"], ["displayName", "Negative"], ["picture", ""], ["required", 10]]
];
private _testKills = createHashMapFromArray [
    ["test_zero", 0],
    ["test_partial", 8],
    ["test_tie_b", 10],
    ["test_tie_a", 10],
    ["test_complete", 10],
    ["test_over", 15],
    ["test_invalid", "not-a-number"],
    ["test_negative", -5]
];

private _inProgress = [_testCatalogue, _testKills, "IN_PROGRESS", 0, 4] call bn_koth_fnc_menu_projectMasteryEntries;
private _inProgressEntries = _inProgress getOrDefault ["entries", []];
private _inProgressClasses = _inProgressEntries apply {_x getOrDefault ["weaponClass", ""]};
["Zero-kill weapon is absent from IN PROGRESS", !("test_zero" in _inProgressClasses)] call _check;
["Invalid and negative kills normalize to zero", !("test_invalid" in _inProgressClasses) && {!("test_negative" in _inProgressClasses)}] call _check;
["Partial weapon appears in IN PROGRESS", "test_partial" in _inProgressClasses] call _check;
["IN PROGRESS sorts highest ratio first", (_inProgressClasses param [0, ""]) isEqualTo "test_partial"] call _check;
["IN PROGRESS tie is deterministic by display then classname", (_inProgressClasses select [1, 2]) isEqualTo ["test_tie_a", "test_tie_b"]] call _check;
private _partial = _inProgressEntries param [_inProgressClasses find "test_partial", createHashMap];
["Partial ratio remains within zero and one", abs ((_partial getOrDefault ["ratio", -1]) - 0.8) < 0.001] call _check;

private _completed = [_testCatalogue, _testKills, "COMPLETED", 0, 4] call bn_koth_fnc_menu_projectMasteryEntries;
private _completedEntries = _completed getOrDefault ["entries", []];
private _completedClasses = _completedEntries apply {_x getOrDefault ["weaponClass", ""]};
["Exact and over-complete weapons appear in COMPLETED", ("test_complete" in _completedClasses) && {"test_over" in _completedClasses}] call _check;
["Over-complete ratio is clamped to one", ((_completedEntries select (_completedClasses find "test_over")) getOrDefault ["ratio", -1]) isEqualTo 1] call _check;
["Over-complete actual kill count is retained", ((_completedEntries select (_completedClasses find "test_over")) getOrDefault ["kills", -1]) isEqualTo 15] call _check;

private _allFirst = [_testCatalogue, _testKills, "ALL", 0, 3] call bn_koth_fnc_menu_projectMasteryEntries;
private _allLast = [_testCatalogue, _testKills, "ALL", 99, 3] call bn_koth_fnc_menu_projectMasteryEntries;
["ALL computes expected page count", (_allFirst getOrDefault ["pageCount", 0]) isEqualTo 3] call _check;
["Requested page clamps to final page", (_allLast getOrDefault ["page", -1]) isEqualTo 2] call _check;
["Final page contains remaining entries", (count (_allLast getOrDefault ["pageEntries", []])) isEqualTo 2] call _check;
["Unknown filter safely normalizes", (([_testCatalogue, _testKills, "UNKNOWN", 0, 4] call bn_koth_fnc_menu_projectMasteryEntries) getOrDefault ["filter", ""]) isEqualTo "IN_PROGRESS"] call _check;

private _display = uiNamespace getVariable ["BN_KOTH_menuDisplay", displayNull];
if (!isNull _display) then {
    private _masteryIdcs = [
        BN_KOTH_IDC_MENU_MASTERY_TITLE,
        BN_KOTH_IDC_MENU_MASTERY_FILTER_PROGRESS,
        BN_KOTH_IDC_MENU_MASTERY_FILTER_COMPLETED,
        BN_KOTH_IDC_MENU_MASTERY_FILTER_ALL,
        BN_KOTH_IDC_MENU_MASTERY_CARD_1_BG,
        BN_KOTH_IDC_MENU_MASTERY_CARD_2_BG,
        BN_KOTH_IDC_MENU_MASTERY_CARD_3_BG,
        BN_KOTH_IDC_MENU_MASTERY_CARD_4_BG
    ];
    ["Open menu contains every dedicated mastery control", (_masteryIdcs findIf {isNull (_display displayCtrl _x)}) < 0] call _check;
};

diag_log format ["[BN_KOTH_TEST] Progression mastery UI: %1 failure(s): %2", count _failures, _failures];
_failures

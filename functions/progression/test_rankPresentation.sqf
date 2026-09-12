/*
    File: test_rankPresentation.sqf
    Author: Legend
    Description: Focused in-engine checks for icon-only rank presentation.
        This file is not registered as a runtime function.
    Execution: Client or hosted debug/test context after function initialization
    Returns: Array of failed assertion labels <ARRAY>
*/

private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label};
};

private _privateIcon = "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa";
private _corporalIcon = "\A3\Ui_f\data\GUI\Cfg\Ranks\corporal_gs.paa";
private _colonelIcon = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
private _grades = createHashMapFromArray [
    ["BRONZE", [0.7, 0.4, 0.2, 1]],
    ["SILVER", [0.7, 0.75, 0.8, 1]],
    ["GOLD", [0.95, 0.72, 0.2, 1]]
];
private _bands = [
    createHashMapFromArray [["minLevel", 10], ["icon", _privateIcon], ["grade", "BRONZE"]],
    createHashMapFromArray [["minLevel", 20], ["icon", _corporalIcon], ["grade", "SILVER"]],
    createHashMapFromArray [["minLevel", 270], ["icon", _colonelIcon], ["grade", "GOLD"]]
];

private _configuredBands = "true" configClasses (missionConfigFile >> "CfgBnKothRanks" >> "Ranks");
["Configured ladder has no player-facing displayName", ({isText (_x >> "displayName")} count _configuredBands) isEqualTo 0] call _check;
["Configured ladder has no player-facing shortName", ({isText (_x >> "shortName")} count _configuredBands) isEqualTo 0] call _check;
["Every configured built-in icon exists", ({private _icon = getText (_x >> "icon"); _icon isEqualTo "" || {!fileExists _icon}} count _configuredBands) isEqualTo 0] call _check;
private _configuredRecruit = [1] call bn_koth_fnc_progression_resolveRankPresentation;
["Configured level 1 remains recruit", !(_configuredRecruit getOrDefault ["hasIcon", true])] call _check;
private _configuredMaximum = [270] call bn_koth_fnc_progression_resolveRankPresentation;
["Configured maximum resolves final icon", _configuredMaximum getOrDefault ["hasIcon", false] && {(_configuredMaximum getOrDefault ["minLevel", -1]) isEqualTo 270}] call _check;

private _result = [1, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Level 1 recruit has no icon", !(_result getOrDefault ["hasIcon", true])] call _check;
["Recruit reports first threshold", (_result getOrDefault ["nextRankLevel", -1]) isEqualTo 10] call _check;

_result = [9, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Immediately below first threshold has no icon", !(_result getOrDefault ["hasIcon", true])] call _check;

_result = [10, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Exact first threshold resolves configured icon", (_result getOrDefault ["icon", ""]) isEqualTo _privateIcon] call _check;
["Bronze band resolves grade and color", (_result getOrDefault ["grade", ""]) isEqualTo "BRONZE" && {(_result getOrDefault ["color", []]) isEqualTo (_grades get "BRONZE")}] call _check;

_result = [19, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Below threshold retains previous icon", (_result getOrDefault ["icon", ""]) isEqualTo _privateIcon] call _check;

_result = [20, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Exact threshold switches icon", (_result getOrDefault ["icon", ""]) isEqualTo _corporalIcon] call _check;
["Silver band resolves grade and color", (_result getOrDefault ["grade", ""]) isEqualTo "SILVER" && {(_result getOrDefault ["color", []]) isEqualTo (_grades get "SILVER")}] call _check;

_result = [270, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Maximum level resolves final configured band", (_result getOrDefault ["icon", ""]) isEqualTo _colonelIcon] call _check;
["Gold band resolves grade and color", (_result getOrDefault ["grade", ""]) isEqualTo "GOLD" && {(_result getOrDefault ["color", []]) isEqualTo (_grades get "GOLD")}] call _check;

_result = [999, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["High level clamps to configured maximum", (_result getOrDefault ["level", -1]) isEqualTo (_result getOrDefault ["maxLevel", -2])] call _check;

_result = [-10, _bands, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Negative level clamps to one", (_result getOrDefault ["level", -1]) isEqualTo 1] call _check;
["Clamped low level remains recruit", !(_result getOrDefault ["hasIcon", true])] call _check;

private _malformed = [
    createHashMapFromArray [["minLevel", 0], ["icon", _privateIcon], ["grade", "BRONZE"]],
    createHashMapFromArray [["minLevel", 1], ["icon", ""], ["grade", "BRONZE"]]
];
_result = [1, _malformed, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Malformed ladder fails to no-icon presentation", !(_result getOrDefault ["hasIcon", true])] call _check;

private _invalidGrade = [createHashMapFromArray [["minLevel", 1], ["icon", _privateIcon], ["grade", "INVALID"]]];
_result = [1, _invalidGrade, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Invalid grade fails safely", !(_result getOrDefault ["hasIcon", true])] call _check;

private _missingIcon = [createHashMapFromArray [["minLevel", 1], ["icon", "\bn_koth\missing_rank_icon.paa"], ["grade", "BRONZE"]]];
_result = [1, _missingIcon, _grades] call bn_koth_fnc_progression_resolveRankPresentation;
["Missing icon fails safely", !(_result getOrDefault ["hasIcon", true]) && {(_result getOrDefault ["icon", "invalid"]) isEqualTo ""}] call _check;
["Resolver requires no displayName field", !("displayName" in _result)] call _check;
["Resolver requires no shortName field", !("shortName" in _result)] call _check;
["Rank payload has no authority state", ({_x in _result} count ["xp", "cash", "ownedWeapons", "weaponKills", "entitled"]) isEqualTo 0] call _check;

if (isServer) then {
    private _state = createHashMapFromArray [
        ["xp", 100], ["cash", 1000], ["rank", "SHOULD_NOT_PERSIST"],
        ["ownedWeapons", []], ["weaponKills", createHashMap]
    ];
    private _projection = ["rank_test_uid", _state] call bn_koth_fnc_persistence_projectPlayerState;
    ["Rank is excluded from persistence projection", !("rank" in _projection)] call _check;
};

_failures

/*
    File: fn_resolveRankPresentation.sqf
    Author: Legend
    Description: Resolves icon-only rank presentation for an account level.
        It grants no authority and performs no persistence or engine-rank work.
    Execution: Any
    Parameters:
        0: Account level <NUMBER>
        1: Optional rank-entry override for pure tests <ARRAY or OBJECT>
        2: Optional grade-colour override for pure tests <HASHMAP or OBJECT>
    Returns: Rank presentation payload <HASHMAP>
    Public: No
*/

params [
    ["_level", 1, [0]],
    ["_entriesOverride", objNull, [objNull, []]],
    ["_gradesOverride", objNull, [objNull, createHashMap]]
];

private _progressionCfg = missionConfigFile >> "CfgBnKothScoring" >> "progression";
private _maxLevel = if (isNumber (_progressionCfg >> "maxLevel")) then {getNumber (_progressionCfg >> "maxLevel")} else {270};
_maxLevel = floor (_maxLevel max 1);
private _safeLevel = (floor (_level max 1)) min _maxLevel;
private _rankCfg = missionConfigFile >> "CfgBnKothRanks";
private _usingMissionConfig = _entriesOverride isEqualType objNull && {_gradesOverride isEqualType objNull};
private _loadedFromCache = false;
if (_usingMissionConfig) then {
    private _cache = missionNamespace getVariable ["BN_KOTH_rankPresentationConfigCache", createHashMap];
    if (_cache isEqualType createHashMap && {"entries" in _cache} && {"grades" in _cache}) then {
        _entriesOverride = _cache getOrDefault ["entries", []];
        _gradesOverride = _cache getOrDefault ["grades", createHashMap];
        _loadedFromCache = true;
    };
};

private _grades = createHashMap;
if (_gradesOverride isEqualType createHashMap) then {
    {
        private _color = _gradesOverride get _x;
        if (_color isEqualType [] && {(count _color) isEqualTo 4} && {{_x isEqualType 0} count _color isEqualTo 4}) then {
            _grades set [toUpper _x, _color apply {(_x max 0) min 1}];
        };
    } forEach (keys _gradesOverride);
} else {
    private _gradesCfg = _rankCfg >> "Grades";
    if (isClass _gradesCfg) then {
        {
            private _color = if (isArray (_x >> "color")) then {getArray (_x >> "color")} else {[]};
            if ((count _color) isEqualTo 4 && {{_x isEqualType 0} count _color isEqualTo 4}) then {
                _grades set [toUpper (configName _x), _color apply {(_x max 0) min 1}];
            };
        } forEach ("true" configClasses _gradesCfg);
    };
};

private _entries = [];
if (_entriesOverride isEqualType []) then {
    _entries = +_entriesOverride;
} else {
    private _bandsCfg = _rankCfg >> "Ranks";
    if (isClass _bandsCfg) then {
        {
            _entries pushBack (createHashMapFromArray [
                ["minLevel", if (isNumber (_x >> "minLevel")) then {getNumber (_x >> "minLevel")} else {-1}],
                ["icon", if (isText (_x >> "icon")) then {getText (_x >> "icon")} else {""}],
                ["grade", if (isText (_x >> "grade")) then {toUpper (getText (_x >> "grade"))} else {""}]
            ]);
        } forEach ("true" configClasses _bandsCfg);
    };
};

if (_usingMissionConfig && {!_loadedFromCache}) then {
    missionNamespace setVariable ["BN_KOTH_rankPresentationConfigCache", createHashMapFromArray [
        ["entries", _entries], ["grades", _grades]
    ]];
};

private _valid = _entries select {
    if !(_x isEqualType createHashMap) exitWith {false};
    private _threshold = _x getOrDefault ["minLevel", -1];
    private _icon = _x getOrDefault ["icon", ""];
    private _grade = _x getOrDefault ["grade", ""];
    if !(_grade isEqualType "") then {_grade = ""} else {_grade = toUpper _grade};
    _threshold isEqualType 0
    && {_threshold >= 1 && {_threshold <= _maxLevel}}
    && {_icon isEqualType "" && {!(_icon isEqualTo "")}}
    && {_grade isEqualType "" && {_grade in _grades}}
};

private _selected = createHashMap;
private _selectedLevel = -1;
{
    private _threshold = floor (_x getOrDefault ["minLevel", -1]);
    if (_threshold <= _safeLevel && {_threshold > _selectedLevel}) then {
        _selected = _x;
        _selectedLevel = _threshold;
    };
} forEach _valid;

private _nextRankLevel = -1;
{
    private _threshold = floor (_x getOrDefault ["minLevel", -1]);
    if (_threshold > _safeLevel && {(_nextRankLevel < 0) || {_threshold < _nextRankLevel}}) then {_nextRankLevel = _threshold};
} forEach _valid;

private _icon = if (_selectedLevel >= 1) then {_selected getOrDefault ["icon", ""]} else {""};
if !(_icon isEqualType "") then {_icon = ""};
if !(_icon isEqualTo "" || {fileExists _icon}) then {_icon = ""};
private _hasIcon = !(_icon isEqualTo "");
private _grade = if (_hasIcon) then {toUpper (_selected getOrDefault ["grade", ""])} else {""};
private _color = if (_hasIcon) then {_grades getOrDefault [_grade, [1, 1, 1, 0]]} else {[1, 1, 1, 0]};

createHashMapFromArray [
    ["hasIcon", _hasIcon], ["icon", _icon], ["grade", _grade], ["color", _color],
    ["minLevel", if (_hasIcon) then {_selectedLevel} else {-1}], ["nextRankLevel", _nextRankLevel],
    ["level", _safeLevel], ["maxLevel", _maxLevel]
]

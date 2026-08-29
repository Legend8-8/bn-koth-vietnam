/*
    File: fn_findRestrictedItems.sqf
    Author: Legend
    Description: Finds managed-loadout item classes matching one perk's
        config-authored restricted traits or explicit classes.
    Execution: Any
    Parameters:
        0: Unit loadout <ARRAY>
        1: Perk id <STRING>
    Returns:
        Matching item classes, unique and lowercase <ARRAY>
    Public: No
*/

params [
    ["_loadout", [], [[]]],
    ["_perkId", "", [""]]
];

private _metadata = [_perkId] call bn_koth_fnc_progression_perks_getConfig;
if !(_metadata getOrDefault ["success", false]) exitWith {[]};

private _restrictedTraits = _metadata getOrDefault ["restrictedTraits", []];
private _restrictedClasses = _metadata getOrDefault ["restrictedClasses", []];
if !(_restrictedTraits isEqualType []) then {_restrictedTraits = []};
if !(_restrictedClasses isEqualType []) then {_restrictedClasses = []};

_restrictedTraits = _restrictedTraits apply {toLower _x};
_restrictedClasses = _restrictedClasses apply {toLower _x};

if ((count _restrictedTraits) isEqualTo 0 && {(count _restrictedClasses) isEqualTo 0}) exitWith {[]};

private _settings = missionConfigFile >> "CfgBnKothArsenalSettings";
private _catalogue = getText (_settings >> "catalogueClass");
if (_catalogue isEqualTo "") then {_catalogue = "CfgBnKothArsenal"};
private _sourceItems = missionConfigFile >> _catalogue >> "Equipment" >> "Compatibility" >> "SourceItems";

private _matches = [];
private _visit = {};

_visit = {
    params ["_value"];

    if (_value isEqualType "") exitWith {
        if (_value isEqualTo "") exitWith {};

        private _class = toLower _value;
        private _restricted = _class in _restrictedClasses;

        if (!_restricted && {(count _restrictedTraits) > 0}) then {
            private _itemCfg = _sourceItems >> _class;
            if (isClass _itemCfg) then {
                private _traits = (getArray (_itemCfg >> "traits")) apply {toLower _x};
                _restricted = (_traits findIf {_x in _restrictedTraits}) >= 0;
            };
        };

        if (_restricted) then {
            _matches pushBackUnique _class;
        };
    };

    if (_value isEqualType []) then {
        {
            [_x] call _visit;
        } forEach _value;
    };
};

[_loadout] call _visit;
_matches

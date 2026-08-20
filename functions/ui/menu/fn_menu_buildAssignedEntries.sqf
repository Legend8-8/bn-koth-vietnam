/*
    File: fn_menu_buildAssignedEntries.sqf
    Author: Legend
    Description: Builds assigned-equipment entries from canonical SourceItems and slot subtype rules.
    Execution: Client
    Parameters:
        0: Intended loadout snapshot <ARRAY>
        1: Compatibility config root <CONFIG>
    Returns:
        Selector entries <ARRAY<HashMap>>
    Public: No
*/

params [
    ["_intendedLoadout", [], [[]]],
    ["_compatibilityCfg", configNull, [configNull]],
    ["_assignedStage", 1, [0]],
    ["_selectedAssignedIndex", -1, [0]]
];

private _entries = [];
private _sourceItemsCfg = _compatibilityCfg >> "SourceItems";
if !(isClass _sourceItemsCfg) exitWith {_entries};

private _assigned = if ((count _intendedLoadout) > 9 && {(_intendedLoadout select 9) isEqualType []}) then {+(_intendedLoadout select 9)} else {[]};
while {(count _assigned) < 6} do {
    _assigned pushBack "";
};

private _slotLabels = ["MAP", "GPS/UAV", "RADIO", "COMPASS", "WATCH", "NVG"];
private _slotSubtypePredicates = [
    {params ["_subType"]; _subType isEqualTo "map"},
    {params ["_subType"]; (_subType isEqualTo "gps") || {_subType find "uav" >= 0}},
    {params ["_subType"]; _subType isEqualTo "radio"},
    {params ["_subType"]; _subType isEqualTo "compass"},
    {params ["_subType"]; _subType isEqualTo "watch"},
    {params ["_subType"]; _subType find "nvg" >= 0}
];

private _resolveItemName = {
    params ["_className"];
    if (_className isEqualTo "") exitWith {"NONE"};

    private _cfg = configFile >> "CfgWeapons" >> _className;
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgVehicles" >> _className;
    };
    if !(isClass _cfg) then {
        _cfg = configFile >> "CfgGlasses" >> _className;
    };
    if !(isClass _cfg) exitWith {toUpper _className};

    private _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then {toUpper _className} else {_displayName}
};

private _slotCandidates = [];
for "_i" from 0 to 5 do {
    _slotCandidates pushBack [];
};

{
    private _class = toLower (configName _x);
    private _itemType = [_class] call BIS_fnc_itemType;
    if !((_itemType isEqualType []) && {(count _itemType) >= 2}) then {continue;};

    private _subType = toLower (_itemType select 1);
    for "_i" from 0 to 5 do {
        if ([_subType] call (_slotSubtypePredicates select _i)) then {
            private _slotArray = _slotCandidates select _i;
            private _displayName = getText (_x >> "displayName");
            if (_displayName isEqualTo "") then {
                _displayName = [_class] call _resolveItemName;
            };
            _slotArray pushBack [_displayName, _class];
            _slotCandidates set [_i, _slotArray];
        };
    };
} forEach ("true" configClasses _sourceItemsCfg);

private _selectedSlotIndex = _selectedAssignedIndex;
if ((_selectedSlotIndex < 0) || {_selectedSlotIndex > 5}) then {
    _selectedSlotIndex = 0;
};

if (_assignedStage isEqualTo 1) then {
    private _facewearClass = if ((count _intendedLoadout) > 7 && {(_intendedLoadout select 7) isEqualType ""}) then {toLower (_intendedLoadout select 7)} else {""};
    private _facewearName = if (_facewearClass isEqualTo "") then {"NONE"} else {[_facewearClass] call _resolveItemName};

    private _binocularClass = "";
    if ((count _intendedLoadout) > 8) then {
        private _binocSlot = _intendedLoadout select 8;
        if (_binocSlot isEqualType "") then {_binocularClass = toLower _binocSlot;} else {
            if ((_binocSlot isEqualType []) && {(count _binocSlot) > 0}) then {_binocularClass = toLower (_binocSlot select 0);};
        };
    };
    private _binocularName = if (_binocularClass isEqualTo "") then {"NONE"} else {[_binocularClass] call _resolveItemName};

    _entries pushBack (createHashMapFromArray [
        ["displayName", format ["FACEWEAR: %1", _facewearName]],
        ["weaponClass", _facewearClass],
        ["targetPage", "LOADOUT_FACEWEAR"],
        ["available", true],
        ["equipped", false]
    ]);
    _entries pushBack (createHashMapFromArray [
        ["displayName", format ["BINOCULAR: %1", _binocularName]],
        ["weaponClass", _binocularClass],
        ["targetPage", "LOADOUT_BINOCULAR"],
        ["available", true],
        ["equipped", false]
    ]);

    for "_i" from 0 to 5 do {
        private _currentClass = toLower (_assigned select _i);
        private _currentName = if (_currentClass isEqualTo "") then {"NONE"} else {[_currentClass] call _resolveItemName};

        _entries pushBack (createHashMapFromArray [
            ["displayName", format ["%1: %2", _slotLabels select _i, _currentName]],
            ["assignedIndex", _i],
            ["itemClass", _currentClass],
            ["available", true],
            ["equipped", false]
        ]);
    };
} else {
    _entries pushBack (createHashMapFromArray [
        ["displayName", format ["%1: NONE", _slotLabels select _selectedSlotIndex]],
        ["assignedIndex", _selectedSlotIndex],
        ["itemClass", ""],
        ["available", true],
        ["equipped", (toLower (_assigned select _selectedSlotIndex)) isEqualTo ""]
    ]);

    private _sortable = +(_slotCandidates select _selectedSlotIndex);
    _sortable sort true;

    {
        private _name = _x select 0;
        private _class = _x select 1;
        _entries pushBack (createHashMapFromArray [
            ["displayName", format ["%1: %2", _slotLabels select _selectedSlotIndex, _name]],
            ["assignedIndex", _selectedSlotIndex],
            ["itemClass", _class],
            ["available", true],
            ["equipped", _class isEqualTo toLower (_assigned select _selectedSlotIndex)]
        ]);
    } forEach _sortable;
};

_entries

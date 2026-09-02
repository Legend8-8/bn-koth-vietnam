/*
    File: fn_menu_projectMasteryEntries.sqf
    Author: Legend
    Description: Normalizes, filters, sorts and pages cached weapon Mastery
        catalogue entries against the local authoritative progression projection.
    Execution: Client
    Parameters:
        0: Cached Mastery catalogue entries <ARRAY>
        1: Canonical weapon kill counts <HASHMAP>
        2: Filter id <STRING>
        3: Requested zero-based page <NUMBER>
        4: Page size <NUMBER>
    Returns: Presentation projection <HASHMAP>
    Public: No
*/

params [
    ["_catalogue", [], [[]]],
    ["_weaponKills", createHashMap, [createHashMap]],
    ["_filter", "IN_PROGRESS", [""]],
    ["_page", 0, [0]],
    ["_pageSize", 4, [0]]
];

_filter = toUpper _filter;
if !(_filter in ["IN_PROGRESS", "COMPLETED", "ALL"]) then {_filter = "IN_PROGRESS"};
if !(_page isEqualType 0 && {finite _page}) then {_page = 0};
if !(_pageSize isEqualType 0 && {finite _pageSize}) then {_pageSize = 4};
_pageSize = floor (_pageSize max 1);

private _sortable = [];
{
    private _entry = _x;
    if !(_entry isEqualType createHashMap) then {continue};
    private _weaponClass = toLower (_entry getOrDefault ["weaponClass", ""]);
    private _displayName = _entry getOrDefault ["displayName", ""];
    private _required = _entry getOrDefault ["required", 0];
    if !(
        !(_weaponClass isEqualTo "")
        && {_displayName isEqualType ""}
        && {_required isEqualType 0 && {finite _required} && {_required > 0}}
    ) then {continue};
    _required = floor _required;

    private _rawKills = _weaponKills getOrDefault [_weaponClass, 0];
    private _kills = if (_rawKills isEqualType 0 && {finite _rawKills}) then {floor (_rawKills max 0)} else {0};
    private _ratio = ((_kills / _required) max 0) min 1;
    private _complete = _kills >= _required;
    private _include = switch (_filter) do {
        case "IN_PROGRESS": {_kills > 0 && {!_complete}};
        case "COMPLETED": {_complete};
        default {true};
    };
    if (!_include) then {continue};

    private _projected = createHashMapFromArray [
        ["weaponClass", _weaponClass],
        ["displayName", _displayName],
        ["picture", _entry getOrDefault ["picture", ""]],
        ["required", _required],
        ["kills", _kills],
        ["ratio", _ratio],
        ["complete", _complete]
    ];
    private _sortKey = if (_filter isEqualTo "IN_PROGRESS") then {
        [1 - _ratio, toLower _displayName, _weaponClass, _projected]
    } else {
        [toLower _displayName, _weaponClass, 0, _projected]
    };
    _sortable pushBack _sortKey;
} forEach _catalogue;

_sortable sort true;
private _entries = _sortable apply {_x select 3};
private _pageCount = (ceil ((count _entries) / _pageSize)) max 1;
_page = (floor (_page max 0)) min (_pageCount - 1);

createHashMapFromArray [
    ["filter", _filter],
    ["entries", _entries],
    ["pageEntries", _entries select [_page * _pageSize, _pageSize]],
    ["page", _page],
    ["pageCount", _pageCount],
    ["pageSize", _pageSize]
]

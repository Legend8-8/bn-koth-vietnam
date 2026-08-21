/*
    File: fn_menu_deleteSessionKit.sqf
    Author: Legend
    Description: Deletes one named locally stored kit.
    Execution: Client
    Parameters: 0: Local kit id <STRING>
    Returns: True when deleted, otherwise false <BOOL>
    Public: Yes
*/
params [["_kitId", "", [""]]];
if (!hasInterface || {_kitId isEqualTo ""}) exitWith {false};
private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
_kits = _kits select {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType []}};
private _index = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualTo _kitId}};
if (_index < 0) exitWith {false};
_kits deleteAt _index;
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
saveProfileNamespace;
uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", ""];
["LOCAL KIT DELETED."] call bn_koth_fnc_ui_notify;
["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
true

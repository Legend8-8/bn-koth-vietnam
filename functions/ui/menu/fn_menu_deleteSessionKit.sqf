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
private _context = [] call bn_koth_fnc_menu_getKitContext;
private _kits = _context get "kits";
private _index = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualTo _kitId}};
if (_index < 0) exitWith {false};
private _record = _kits select _index;
if (count _record >= 5 && {!((_record select 3) isEqualTo (_context get "sideToken"))}) exitWith {false};
if (_kitId isEqualTo (_context get "preferredId")) then {
    ["", "CLEAR"] call bn_koth_fnc_menu_setSpawnKit;
};
_kits deleteAt _index;
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
saveProfileNamespace;
uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", ""];
["LOCAL KIT DELETED."] call bn_koth_fnc_ui_notify;
["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
true

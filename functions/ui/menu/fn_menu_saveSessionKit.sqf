/*
    File: fn_menu_saveSessionKit.sqf
    Author: Legend
    Description: Saves the current server-supplied intended loadout as a new
        named local kit, or renames an existing local kit.
    Execution: Client
    Parameters:
        0: Kit name <STRING>
        1: Existing kit id to rename, or empty to save new <STRING>
    Returns:
        True when stored, otherwise false <BOOL>
    Public: Yes
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_name", "", [""]], ["_kitId", "", [""]]];
if (!hasInterface) exitWith {false};

if (_name isEqualTo "") then {
    private _display = findDisplay BN_KOTH_IDD_MENU;
    if !(isNull _display) then {
        _name = ctrlText (_display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME);
    };
};
_name = _name select [0, 32];
if (_name isEqualTo "") exitWith {["ENTER A KIT NAME FIRST."] call bn_koth_fnc_ui_notify; false};

private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
_kits = _kits select {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType []}};
private _duplicateIndex = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(toLower (_x select 1)) isEqualTo (toLower _name)} && {!((_x select 0) isEqualTo _kitId)}};
if (_duplicateIndex >= 0) exitWith {["A KIT WITH THAT NAME ALREADY EXISTS."] call bn_koth_fnc_ui_notify; false};

if !(_kitId isEqualTo "") exitWith {
    private _index = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualTo _kitId}};
    if (_index < 0) exitWith {["THE SELECTED LOCAL KIT NO LONGER EXISTS."] call bn_koth_fnc_ui_notify; false};
    private _record = +(_kits select _index);
    _record set [1, _name];
    _kits set [_index, _record];
    profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
    saveProfileNamespace;
    ["LOCAL KIT RENAMED."] call bn_koth_fnc_ui_notify;
    ["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
    true
};

private _loadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if !(_loadout isEqualType [] && {(count _loadout) >= 10}) exitWith {false};
if ((count _kits) >= 12) exitWith {["LOCAL KIT LIMIT REACHED (12)."] call bn_koth_fnc_ui_notify; false};
private _newId = format ["kit_%1_%2", floor diag_tickTime, floor (random 1000000)];
_kits pushBack [_newId, _name, +_loadout];
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
saveProfileNamespace;
uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", _newId];
["KIT SAVED LOCALLY."] call bn_koth_fnc_ui_notify;
["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
true

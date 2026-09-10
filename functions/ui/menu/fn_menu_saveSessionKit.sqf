/*
    File: fn_menu_saveSessionKit.sqf
    Author: Legend
    Description: Saves the current server-supplied intended loadout as a new
        named local kit, renames a local kit, or explicitly overwrites the
        active saved-kit edit target.
    Execution: Client
    Parameters:
        0: Kit name <STRING>
        1: Existing kit id to rename, or empty to save new <STRING>
        2: Operation, NEW/RENAME/UPDATE <STRING>
    Returns:
        True when stored, otherwise false <BOOL>
    Public: Yes
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_name", "", [""]], ["_kitId", "", [""]], ["_operation", "", [""]]];
if (!hasInterface) exitWith {false};
_operation = toUpper _operation;

if (_operation isEqualTo "UPDATE") exitWith {
    if (_kitId isEqualTo "") exitWith {["THE SAVED LOADOUT EDIT TARGET IS NO LONGER AVAILABLE."] call bn_koth_fnc_ui_notify; false};
    private _loadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
    if !(_loadout isEqualType [] && {(count _loadout) >= 10}) exitWith {["CURRENT VALIDATED LOADOUT IS NOT AVAILABLE."] call bn_koth_fnc_ui_notify; false};
    private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
    if !(_kits isEqualType []) then {_kits = []};
    private _index = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualTo _kitId}};
    if (_index < 0) exitWith {["THE SAVED LOADOUT EDIT TARGET NO LONGER EXISTS."] call bn_koth_fnc_ui_notify; false};
    private _record = +(_kits select _index);
    private _savedName = _record select 1;
    _record set [2, +_loadout];
    _kits set [_index, _record];
    profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
    saveProfileNamespace;
    [createHashMapFromArray [["savedKitOperation", "UPDATE"], ["savedKitId", _kitId]]] call bn_koth_fnc_loadouts_request;
    uiNamespace setVariable ["BN_KOTH_menuKitEditId", ""];
    uiNamespace setVariable ["BN_KOTH_menuKitEditName", ""];
    if (_kitId isEqualTo (profileNamespace getVariable ["BN_KOTH_preferredSpawnKitId", ""])) then {
        [_kitId, "SET"] call bn_koth_fnc_menu_setSpawnKit;
    };
    [format ["SAVED LOADOUT UPDATED: %1", toUpper _savedName]] call bn_koth_fnc_ui_notify;
    ["LOADOUT"] call bn_koth_fnc_menu_refresh;
    true
};

if (_name isEqualTo "") then {
    private _display = findDisplay BN_KOTH_IDD_MENU;
    if !(isNull _display) then {
        _name = ctrlText (_display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME);
    };
};
private _maxNameLength = (getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxNameLength")) max 1;
_name = _name select [0, _maxNameLength];
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
    [createHashMapFromArray [["savedKitOperation", "RENAME"], ["savedKitId", _kitId], ["savedKitName", _name]]] call bn_koth_fnc_loadouts_request;
    ["LOCAL KIT RENAMED."] call bn_koth_fnc_ui_notify;
    ["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
    true
};

private _loadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if !(_loadout isEqualType [] && {(count _loadout) >= 10}) exitWith {false};
private _maxKits = (getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxCount")) max 1;
if ((count _kits) >= _maxKits) exitWith {[format ["LOCAL KIT LIMIT REACHED (%1).", _maxKits]] call bn_koth_fnc_ui_notify; false};
private _newId = format ["kit_%1_%2", floor diag_tickTime, floor (random 1000000)];
_kits pushBack [_newId, _name, +_loadout];
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
saveProfileNamespace;
[createHashMapFromArray [["savedKitOperation", "CREATE"], ["savedKitId", _newId], ["savedKitName", _name]]] call bn_koth_fnc_loadouts_request;
uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", _newId];
["KIT SAVED LOCALLY."] call bn_koth_fnc_ui_notify;
["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
true

/*
    File: fn_menu_saveSessionKit.sqf
    Author: Legend
    Description: Creates, updates or renames local team kits, or copies a preserved
        legacy kit into an empty unlocked slot. Local data never grants entitlement.
    Execution: Client (unscheduled)
    Parameters:
        0: Kit name <STRING>
        1: Existing kit ID <STRING>
        2: NEW, RENAME, UPDATE or IMPORT <STRING>
        3: Requested empty slot; zero selects the first available <NUMBER>
    Returns: Stored successfully <BOOL>
    Public: Yes
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_name", "", [""]], ["_kitId", "", [""]], ["_operation", "NEW", [""]], ["_slot", 0, [0]]];
if (!hasInterface) exitWith {false};
_operation = toUpper _operation;
private _context = [] call bn_koth_fnc_menu_getKitContext;
private _sideToken = _context get "sideToken";
private _assignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !([_assignments getOrDefault [getPlayerUID player, sideUnknown]] call bn_koth_fnc_teams_validateSide) exitWith {false};
private _kits = _context get "kits";
private _teamKits = _context get "teamKits";
private _index = _kits findIf {(_x select 0) isEqualTo _kitId};
private _existing = if (_index >= 0) then {_kits select _index} else {[]};
private _unlocked = _context get "unlocked";

if (_operation in ["UPDATE", "RENAME"]) exitWith {
    if (_existing isEqualTo []) exitWith {["THE SAVED LOADOUT NO LONGER EXISTS."] call bn_koth_fnc_ui_notify; false};
    private _isArchive = count _existing isEqualTo 3;
    private _teamIndex = _teamKits findIf {(_x select 0) isEqualTo _kitId};
    if (!_isArchive && {_teamIndex < 0}) exitWith {false};
    private _updating = _operation isEqualTo "UPDATE";
    if (_updating && {_isArchive || {(_existing select 4) > _unlocked}}) exitWith {false};
    private _loadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
    if (_updating && {!(_loadout isEqualType [] && {count _loadout >= 10})}) exitWith {false};
    private _record = +_existing;
    if (_updating) then {
        _record set [2, +_loadout];
    } else {
        if (_name isEqualTo "") then {
            private _display = findDisplay BN_KOTH_IDD_MENU;
            if !(isNull _display) then {_name = ctrlText (_display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME)};
        };
        private _maxNameLength = (getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxNameLength")) max 1;
        _name = _name select [0, _maxNameLength];
        if !(_name isEqualTo "") then {_record set [1, _name]};
    };
    if (!_updating && {_name isEqualTo ""}) exitWith {["ENTER A KIT NAME FIRST."] call bn_koth_fnc_ui_notify; false};
    private _peers = if (_isArchive) then {_context get "legacyKits"} else {_teamKits};
    if (!_updating && {(_peers findIf {toLower (_x select 1) isEqualTo toLower _name && {!((_x select 0) isEqualTo _kitId)}}) >= 0}) exitWith {
        ["A KIT WITH THAT NAME ALREADY EXISTS."] call bn_koth_fnc_ui_notify; false
    };
    _kits set [_index, _record];
    profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
    saveProfileNamespace;
    if (_operation isEqualTo "UPDATE") then {
        uiNamespace setVariable ["BN_KOTH_menuKitEditId", ""];
        uiNamespace setVariable ["BN_KOTH_menuKitEditName", ""];
        if (_kitId isEqualTo (_context get "preferredId")) then {[_kitId, "SET"] call bn_koth_fnc_menu_setSpawnKit};
    };
    ["SAVED LOADOUT UPDATED."] call bn_koth_fnc_ui_notify;
    [if (_operation isEqualTo "UPDATE") then {"LOADOUT"} else {"LOADOUT_KITS"}] call bn_koth_fnc_menu_refresh;
    true
};
if !(_operation in ["NEW", "IMPORT", ""]) exitWith {false};
if (_slot isEqualTo 0) then {
    for "_candidate" from 1 to _unlocked do {
        if ((_teamKits findIf {(_x select 4) isEqualTo _candidate}) < 0) exitWith {_slot = _candidate};
    };
};
if !(finite _slot && {_slot >= 1} && {_slot <= _unlocked} && {_slot isEqualTo floor _slot}
    && {(_teamKits findIf {(_x select 4) isEqualTo _slot}) < 0}) exitWith {
    ["NO EMPTY UNLOCKED SLOT. DELETE A KIT OR UNLOCK THE NEXT SLOT."] call bn_koth_fnc_ui_notify; false
};
private _loadout = uiNamespace getVariable ["BN_KOTH_menuIntendedLoadout", []];
if (_operation isEqualTo "IMPORT") then {
    if (count _existing isEqualTo 3) then {_name = _existing select 1; _loadout = +(_existing select 2)} else {_loadout = []};
} else {
    if (_name isEqualTo "") then {
        private _display = findDisplay BN_KOTH_IDD_MENU;
        if !(isNull _display) then {_name = ctrlText (_display displayCtrl BN_KOTH_IDC_MENU_KIT_NAME)};
    };
};
private _maxNameLength = (getNumber (missionConfigFile >> "CfgBnKothPersistence" >> "savedKitMaxNameLength")) max 1;
_name = _name select [0, _maxNameLength];
if (_name isEqualTo "") exitWith {["ENTER A KIT NAME FIRST."] call bn_koth_fnc_ui_notify; false};
if ((_teamKits findIf {toLower (_x select 1) isEqualTo toLower _name}) >= 0) exitWith {
    ["A KIT WITH THAT NAME ALREADY EXISTS."] call bn_koth_fnc_ui_notify; false
};
if !(_loadout isEqualType [] && {count _loadout >= 10}) exitWith {false};
private _newId = format ["kit_%1_%2_%3", _sideToken, floor diag_tickTime, floor (random 1000000)];
_kits pushBack [_newId, _name, +_loadout, _sideToken, _slot];
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _kits];
saveProfileNamespace;
uiNamespace setVariable ["BN_KOTH_menuKitSelectedId", _newId];
[if (_operation isEqualTo "IMPORT") then {"KIT COPIED TO TEAM SLOT. ORIGINAL PRESERVED; VALIDATED ON LOAD."} else {"KIT SAVED LOCALLY."}] call bn_koth_fnc_ui_notify;
["LOADOUT_KITS"] call bn_koth_fnc_menu_refresh;
true

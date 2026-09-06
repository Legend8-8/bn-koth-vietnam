/*
    File: test_spawnPreference.sqf
    Author: Legend
    Description: Exercises preference UI owners with network/render calls stubbed.
        Run in an isolated client test mission with the menu closed. Restores
        profile data and function bindings; never sends equipment requests.
    Execution: Client debug console (unscheduled)
    Parameters: None
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/
if (!hasInterface) exitWith {["Client required."]};
private _failures = [];
private _check = {params ["_label", "_ok"]; if (!_ok) then {_failures pushBack _label}};
private _oldKits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
private _oldPreference = profileNamespace getVariable ["BN_KOTH_preferredSpawnKitId", ""];
private _oldResponse = missionNamespace getVariable ["BN_KOTH_spawnKitResponse", [0, "", false]];
private _uiKeys = ["BN_KOTH_menuIntendedLoadout", "BN_KOTH_menuKitEditId", "BN_KOTH_menuKitEditName", "BN_KOTH_menuKitSelectedId"];
private _oldUi = _uiKeys apply {uiNamespace getVariable [_x, ""]};
private _functions = ["bn_koth_fnc_loadouts_request", "bn_koth_fnc_menu_refresh", "bn_koth_fnc_ui_notify"];
private _oldFunctions = _functions apply {missionNamespace getVariable _x};
private _sent = [];
bn_koth_fnc_loadouts_request = {_sent pushBack (_this select 0)};
bn_koth_fnc_menu_refresh = {};
bn_koth_fnc_ui_notify = {};
private _kit = [[], [], [], ["", []], ["", []], ["", []], "", "", [], []];
profileNamespace setVariable ["BN_KOTH_savedKits_v2", [["a", "A", +_kit], ["b", "B", +_kit]]];
uiNamespace setVariable ["BN_KOTH_menuIntendedLoadout", +_kit];
["a", "SET"] call bn_koth_fnc_menu_setSpawnKit;
private _oldRevision = (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0;
["b", "SET"] call bn_koth_fnc_menu_setSpawnKit;
["Exactly one preferred ID", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "b"] call _check;
["Preference does not change intended view", (uiNamespace getVariable "BN_KOTH_menuIntendedLoadout") isEqualTo _kit] call _check;
["Renamed B", "b", "RENAME"] call bn_koth_fnc_menu_saveSessionKit;
["Rename preserves preference", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "b"] call _check;
// Exercise the actual response branch, excluding only its remote-origin guard.
private _source = loadFile "functions\loadouts\fn_receiveValidatedLoadout.sqf";
private _start = _source find "if (_validationResult getOrDefault [""spawnPreference"", false]) exitWith {";
private _end = _source find "if !(_validationResult getOrDefault [""success"", false]) exitWith {";
private _receive = compile (_source select [_start, _end - _start]);
private _validationResult = createHashMapFromArray [["spawnPreference", true], ["success", false], ["preferenceRevision", _oldRevision]];
call _receive;
["Old failure cannot clear newer preference", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "b"] call _check;
_validationResult set ["preferenceRevision", (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0];
call _receive;
["Matching failure clears selection", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo ""] call _check;
["a", "SET"] call bn_koth_fnc_menu_setSpawnKit;
_validationResult set ["success", true];
_validationResult set ["preferenceRevision", (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0];
call _receive;
["", "RESUBMIT"] call bn_koth_fnc_menu_setSpawnKit;
_validationResult set ["success", false];
_validationResult set ["preferenceRevision", (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0];
call _receive;
["Restore failure preserves temporary side preference", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "a"] call _check;
["", "a", "UPDATE"] call bn_koth_fnc_menu_saveSessionKit;
["Overwrite resubmits replacement array", (((_sent select ((count _sent) - 1)) get "mutation") get "savedLoadout") isEqualTo _kit] call _check;
["", "RESUBMIT"] call bn_koth_fnc_menu_setSpawnKit;
_validationResult set ["preferenceRevision", (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0];
call _receive;
["Resubmission does not hide rejected overwrite", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo ""] call _check;
["a", "SET"] call bn_koth_fnc_menu_setSpawnKit;
["a"] call bn_koth_fnc_menu_deleteSessionKit;
["Delete clears preference", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo ""] call _check;
["Delete sends only candidate clear", ((_sent select ((count _sent) - 1)) get "spawnPreference") isEqualTo "CLEAR"] call _check;
profileNamespace setVariable ["BN_KOTH_savedKits_v2", _oldKits];
profileNamespace setVariable ["BN_KOTH_preferredSpawnKitId", _oldPreference];
saveProfileNamespace;
missionNamespace setVariable ["BN_KOTH_spawnKitResponse", _oldResponse];
{uiNamespace setVariable [_x, _oldUi select _forEachIndex]} forEach _uiKeys;
{missionNamespace setVariable [_x, _oldFunctions select _forEachIndex]} forEach _functions;
diag_log format ["[KOTH TEST] client spawn preference failures: %1", _failures];
_failures

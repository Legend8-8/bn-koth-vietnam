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
private _uiKeys = ["BN_KOTH_menuIntendedLoadout", "BN_KOTH_menuKitEditId", "BN_KOTH_menuKitEditName", "BN_KOTH_menuKitSelectedId", "BN_KOTH_menuPendingKitOperation", "BN_KOTH_menuPendingKitId", "BN_KOTH_menuPendingKitName"];
private _oldUi = _uiKeys apply {uiNamespace getVariable [_x, ""]};
private _functions = ["bn_koth_fnc_loadouts_request", "bn_koth_fnc_menu_refresh", "bn_koth_fnc_ui_notify"];
private _oldFunctions = _functions apply {missionNamespace getVariable _x};
private _sent = [];
private _notices = [];
bn_koth_fnc_loadouts_request = {_sent pushBack (_this select 0)};
bn_koth_fnc_menu_refresh = {};
bn_koth_fnc_ui_notify = {_notices pushBack (_this select 0)};
private _kit = [[], [], [], ["", []], ["", []], ["", []], "", "", [], []];
profileNamespace setVariable ["BN_KOTH_savedKits_v2", [["a", "A", +_kit], ["b", "B", +_kit]]];
uiNamespace setVariable ["BN_KOTH_menuIntendedLoadout", +_kit];
private _requestsBeforeSave = count _sent;
["C"] call bn_koth_fnc_menu_saveSessionKit;
["Create stores kit in local profile", ((profileNamespace getVariable ["BN_KOTH_savedKits_v2", []]) findIf {(_x select 1) isEqualTo "C"}) >= 0] call _check;
["Create sends no database or loadout request", (count _sent) isEqualTo _requestsBeforeSave] call _check;
["a", "SET"] call bn_koth_fnc_menu_setSpawnKit;
private _oldRevision = (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0;
["b", "SET"] call bn_koth_fnc_menu_setSpawnKit;
["Exactly one preferred ID", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "b"] call _check;
["Preference does not change intended view", (uiNamespace getVariable "BN_KOTH_menuIntendedLoadout") isEqualTo _kit] call _check;
["Renamed B", "b", "RENAME"] call bn_koth_fnc_menu_saveSessionKit;
["Rename preserves preference", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo "b"] call _check;
["Rename stores local name", (((profileNamespace getVariable ["BN_KOTH_savedKits_v2", []]) select 1) select 1) isEqualTo "Renamed B"] call _check;
// Exercise the actual response branch, excluding only its remote-origin guard.
private _source = loadFile "functions\loadouts\fn_receiveValidatedLoadout.sqf";
private _rejectionStart = _source find "private _rejectionMessage =";
private _end = _source find "if !(_validationResult getOrDefault [""success"", false]) exitWith {";
private _receive = compile (_source select [_rejectionStart, _end - _rejectionStart]);
private _rejectionEnd = _source find "if (isNull player) exitWith {};";
private _receiveRejection = compile (_source select [_rejectionStart, _rejectionEnd - _rejectionStart]);
private _magazineClass = "vn_m34_grenade_mag";
private _magazineName = getText (configFile >> "CfgMagazines" >> _magazineClass >> "displayName");
uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", "LOAD"];
private _validationResult = createHashMapFromArray [["success", false], ["code", "NOT_AVAILABLE"], ["message", "Item is not available in the KOTH Arsenal."], ["rejectedClass", _magazineClass]];
call _receiveRejection;
["Unavailable item notification resolves magazine displayName",
    !(_magazineName isEqualTo "") &&
    {(_notices select ((count _notices) - 1)) isEqualTo format ["Saved loadout rejected: %1 is not available in the KOTH Arsenal.", _magazineName]}
] call _check;
uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", "LOAD"];
_validationResult set ["rejectedClass", "vn_missing_display_name"];
call _receiveRejection;
["Unknown displayName falls back to classname",
    (_notices select ((count _notices) - 1)) isEqualTo "Saved loadout rejected: vn_missing_display_name is not available in the KOTH Arsenal."
] call _check;
uiNamespace setVariable ["BN_KOTH_menuPendingKitOperation", "LOAD"];
_validationResult set ["code", "LOCKED_LEVEL"];
_validationResult set ["message", "Requires level 175."];
_validationResult set ["rejectedClass", "vn_m3carbine"];
call _receiveRejection;
private _weaponName = getText (configFile >> "CfgWeapons" >> "vn_m3carbine" >> "displayName");
if (_weaponName isEqualTo "") then {_weaponName = "vn_m3carbine"};
["Unavailable saved weapon notification names the weapon",
    (_notices select ((count _notices) - 1)) isEqualTo format ["Saved loadout rejected: %1: Requires level 175.", _weaponName]
] call _check;
_validationResult = createHashMapFromArray [["spawnPreference", true], ["success", false], ["preferenceRevision", _oldRevision]];
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
["Overwrite stores local loadout", (((profileNamespace getVariable ["BN_KOTH_savedKits_v2", []]) select 0) select 2) isEqualTo _kit] call _check;
["Overwrite resubmits replacement array", (((_sent select ((count _sent) - 1)) get "mutation") get "savedLoadout") isEqualTo _kit] call _check;
["", "RESUBMIT"] call bn_koth_fnc_menu_setSpawnKit;
_validationResult set ["preferenceRevision", (missionNamespace getVariable "BN_KOTH_spawnKitResponse") select 0];
call _receive;
["Resubmission does not hide rejected overwrite", (profileNamespace getVariable "BN_KOTH_preferredSpawnKitId") isEqualTo ""] call _check;
["a", "SET"] call bn_koth_fnc_menu_setSpawnKit;
["a"] call bn_koth_fnc_menu_deleteSessionKit;
["Delete removes local kit", ((profileNamespace getVariable ["BN_KOTH_savedKits_v2", []]) findIf {(_x select 0) isEqualTo "a"}) < 0] call _check;
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

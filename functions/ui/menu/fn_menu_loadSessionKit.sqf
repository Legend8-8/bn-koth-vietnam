/*
    File: fn_menu_loadSessionKit.sqf
    Author: Legend
    Description: Submits one named locally stored kit as untrusted loadout intent.
    Execution: Client
    Parameters: 0: Local kit id <STRING>
    Returns: True when request sent, otherwise false <BOOL>
    Public: Yes
*/
params [["_kitId", "", [""]]];
if (!hasInterface || {_kitId isEqualTo ""}) exitWith {false};
private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
_kits = _kits select {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType []}};
private _index = _kits findIf {(_x isEqualType []) && {(count _x) >= 3} && {(_x select 0) isEqualTo _kitId}};
if (_index < 0) exitWith {["THE SELECTED LOCAL KIT NO LONGER EXISTS."] call bn_koth_fnc_ui_notify; false};
private _savedLoadout = (_kits select _index) select 2;
if !(_savedLoadout isEqualType [] && {(count _savedLoadout) >= 10}) exitWith {["THE SELECTED LOCAL KIT IS INVALID."] call bn_koth_fnc_ui_notify; false};
private _request = createHashMapFromArray [["mutation", createHashMapFromArray [["op", "load_local_kit"], ["kitId", _kitId], ["savedLoadout", +_savedLoadout]]]];
[_request] call bn_koth_fnc_loadouts_request;
true

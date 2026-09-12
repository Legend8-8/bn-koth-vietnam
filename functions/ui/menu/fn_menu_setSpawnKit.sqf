/*
    File: fn_menu_setSpawnKit.sqf
    Author: Legend
    Description: Stores one local spawn preference and submits untrusted kit intent.
        RESTORE preserves a temporarily invalid preference; CLEAR removes only it.
    Execution: Client (unscheduled)
    Parameters:
        0: Stable local kit ID, empty for stored preference <STRING>
        1: SET, RESTORE (client initialization), RESUBMIT (menu open) or CLEAR <STRING>
    Returns: Request submitted <BOOL>
    Public: No
*/
params [["_kitId", "", [""]], ["_mode", "RESTORE", [""]]];
if (!hasInterface) exitWith {false};
private _preferred = profileNamespace getVariable ["BN_KOTH_preferredSpawnKitId", ""];
if !(_preferred isEqualType "") then {_preferred = ""};
if (_mode in ["RESTORE", "RESUBMIT"]) then {_kitId = _preferred};
if (_mode isEqualTo "CLEAR") then {_kitId = ""};
if (_kitId isEqualTo "" && {!(_mode isEqualTo "CLEAR")}) exitWith {false};
private _kits = profileNamespace getVariable ["BN_KOTH_savedKits_v2", []];
if !(_kits isEqualType []) then {_kits = []};
private _index = _kits findIf {_x isEqualType [] && {count _x >= 3} && {(_x select 0) isEqualTo _kitId}};
private _saved = [];
if !(_kitId isEqualTo "") then {
    if (_index < 0) then {_kitId = ""} else {_saved = (_kits select _index) select 2};
};
// One client-only correlation tuple; no server authority or pending request map.
private _previous = missionNamespace getVariable ["BN_KOTH_spawnKitResponse", [0, "", false]];
private _revision = (_previous select 0) + 1;
private _rejectClears = _mode isEqualTo "SET" || {(_previous select 1) isEqualTo _kitId && {_previous select 2}};
missionNamespace setVariable ["BN_KOTH_spawnKitResponse", [_revision, _kitId, _rejectClears]];
profileNamespace setVariable ["BN_KOTH_preferredSpawnKitId", _kitId];
saveProfileNamespace;
[createHashMapFromArray [
    ["spawnPreference", if (_kitId isEqualTo "") then {"CLEAR"} else {"SET"}],
    ["preferenceRevision", _revision],
    ["mutation", createHashMapFromArray [["op", "load_local_kit"], ["kitId", _kitId], ["savedLoadout", _saved]]]
]] call bn_koth_fnc_loadouts_request;
[] call bn_koth_fnc_menu_refresh;
true

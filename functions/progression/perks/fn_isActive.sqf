/*
    File: fn_isActive.sqf
    Author: Legend
    Description: Checks the server-owned progression state for one active perk.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Stable perk ID <STRING>
    Returns: True only when the configured perk is active <BOOL>
    Public: Yes
*/

params [
    ["_uid", "", [""]],
    ["_perkId", "", [""]]
];

if (!isServer || {_uid isEqualTo ""} || {_perkId isEqualTo ""}) exitWith {false};

private _id = toLower _perkId;
private _metadata = [_id] call bn_koth_fnc_progression_perks_getConfig;
if !(_metadata getOrDefault ["success", false] && {_metadata getOrDefault ["available", false]}) exitWith {false};

private _registry = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_registry isEqualType createHashMap) exitWith {false};

private _state = _registry getOrDefault [_uid, createHashMap];
if !(_state isEqualType createHashMap) exitWith {false};

private _activePerks = _state getOrDefault ["activePerks", []];
_activePerks isEqualType [] && {_id in _activePerks}

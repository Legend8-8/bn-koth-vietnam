/*
    File: fn_initPlayer.sqf
    Author: Legend
    Description: Initializes one player's server-session weapon ownership and
        rental state without resetting existing progression.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        Current progression state, or an empty hash map when rejected <HASHMAP>
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {createHashMap};
if (_uid isEqualTo "") exitWith {createHashMap};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {
    ["Weapon acquisition initialization rejected: progression state unavailable", "WARN"] call bn_koth_fnc_common_log;
    createHashMap
};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};

private _ownedWeapons = _progression getOrDefault ["ownedWeapons", []];
if !(_ownedWeapons isEqualType []) then {_ownedWeapons = []};
private _rentedWeapons = _progression getOrDefault ["rentedWeapons", []];
if !(_rentedWeapons isEqualType []) then {_rentedWeapons = []};

_progression set ["uid", _uid];
_progression set ["ownedWeapons", _ownedWeapons];
_progression set ["rentedWeapons", _rentedWeapons];
_progressionByUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];

_progression

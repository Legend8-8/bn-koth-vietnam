/*
    File: fn_initPlayer.sqf
    Author: Legend
    Description: Initializes one player's canonical weapon mastery map without
        resetting existing server-session mastery.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns: Current progression state, or an empty hash map <HASHMAP>
    Public: No
*/

params [["_uid", "", [""]]];

if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMap};

private _byUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_byUid isEqualType createHashMap) exitWith {createHashMap};

private _progression = _byUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _weaponKills = _progression getOrDefault ["weaponKills", createHashMap];
if !(_weaponKills isEqualType createHashMap) then {_weaponKills = createHashMap};

_progression set ["uid", _uid];
_progression set ["weaponKills", _weaponKills];
_byUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _byUid];
_progression


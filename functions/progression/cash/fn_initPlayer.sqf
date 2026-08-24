/*
    File: fn_initPlayer.sqf
    Author: Legend
    Description: Initializes a player's session cash once without resetting
        existing progression or cash state.
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
    ["Cash initialization rejected: BN_KOTH_playerProgression missing/invalid", "WARN"] call bn_koth_fnc_common_log;
    createHashMap
};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};

if (isNil {_progression get "cash"}) then {
    _progression set ["cash", missionNamespace getVariable ["BN_KOTH_startingCash", 1000]];
};

_progression set ["uid", _uid];
_progressionByUid set [_uid, _progression];
missionNamespace setVariable ["BN_KOTH_playerProgression", _progressionByUid];

_progression

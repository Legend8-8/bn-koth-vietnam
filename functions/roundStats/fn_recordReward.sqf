/*
    File: fn_recordReward.sqf
    Author: Legend
    Description: Records a canonical XP or cash delta in the active round entry.
    Execution: Server
    Parameters: 0: UID <STRING>, 1: Resource <STRING>, 2: Signed amount <NUMBER>
    Returns: Whether the delta was recorded <BOOL>
    Public: No
*/

params [["_uid", "", [""]], ["_resource", "", [""]], ["_amount", 0, [0]]];
if (!isServer || {_uid isEqualTo ""} || {!finite _amount} || {_amount isEqualTo 0}) exitWith {false};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {false};
if !([_uid] call bn_koth_fnc_roundStats_registerParticipant) exitWith {false};

private _field = switch (toLower _resource) do {
    case "xp": {"xpEarned"};
    case "cash": {"cashEarned"};
    default {""};
};
if (_field isEqualTo "") exitWith {false};

private _stats = missionNamespace getVariable ["BN_KOTH_roundStats", createHashMap];
private _entry = _stats getOrDefault [_uid, createHashMap];
_entry set [_field, (_entry getOrDefault [_field, 0]) + _amount];
_stats set [_uid, _entry];
missionNamespace setVariable ["BN_KOTH_roundStats", _stats];
true
